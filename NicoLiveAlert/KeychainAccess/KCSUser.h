//
//  KCSUser.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -
@interface KCSUser : NSObject {
@protected
	NSString			*account;
	NSString			*password;
	SecKeychainRef		keyChain;			// optional
	SecKeychainItemRef	keyChainItem;
	BOOL				syncronized;
	UInt8				paramFlags;
	OSStatus			status;
}
@property (copy, readwrite)		NSString			*account;
@property (copy, readonly)		NSString			*password;
@property (assign, readwrite)	SecKeychainRef		keyChain;
@property (readonly)			SecKeychainItemRef	keyChainItem;
@property (readonly)			OSStatus			status;

#pragma mark class method
+ (SecKeychainRef) newKeychain:(NSString *)keychainPath withPassword:(NSString *)password orPrompt:(BOOL)prompt error:(OSStatus *)error;
+ (OSStatus) deleteKeychain:(SecKeychainRef)keyChain;
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
- (id) initWithURI:(NSURL *)URI;
- (id) initWithURI:(NSURL *)URI withAuth:(SecAuthenticationType)auth;
#pragma mark constructor support
- (NSDictionary *) protocolDict;
#pragma mark action
- (OSStatus) changePasswordTo:(NSString *)newPassword;
@end
