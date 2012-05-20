//
//  NicoLivePrefManager.m
//  NicoLiveAlert
//
//  Created by Чайка on 4/24/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NicoLivePrefManager.h"
#import "NicoLiveAlertDefinitions.h"

@interface NicoLivePrefManager ()
- (void) registerDefaults;
@end

@implementation NicoLivePrefManager
@synthesize myDefaults;

- (id) initWithDefaults:(NSUserDefaultsController *)defaults
{
	self = [super init];
	if (self)
	{
		myDefaults = [defaults defaults];
#if __has_feature(objc_arc) == 0
		[myDefaults retain];
#endif
		[self registerDefaults];
	}// end if

	return self;
}// end - (id) init

- (void) dealloc
{
	[myDefaults synchronize];
#if __has_feature(objc_arc) == 0
	[myDefaults release];

	[super dealloc];
#endif
}

#if __OBJC_GC__
- (void) finalize
{
	[myDefaults synchronize];
	[super finalize];
}
#endif

- (void) registerDefaults
{
	NSString		*initialDefaultFilePath = nil;
	NSDictionary	*initialDefaultDict = nil;

	initialDefaultFilePath = [[NSBundle mainBundle] pathForResource:UserDefaultsFileName ofType:TypeDefaultsFile];
	initialDefaultDict = [NSDictionary dictionaryWithContentsOfFile:initialDefaultFilePath];
	[myDefaults registerDefaults:initialDefaultDict];
}// end - (void) registerDefaults

#pragma mark -
#pragma mark watchlist
	// watchlist tab
- (NSArray *) loadManualWatchList
{
	NSArray *array = [myDefaults objectForKey:WathListTable];
	if ([array count] == 0)
		return nil;

	NSMutableArray *ary = [NSMutableArray array];
	for (NSDictionary *dict in array)
	{
		id watchItem = [NSUnarchiver unarchiveObjectWithData:[dict objectForKey:keyWatchItem]];
		NSMutableDictionary *watchDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[dict valueForKey:keyAutoOpen], keyAutoOpen,
			watchItem, keyWatchItem,
			[dict valueForKey:keyNote], keyNote, nil];
		[ary addObject:watchDict];
	}// end if

	if ([ary count] != 0)
		return ary;
	else
		return nil;
}// end - (NSArray *) loadManualWatchList

- (void) saveManualWatchList:(NSArray *)watchlist
{
	NSMutableArray *array = [NSMutableArray array];
	for (NSDictionary *dict in watchlist)
	{
		NSData *watch = [NSArchiver archivedDataWithRootObject:[dict valueForKey:keyWatchItem]];
		NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:
			  [dict valueForKey:keyAutoOpen], keyAutoOpen,
			  watch, keyWatchItem,
			  [dict valueForKey:keyNote], keyNote, nil];
		[array addObject:item];
	}
	if ([array count] != 0)
		[myDefaults setObject:array forKey:WathListTable];
	else
		[myDefaults setObject:nil forKey:WathListTable];
}// end - (void) saveManualWatchList

- (BOOL) loadAutoOpenMenuState
{
	return [myDefaults boolForKey:EnableAutoOpen];
}// end - (BOOL) loadAutoOpenMenuState

- (void) saveAutoOpenMenuState:(BOOL)state
{
	[myDefaults setBool:state forKey:EnableAutoOpen];
}// end - (void) saveAutoOpenMenuState

- (BOOL) loadWatchOfficialProgramState
{
	return [myDefaults boolForKey:CheckOfficialProgram];
}// end - (BOOL) loadWatchOfficialProgramState

- (void) saveWatchOfficialProgramState:(BOOL)state
{
	[myDefaults setBool:state forKey:CheckOfficialProgram];
}// end - (void) saveWatchOfficialProgramState:(BOOL)state

- (BOOL) loadWatchOfficialChannelState
{
	return [myDefaults boolForKey:CheckOfficialChannel];
}// end - (BOOL) loadWatchOfficialProgramState

- (void) saveWatchOfficialChannelState:(BOOL)state
{
	[myDefaults setBool:state forKey:CheckOfficialChannel];
}// end - (void) saveWatchOfficialProgramState:(BOOL)state

#pragma mark -
	// account tab
- (NSDictionary *)loadAccounts
{

	NSMutableDictionary *tmpAccounts = [NSMutableDictionary dictionary];
	NSArray *savedAccounts = [myDefaults objectForKey:AccountsList];
	for (NSDictionary *accountData in savedAccounts)
		[tmpAccounts setValue:[accountData valueForKey:keyAccountWatchEnabled]
					   forKey:[accountData valueForKey:keyAccountUserID]];
	// end foreach saved accounts	

	if ([tmpAccounts count] != 0)
		return [NSDictionary dictionaryWithDictionary:tmpAccounts];
	else
		return nil;
}// end - (NSDictionary *)loadAccounts

- (void) saveAccountsList:(NSArray *)accountsList
{
	[myDefaults setObject:accountsList forKey:AccountsList];
}// end - (void) saveAccountsList:(NSArray *)accountsList

	// application collaboration tab
- (NSArray *) loadLauncherDict
{
	NSArray *launcherList = [myDefaults objectForKey:LauncItemList];
	if ([launcherList count] == 0)
		return nil;

	NSMutableArray *launchlist = [NSMutableArray array];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	for (NSString *app in launcherList)
	{
		NSURL *fileURL = [NSURL URLWithString:app];
		NSString *fullpath = [fileURL path];
		NSString *appname = [fm displayNameAtPath:fullpath];
		NSImage *icon = [ws iconForFile:[fileURL path]];
		if ([[fullpath pathExtension] isEqualToString:@"app"] == YES)
		{
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:icon,keyLauncherIcon, appname, keyLauncherAppName, fullpath, keyLauncherAppPath, nil];
			[launchlist addObject:dict]; 
		}// end if
	}// end for

	if ([launchlist count] != 0)
		return [NSArray arrayWithArray:launchlist];
	else
		return nil;
}// end - (void) loadLauncherDict

- (void) saveLauncherList:(NSArray *)launcherItems
{
	if ([launcherItems count] == 0)
	{
		[myDefaults setObject:nil forKey:LauncItemList];
		return;
	}

	NSMutableArray *ary = [NSMutableArray array];
	for (NSDictionary *dict in launcherItems)
		[ary addObject:[dict valueForKey:keyLauncherAppPath]];
	// end for

	[myDefaults setObject:ary forKey:LauncItemList];
}// - (void) saveLauncherDict:(NSDictionary *)launcherDict

@end
