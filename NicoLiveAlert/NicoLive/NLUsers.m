//
//  NLUsers.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/25/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLUsers.h"
#import "NicoLiveAlertCollaboration.h"

@interface NLUsers ()
- (NSMutableDictionary *) makeAccounts:(NSArray *)activeUsers;
- (NSMutableDictionary *) makeManualWatchList:(NSDictionary *)list;
- (void) removeProgramFromWatchList:(NSNotification *)aNotification;
- (void) updateCurrentWatchlist;
- (void) creteUserStateMenu;
- (void) calcUserState;
@end

@implementation NLUsers
@synthesize users;
@synthesize originalWatchList;
@synthesize watchlist;
@synthesize usersMenu;
@synthesize userState;

NSNumber *active;
NSNumber *inactive;

#pragma mark constructor / destructor
- (id) initWithActiveUsers:(NSArray *)activeUsers andManualWatchList:(NSMutableDictionary *)manualWatchList
{
	self = [super init];
	if (self)
	{
		active = [[NSNumber alloc] initWithBool:YES];
		inactive = [[NSNumber alloc] initWithBool:NO];
		usersState = [[NSMutableDictionary alloc] init];
		users = [[NSMutableArray alloc] init];
		accounts = [[NSMutableDictionary alloc] initWithDictionary:[self makeAccounts:activeUsers]];
		originalWatchList = [[NSMutableDictionary alloc] initWithDictionary:[self makeManualWatchList:manualWatchList]];
		watchlist = [[NSMutableDictionary alloc] init];
		[self updateCurrentWatchlist];
		usersMenu = nil;
		[self creteUserStateMenu];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeProgramFromWatchList:) name:NLNotificationFoundProgram object:nil];
	}
	return self;
}// end - (id) initWithActiveUsers:(NSArray *)users andManualWatchList:(NSDictionary *)manualWatchList

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NLNotificationFoundProgram object:nil];
#if __has_feature(objc_arc) == 0
	if (active != nil)				[active release];
	if (inactive != nil)			[inactive release];
	if (usersState != nil)			[usersState release];
	if (accounts != nil)			[accounts release];
	if (users != nil)				[users release];
	if (originalWatchList != nil)	[originalWatchList release];
	if (watchlist != nil)			[watchlist release];
	if (usersMenu != nil)
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
- (NSMutableDictionary *) makeAccounts:(NSArray *)activeUsers
{
	NSArray *usesArray = [KCSInternetUser usersOfAccountsForServer:NICOLOGINSERVER path:NICOLOGINPATH forAuthType:kSecAuthenticationTypeAny inKeychain:systemDefaultKeychain];
	if ((usesArray == nil) || ([usesArray count] == 0))
		return nil;

	NSMutableDictionary *usersDict = [NSMutableDictionary dictionary];
	NLAccount *account;
	for (KCSInternetUser *user in usesArray)
	{
		account = [[NLAccount alloc] initWithAccount:[user account] andPassword:[user password]];
#if __has_feature(objc_arc) == 0
		[account autorelease];
#endif
		[usersDict setValue:account forKey:[account nickname]];
		if ([activeUsers containsObject:[account userid]] == YES)
			[usersState setValue:active forKey:[account nickname]];
		else
			[usersState setValue:inactive forKey:[account nickname]];
		// end if is set userState
		[users addObject:account];
	}// end for

	return usersDict;
}// end - (NSDictionary *) makeAccounts

- (NSMutableDictionary *) makeManualWatchList:(NSDictionary *)list
{
	NSMutableDictionary	*watchList = [NSMutableDictionary dictionary];
	for (NSString *item in [list allKeys])
	{
		if ([[list valueForKey:item] boolValue] == YES)
			[watchList setValue:active forKey:item];
		else
			[watchList setValue:inactive forKey:item];
	}// end foreach

	if ([list count] != 0)
		return [NSMutableDictionary dictionaryWithDictionary:watchList];
	else
		return [NSMutableDictionary dictionary];
}// end - (NSMutableDictionary *) makeManualWatchList:(NSDictionary *)list

- (void) removeProgramFromWatchList:(NSNotification *)aNotification
{
	NSString *liveNo = [[aNotification userInfo] valueForKey:LiveNumber];
	[originalWatchList removeObjectForKey:liveNo];
	[self updateCurrentWatchlist];
}// end - (void) removeProgramFromWatchList:(NSNotification *)aNotification

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
	if (user == nil)
		return error;
	// end if user was logined.

		// store account
	[accounts setValue:user forKey:[user nickname]];
	[usersState setValue:inactive forKey:[user nickname]];
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
	{
		error = noErr;
		[users addObject:user];
			// create account menuItem
		if (usersMenu == nil)
			usersMenu = [[NSMenu alloc] initWithTitle:@""];
		[usersMenu addItem:[user accountMenu]];
		
		[self updateCurrentWatchlist];
		[self updateUserSateMenu];
	}
	else
	{
		error = [keychainOfUser status];
	}// end if add to keychain success or not
#if __has_feature(objc_arc) == 0
	[user autorelease];
	[keychainOfUser autorelease];
#endif

	return error;
}// end - (OSStatus) addUser:(NSString *)useraccount andPassword:(NSString *)userpassword

- (NLAccount *) addUser:(NSString *)useraccount withPassword:(NSString *)userpassword status:(OSStatus *)result
{
	*result = 1;
		// create NLAccount instance
	NLAccount *user = [[NLAccount alloc] initWithAccount:useraccount andPassword:userpassword];
	if (user == nil)
		return nil;
	// end if user was not logined.
	
		// store account
	[accounts setValue:user forKey:[user nickname]];
	[usersState setValue:inactive forKey:[user nickname]];
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
	{
		*result = noErr;
		[users addObject:user];
			// create account menuItem
		if (usersMenu == nil)
			usersMenu = [[NSMenu alloc] initWithTitle:@""];
		[usersMenu addItem:[user accountMenu]];
		
		[self updateCurrentWatchlist];
		[self updateUserSateMenu];
	}
	else
	{
		*result = [keychainOfUser status];
	}// end if add to keychain success or not
#if __has_feature(objc_arc) == 0
	[user autorelease];
	[keychainOfUser autorelease];
#endif
	
	return user;
}// end - (NLAccount *) addUser:(NSString *)useraccount withPassword:(NSString *)userpassword status:(OSStatus *)result

- (BOOL) updateUserAccountInforms
{
	BOOL updated = NO;

	for (NLAccount *user in users)
		updated += [user updateAccountInfo];

	if (updated == NO)	// > 1 isn't mean yes
		return NO;

	[self updateCurrentWatchlist];
	return YES;
}// end - (BOOL) updateUserAccountInforms

- (NLAccount *) primaryAccountForCommunity:(NSString *)community
{
	for (NSString *username in [usersState allKeys])
	{
		if ([[usersState valueForKey:username] isEqual:active])
		{
			NLAccount *account = [accounts valueForKey:username];
			if ([[account channels] valueForKey:community] != nil)
				return account;
		}// end if account is active
	}// end for

	return nil;
}// end if - (NLAccount *) primaryAccountForCommunity:(NSString *)community

- (NSArray *) activeUsers
{
	NSMutableArray *activeUsers = [NSMutableArray array];

	for (NSString *username in [usersState allKeys])
		if ([usersState valueForKey:username] == active)
			[activeUsers addObject:username];
		// end if user is active
	//end foreach all users

	if ([activeUsers count] == 0)
		return nil;
	else
		return [NSArray arrayWithArray:activeUsers];
}// end - (NSArray *) activeUsers

- (NSArray *) accountIDs
{
	NSMutableArray *ary = [NSMutableArray array];
	for (NLAccount *user in users)
		[ary addObject:[user userid]];
	 // end foreach account

	if ([ary count] != 0)
		return [NSArray arrayWithArray:ary];
	else
		return nil;
}// end - (NSArray *) accountIDs

- (NLAccount *) accountByNickname:(NSString *)nickname
{
	return [accounts valueForKey:nickname];
}// end - (NLAccount *) accountForNickname:(NSString *)nickname

- (NLAccount *) accountByAccount:(NSString *)account
{
	for (NLAccount *user in users)
		if ([[user mailaddr] isEqualToString:account])
			return user;
		// end if match mailaddress
	// end foreach users

	return nil;
}// end - (NLAccount *) accountByAccount:(NSString *)account

#pragma mark -
#pragma mark menu management
- (void) creteUserStateMenu
{
	usersMenu = [[NSMenu alloc] initWithTitle:@""];

	NSMenuItem *userItem;
	for (NLAccount *user in users)
	{
		userItem = [user accountMenu];
		if ([[usersState valueForKey:[user nickname]] isEqual:active] == YES)
			[userItem setState:NSOnState];
		else
			[userItem setState:NSOffState];
		// end if set user's state
		[userItem setEnabled:YES];
		[usersMenu addItem:userItem];
	}// end foreach user
	[self calcUserState];
}// end - (NSMenu *) creteUserStateMenu

- (void) updateUserSateMenu
{
	NSMenuItem *userItem;
	for (NLAccount *user in users)
	{
		userItem = [user accountMenu];
		if ([[usersState valueForKey:[user nickname]] isEqual:active] == YES)
			[userItem setState:NSOnState];
		else
			[userItem setState:NSOffState];
		// end if set user's state
	}// end foreach user
	[self calcUserState];
}// end - (NSMenu *) creteUserStateMenu

- (NSCellStateValue) toggleUserState:(NSMenuItem *)item
{
	if ([item state] == NSOnState)
	{
		[item setState:NSOffState];
		[usersState setValue:inactive forKey:[item title]];
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
		[originalWatchList setValue:inactive forKey:item];

	[self updateCurrentWatchlist];
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
			[originalWatchList setValue:inactive forKey:item];
	}// end foreach watchDict

	[self updateCurrentWatchlist];
}// end - (void) addWatchListItems:(NSDictionary *)watchlist

- (void) switchWatchListItemProperty:(NSString *)item autoOpen:(BOOL)autoOpen
{
	if (autoOpen == YES)
		[originalWatchList setValue:active forKey:item];
	else
		[originalWatchList setValue:inactive forKey:item];

	[self updateCurrentWatchlist];
}// end - (void) switchWatchListItemProperty:(NSString *)item autoOpen:(BOOL)autoOpen

- (void) removeWatchListItem:(NSString *)item
{
	[originalWatchList setValue:nil forKey:item];
	[self updateCurrentWatchlist];
}// end - (void) removeWatchListItem:(NSString *)item

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
	NSString *object = nil;
	if (index < itemCount)
		object = [[accounts valueForKey:[accountArray objectAtIndex:index]] mailaddr];

	return object;
}// end - (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
	return [[accounts allKeys] count];
}// end - (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox

@end
