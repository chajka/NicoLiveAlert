//
//  KCSUser.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCSUser : NSObject {
	NSString	*account;
	NSString	*password;
	BOOL		syncronized;
}
@property (copy, readwrite) NSString	*account;
@property (copy, readwrite) NSString	*password;

@end
