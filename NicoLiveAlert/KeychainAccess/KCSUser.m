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
	// keychain item query enumuration
enum kcItemQueryOrder {
	orderAccount = 0,
	orderServerName,
	orderServerPath,
	orderSecurityDomain,
	orderServerType,
	orderProtocol,
	orderPort,
	orderAuthType,
	orderKeychainName,
	orderDescription,
	attrQueryCount
};

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
- (id) initWithAccount:(NSString *)account_ password:(NSString *)pass serverName:(NSString *)server path:(NSString *)path domain:(NSString *)domain protocol:(SecProtocolType)protocol_ authentication:(SecAuthenticationType)auth port:(UInt16)port_;
- (NSString *) getPassword:(OSStatus *)error;
#pragma mark constructor support
- (NSDictionary *) protocolDict;
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
- (CFMutableDictionaryRef) makeQuery;
#else
SecKeychainAttributeInfo makeQuery(void);
#endif
@end


@implementation KCSInternetUser
// KCSInternetUser's C Function prototype;
NSArray *keyChainUsersOfServer(NSString *server, NSString *path, SecAuthenticationType type);
#pragma mark class method
+ (NSArray *) initWithAccountsForServer:(NSString *)where path:(NSString *)path forAuthType:(SecAuthenticationType)type
{
	NSArray *accounts = keyChainUsersOfServer(where, path, type);
	
	return accounts;
}// end + (NSArray *) initWithAccountsForServer:(NSString *)where path:(NSString *)path forAuthType:(SecAuthenticationType)type
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
		if ((paramFlags^maskBitsInetOptional) == resultAllClear)
			password = [self getPassword:&status];
	}// end if self
	return self;
}// end - (id) initWithURI:(NSURL *)URI withAuth:(SecAuthenticationType)auth;

- (id) initWithAccount:(NSString *)account_ password:(NSString *)pass serverName:(NSString *)server path:(NSString *)path domain:(NSString *)domain protocol:(SecProtocolType)protocol_ authentication:(SecAuthenticationType)auth port:(UInt16)port_
{
	self = [super init];
	if (self)
	{		// assign superclass's member
		account = account_;
		password = pass;
			// initialize class specific member
		serverName = server;
		serverPath = path;
		securityDomain = domain;
		protocol = protocol_;
		authType = auth;
		port = port_;
	}
	return self;
}// end - (id) initWithAccount:(NSString *)account_ password:(NSString *)pass serverName:(NSString *)server path:(NSString *)path_ domain:(NSString *)domain protocol:(SecProtocolType)protocol_ authentication:(SecAuthenticationType)auth port:(UInt16)port_;

- (id) initWithItemRef:(SecKeychainItemRef)item
{
	if (item == NULL)
		return NULL;
	self = [super init];
	if (self)
	{
		SecKeychainAttributeInfo info = makeQuery();
		SecKeychainAttributeList *attrList = NULL;
		UInt32 length = 0;
		void *data = NULL;
		status = SecKeychainItemCopyAttributesAndData(item, &info, NULL, &attrList, &length, &data);
		if (status != noErr)	// check fetch data is success?
		{
			[super dealloc];
			return NULL;
		}// end if fetch data failed

		keychainItem = item;

			// get password
		password = [[[[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding] autorelease] copy];
			// get account
		account = [[[[NSString alloc] initWithBytes:attrList->attr[orderAccount].data length:attrList->attr[orderAccount].length encoding:NSUTF8StringEncoding] autorelease] copy];
			// get server name
		serverName = [[[[NSString alloc] initWithBytes:attrList->attr[orderServerName].data length:attrList->attr[orderServerName].length encoding:NSUTF8StringEncoding] autorelease] copy];
			// get server path
		serverPath = [[[[NSString alloc] initWithBytes:attrList->attr[orderServerPath].data length:attrList->attr[orderServerPath].length encoding:NSUTF8StringEncoding] autorelease] copy];
			// get security domain
		securityDomain = [[[[NSString alloc] initWithBytes:attrList->attr[orderSecurityDomain].data length:attrList->attr[orderSecurityDomain].length encoding:NSUTF8StringEncoding] autorelease] copy];
			// get protocol
		protocol = *(SecProtocolType *)(attrList->attr[orderProtocol].data);
			// get authentication type
		authType = *(SecAuthenticationType *)(attrList->attr[orderAuthType].data);
			// get keychain name
		keychainName = [[[[NSString alloc] initWithBytes:attrList->attr[orderKeychainName].data length:attrList->attr[orderKeychainName].length encoding:NSUTF8StringEncoding] autorelease] copy];
			// get keychain kind
		keychainKind = [[[[NSString alloc] initWithBytes:attrList->attr[orderDescription].data length:attrList->attr[orderDescription].length encoding:NSUTF8StringEncoding] autorelease] copy];

		SecKeychainItemFreeAttributesAndData(attrList, data);
	}// end if self
	return self;
}// end - (id) initWithItemRef:(SecKeychainItemRef)item

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

NSArray *keyChainUsersOfServer(NSString *server, NSString *path, SecAuthenticationType type)
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
{
	OSStatus status;
	// Later 10.6 use SecItemCopyMatching
    // create query
	CFMutableDictionaryRef query = CFDictionaryCreateMutable(kCFAllocatorDefault, 5, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);	
    CFDictionaryAddValue(query, kSecClass, kSecClassInternetPassword);
    CFDictionaryAddValue(query, kSecReturnAttributes, kCFBooleanTrue);
    CFDictionaryAddValue(query, kSecMatchLimit, kSecMatchLimitAll);
    CFDictionaryAddValue(query, kSecClass, kSecClassInternetPassword);
	CFDictionaryAddValue(query, kSecAttrServer, (__bridge CFStringRef)server);
	
    // get search results
	CFIndex items = 0;
    CFArrayRef search = NULL;
    status = SecItemCopyMatching(query, (CFTypeRef*)&search);
	CFRelease(query);
	if ((status != noErr) && ((items = CFArrayGetCount(search)) != 0))
		return NULL;
	
	NSMutableArray *users = [NSMutableArray array];
	KCSInternetUser *user;
	UInt32 passwordLength;
	const char *passwordString;
	NSString *account = NULL;
	NSString *password = NULL;
	NSString *serverName = NULL;
	NSInteger protcol = 0;
	NSNumber *serverType = NULL;
	NSInteger port = 0;
	SecKeychainItemRef itemRef = NULL;
	for (NSDictionary *item in (__bridge NSArray *)search)
	{
		account = [item objectForKey:kSecAttrAccount];
		serverName = [item objectForKey:kSecAttrServer];
		protcol = [[item objectForKey:kSecAttrProtocol] integerValue];
		port = [[item objectForKey:kSecAttrPort] integerValue];
		serverType = [item objectForKey:kSecAttrType];
		status = SecKeychainFindInternetPassword(NULL, [serverName length], (const char *)[serverName UTF8String], 0, NULL, [account length], (const char *)[account UTF8String], [path length], (const char *)[path UTF8String], port, protcol, type, &passwordLength, (void **)&passwordString, &itemRef);
		
		if (status == noErr)
		{
			NSLog(@"%@", itemRef);
			// convet password to NSString
			password = [[NSString alloc] initWithBytes:(void *)passwordString length:passwordLength encoding:NSUTF8StringEncoding];
			// Make User instance and set each value
			user = [[KCSInternetUser alloc] init];
			[user setAccount:account];
			[user setPassword:password];
			[user setServerName:serverName];
			[user setServerPath:path];
			[user setType:serverType];
			[user setProtocol:protcol];
			[users addObject:user];
			SecKeychainItemFreeContent(NULL, (void *)passwordString);
		}// end if status is OK
	}// end for
	CFRelease(search);
	
#else
	{
		// Earler 10.5 user SecKeychainSearchCreateFromAttributes
			// Construct a query.
		const char *cStringServerName = [server cStringUsingEncoding:NSUTF8StringEncoding];
		OSStatus status;
		SecKeychainAttribute attr[1];
		
		attr[0].tag = kSecServerItemAttr; 
		attr[0].length = strlen(cStringServerName); 
		attr[0].data = (void *)cStringServerName;
		
		SecKeychainAttributeList attrList = { .count = 1, .attr = attr };
		SecKeychainSearchRef search = NULL;
		
		status = SecKeychainSearchCreateFromAttributes(NULL, kSecInternetPasswordItemClass, &attrList, &search);
		NSMutableArray *users = NULL;
		if (status != noErr)
			return users;
		
		users = [NSMutableArray array];
		// iterate user accounts
		while (true)
		{
			SecKeychainItemRef item = NULL;
			status = SecKeychainSearchCopyNext(search, &item);
			if (status != noErr)
				break;
			KCSInternetUser *user = [[[KCSInternetUser alloc] initWithItemRef:item] autorelease];
			if (item != NULL)
				[users addObject:user];
		}// end while (true)
		CFRelease(search);
#endif
		return users;
}// end NSArray *keyChainUsersOfServer(NSString *server, NSString *path, SecAuthenticationType type)
	
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
#else
SecKeychainAttributeInfo makeQuery(void)
{
		// create query
	UInt32 tags[attrQueryCount];
	UInt32 formats[attrQueryCount];
		// account item
	tags[orderAccount] = kSecAccountItemAttr;
	formats[orderAccount] = CSSM_DB_ATTRIBUTE_FORMAT_STRING;
		// server name item
	tags[orderServerName] = kSecServerItemAttr;
	formats[orderServerName] = CSSM_DB_ATTRIBUTE_FORMAT_STRING;
		// server path item
	tags[orderServerPath] = kSecPathItemAttr;
	formats[orderServerPath] = CSSM_DB_ATTRIBUTE_FORMAT_STRING;
		// server security domain item
	tags[orderSecurityDomain] = kSecSecurityDomainItemAttr;
	formats[orderSecurityDomain] = CSSM_DB_ATTRIBUTE_FORMAT_STRING;
		// server type item
	tags[orderServerType] = kSecTypeItemAttr;
	formats[orderServerType] = CSSM_DB_ATTRIBUTE_FORMAT_STRING;
		// server protocol item
	tags[orderProtocol] = kSecProtocolItemAttr;
	formats[orderProtocol] = CSSM_DB_ATTRIBUTE_FORMAT_UINT32;
		// server port item
	tags[orderPort] = kSecPortItemAttr;
	formats[orderPort] = CSSM_DB_ATTRIBUTE_FORMAT_UINT32;
		// server authentication item
	tags[orderAuthType] = kSecAuthenticationTypeItemAttr;
	formats[orderAuthType] = CSSM_DB_ATTRIBUTE_FORMAT_UINT32;
		// server label item
	tags[orderKeychainName] = kSecLabelItemAttr;
	formats[orderKeychainName] = CSSM_DB_ATTRIBUTE_FORMAT_STRING;
		// server kind item
	tags[orderDescription] = kSecDescriptionItemAttr;
	formats[orderDescription] = CSSM_DB_ATTRIBUTE_FORMAT_STRING;
	
	SecKeychainAttributeInfo info;
	info.count = attrQueryCount;
	info.tag = tags;
	info.format = formats;

	return info;
}//end SecKeychainAttributeInfo makeQuery(void)
#endif
@end
