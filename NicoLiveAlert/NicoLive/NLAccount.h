//
//  NLAccount.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/22/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPConnection.h"

#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
@interface NLAccount : NSObject <NSXMLParserDelegate> {
#else
@interface NLAccount : NSObject {
#endif
		// user information member variables
	NSString			*mailaddr;
	NSString			*password;
	NSString			*username;
	NSNumber			*userid;
	NSString			*ticket;
	NSMutableDictionary	*channels;
}
@property (readonly)	NSString			*mailaddr;
@property (readonly)	NSString			*password;
@property (readonly)	NSString			*username;
@property (readonly)	NSNumber			*userid;
@property (readonly)	NSString			*ticket;
@property (readonly)	NSMutableDictionary	*channels;
	
#pragma mark construct
- (id) initWithAccount:(NSString *)account andPassword:(NSString *)pass;

- (BOOL) updateAccountInfo;
@end
