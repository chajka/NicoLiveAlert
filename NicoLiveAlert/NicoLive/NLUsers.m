//
//  NLUsers.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/25/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLUsers.h"

@interface NLUsers ()
- (NSMutableDictionary *) makeAccounts;
- (void) makeCurrentWatchlist:(NSArray *)users;
@end

@implementation NLUsers
@synthesize watchlist;

#pragma mark constructor / destructor
- (id) initWithActiveUsers:(NSArray *)users andManualWatchList:(NSDictionary *)manualWatchList
{
	self = [super init];
	if (self)
	{
		enabledUsers = [NSMutableArray arrayWithArray:users];
		disabledUsers = [NSMutableArray array];
		accounts = [NSDictionary dictionaryWithDictionary:[self makeAccounts]];
		originalWatchList = [manualWatchList copy];
		watchlist = [NSMutableDictionary dictionary];
		[self makeCurrentWatchlist:users];
	}
	return self;
}// end - (id) initWithActiveUsers:(NSArray *)users andManualWatchList:(NSDictionary *)manualWatchList

- (void) dealloc
{
#if __has_feature(objc_arc) == 0
	if (originalWatchList != NULL) {	[originalWatchList release]; }
	[super dealloc];
#endif
}// end - (void) dealloc

#pragma mark constructor support
- (NSMutableDictionary *) makeAccounts
{
	NSArray *usesArray = [KCSInternetUser usersOfAccountsForServer:NICOLOGINSERVER path:NICOLOGINPATH forAuthType:kSecAuthenticationTypeAny inKeychain:systemDefaultKeychain];
	if ((usesArray == NULL) || ([usesArray count] == 0))
		return NULL;

	NSMutableDictionary *usersDict = [NSMutableDictionary dictionary];
	for (KCSInternetUser *user in usesArray)
		[usersDict setValue:user forKey:[user account]];

	return usersDict;
}// end - (NSDictionary *) makeAccounts

- (void) makeCurrentWatchlist:(NSArray *)users
{
	for (NSString *currentUser in users)
		[watchlist addEntriesFromDictionary:[[accounts valueForKey:currentUser] channels]];
	// end foreach active users.

	[watchlist addEntriesFromDictionary:originalWatchList];
}// end - (void) makeCurrentWatchlist:(NSArray *)users

@end
