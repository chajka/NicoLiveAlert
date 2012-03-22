//
//  NicoLiveAlert.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
@interface NicoLiveAlert : NSObject <NSApplicationDelegate> {
#else
@interface NicoLiveAlert : NSObject {
#endif
	NSMenu *menuStatusbar;
}
@property (retain) IBOutlet NSMenu *menuStatusbar;
@end
