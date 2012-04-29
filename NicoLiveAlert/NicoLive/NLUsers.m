//
//  NLUsers.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/25/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLUsers.h"

@interface NLUsers ()
- (NSMutableDictionary *) makeAccounts:(NSArray *)users;
- (void) updateCurrentWatchlist;
- (void) creteUserStateMenu;
- (void) calcUserState;
@end

@implementation NLUsers
@synthesize originalWatchList;
@synthesize watchlist;
@synthesize usersMenu;
@synthesize userState;

#pragma mark constructor / destructor
- (id) initWithActiveUsers:(NSArray *)users andManualWatchList:(NSMutableDictionary *)manualWatchList
{
	self = [super init];
	if (self)
	{
		active = [[NSNumber alloc] initWithBool:YES];
		deactive = [[NSNumber alloc] initWithBool:NO];
		usersState = [[NSMutableDictionary alloc] init];
		accounts = [[NSMutableDictionary alloc] initWithDictionary:[self makeAccounts:users]];
		originalWatchList = manualWatchList;
		watchlist = [[NSMutableDictionary alloc] init];
		[self updateCurrentWatchlist];
		usersMenu = NULL;
		[self creteUserStateMenu];
	}
	return self;
}// end - (id) initWithActiveUsers:(NSArray *)users andManualWatchList:(NSDictionary *)manualWatchList

- (void) dealloc
{
#if __has_feature(objc_arc) == 0
	if (active != NULL)				[active release];
	if (deactive != NULL)			[deactive release];
	if (usersState != NULL)			[usersState release];
	if (accounts != NULL)			[accounts release];
	if (originalWatchList != NULL)	[originalWatchList release];
	if (watchlist != NULL)			[watchlist release];
	if (usersMenu != NULL)
	{
		for (NSMenuItem *item in [usersMenu itemArray])
			[usersMenu removeItem:item];
		// end foreach delete users menuitem.
		[usersMenu release];
	}// end if cleanup usersMenu

	[super dealloc];
#endif
}// end - (void) dealloc

#pragma mark constructor support
- (NSMutableDictionary *) makeAccounts:(NSArray *)users
{
	NSArray *usesArray = [KCSInternetUser usersOfAccountsForServer:NICOLOGINSERVER path:NICOLOGINPATH forAuthType:kSecAuthenticationTypeAny inKeychain:systemDefaultKeychain];
	if ((usesArray == NULL) || ([usesArray count] == 0))
		return NULL;

	NSMutableDictionary *usersDict = [NSMutableDictionary dictionary];
	NLAccount *account;
	for (KCSInternetUser *user in usesArray)
	{
		account = [[NLAccount alloc] initWithAccount:[user account] andPassword:[user password]];
#if __has_feature(objc_arc) == 0
		[account autorelease];
#endif
		[usersDict setValue:account forKey:[account username]];
		if ([users containsObject:[user account]] == YES)
			[usersState setValue:active forKey:[account username]];
		else
			[usersState setValue:deactive forKey:[account username]];
		// end if is set userState)
	}// end for

	return usersDict;
}// end - (NSDictionary *) makeAccounts

- (void) updateCurrentWatchlist
{
	[watchlist removeAllObjects];

	for (NSString *currentUser in [usersState allKeys])
	{
		if ([[usersState valueForKey:currentUser] boolValue] == YES)
			[watchlist addEntriesFromDictionary:[[accounts valueForKey:currentUser] channels]];
	}// end foreach active users.

	[watchlist addEntriesFromDictionary:originalWatchList];
}// end - (void) updateCurrentWatchlist:(NSArray *)users

#pragma mark -
#pragma mark user management
- (OSStatus) addUser:(NSString *)useraccount withPassword:(NSString *)userpassword
{
	OSStatus error = 1;
		// create NLAccount instance
	NLAccount *user = [[NLAccount alloc] initWithAccount:useraccount andPassword:userpassword];
	if (user == NULL)
		return error;
	// end if user was logined.
		// store account
	[accounts setValue:user forKey:[user username]];
	[usersState setValue:deactive forKey:[user username]];
		// update current watch list
	[self updateCurrentWatchlist];

		// add to keychain this user
	KCSInternetUser *keychainOfUser =
	[[KCSInternetUser alloc] initWithAccount:useraccount andPassword:userpassword];
	[keychainOfUser setServerName:NICOLOGINSERVER];
	[keychainOfUser setServerPath:NICOLOGINPATH];
	[keychainOfUser setAuthType:kSecAuthenticationTypeHTMLForm];
	[keychainOfUser setProtocol:kSecProtocolTypeHTTPS];
	[keychainOfUser setKeychainName:[NSString stringWithFormat:NICOKEYCHAINNAMEFORMAT,NICOLOGINSERVER, useraccount]];
	[keychainOfUser setKeychainKind:NICOKEYCHAINLABEL];
	if ([keychainOfUser addTokeychain] == YES)
		error = noErr;
	else
		error = [keychainOfUser status];

#if __has_feature(objc_arc) == 0
	[user autorelease];
	[keychainOfUser autorelease];
#endif

	return error;
}// end - (OSStatus) addUser:(NSString *)useraccount andPassword:(NSString *)userpassword

- (NLAccount *) primaryAccountForCommunity:(NSString *)community
{
	for (NSString *username in [usersState allKeys])
	{
		if ([[usersState valueForKey:username] isEqual:active])
		{
			NLAccount *account = [accounts valueForKey:username];
			if ([[account channels] valueForKey:community] != NULL)
				return account;
		}// end if account is active
	}// end for
	return NULL;
}// end if - (NLAccount *) primaryAccountForCommunity:(NSString *)community

- (NSArray *) activeUsers
{
	NSMutableArray *users = [NSMutableArray array];

	for (NSString *username in [usersState allKeys])
		if ([usersState valueForKey:username] == active)
			[users addObject:username];
		// end if user is active
	//end foreach all users

	if ([users count] == 0)
		return NULL;
	else
		return [NSArray arrayWithArray:users];
}// end - (NSArray *) activeUsers

#pragma mark -
#pragma mark menu management
- (void) creteUserStateMenu
{
	usersMenu = [[NSMenu alloc] initWithTitle:@""];

	NSMenuItem *userItem;
	NSImage *onStateImg = [NSImage imageNamed:@"NLOnState"];
	NSImage *offStateImg = [NSImage imageNamed:@"NLOffStateRed"];
	for (NSString *user in [usersState allKeys])
	{
		userItem = [[NSMenuItem alloc] initWithTitle:user action:@selector(toggleUserState:) keyEquivalent:@""];
		[userItem setOnStateImage:onStateImg];
		[userItem setOffStateImage:offStateImg];
		if ([[usersState valueForKey:user] isEqual:active] == YES)
			[userItem setState:NSOnState];
		else
			[userItem setState:NSOffState];
		// end if set user's state
		[userItem setEnabled:YES];
		[usersMenu addItem:userItem];
#if __has_feature(objc_arc) == 0
		[userItem autorelease];
#endif
	}// end foreach user
	[self calcUserState];
}// end - (NSMenu *) creteUserStateMenu

- (NSCellStateValue) toggleUserState:(NSMenuItem *)item
{
	if ([item state] == NSOnState)
	{
		[item setState:NSOffState];
		[usersState setValue:deactive forKey:[item title]];
	}
	else
	{
		[item setState:NSOnState];
		[usersState setValue:active forKey:[item title]];
	}// end if
	[self updateCurrentWatchlist];
	[self calcUserState];

	return userState;
}// end - (IBAction) toggleUserState:(id)sender

- (void) calcUserState
{
	uint userCount = (int)[usersState count];
	int activeCount = 0;
	for (NSNumber *num in [usersState allValues])
		activeCount += [num intValue];
	// end for
	if (activeCount == kNoUsers)
		userState = NSOffState;
	else if (activeCount == userCount)
		userState = NSOnState;
	else
		userState = NSMixedState;
}// end - (void) calcUserState

#pragma mark -
#pragma mark watchlist management
- (void) addWatchListItem:(NSString *)item autoOpen:(BOOL)autoOpen
{
	if (autoOpen == YES)
		[originalWatchList setValue:active forKey:item];
	else
		[originalWatchList setValue:deactive forKey:item];
}// end - (void) addWatchListItem:(NSString *)item autoOpen:(BOOL)autoOpen

- (void) addWatchListItems:(NSDictionary *)watchDict
{
	BOOL autoOpen = NO;
	for (NSString *item in [watchDict allKeys])
	{
		autoOpen = [[watchlist valueForKey:item] boolValue];
		if (autoOpen == YES)
			[originalWatchList setValue:active forKey:item];
		else
			[originalWatchList setValue:deactive forKey:item];
	}// end foreach watchDict
}// end - (void) addWatchListItems:(NSDictionary *)watchlist

- (void) switchWatchListItemProperty:(NSString *)item autoOpen:(BOOL)autoOpen
{
	if (autoOpen == YES)
		[originalWatchList setValue:active forKey:item];
	else
		[originalWatchList setValue:deactive forKey:item];
}// end - (void) switchWatchListItemProperty:(NSString *)item autoOpen:(BOOL)autoOpen

#pragma mark -
#pragma mark NSCombobox Delegate
- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)uncompletedString
{
	return EMPTYSTRING;
}// end - (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)uncompletedString

- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)aString
{
	NSInteger index = 0;
	for (NSString *nickname in [accounts allKeys])
	{
		NLAccount *account = [accounts valueForKey:nickname];
		if ([aString isEqualToString:[account mailaddr]])
			return index;
		index++;
	}// end for

	return  NSNotFound;
}// end - (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)aString

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
	NSArray *accountArray = [accounts allKeys];
	NSInteger itemCount = [accountArray count];
	NSString *object = NULL;
	if (index < itemCount)
		object = [[accounts valueForKey:[accountArray objectAtIndex:index]] mailaddr];

	return object;
}// end - (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
	return [[accounts allKeys] count];
}// end - (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox

@end
