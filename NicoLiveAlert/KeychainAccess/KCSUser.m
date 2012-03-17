//
//  KCSUser.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "KCSUser.h"

#pragma mark constant definition
	// Common flag Bit
const UInt8 resultAllClear				= 0x00;
const UInt8 flagBitAccount				= 0x01 << 0;
	// Internet keychain specific Bits
const UInt8 flagInetServerName			= 0x01 << 1;
const UInt8 flagBitInetServerName		= 0x01 << 2;
const UInt8 flagBitInetPort				= 0x01 << 3;
const UInt8 flagBitInetAuthType			= 0x01 << 4;
const UInt8 flagBitInetSecurityDomain	= 0x01 << 5;
const UInt8 flagBitInetServerPath		= 0x01 << 6;
const UInt8 mastBitsInetRequired = 
	flagBitAccount | flagInetServerName | flagBitInetServerName | flagBitInetPort | 
	flagBitInetAuthType ;
const UInt8 maskBitsInetOptional = 
	flagBitAccount | flagInetServerName | flagBitInetServerName | flagBitInetPort |
	flagBitInetAuthType | flagBitInetSecurityDomain | flagBitInetServerPath;
	// Generic keychain specific Bits


@implementation KCSUser
@synthesize password;
@synthesize keychainName;
@synthesize keychainKind;
@synthesize keychain;
@synthesize keychainItem;
@synthesize status;

#pragma mark class method
+ (SecKeychainRef) newkeychain:(NSString *)keychainPath withPassword:(NSString *)password orPrompt:(BOOL)prompt error:(OSStatus *)error
{
	SecKeychainRef newKey = NULL;
	NSString *path = NULL;
	UInt32 passLength;
	const char *passwordString = NULL;

	path = [keychainPath stringByExpandingTildeInPath];
	passwordString = [password UTF8String];
	passLength = (UInt32)[password length];
	if (prompt)
		*error = SecKeychainCreate([path UTF8String], 0, (void *)NULL, TRUE, NULL, &newKey);
	else
		*error = SecKeychainCreate([path UTF8String], passLength, passwordString, FALSE, NULL, &newKey);

	return newKey;
}// end - (SeckeychainRef) newkeychain:(NSString *)keychainPath withPassword:(NSString *)password orPrompt:(BOOL)prompt error:(OSStatus *)error

+ (OSStatus) deletekeychain:(SecKeychainRef)keychain
{
	OSStatus result = SecKeychainDelete(keychain);
	if (result == noErr)
	{
		CFRelease(keychain);
		keychain = Nil;
	}

	return result;
}// end + (OSStatus) deletekeychain:(SeckeychainRef)keychain;
#pragma mark construct / destruct
- (id) init
{
	self = [super init];
	if (self)
	{
		account = NULL;
		password = NULL;
		keychainName = NULL;
		keychainKind = NULL;
		keychain = NULL;
		keychainItem = NULL;
		syncronized = NO;
		paramFlags = 0x00 | flagBitInetSecurityDomain | flagBitInetServerPath;
		status = 1;
	}
	return self;
}// - (id) init

- (void) dealloc
{
	if (keychain != NULL)
		CFRelease(keychain);
	if (keychainItem != NULL)
		CFRelease(keychainItem);
#if __has_feature(objc_arc) == 0
	// relase account
    if (account != NULL)
		[account release];
	// relase password
	if (password != NULL)
		[password release];
	// no need care synced
	[super dealloc];
#endif
}// end - (void) dealloc

#ifdef __OBJC_GC__
- (void) finalize
{
	if (keychain != NULL)
		CFRelease(keychain);
	if (keychainItem != NULL)
		CFRelease(keychainItem);
	[super finalize];
}// end - (void) finalize
#endif

#pragma mark -
#pragma mark account’s accessor
- (NSString *) account
{
	return account;
}// - (NSString *) account

- (void) setAccount:(NSString *)account_
{
	syncronized = NO;
	account = [account_ copy];
	if ((account != NULL) && ([account length] != 0))
		paramFlags |= flagBitAccount;
}// end - (void) setAccount:(NSString *)account_

@end

#pragma mark -

@interface KCSInternetUser ()
- (NSString *) getPassword:(OSStatus *)error;
@end

@implementation KCSInternetUser
#pragma mark construct / destruct
- (id) init
{
	self = [super init];
	if (self)
	{
		keychain = NULL;
		serverName = NULL;
		serverPath = NULL;
		securityDomain = NULL;
		protocol = kSecProtocolTypeAny;
		authType = kSecAuthenticationTypeAny;
		port = 0;
	}// end if self
	return self;
}// end - (id) init

- (id) initWithAccount:(NSString *)account_ andPassword:(NSString *)password_
{
	self = [super init];
	if (self)
	{
		[super setAccount:account_];
		password = password_;
		keychain = NULL;
		serverName = NULL;
		securityDomain = NULL;
		protocol = kSecProtocolTypeAny;
		paramFlags |= flagBitInetServerName;
		authType = kSecAuthenticationTypeAny;
		paramFlags |= flagBitInetAuthType;
	}// end if self
	return self;
}// end - (id) initWithAccount:(NSString *)account_ andPassword:(NSString *)password_

- (id) initWithURI:(NSURL *)URI
{
	self = [super init];
	if (self)
	{
		account = [[URI user] copy];
		if ((account != NULL) && ([account length] != 0))
			paramFlags |= flagBitAccount;
		serverName = [[URI host] copy];
		if ((serverName != NULL) && ([serverName length] != 0))
			paramFlags |= flagInetServerName;
		serverPath = [[URI path] copy];
		securityDomain = [[URI host] copy];
		if ((securityDomain != NULL) && ([securityDomain length] != 0))
			paramFlags |= flagBitInetSecurityDomain;
		if ([[URI scheme] isEqualToString:@""] == NO)
		{
			NSDictionary *protocolDict = [self protocolDict];
			protocol = [[protocolDict valueForKey:[URI scheme]] intValue];
			if (protocol == 0)
				protocol = kSecProtocolTypeAny;
			paramFlags |= flagBitInetServerName;
		}// end if scheme
		port = [[URI port] intValue];
		paramFlags |= flagBitInetPort;
		authType = kSecAuthenticationTypeAny;
		paramFlags |= flagBitInetAuthType;
		
			// check flags and find keychain item
		if ((paramFlags^maskBitsInetOptional) == resultAllClear)
			password = [self getPassword:&status];
	}// end if self
	return self;
}// end - (id) initWithURI:(NSURL *)URI

- (id) initWithURI:(NSURL *)URI withAuth:(SecAuthenticationType)auth
{
	self = [super init];
	if (self)
	{
		account = [[URI user] copy];
		if ((account != NULL) && ([account length] != 0))
			paramFlags |= flagBitAccount;
		serverName = [[URI host] copy];
		if ((serverName != NULL) && ([serverName length] != 0))
			paramFlags |= flagInetServerName;
		serverPath = [[URI path] copy];
		securityDomain = [[URI host] copy];
		if ((securityDomain != NULL) && ([securityDomain length] != 0))
			paramFlags |= flagBitInetSecurityDomain;
		if ([[URI scheme] isEqualToString:@""] == NO)
		{
			NSDictionary *protocolDict = [self protocolDict];
			protocol = [[protocolDict valueForKey:[URI scheme]] intValue];
			if (protocol == 0)
				protocol = kSecProtocolTypeAny;
			paramFlags |= flagBitInetServerName;
		}// end if scheme
		port = [[URI port] integerValue];
		paramFlags |= flagBitInetPort;
		authType = auth;
		paramFlags |= flagBitInetAuthType;

			// check flags and find keychain item
		if ((paramFlags^maskBitsInetOptional) == resultAllClear)
			password = [self getPassword:&status];
	}// end if self
	return self;
}// end - (id) initWithURI:(NSURL *)URI withAuth:(SecAuthenticationType)auth;

- (void) dealloc
{
#if __has_feature(objc_arc) == 0
	if (serverName)
		[serverName release];
	if (serverPath)
		[serverPath release];
	if (securityDomain)
		[securityDomain release];
	[super dealloc];
#endif
}// end - (void) dealloc

#pragma mark constructor support
- (NSDictionary *) protocolDict
{
	NSDictionary *protocolDict = [NSDictionary dictionaryWithObjectsAndKeys:
	 [NSNumber numberWithInteger:kSecProtocolTypeHTTP], @"http", 
	 [NSNumber numberWithInteger:kSecProtocolTypeHTTPS], @"https",
	 [NSNumber numberWithInteger:kSecProtocolTypeFTP], @"ftp", 
	 [NSNumber numberWithInteger:kSecProtocolTypePOP3], @"pop3", 
	 [NSNumber numberWithInteger:kSecProtocolTypeSMTP], @"smtp", 
	 [NSNumber numberWithInteger:kSecProtocolTypeAFP], @"afp", 
	 [NSNumber numberWithInteger:kSecProtocolTypeSMB], @"smb", 
	 nil];

	return protocolDict;
}// end - (NSDictionary *) protocolDict

#pragma mark -
#pragma mark override account’s settor
- (void) setAccount:(NSString *)account_
{
	[super setAccount:account_];

		// check flags and find keychain item
	if (((paramFlags^maskBitsInetOptional) == resultAllClear) ||
		((paramFlags^mastBitsInetRequired) == resultAllClear))
		password = [self getPassword:&status];
}// end - (void) setAccount:(NSString *)account_

#pragma mark -
#pragma mark serverName’s accessor
//@synthesize serverName
- (NSString *) serverName
{
	return serverName;
}// end - (NSString *) serverName

- (void) setServerName:(NSString *)serverName_
{
	syncronized = NO;
#if __has_feature(objc_arc) == 0
	if (serverName != NULL)
		[serverName autorelease];
#endif
	serverName = [serverName_ copy];
		// set/clear server name flag
	if (serverName != NULL)	// set server name flag
		paramFlags |= flagInetServerName;
	else	// clear server name flag
		paramFlags &= ~flagInetServerName;

		// check flags and find keychain item
	if (((paramFlags^maskBitsInetOptional) == resultAllClear) ||
		((paramFlags^mastBitsInetRequired) == resultAllClear))
		password = [self getPassword:&status];
}// end - (void) setServerName:(NSString *)serverName_

#pragma mark -
#pragma mark serverPath’s accessor
//@synthesize serverPath;
- (NSString *) serverPath
{
	return serverPath;
}// end - (NSString *) serverPath

- (void) setServerPath:(NSString *)serverPath_
{
	syncronized = NO;
#if __has_feature(objc_arc) == 0
	if (serverPath != NULL)
		[serverPath autorelease];
#endif
	serverPath = [serverPath_ copy];

		// check flags and find keychain item
	if (((paramFlags^maskBitsInetOptional) == resultAllClear) ||
		((paramFlags^mastBitsInetRequired) == resultAllClear))
		password = [self getPassword:&status];
}// end - (void) setServerPath:(NSString *)serverPath_

#pragma mark -
#pragma mark securityDomain’s accessor
//@synthesize securityDomain;
- (NSString *) securityDomain
{
	return securityDomain;
}// end - (NSString *) securityDomain

- (void) setSecurityDomain:(NSString *)securityDomain_
{
	syncronized = NO;
#if __has_feature(objc_arc) == 0
	if (securityDomain != NULL)
		[securityDomain autorelease];
#endif
	securityDomain = [securityDomain_ copy];
		// set/clear security domain flag
	if (securityDomain != NULL)	// set security domain flag
		paramFlags |= flagBitInetSecurityDomain;
	else	// clear security domain flag
		paramFlags &= ~flagBitInetSecurityDomain;
	
		// check flags and find keychain item
	if (((paramFlags^maskBitsInetOptional) == resultAllClear) ||
		((paramFlags^mastBitsInetRequired) == resultAllClear))
		password = [self getPassword:&status];
}// end - (void) setSecurityDomain:(NSString *)securityDomain_

#pragma mark -
#pragma mark protocol’s accessor
//@synthesize protocol;
- (SecProtocolType) protocol
{
	return protocol;
}// end - (SecProtocolType) protocol

- (void) setProtocol:(SecProtocolType)protocol_
{
	syncronized = NO;
	protocol = protocol_;
		// set protocol flag
	paramFlags |= flagBitInetServerName;
	
		// check flags and find keychain item
	if (((paramFlags^maskBitsInetOptional) == resultAllClear) ||
		((paramFlags^mastBitsInetRequired) == resultAllClear))
		password = [self getPassword:&status];
}// end - (SecProtocolType) protocol

#pragma mark -
#pragma mark authType’s accessor
//@synthesize authType;
- (SecAuthenticationType) authType
{
	return authType;
}// end - (SecAuthenticationType) authType

- (void) setAuthType:(SecAuthenticationType)authType_
{
	syncronized = NO;
	authType = authType_;
		// set authentication flag
	paramFlags |= flagBitInetAuthType;
	
		// check flags and find keychain item
	if (((paramFlags^maskBitsInetOptional) == resultAllClear) ||
		((paramFlags^mastBitsInetRequired) == resultAllClear))
		password = [self getPassword:&status];
}// end - (void) setAuthType:(SecAuthenticationType)authType_

#pragma mark -
#pragma mark port’s accessor
//@synthesize port;
- (UInt16) port
{
	return port;
}// end - (UInt16) port

- (void) setPort:(UInt16)port_
{
	syncronized = NO;
	port = port_;
		// set port flag
	paramFlags |= flagBitInetPort;
	
	// check flags and find keychain item
	if (((paramFlags^maskBitsInetOptional) == resultAllClear) ||
		((paramFlags^mastBitsInetRequired) == resultAllClear))
		password = [self getPassword:&status];
}// end - (void) setPort:(UInt16)port_

#pragma mark -
#pragma mark password’s accessor
- (NSString *) getPassword:(OSStatus *)error
{
	*error = noErr;
	if (syncronized)
		return password;
	
	// make cstring & length data;
	const char *strAccountName = [account UTF8String];
	UInt32		lenAccountName = (UInt32)[account length];
	const char *strServerName = [serverName UTF8String];
	UInt32		lenServerName = (UInt32)[serverName length];
	const char *strSecurityDomain = [securityDomain UTF8String];
	UInt32		lenSecurityDomain = (UInt32)[securityDomain length];
	const char *strServerPath = [serverPath UTF8String];
	UInt32		lenServerPath = (UInt32)[serverPath	length];
	// returned password data
	const char *strPassword = NULL;
	UInt32 lenPassword;
	
	// fetch password from keychain
	*error = SecKeychainFindInternetPassword(keychain, lenServerName, strServerName, lenSecurityDomain, strSecurityDomain, lenAccountName, strAccountName, lenServerPath, strServerPath, port, protocol, authType, &lenPassword, (void **)&strPassword, &keychainItem);
	
	// check err 
	if (*error == noErr)
	{
		NSData *data = [[NSData alloc] initWithBytes:strPassword length:lenPassword];
		password = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		SecKeychainItemFreeContent(NULL, (void *)strPassword);
#if __has_feature(objc_arc) == 0
		[data release];
		[[password autorelease] retain];
#endif
	}
	
	return password;
}// end - (NSString *) getPassword:(OSStatus  *)error

#pragma mark manage keychainItem 
- (BOOL) addTokeychain
{		// check params
	if (((paramFlags^maskBitsInetOptional) != resultAllClear) &&
		((paramFlags^mastBitsInetRequired) != resultAllClear))
		return NO;

		// check password is existing
	if ((password == NULL) || ([password length] == 0))
		return NO;

		// make cstring & length data
	// make cstring & length data;
	const char *strAccountName = [account UTF8String];
	UInt32		lenAccountName = (UInt32)[account length];
	const char *strServerName = [serverName UTF8String];
	UInt32		lenServerName = (UInt32)[serverName length];
	const char *strSecurityDomain = NULL;
	UInt32		lenSecurityDomain = 0;
	if (securityDomain != NULL)
	{
		strSecurityDomain = [securityDomain UTF8String];
		lenSecurityDomain = (UInt32)[securityDomain length];
	}// endif
	const char *strServerPath = [serverPath UTF8String];
	UInt32		lenServerPath = (UInt32)[serverPath	length];
	// returned password data
	const char *strPassword = [password UTF8String];
	UInt32 lenPassword = (UInt32)[password length];
	
		// add keychain Item
	status = SecKeychainAddInternetPassword(keychain, lenServerName, strServerName, lenSecurityDomain, strSecurityDomain, lenAccountName, strAccountName, lenServerPath, strServerPath, port, protocol, authType, lenPassword, strPassword, &keychainItem);

		// check status
	if (status != noErr)
		return NO;

		// add keychain name if exists
	if ((keychainName != NULL) || ([keychainName length] != 0))
	{		// create attribute
		SecKeychainAttribute attribute;
		SecKeychainAttributeList attrs;
		attribute.tag = kSecLabelItemAttr;
		attribute.data = (void *)[keychainName UTF8String];
		attribute.length = (UInt32)[keychainName length];
		attrs.count = 1;
		attrs.attr = &attribute;
		
			// write to keychain
		status = SecKeychainItemModifyContent(keychainItem, &attrs, 0, NULL);
	}// end if keychain name is exists

		// add keychain kind if exists
	if ((keychainKind != NULL) || ([keychainKind length] != 0))
	{		// create attribute
		SecKeychainAttribute attribute;
		SecKeychainAttributeList attrs;
		attribute.tag = kSecDescriptionItemAttr;
		attribute.data = (void *)[keychainKind UTF8String];
		attribute.length = (UInt32)[keychainKind length];
		attrs.count = 1;
		attrs.attr = &attribute;
		
			// write to keychain
		status = SecKeychainItemModifyContent(keychainItem, &attrs, 0, NULL);
	}// end if keychain kind is exists

		// check result and return
	if (status == noErr)
		return YES;
	else
		return NO;
}// end - (BOOL) addTokeychain;

- (OSStatus) removeFromkeychain
{
	if (keychainItem == NULL)
		return errSecItemNotFound;

	status = SecKeychainItemDelete(keychainItem);
	if (status == noErr)
	{
		CFRelease(keychainItem);
		keychainItem = NULL;
	}// end if success

	return status;
}// end - (OSStatus) removeFromkeychain;

// TODO: must be implement contents
- (OSStatus) changePasswordTo:(NSString *)newPassword
{
	OSStatus error = errSecItemNotFound;
	if (keychainItem == NULL)
		return error;

//	SeckeychainModifyContent();

	return error;
}// end - (OSStatus ) changePasswordTo:(NSString *)newPassword
@end