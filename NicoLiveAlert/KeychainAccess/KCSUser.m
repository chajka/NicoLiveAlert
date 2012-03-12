//
//  KCSUser.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "KCSUser.h"

@implementation KCSUser
#pragma mark construct / destruct
- (id) init
{
	self = [super init];
	if (self)
	{
		account = NULL;
		password = NULL;
		keyChain = NULL;
		keyChainItem = NULL;
		syncronized = NO;
	}
	return self;
}// - (id) init

#if __has_feature(objc_arc) == 0
- (void) dealloc
{
	// relase account
    if (account != NULL)
		[account release];
	// relase password
	if (password != NULL)
		[password release];
	// no need care synced
	[super dealloc];
}// end - (void) dealloc
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
}// end - (void) setAccount:(NSString *)account_
#pragma mark -
#pragma mark password’s accessor
- (NSString *) password
{
	return password;
}// - (NSString *) account

- (void) setPassword:(NSString *)_password
{
#if __has_feature(objc_arc) == 1
	password = _password;
#else
	if (password != NULL)
		[password autorelease];
	password = [_password copy];
#endif
	syncronized = NO;
}// end - (void) setPassword:(NSString *)password

#pragma mark -
#pragma mark keyChain’s accessor
//@synthesize keyChain
- (SecKeychainRef) keyChain
{
	return keyChain;
}// end - (SecKeychainRef) keyChain

- (void) setKeyChain:(SecKeychainRef)keyChain_
{
#if __has_feature(objc_arc) == 0
	if (keyChain != NULL)
		CFRelease(keyChain);
#endif
	keyChain = keyChain;
}// end - (void) setKeyChain:(SecKeychainRef)keyChain_

#pragma mark -
#pragma mark keyChain’s accessor
//@synthesize keyChain
- (SecKeychainItemRef) keyChainItem
{
	return keyChainItem;
}// end - (SecKeychainRef) keyChain

- (void) setKeyChainItem:(SecKeychainItemRef)keyChainItem_
{
#if __has_feature(objc_arc) == 0
	if (keyChainItem_ != NULL)
		CFRelease(keyChainItem);
#endif
	keyChainItem = keyChainItem_;
}// end - (void) setKeyChain:(SecKeychainItemRef)keyChainItem_

@end

#pragma mark -

@implementation KCSInternetUser
#pragma mark construct / destruct
- (id) init
{
	self = [super init];
	if (self)
	{
		keyChain = NULL;
		serverName = NULL;
		serverPath = NULL;
		securityDomain = NULL;
		protocol = kSecProtocolTypeAny;
		authType = kSecAuthenticationTypeAny;
		port = 0;
	}// end if self
	return self;
}// end - (id) init

- (id) initWithURI:(NSURL *)URI
{
	self = [super init];
	if (self)
	{
		account = [[URI user] copy];
		serverName = [[URI host] copy];
		serverPath = [[URI path] copy];
		securityDomain = [[URI host] copy];
		if ([[URI scheme] isEqualToString:@""] == NO)
		{
			NSDictionary *schemeDict = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithInteger:kSecProtocolTypeHTTP], @"http", 
										[NSNumber numberWithInteger:kSecProtocolTypeHTTPS], @"https",
										[NSNumber numberWithInteger:kSecProtocolTypeFTP],@"ftp", 
										[NSNumber numberWithInteger:kSecProtocolTypePOP3],@"pop3", 
										[NSNumber numberWithInteger:kSecProtocolTypeSMTP], @"smtp", 
										[NSNumber numberWithInteger:kSecProtocolTypeAFP],@"afp", 
										[NSNumber numberWithInteger:kSecProtocolTypeSMB],@"smb", 
										nil];
			NSLog(@"%@", [URI scheme]);
			NSLog(@"%@",[schemeDict valueForKey:[URI scheme]]);
			protocol = [[schemeDict valueForKey:[URI scheme]] integerValue];
			if (protocol == 0)
				protocol = kSecProtocolTypeAny;
		}// end if scheme
		authType = kSecAuthenticationTypeAny;
		port = [[URI port] integerValue];
	}// end if self
	return self;
}// end - (id) initWithURI:(NSURL *)URI

#if __has_feature(objc_arc) == 0
- (void) dealloc
{
	if (serverName)
		[serverName release];
	if (serverPath)
		[serverPath release];
	if (securityDomain)
		[securityDomain release];
	[super dealloc];
}// end - (void) dealloc
#endif

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
}// end - (void) setPort:(UInt16)port_

#pragma mark -
#pragma mark password’s accessor
- (NSString *) password:(OSStatus *)error
{
	*error = noErr;
	if (syncronized)
		return password;
	
	// make cstring & length data;
	const char *strAccountName = [account UTF8String];
	UInt32		lenAccountName = [account length];
	const char *strServerName = [serverName UTF8String];
	UInt32		lenServerName = [serverName length];
	const char *strSecurityDomain = [securityDomain UTF8String];
	UInt32		lenSecurityDomain = [securityDomain length];
	const char *strServerPath = [serverPath UTF8String];
	UInt32		lenServerPath = [serverPath	length];
	// returned password data
	const char *strPassword = NULL;
	UInt32 lenPassword;
	
	// fetch password from keychain
	*error = SecKeychainFindInternetPassword(NULL, lenServerName, strServerName, lenSecurityDomain, strSecurityDomain, lenAccountName, strAccountName, lenServerPath, strServerPath, port, protocol, authType, &lenPassword, (void **)&strPassword, NULL);
	
	// check err 
	if (*error == noErr)
	{
		NSData *data = [[NSData alloc] initWithBytes:strPassword length:lenPassword];
		password = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	
	return password;
}// end - (NSString *) getPassword:(OSStatus  *)error

@end