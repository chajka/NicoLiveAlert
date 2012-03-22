//
//  NLAccount.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/22/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NLAccount : NSObject {
	NSString			*mailaddr;
	NSString			*password;
	NSString			*username;
	NSNumber			*userid;
	NSString			*ticket;
	NSMutableDictionary	*channels;
}
@property (copy, readwrite)	NSString			*mailaddr;
@property (copy, readwrite)	NSString			*password;
@property (copy, readwrite)	NSString			*username;
@property (copy, readwrite)	NSNumber			*userid;
@property (copy, readwrite)	NSString			*ticket;
@property (copy, readwrite)	NSMutableDictionary	*channels;

@end
