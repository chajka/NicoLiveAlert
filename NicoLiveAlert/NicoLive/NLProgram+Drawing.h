//
//  NLProgram+Drawing.h
//  NicoLiveAlert
//
//  Created by Чайка on 7/16/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Growl/Growl.h>
#import "NLProgram.h"

static const CGFloat thumbnailSize = 50.0;

#pragma mark user program constant
static const CGFloat programBoundsW = 293.0;
static const CGFloat programBoundsH = 75.0;
static const CGFloat progOwnerOffsetX = 12.0;
static const CGFloat progOwnerOffsetY = programBoundsH - 25;

#pragma mark official program constant
static const CGFloat officialBoundsW = 293.0;
static const CGFloat officialBoundsH = 50.0;

@interface NLProgram (Drawing)
	// drawing methods
- (void) drawUserProgram;
- (void) drawOfficialProgram;
	// timer driven methods
- (void) updateElapse:(NSTimer *)theTimer;
	// growling;
- (void) growlProgramNotify:(NSString *)notificationName;
	// static variable
@end
