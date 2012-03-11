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

#pragma mark -
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

- (id) init;
@end
