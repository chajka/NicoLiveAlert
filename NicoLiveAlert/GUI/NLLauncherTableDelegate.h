//
//  NLLauncherTableDelegate.h
//  NicoLiveAlert
//
//  Created by Чайка on 4/25/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NLLauncherTableDelegate : NSObject <NSTableViewDelegate> {
	NSArrayController *array;
}
	//@property (retain, readwrite) NSArrayController *launcherArrayController;
- (id) initWithAryController:(NSArrayController	*) controller;
@end
