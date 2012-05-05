//
//  NicoLivePrefManager.h
//  NicoLiveAlert
//
//  Created by Чайка on 4/24/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NicoLivePrefManager : NSObject {
	__strong NSUserDefaults *myDefaults;
}
@property (readonly) NSUserDefaults *myDefaults;

	// watchlist tab 
- (NSArray *) loadManualWatchList;
- (void) saveManualWatchList:(NSArray *)watchlist;
	// account tab
- (NSDictionary *)loadAccounts;
- (void) saveAccountsList:(NSArray *)accountsList;
	// application collaboration tab
- (NSArray *) loadLauncherDict;
- (void) saveLauncherList:(NSArray *)launcherItems;

- (BOOL) dontOpenWhenImBroadcast;
- (void) setDontOpenWhenImBroadcast:(BOOL)flag;
- (BOOL) kickFMELauncher;
- (void) setKickFMELauncher:(BOOL)flag;
- (BOOL) kickCharlestonOnMyBroadcast;
- (void) setKickCharlestonOnMyBroadcast:(BOOL)flag;
- (BOOL) kickCharlestonAtAutoOpen;
- (void) setKickCharlestonAtAutoOpen:(BOOL)flag;
- (BOOL) kickCharlestonOpenByMe;
- (void) setKickCharlestonOpenByMe:(BOOL)flag;

@end
