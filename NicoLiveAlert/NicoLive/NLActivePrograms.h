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
	NLStatusbar			*sbItem;
	NLUsers				*users;
		// store current programs
	NSMutableArray		*programs;		// array of NLProgram object
		// store program for guard double notify
	NSMutableDictionary *liveNumbers;	// value : yes - key : LiveNoString
}
@property (retain, readwrite) NLStatusbar	*sbItem;
@property (retain, readwrite) NLUsers		*users;

- (void) addUserProgram:(NSString *)liveNo withDate:(NSDate *)date community:(NSString *)community owner:owner;
- (void) addOfficialProgram:(NSString *)liveNo withDate:(NSDate *)date;
	//
- (void) suspend;
- (void) resume;
@end
