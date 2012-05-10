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

- (id) initWithDefaults:(NSUserDefaultsController *)defaults;
	// watchlist tab 
- (NSArray *) loadManualWatchList;
- (void) saveManualWatchList:(NSArray *)watchlist;
- (BOOL) loadAutoOpenMenuState;
- (void) saveAutoOpenMenuState:(BOOL)state;
- (BOOL) loadWatchOfficialProgramState;
- (void) saveWatchOfficialProgramState:(BOOL)state;
- (BOOL) loadWatchOfficialChannelState;
- (void) saveWatchOfficialChannelState:(BOOL)state;
	// account tab
- (NSDictionary *)loadAccounts;
- (void) saveAccountsList:(NSArray *)accountsList;
	// application collaboration tab
- (NSArray *) loadLauncherDict;
- (void) saveLauncherList:(NSArray *)launcherItems;

@end
