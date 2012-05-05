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

- (id) init
{
	self = [super init];
	if (self)
	{
		myDefaults = [NSUserDefaults standardUserDefaults];
#if __has_feature(objc_arc) == 0
		[myDefaults retain];
#endif
	}// end if

	return self;
}// end - (id) init

- (void) dealloc
{
#if __has_feature(objc_arc) == 0
	[myDefaults release];

	[super dealloc];
#endif
}

- (void) registerDefaults
{
	
}// end - (void) registerDefaults

	// watchlist tab
- (NSArray *) loadManualWatchList
{
	NSArray *array = [myDefaults objectForKey:WathListTable];
	if ([array count] == 0)
		return NULL;

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
		return NULL;
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
		[myDefaults setObject:NULL forKey:WathListTable];
}// end - (void) saveManualWatchList

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
		return NULL;
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
		return NULL;

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
		return NULL;
}// end - (void) loadLauncherDict

- (void) saveLauncherList:(NSArray *)launcherItems
{
	if ([launcherItems count] == 0)
	{
		[myDefaults setObject:NULL forKey:LauncItemList];
		return;
	}

	NSMutableArray *ary = [NSMutableArray array];
	for (NSDictionary *dict in launcherItems)
		[ary addObject:[dict valueForKey:keyLauncherAppPath]];
	// end for

	[myDefaults setObject:ary forKey:LauncItemList];
}// - (void) saveLauncherDict:(NSDictionary *)launcherDict

- (BOOL) dontOpenWhenImBroadcast
{
	return [myDefaults boolForKey:DoNotAutoOpenInMyBroadcast];
}// end - (BOOL) dontOpenWhenImBroadcast

- (void) setDontOpenWhenImBroadcast:(BOOL)flag
{
	[myDefaults setBool:flag forKey:DoNotAutoOpenInMyBroadcast];
}// end setDontOpenWhenImBroadcast:(BOOL)flag

- (BOOL) kickFMELauncher
{
	return [myDefaults boolForKey:KickFMELauncher];
}// end - (BOOL) kickFMELauncher

- (void) setKickFMELauncher:(BOOL)flag
{
	[myDefaults setBool:flag forKey:KickFMELauncher];
}// end setKickFMELauncher:(BOOL)flag

- (BOOL) kickCharlestonOnMyBroadcast
{
	return [myDefaults boolForKey:KickCharlestonOnMyBroadcast];
}// end kickCharlestonOnMyBroadcast

- (void) setKickCharlestonOnMyBroadcast:(BOOL)flag
{
	[myDefaults setBool:flag forKey:KickCharlestonOnMyBroadcast];
}// end - (void) setKickCharlestonOnMyBroadcast:(BOOL)flag

- (BOOL) kickCharlestonAtAutoOpen
{
	return [myDefaults boolForKey:KickCharlestonAtAutoOpen];
}// end - (BOOL) kickCharlestonAtAutoOpen

- (void) setKickCharlestonAtAutoOpen:(BOOL)flag
{
	[myDefaults setBool:flag forKey:KickCharlestonAtAutoOpen];
}// end - (void) setKickCharlestonAtAutoOpen:(BOOL)flag

- (BOOL) kickCharlestonOpenByMe
{
	return [myDefaults boolForKey:KickCharlestonByOpenFromMe];
}// end - (BOOL) kickCharlestonOpenByMe

- (void) setKickCharlestonOpenByMe:(BOOL)flag
{
	[myDefaults setBool:flag forKey:KickCharlestonByOpenFromMe];
}// end - (void) setKickCharlestonOpenByMe:(BOOL)flag

@end
