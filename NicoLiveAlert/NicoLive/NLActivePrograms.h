//
//  NLActivePrograms.h
//  NicoLiveAlert
//
//  Created by Чайка on 4/12/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NLStatusbar.h"
#import "NLUsers.h"
#import "NLProgram.h"

@interface NLActivePrograms : NSObject {
	NSNumber			*yes;
	NLStatusbar			*sbItem;
	NLUsers				*users;
		// store current programs
	NSMutableArray		*programs;
		// store program for guard double notify
	NSMutableDictionary *liveNumbers;
}
@property (retain, readwrite) NLStatusbar	*sbItem;
@property (retain, readwrite) NLUsers		*users;

- (void) addUserProgram:(NSString *)liveNo withDate:(NSDate *)date community:(NSString *)community owner:owner;
- (void) addOfficialProgram:(NSString *)liveNo withDate:(NSDate *)date;
	//
- (void) suspend;
- (void) resume;
@end
