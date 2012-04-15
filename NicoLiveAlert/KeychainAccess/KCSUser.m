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
const UInt8 flagBitInetProtocol			= 0x01 << 5;
const UInt8 flagBitInetServerPath		= 0x01 << 6;
const UInt8 flagBitInetSecurityDomain	= 0x01 << 7;
const UInt8 mastBitsInetRequired = 
	flagBitAccount | flagInetServerName | flagBitInetServerName | flagBitInetPort | 
	flagBitInetAuthType ;
const UInt8 maskBitsInetOptional = 
	flagBitAccount | flagInetServerName | flagBitInetServerName | flagBitInetPort |
	flagBitInetAuthType | flagBitInetProtocol | flagBitInetSecurityDomain | flagBitInetServerPath;
	// Generic keychain specific Bits

@interface KCSUser ()
@end

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
	if (password != NULL)
	{
		passwordString = [password UTF8String];
		passLength = (UInt32)[password length];
	}
	else
	{
		prompt = YES;
	}
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
		paramFlags = resultAllClear;
		status = 1;
	}
	return self;
}// - (id) init

- (void) dealloc
{
	if (keychain != NULL)		CFRelease(keychain);
	if (keychainItem != NULL)	CFRelease(keychainItem);
#if __has_feature(objc_arc) == 0
	// relase account
    if (account != NULL)		[account release];
	// relase password
	if (password != NULL)		[password release];
	[super dealloc];
#endif
}// end - (void) dealloc

#ifdef __OBJC_GC__
- (void) finalize
{
	if (keychain != NULL)		CFRelease(keychain);
	if (keychainItem != NULL)	CFRelease(keychainItem);
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
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
- (id) initWithDictionary:(NSDictionary *)user inKeychain:(SecKeychainRef)keyChain;
#else
- (id) initWithItemRef:(SecKeychainItemRef)item andKeychain:(SecKeychainRef)keyChain;
#endif
- (NSString *) getPassword:(OSStatus *)error;
#pragma mark constructor support
- (NSDictionary *) protocolDict;
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
CFMutableDictionaryRef makeQuery(CFStringRef server);
#endif
@end


@implementation KCSInternetUser
// KCSInternetUser's C Function prototype;
NSArray *keyChainUsersOfServer(NSString *server, NSString *path, SecAuthenticationType type, SecKeychainRef keychain);
#pragma mark class method
+ (NSArray *) usersOfAccountsForServer:(NSString *)where path:(NSString *)path forAuthType:(SecAuthenticationType)type inKeychain:(SecKeychainRef)keychain
{
	NSArray *accounts = keyChainUsersOfServer(where, path, type, keychain);
	
	return accounts;
}// end + (NSArray *) usersOfAccountsForServer:(NSString *)where path:(NSString *)path forAuthType:(SecAuthenticationType)type inKeychain:(SecKeychainRef)keychain
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
		paramFlags |= flagBitInetProtocol;
		authType = kSecAuthenticationTypeAny;
		paramFlags |= flagBitInetAuthType;
		port = 0;
		paramFlags |= flagBitInetPort;
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
		port = 0;
		paramFlags |= flagBitInetPort;
		protocol = kSecProtocolTypeAny;
		paramFlags |= flagBitInetProtocol;
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
		if (serverPath == NULL)
			serverPath = [@"" copy];
		paramFlags |= flagBitInetServerPath;
		securityDomain = [[URI host] copy];
		if ((securityDomain != NULL) && ([securityDomain length] != 0))
			paramFlags |= flagBitInetSecurityDomain;
		if ([[URI scheme] isEqualToString:@""] == NO)
		{
			NSDictionary *protocolDict = [self protocolDict];
			protocol = [[protocolDict valueForKey:[URI scheme]] unsignedIntValue];
			if (protocol == 0)
				protocol = kSecProtocolTypeAny;
			paramFlags |= flagBitInetServerName;
		}// end if scheme
		port = [[URI port] unsignedIntValue];
		paramFlags |= flagBitInetPort;
		authType = kSecAuthenticationTypeAny;
		paramFlags |= flagBitInetAuthType;
		
			// check flags and find keychain item
		if (((paramFlags & mastBitsInetRequired) ^ mastBitsInetRequired) == resultAllClear)
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
		if (serverPath == NULL)
			serverPath = [@"" copy];
		paramFlags |= flagBitInetServerPath;
		securityDomain = [[URI host] copy];
		if ((securityDomain != NULL) && ([securityDomain length] != 0))
			paramFlags |= flagBitInetSecurityDomain;
		if ([[URI scheme] isEqualToString:@""] == NO)
		{
			NSDictionary *protocolDict = [self protocolDict];
			protocol = [[protocolDict valueForKey:[URI scheme]] unsignedIntValue];
			if (protocol == 0)
				protocol = kSecProtocolTypeAny;
			paramFlags |= flagBitInetServerName;
		}// end if scheme
		port = [[URI port] integerValue];
		paramFlags |= flagBitInetPort;
		authType = auth;
		paramFlags |= flagBitInetAuthType;

			// check flags and find keychain item
		if (((paramFlags & mastBitsInetRequired) ^ mastBitsInetRequired) == resultAllClear)
			password = [self getPassword:&status];
	}// end if self
	return self;
}// end - (id) initWithURI:(NSURL *)URI withAuth:(SecAuthenticationType)auth;

#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
- (id) initWithDictionary:(NSDictionary *)user inKeychain:(SecKeychainRef)keyChain
{
	if ([user count] == 0)
		return NULL;
	self = [super init];
	if (self)
	{
		keychain = keyChain;
		account = [[user objectForKey:kSecAttrAccount] copy];
		if ((account != NULL) && ([account length] != 0))
			paramFlags |= flagBitAccount;
		keychainName = [[user objectForKey:kSecAttrLabel] copy];
		keychainKind = [[user objectForKey:kSecAttrDescription] copy];
		serverName = [[user objectForKey:kSecAttrServer] copy];
		serverPath = [[user objectForKey:kSecAttrPath] copy];
		if (serverPath == NULL)
			serverPath = [@"" copy];
		paramFlags |= flagBitInetServerPath;
		securityDomain = [[user objectForKey:kSecAttrSecurityDomain] copy];
		if ((securityDomain != NULL) && ([securityDomain length] == 0))
			paramFlags |= flagBitInetSecurityDomain;
		protocol = [[user objectForKey:kSecAttrProtocol] integerValue];
		paramFlags |= flagBitInetProtocol;
		authType = [[user objectForKey:kSecAttrAuthenticationType] integerValue];
		paramFlags |= flagBitInetAuthType;
		port = [[user objectForKey:kSecAttrPort] integerValue];
		paramFlags |= flagBitInetPort;

		UInt32 passwordLength = 0;
		const char *passwordString = NULL;
		status = SecKeychainFindInternetPassword(NULL, [serverName length], (const char *)[serverName UTF8String], 0, NULL, [account length], (const char *)[account UTF8String], [serverPath length], (const char *)[serverPath UTF8String], port, protocol, authType, &passwordLength, (void **)&passwordString, &keychainItem);
		if (status != noErr)
		{
			SecKeychainItemFreeContent(NULL, (void *)passwordString);
#if __has_feature(objc_arc) == 0
			[serverName release];
			[serverPath release];
			[securityDomain release];
			[super dealloc];
#endif
			return NULL;
		}// end if status is error
		
		NSString *passwd = [[NSString alloc] initWithBytes:(const void *)passwordString length:passwordLength encoding:NSUTF8StringEncoding];
		password = [passwd copy];
#if __has_feature(objc_arc) == 0
		[passwd autorelase];
#endif
		syncronized = TRUE;
		
		SecKeychainItemFreeContent(NULL, (void *)passwordString);
	}// end if self
	return self;
}// end - (id) initWithDictionary:(NSDictionary *)user inKeychain:(SecKeychainRef)keyChain
#endif

#if MAC_OS_X_VERSION_MIN_REQUIRED <= MAC_OS_X_VERSION_10_5
- (id) initWithItemRef:(SecKeychainItemRef)item andKeychain:(SecKeychainRef)keyChain
{
	if (item == NULL)
		return NULL;
	self = [super init];
	if (self)
	{		// set keychain
		keychain = keyChain;
			// set keychain item
		keychainItem = item;
			// initialize variables
		SecKeychainAttributeInfo info;
		UInt32 tag;
		UInt32 format;
		info.count = 1;
		info.tag = &tag;
		info.format = &format;
		SecKeychainAttributeList *attrList = NULL;
		UInt32 length = 0;
		void *data = NULL;

				// get account, password and keychainItem
		tag = kSecAccountItemAttr;
		format = CSSM_DB_ATTRIBUTE_FORMAT_STRING;
		status = SecKeychainItemCopyAttributesAndData(item, &info, NULL, &attrList, &length, &data);
		if (status == noErr)	// check fetch data is success?
		{		// get account
			account = [[[[NSString alloc] initWithBytes:attrList->attr->data length:attrList->attr->length encoding:NSUTF8StringEncoding] autorelease] copy];
			paramFlags |= flagBitAccount;
				// get password
			password = [[[[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding] autorelease] copy];
			SecKeychainItemFreeAttributesAndData(attrList, data);
			syncronized = TRUE;
		}
		else
		{
			SecKeychainItemFreeAttributesAndData(attrList, NULL);
			[super dealloc];
			return NULL;
		}// end if fetch data success

				// get server name
		tag = kSecServerItemAttr;
		format = CSSM_DB_ATTRIBUTE_FORMAT_STRING;
		status = SecKeychainItemCopyAttributesAndData(item, &info, NULL, &attrList, 0, NULL);
		if (status == noErr)	// check fetch data is success?
		{
			serverName = [[[[NSString alloc] initWithBytes:attrList->attr->data length:attrList->attr->length encoding:NSUTF8StringEncoding] autorelease] copy];
			SecKeychainItemFreeAttributesAndData(attrList, NULL);
			paramFlags |= flagBitInetServerName;
		}
		else
		{
			serverName = NULL;
			SecKeychainItemFreeAttributesAndData(attrList, NULL);
		}// end if set server name 

				// get server path
		tag = kSecPathItemAttr;
		format = CSSM_DB_ATTRIBUTE_FORMAT_STRING;
		status = SecKeychainItemCopyAttributesAndData(item, &info, NULL, &attrList, 0, NULL);
		if (status == noErr)	// check fetch data is success?
		{
			serverPath = [[[[NSString alloc] initWithBytes:attrList->attr->data length:attrList->attr->length encoding:NSUTF8StringEncoding] autorelease] copy];
			SecKeychainItemFreeAttributesAndData(attrList, NULL);
			paramFlags |= flagBitInetServerPath;
		}
		else
		{
			serverPath = NULL;
			SecKeychainItemFreeAttributesAndData(attrList, NULL);
		}// end if set server path

			// get security domain
		tag = kSecSecurityDomainItemAttr;
		format = CSSM_DB_ATTRIBUTE_FORMAT_STRING;
		status = SecKeychainItemCopyAttributesAndData(item, &info, NULL, &attrList, 0, NULL);
		if (status == noErr)	// check fetch data is success?
		{
			securityDomain = [[[[NSString alloc] initWithBytes:attrList->attr->data length:attrList->attr->length encoding:NSUTF8StringEncoding] autorelease] copy];
			SecKeychainItemFreeAttributesAndData(attrList, NULL);
			paramFlags |= flagBitInetSecurityDomain;
		}
		else
		{
			securityDomain = NULL;
			SecKeychainItemFreeAttributesAndData(attrList, NULL);
		}// end if set security domain

			// get protocol
		tag = kSecProtocolItemAttr;
		format = CSSM_DB_ATTRIBUTE_FORMAT_UINT32;
		status = SecKeychainItemCopyAttributesAndData(item, &info, NULL, &attrList, 0, NULL);
		if (status == noErr)	// check fetch data is success?
		{
			protocol = *(SecProtocolType *)(attrList->attr->data);
			SecKeychainItemFreeAttributesAndData(attrList, NULL);
		}
		else
		{
			protocol = kSecProtocolTypeAny;
			SecKeychainItemFreeAttributesAndData(attrList, NULL);
		}// end if set protocol
		paramFlags |= flagBitInetProtocol;
		
				// get prot
		tag = kSecPortItemAttr;
		format = CSSM_DB_ATTRIBUTE_FORMAT_UINT32;
		status = SecKeychainItemCopyAttributesAndData(item, &info, NULL, &attrList, 0, NULL);
		if (status == noErr)	// check fetch data is success?
		{
			port = *(SecAuthenticationType *)(attrList->attr->data);
			SecKeychainItemFreeAttributesAndData(attrList, NULL);
		}
		else
		{
			port = 0;
			SecKeychainItemFreeAttributesAndData(attrList, NULL);
		}// end set authentication type
		paramFlags |= flagBitInetPort;

				// get authentication type
		tag = kSecProtocolItemAttr;
		format = CSSM_DB_ATTRIBUTE_FORMAT_UINT32;
		status = SecKeychainItemCopyAttributesAndData(item, &info, NULL, &attrList, 0, NULL);
		if (status == noErr)	// check fetch data is success?
		{
			authType = *(SecAuthenticationType *)(attrList->attr->data);
			SecKeychainItemFreeAttributesAndData(attrList, NULL);
			paramFlags |= flagBitInetAuthType;
		}
		else
		{
			authType = kSecAuthenticationTypeAny;
			SecKeychainItemFreeAttributesAndData(attrList, NULL);
		}// end set authentication type

				// get keychain name
		tag = kSecLabelItemAttr;
		format = CSSM_DB_ATTRIBUTE_FORMAT_STRING;
		status = SecKeychainItemCopyAttributesAndData(item, &info, NULL, &attrList, 0, NULL);
		if (status == noErr)	// check fetch data is success?
		{
			keychainName = [[[[NSString alloc] initWithBytes:attrList->attr->data length:attrList->attr->length encoding:NSUTF8StringEncoding] autorelease] copy];
			SecKeychainItemFreeAttributesAndData(attrList, NULL);
		}
		else
		{
			keychainName = NULL;
			SecKeychainItemFreeAttributesAndData(attrList, NULL);
		}// end set keychain name

				// get keychain kind
		tag = kSecDescriptionItemAttr;
		format = CSSM_DB_ATTRIBUTE_FORMAT_STRING;
		status = SecKeychainItemCopyAttributesAndData(item, &info, NULL, &attrList, 0, NULL);
		if (status == noErr)	// check fetch data is success?
		{
			keychainKind = [[[[NSString alloc] initWithBytes:attrList->attr->data length:attrList->attr->length encoding:NSUTF8StringEncoding] autorelease] copy];
			SecKeychainItemFreeAttributesAndData(attrList, NULL);
		}
		else
		{
			keychainKind = NULL;
			SecKeychainItemFreeAttributesAndData(attrList, NULL);
		}// end set keychain name
	}// end if self
	return self;
}// end - (id) initWithItemRef:(SecKeychainItemRef)item andKeychain:(SecKeychainRef)keyChain
#endif

- (void) dealloc
{
#if __has_feature(objc_arc) == 0
	if (serverName)			[serverName release];
	if (serverPath)			[serverPath release];
	if (securityDomain)		[securityDomain release];

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
	if (((paramFlags & mastBitsInetRequired) ^ mastBitsInetRequired) == resultAllClear)
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
	if (((paramFlags & mastBitsInetRequired) ^ mastBitsInetRequired) == resultAllClear)
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
	if (((paramFlags & mastBitsInetRequired) ^ mastBitsInetRequired) == resultAllClear)
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
	if (((paramFlags & mastBitsInetRequired) ^ mastBitsInetRequired) == resultAllClear)
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
	paramFlags |= flagBitInetProtocol;
	
		// check flags and find keychain item
	if (((paramFlags & mastBitsInetRequired) ^ mastBitsInetRequired) == resultAllClear)
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
	if (((paramFlags & mastBitsInetRequired) ^ mastBitsInetRequired) == resultAllClear)
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
	if (((paramFlags & mastBitsInetRequired) ^ mastBitsInetRequired) == resultAllClear)
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
		syncronized = TRUE;
	}
	
	return password;
}// end - (NSString *) getPassword:(OSStatus  *)error

#pragma mark manage keychainItem 
- (BOOL) addTokeychain
{		// check params
	if (((paramFlags & mastBitsInetRequired) ^ mastBitsInetRequired) == resultAllClear)
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

- (OSStatus) changePasswordTo:(NSString *)newPassword
{
	OSStatus error = errSecItemNotFound;
	if (keychainItem == NULL)
		return error;

		// write to keychain
	const char *passwordString = [newPassword UTF8String];
	status = SecKeychainItemModifyAttributesAndData(keychainItem, NULL, (UInt32)strlen(passwordString), (void *)passwordString);
	if (status == noErr)
		syncronized = TRUE;

	return status;
}// end - (OSStatus ) changePasswordTo:(NSString *)newPassword

NSArray *keyChainUsersOfServer(NSString *server, NSString *path, SecAuthenticationType type, SecKeychainRef keychain)
{
	NSMutableArray *users = [NSMutableArray array];
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
	OSStatus status;
	// Later 10.6 use SecItemCopyMatching
    // create query
	CFMutableDictionaryRef query = makeQuery((__bridge CFStringRef)server);
	
	
    // get search results
	CFIndex items = 0;
    CFArrayRef search = NULL;
    status = SecItemCopyMatching(query, (CFTypeRef*)&search);
	CFRelease(query);
	if ((search == NULL) || ((status != noErr) && ((items = CFArrayGetCount(search)) != 0)))
		return NULL;
	
	KCSInternetUser *user;
	for (NSDictionary *item in (__bridge NSArray *)search)
	{
		user = [[KCSInternetUser alloc] initWithDictionary:item inKeychain:keychain];
		if (user != NULL)
			[users addObject:user];
	}// end for
	CFRelease(search);
	
#else
	// Earler 10.5 user SecKeychainSearchCreateFromAttributes
		// Construct a query.
	const char *cStringServerName = [server cStringUsingEncoding:NSUTF8StringEncoding];
	OSStatus status;
	SecKeychainAttribute attr[1];
	
	attr[0].tag = kSecServerItemAttr; 
	attr[0].length = (UInt32)strlen(cStringServerName); 
	attr[0].data = (void *)cStringServerName;
	
	SecKeychainAttributeList attrList = { .count = 1, .attr = attr };
	SecKeychainSearchRef search = NULL;
	
	status = SecKeychainSearchCreateFromAttributes(keychain, kSecInternetPasswordItemClass, &attrList, &search);
	if (status != noErr)
		return users;
	
	// iterate user accounts
	while (true)
	{
		SecKeychainItemRef item = NULL;
		status = SecKeychainSearchCopyNext(search, &item);
		if (status != noErr)
			break;
		KCSInternetUser *user = [[[KCSInternetUser alloc] initWithItemRef:item andKeychain:keychain] autorelease];
		if (item != NULL)
			[users addObject:user];
	}// end while (true)
	CFRelease(search);
#endif
	if ([users count] == 0)
		users = NULL;

	return users;
}// end NSArray *keyChainUsersOfServer(NSString *server, NSString *path, SecAuthenticationType type)
	
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
CFMutableDictionaryRef makeQuery(CFStringRef server)
{
	CFMutableDictionaryRef query = CFDictionaryCreateMutable(kCFAllocatorDefault, 5, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);	
    CFDictionaryAddValue(query, kSecClass, kSecClassInternetPassword);
	CFDictionaryAddValue(query, kSecAttrServer, server);
    CFDictionaryAddValue(query, kSecMatchLimit, kSecMatchLimitAll);
    CFDictionaryAddValue(query, kSecReturnAttributes, kCFBooleanTrue);
	CFDictionaryAddValue(query, kSecAttrKeyClass, kSecAttrDescription);
	CFDictionaryAddValue(query, kSecAttrKeyClass, kSecAttrSecurityDomain);
	CFDictionaryAddValue(query, kSecAttrKeyClass, kSecAttrProtocol);
	CFDictionaryAddValue(query, kSecAttrKeyClass, kSecAttrAuthenticationType);
	CFDictionaryAddValue(query, kSecAttrKeyClass, kSecAttrPort);
	CFDictionaryAddValue(query, kSecAttrKeyClass, kSecAttrPath);
	
	return query;
}// end - (CFDictionaryRef) makeQuery
#endif
@end
