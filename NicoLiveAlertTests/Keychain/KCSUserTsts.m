//
//  KCSUserTsts.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "KCSUserTsts.h"
#import "KCSUser.h"

#define USERNAME		@"chajka.niconico@gmail.com"
#define PASSWORD		@"somepassword"
#define SERVER			@"chajka.from.tv"
#define SERVPATH		@""
#define SECDOMAIN		@"secure.nicovideo.jp"
#define URI				@"https://chajka@secure.nicovideo.jp/"
#define URI2			@"https://secure.nicovideo.jp"
#define URIUSERNAME		@"chajka"
#define KEYCHAINNAME	@"Test Keychain"
#define KEYCHAINKIND	@"Web form password"

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

- (void) test_01_InitializeKCSUser
{
		// allocation test
	KCSUser *user = [[KCSUser alloc] init];

		// check initial value
	STAssertNotNil(user, @"Genarate KCSUser instance failed");
	NSString *username = [user account];
	STAssertNil(username, @"Initial accout is not NILL");
	NSString *password = [user password];
	STAssertNil(password, @"Initial password is not NILL");
	SecKeychainRef keychain = [user keychain];
	STAssertNil((__bridge_transfer id)keychain, @"Initial keychain is not NILL");
	SecKeychainItemRef itemRef = [user keychainItem];
	STAssertNil((__bridge_transfer id)itemRef, @"Inital keychainItem is not NILL");
}// end - (void) testInitializeKCSUser

- (void) test_02_GetSetValue
{
	KCSUser *user = [[KCSUser alloc] init];
	
		// set get account value check
	[user setAccount:USERNAME];
	NSString *username = [user account];
	STAssertEquals(USERNAME, username, @"Set and get user name is not match");

		// set get keychain name check
	[user setKeychainName:KEYCHAINNAME];
	NSString *keychainname = [user keychainName];
	STAssertEquals(KEYCHAINNAME, keychainname, @"Set and get keychain name is not match");

		// set get keychain name check
	[user setKeychainKind:KEYCHAINKIND];
	NSString *keychainkind = [user keychainKind];
	STAssertEquals(KEYCHAINKIND, keychainkind, @"Set and get keychain kind is not match");
	
}// end - (void) testGetSetValue

#define keychainPATH	@"~/Documents/tmpkeychain"
- (void) _test_03_CreateDeletekeychain
{
	OSStatus error;

		// create keychain with password
	SecKeychainRef kc = [KCSUser newkeychain:keychainPATH withPassword:@"testpassword" orPrompt:FALSE error:&error];
	STAssertTrue((kc != Nil), @"new keychainRef is not allocated");
	STAssertTrue((error == noErr), @"keychain create error = %d", error);
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *fullpath = [keychainPATH stringByExpandingTildeInPath];
	BOOL keyisExist = [fm fileExistsAtPath:fullpath];
	STAssertTrue(keyisExist, @"Create keychain Failed");

		// delete keychain
	error = [KCSUser deletekeychain:kc];
	STAssertTrue((error == noErr), @"Delete keychain Failed");
	keyisExist = [fm fileExistsAtPath:fullpath];
	STAssertFalse(keyisExist, @"Delete keychain file Failed");

		// create keychain with prompt
	kc = [KCSUser newkeychain:keychainPATH withPassword:@"testpassword" orPrompt:TRUE error:&error];
	STAssertTrue((kc != Nil), @"new keychainRef is not allocated");
	STAssertTrue((error == noErr), @"keychain create error = %d", error);
	fm = [NSFileManager defaultManager];
	fullpath = [keychainPATH stringByExpandingTildeInPath];
	keyisExist = [fm fileExistsAtPath:fullpath];
	STAssertTrue(keyisExist, @"Create keychain Failed");
	
		// delete keychain (again)
	error = [KCSUser deletekeychain:kc];
	STAssertTrue((error == noErr), @"Delete keychain Failed");
	keyisExist = [fm fileExistsAtPath:fullpath];
	STAssertFalse(keyisExist, @"Delete keychain file Failed");
}// end - (void) testCreatekeychain

@end
