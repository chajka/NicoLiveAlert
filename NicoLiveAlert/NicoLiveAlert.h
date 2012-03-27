//
//  NicoLiveAlert.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NLStatusbarIcon.h"

#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
@interface NicoLiveAlert : NSObject <NSApplicationDelegate> {
#else
@interface NicoLiveAlert : NSObject {
#endif
	IBOutlet NSMenu *menuStatusbar;
	IBOutlet NSPanel *preferencePanel;

	__strong NSStatusItem *sbItem;
	NLStatusbarIcon	*statusBar;
}
@property (retain) NSMenu *menuStatusbar;
@property (assign) NSPanel *prefencePanel;

- (BOOL) checkFirstLaunch;
@end
