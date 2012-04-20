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
	__unsafe_unretained NLStatusbar		*sbItem;
	__unsafe_unretained NLUsers			*users;
	NSMutableArray		*programs;
	NSMutableDictionary *liveNumbers;
}
@property (assign, readwrite) NLStatusbar	*sbItem;
@property (assign, readwrite) NLUsers			*users;

- (void) addUserProgram:(NSString *)liveNo withDate:(NSDate *)date community:(NSString *)community owner:owner;
- (void) addOfficialProgram:(NSString *)liveNo withDate:(NSDate *)date;
@end
