//
//  NLActivePrograms.h
//  NicoLiveAlert
//
//  Created by Чайка on 4/12/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NLStatusbarIcon.h"
#import "NLUsers.h"
#import "NLProgram.h"

@interface NLActivePrograms : NSObject {
	NLStatusbarIcon	*sbItem;
	NLUsers			*users;
	NSMutableArray	*programs;
}
@property (assign, readwrite) NLStatusbarIcon	*sbItem;
@property (assign, readwrite) NLUsers			*users;

- (void) addUserProgram:(NSString *)liveNo community:(NSString *)community owner:owner;
- (void) addOfficialProgram:(NSString *)liveNo;
@end
