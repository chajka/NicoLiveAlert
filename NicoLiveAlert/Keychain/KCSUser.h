//
//  KCSUser.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/9/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface KCSUser : NSObject {
	NSString	*account;
	NSString	*password;
	BOOL		synced;
}
@property (copy, readwrite) NSString	*account;
@property (copy, readwrite) NSString	*password;

@end

@interface KCSInternetUser : KCSUser {
	SecKeychainRef			keyChain;			// optional
	NSString				*serverName;
	NSString				*serverPath;
	NSString				*securityDomain;	// optional
	NSString				*serviceName;
	SecProtocolType			protocol;
	SecAuthenticationType	authType;
	UInt16					port;
}
@property (assign, readwrite)	SecKeychainRef			keyChain;
@property (copy, readwrite)		NSString				*serverName;
@property (copy, readwrite)		NSString				*serverPath;
@property (copy, readwrite)		NSString				*securityDomain;
@property (copy, readwrite)		NSString				*serviceName;
@property (assign, readwrite)	SecProtocolType			protocol;
@property (assign, readwrite)	SecAuthenticationType	authType;
@property (assign, readwrite)	UInt16					port;

- (id) init;

- (NSString *) password:(OSStatus  *)error;

@end
