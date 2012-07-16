//
//  NLProgram+Drawing.h
//  NicoLiveAlert
//
//  Created by Чайка on 7/16/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLProgram.h"

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
static const CGFloat thumbnailSize = 50.0;
