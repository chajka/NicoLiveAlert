//
//  KCSUserTsts.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "KCSUserTsts.h"
#import "KCSUser.h"

#define USERNAME	@"chajka.niconico@gmail.com"
#define PASSWORD	@"somepassword"
#define SERVER		@"secure.nicovideo.jp"
#define SERVPATH	@""
#define SECDOMAIN	@"secure.nicovideo.jp"
#define URI			@"https://chajka@secure.nicovideo.jp/"
#define URIUSERNAME	@"chajka"

@implementation KCSUserTsts

- (void) setUp
{
    [super setUp];
    
    // Set-up code here.
}// end - (void) setUp

- (void) tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}// end - (void) tearDown

- (void) testInitializeKCSUser
{
		// allocation test
	KCSUser *user = [[KCSUser alloc] init];

		// check initial value
	STAssertNotNil(user, @"Genarate KCSUser instance failed");
	NSString *username = [user account];
	STAssertNil(username, @"Initial accout is not NILL");
	NSString *password = [user password];
	STAssertNil(password, @"Initial password is not NILL");
	SecKeychainRef keyChain = [user keyChain];
	STAssertNil((__bridge_transfer id)keyChain, @"Initial keyChain is not NILL");
	SecKeychainItemRef itemRef = [user keyChainItem];
	STAssertNil((__bridge_transfer id)itemRef, @"Inital keyChainItem is not NILL");
	
		// set get value check
	[user setAccount:USERNAME];
	username = [user account];
	STAssertEquals(USERNAME, username, @"Set and get user name is not match");
	[user setPassword:PASSWORD];
	password = [user password];
	STAssertEquals(PASSWORD, password, @"Set and get password is not match");	
}// end - (void) testInitializeKCSUser

- (void) testInitializeKCSInternetUser
{
		// allocation test
	KCSInternetUser *user = [[KCSInternetUser alloc] init];

		// check initial value (inherited)
	STAssertNotNil(user, @"Generate KCSInternetUser instance failed");
	NSString *username = [user account];
	STAssertNil(username, @"Initial accout is not NILL");
	NSString *password = [user password];
	STAssertNil(password, @"Initial password is not NILL");

		// check inital value (class sepecific)
	NSString *server = [user serverName];
	STAssertNil(server, @"Initial server name is not NILL");
	NSString *path = [user serverPath];
	STAssertNil(path, @"Initial server path is not NILL");
	NSString *domain = [user securityDomain];
	STAssertNil(domain, @"Initial domain is not NILL");
	SecProtocolType protocol = [user protocol];
	STAssertTrue((protocol == kSecProtocolTypeAny), @"Initial protocol is not kSecProtocolTypeAny");
	SecAuthenticationType auth = [user authType];
	STAssertTrue((auth == kSecAuthenticationTypeAny), @"Initial authentication type is not kSecAuthenticationTypeAny");

		// set get value check (inherited)
	[user setAccount:USERNAME];
	username = [user account];
	STAssertEquals(USERNAME, username, @"Set and get user name is not match");
	[user setPassword:PASSWORD];
	password = [user password];
	STAssertEquals(PASSWORD, password, @"Set and get password is not match");

		// set get value check (class specific)
	[user setServerName:SERVER];
	server = [user serverName];
	STAssertEquals(server, SERVER, @"Set and get server name is not match");
	[user setServerPath:SERVPATH];
	path = [user serverPath];
	STAssertEquals(path, SERVPATH, @"Set and get server path is not match");
	[user setSecurityDomain:SERVER];
	domain = [user securityDomain];
	STAssertEquals(domain, SERVER, @"Set and get sercurity domain is not match");
	[user setProtocol:kSecProtocolTypeHTTP];
	protocol = [user protocol];
	STAssertTrue((protocol == kSecProtocolTypeHTTP), @"Set and Get protocol is not match");
	[user setAuthType:kSecAuthenticationTypeHTMLForm];
	auth = [user authType];
	STAssertTrue((auth == kSecAuthenticationTypeHTMLForm), @"Set and Get authentication type is not match");

}// end - (void) testInitializeKCSInternetUser

- (void) testInitializers
{
	KCSInternetUser *user = [[KCSInternetUser alloc] initWithURI:[NSURL URLWithString:URI]];
	STAssertNotNil(user, @"KCSInternetUser allocation failed");
	NSString *username = [user account];
	STAssertTrue([username isEqualToString:URIUSERNAME], @"username and account is not match");
	NSString *server = [user serverName];
	STAssertTrue([server isEqualToString:SERVER], @"server and serverName is not match");
	NSString *path = [user serverPath];
	STAssertTrue([path isEqualToString:@"/"], @"Path and serverPath is not match");
	NSString *domain = [user securityDomain];
	STAssertTrue([domain isEqualToString:SECDOMAIN], @"Domain and securityDomain is not match");
	SecProtocolType protocol = [user protocol];
	STAssertTrue((protocol == kSecProtocolTypeHTTPS), @"protocol and protocol is not match");
}// end - (void) testInitializers

- (void)testExample
{
//    STFail(@"Unit tests are not implemented yet in NicoLiveAlertTests");
}

@end
