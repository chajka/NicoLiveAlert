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
@protected
		// user information member variables
	NSString			*mailaddr;
	NSString			*password;
	NSString			*username;
	NSNumber			*userid;
		// connection information member variables
	NSString			*ticket;
	NSString			*userHash;
	NSMutableDictionary	*channels;
	NSString			*messageServerName;
	NSUInteger			messageServerPortNo;
	NSString			*messageServerThreadID;
		// internal use variables (when initialize only)
	NSDictionary		*elements;
	NSMutableString		*stringBuffer;
	NSUInteger			currentElement;
	NSNumber			*notAutoOpen;
	BOOL				xmlResult;
}
@property (readonly)	NSString			*mailaddr;
@property (readonly)	NSString			*password;
@property (readonly)	NSString			*username;
@property (readonly)	NSNumber			*userid;
@property (readonly)	NSString			*ticket;
@property (readonly)	NSString			*userHash;
@property (readonly)	NSMutableDictionary	*channels;
@property (readonly)	NSString			*messageServerName;
@property (readonly)	NSUInteger			messageServerPortNo;
@property (readonly)	NSString			*messageServerThreadID;
	
#pragma mark construct
- (id) initWithAccount:(NSString *)account andPassword:(NSString *)pass;

@end
