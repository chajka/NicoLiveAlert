//
//  KCSUser.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCSUser : NSObject {
@protected
	NSString			*account;
	NSString			*password;
	SecKeychainRef		keyChain;			// optional
	SecKeychainItemRef	keyChainItem;
	BOOL				syncronized;
}
@property (copy, readwrite)		NSString			*account;
@property (copy, readwrite)		NSString			*password;
@property (assign, readwrite)	SecKeychainRef		keyChain;
@property (assign, readwrite)	SecKeychainItemRef	keyChainItem;

#pragma mark construct / destruct
- (id) init;
@end

#pragma mark -
@interface KCSInternetUser : KCSUser {
@protected
	NSString				*serverName;
	NSString				*serverPath;
	NSString				*securityDomain;	// optional
	SecProtocolType			protocol;
	SecAuthenticationType	authType;
	UInt16					port;
}
@property (copy, readwrite)		NSString				*serverName;
@property (copy, readwrite)		NSString				*serverPath;
@property (copy, readwrite)		NSString				*securityDomain;
@property (assign, readwrite)	SecProtocolType			protocol;
@property (assign, readwrite)	SecAuthenticationType	authType;
@property (assign, readwrite)	UInt16					port;

#pragma mark construct / destruct
- (id) init;
#pragma mark accessor
- (NSString *) password:(OSStatus *)error;
@end
