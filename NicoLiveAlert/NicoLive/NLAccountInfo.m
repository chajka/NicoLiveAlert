//
//  NLAccountInfo.m
//  NicoLiveAlert
//
//  Created by Чайка on 5/10/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLAccountInfo.h"
#import "NicoLiveAlertDefinitions.h"

@implementation NLAccountInfo
@synthesize enableAtStart;
@synthesize userid;
@synthesize nickname;
@synthesize mailaddr;

- (id) initWithAccountDict:(NSDictionary *)accountInfo
{
	self = [super init];
	if (self)
	{
		enableAtStart = [[accountInfo valueForKey:keyAccountWatchEnabled] boolValue];
		userid = [[accountInfo valueForKey:keyAccountUserID] copy];
		nickname = [[accountInfo valueForKey:keyAccountNickname] copy];
		mailaddr = [[accountInfo valueForKey:keyAccountMailAddr] copy];
#if __has_feature(objc_arc) == 0
		[userid retain];
		[nickname retain];
		[mailaddr retain];
#endif
	}// end if

	return self;
}// end - (id) initWithAccountDict:(NSDictionary *)accountInfo

- (id) initWithAccount:(NLAccount *)account enableWatchAtNext:(BOOL)enable;
{
	self = [super init];
	if (self)
	{
		enableAtStart = enable;
		userid = [[account userid] copy];
		nickname = [[account nickname] copy];
		mailaddr = [[account mailaddr] copy];
#if __has_feature(objc_arc) == 0
		[userid retain];
		[nickname retain];
		[mailaddr retain];
#endif
	}// end if

	return self;
}// end - (id) initWithAccount:(NLAccount *)account

- (void) dealloc
{
#if __has_feature(objc_arc) == 0
	if (userid != nil)		[userid retain];
	if (nickname != nil)	[nickname retain];
	if (mailaddr != nil)	[mailaddr retain];

	[super dealloc];
#endif
}

@end
