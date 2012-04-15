//
//  NLActivePrograms.m
//  NicoLiveAlert
//
//  Created by Чайка on 4/12/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLActivePrograms.h"

@interface NLActivePrograms ()
- (void) removeEndedProgram:(NSNotification *)notification;
@end

@implementation NLActivePrograms
@synthesize sbItem;
@synthesize users;

#pragma mark construct / destruct
- (id) init
{
	self = [super init];
	if (self)
	{
		yes = [[NSNumber alloc] initWithBool:YES];
		sbItem = NULL;
		users = NULL;
		programs = [[NSMutableArray alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeEndedProgram:) name:NLNotificationPorgramEnd object:NULL];
	}// end if
	return self;
}// end - (id) init

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NLNotificationPorgramEnd object:NULL];
#if __has_feature(objc_arc) == 0
	if (programs != NULL)		[programs release];
	if (liveNumbers != NULL)	[liveNumbers release];
	if (yes != NULL)			[yes release];

    [super dealloc];
#endif
}// end - (void) dealloc

#pragma mark -
- (void) addUserProgram:(NSString *)liveNo withDate:(NSDate *)date community:(NSString *)community owner:owner
{
	if ([[liveNumbers valueForKey:liveNo] isEqualTo:yes])
		return;
	else
		[liveNumbers setValue:yes forKey:liveNo];

	
	NLAccount *account = [users primaryAccountForCommunity:community];
	NLProgram *program = [[NLProgram alloc] initWithProgram:liveNo withDate:date forAccount:account];
	if (program == NULL)
		return;
#if __has_feature(objc_arc) == 0
	[program autorelease];
#endif
	NSMenuItem *item = [program programMenu];
	if (item == NULL)
		return;
	[programs addObject:program];
	[sbItem addUserMenu:item];
}// end - (void) addUserProgram:(NSString *)liveNo community:(NSString *)community owner:owner

- (void) addOfficialProgram:(NSString *)liveNo withDate:(NSDate *)date
{
	if ([[liveNumbers valueForKey:liveNo] isEqualTo:yes])
		return;
	else
		[liveNumbers setValue:yes forKey:liveNo];

	NLProgram *program = [[NLProgram alloc] initWithProgram:liveNo  withDate:date];
	if (program == NULL)
		return;
#if __has_feature(objc_arc) == 0
	[program autorelease];
#endif
	NSMenuItem *item = [program programMenu];
	if (item == NULL)
		return;
	[programs addObject:program];
	[sbItem addOfficialMenu:item];
}// end - (void) addOfficialProgram:(NSString *)liveNo

- (void) removeEndedProgram:(NSNotification *)notification
{		// iterate for find ended program.
NSLog(@"%@", notification);
	for (NLProgram *program in [programs reverseObjectEnumerator])
	{		// check program was ended.
		if ([program isBroadCasting] == NO)
		{		// remove from dictionary
			[liveNumbers removeObjectForKey:[program programNumber]];
				// remove menu item
			NSMenuItem *item = [program programMenu];
			if ([program isOfficial] == YES)
				[sbItem removeOfficialMenu:item];
			else 
				[sbItem removeUserMenu:item];
			// end if official program or user program
				// remove but no release, because already autorelease it.
			[programs removeObject:program];
		}// end if program was ended.
	}// end foreach member of active programs.
}// end - (void) removeEndedProgram:(NSNotification *)notification
@end
