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
	NSString			*keychainName;	// optional it's set to name attribute of keychainAccess	
	NSString			*keychainKind;	// optional it's set to kind attribute of keychain
	SecKeychainRef		keychain;		// optional
	SecKeychainItemRef	keychainItem;
	BOOL				syncronized;
	UInt8				paramFlags;
	OSStatus			status;
}
@property (copy, readwrite)		NSString			*account;
@property (copy, readonly)		NSString			*password;
@property (copy, readwrite)		NSString			*keychainName;
@property (copy, readwrite)		NSString			*keychainKind;
@property (assign, readwrite)	SecKeychainRef		keychain;
@property (readonly)			SecKeychainItemRef	keychainItem;
@property (readonly)			OSStatus			status;

#pragma mark class method
+ (SecKeychainRef) newkeychain:(NSString *)keychainPath withPassword:(NSString *)password orPrompt:(BOOL)prompt error:(OSStatus *)error;
+ (OSStatus) deletekeychain:(SecKeychainRef)keychain;
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

#pragma mark class method
+ (NSArray *) usersOfAccountsForServer:(NSString *)where path:(NSString *)path forAuthType:(SecAuthenticationType)type inKeychain:(SecKeychainRef)keychain;
#pragma mark construct / destruct
- (id) init;
- (id) initWithAccount:(NSString *)account_ andPassword:(NSString *)password_;
- (id) initWithURI:(NSURL *)URI;
- (id) initWithURI:(NSURL *)URI withAuth:(SecAuthenticationType)auth;
#pragma mark manage keychainItem 
- (BOOL) addTokeychain;
- (OSStatus) removeFromkeychain;
- (OSStatus) changePasswordTo:(NSString *)newPassword;
@end
