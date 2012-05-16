//
//  KCSUser.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

/*!
	@header KCSUser.h

	This header file describes the Keychain Service's Cocoa
	Wrapper for Internet and Generic user.
	bur currently useable for InternetUser.
*/

#pragma mark -
/*!
	@class KCSUser
	@abstract base class management elements of Generid and
	Internet password.
*/
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
/*!
	@method newkeychain:withPassword:orPrompt:error:
	@abstract create new keychain holder file with password.
	@param path to new keychain file.
	@param keychain master password.
	it can be nil then prompt password by dialog.
	@param flag for password from param or prompt dialog.
	but password is nil, then force prompt it.
	@param return error by OSStatus
	@result created keychain's SecKeychainRef
*/
+ (SecKeychainRef) newkeychain:(NSString *)keychainPath withPassword:(NSString *)password orPrompt:(BOOL)prompt error:(OSStatus *)error;

/*!
	 @method deletekeychain:
	 @abstract delete keychain file by pointed SeckeychainRef.
	 @result error code of OSStatus
*/
+ (OSStatus) deletekeychain:(SecKeychainRef)keychain;
#pragma mark construct / destruct
- (id) init;
@end

#pragma mark -
/*!
	 @class KCSInternetUser
	 @abstract Cocoa Wrapper of Keychain Service for Internet keychain.
*/
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
/*!
	 @method usersOfAccountsForServer:path:forAuthType:inKeychain
	 @abstract search and return users account and for specified server.
	 @param server name it <b>isn't</b> need like http(s):// kind prefix.
	 @param path for server. if no path, this parameter set be @""
	 @param authentication type
	 @param specify where to serch from keychains.
	 if this parameter is nil, then serch in system default keychain.
	 @result found user's array of KCSInternetUser.
*/
+ (NSArray *) usersOfAccountsForServer:(NSString *)where path:(NSString *)path forAuthType:(SecAuthenticationType)type inKeychain:(SecKeychainRef)keychain;
#pragma mark construct / destruct
/*!
	 @method init
	 @abstract create KCSInternetUser instance
	 of all member value to nil or zero.
	 @result empty internet KCSInternetUser instance.
*/
- (id) init;

/*!
	 @method initWithAccount:andPassword:
	 @abstract create KCSInternetUser instance by accout and password set.
	 but not specify server, protocl and so on.
	 This method create instance but didn't entry to keychain yet.
	 @param user accout name.
	 @param password of account.
	 @result accuont name and password setted KCSInternetUser instance.
 */
- (id) initWithAccount:(NSString *)account_ andPassword:(NSString *)password_;

/*!
	@method initWithURI:
	@abstract create KCSInternetUser instance by URI specifyd by NSURL.
	It can be set account by pointed ://[account]@ .
	This method create instance but didn't entry to keychain yet.
	@param Internet location by NSURL class.
	It can include account name like a ftp://anonymous@apple.com style.
	@result (accuont name), URL, path setted KCSInternetUser instance.
*/
- (id) initWithURI:(NSURL *)URI;

/*!
	@method initWithURI:withAuth:
	@abstract create KCSInternetUser instance by URI specifyd by NSURL.
	It can be set account by pointed ://[account]@ .
	This method create instance but didn't entry to keychain yet.
	@param Internet location by NSURL class.
	It can include account name like a ftp://anonymous@apple.com style.
	@param authentication type for http and other
	@result (accuont name), URL, path setted KCSInternetUser instance.
*/
- (id) initWithURI:(NSURL *)URI withAuth:(SecAuthenticationType)auth;
#pragma mark manage keychainItem 
/*!
	@method addTokeychain
	@abstract warite reciever to keychain
	@result YES if success and NO if add to keychain was faild.
	success and failed OSStatus is reference by property status.
*/
- (BOOL) addTokeychain;

/*!
	@method removeFromkeychain
	@abstract remove entry pointed by reciever from keychain.
	but information is keep in reciever until release reciever.
	@result OSStatus it can reference from both result and property.
*/
- (OSStatus) removeFromkeychain;

/*!
	@method changePasswordTo:
	@abstract change password of reciever pointed keychain item.
	@result OSStatus code. write to keychain.
*/
- (OSStatus) changePasswordTo:(NSString *)newPassword;
@end
