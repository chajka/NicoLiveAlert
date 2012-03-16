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
#define URI2		@"https://secure.nicovideo.jp"
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
}// end - (void) testInitializeKCSUser

- (void) testGetSetValue
{
	KCSUser *user = [[KCSUser alloc] init];
	
		// set get account value check
	[user setAccount:USERNAME];
	NSString *username = [user account];
	STAssertEquals(USERNAME, username, @"Set and get user name is not match");
}// end - (void) testGetSetValue

#define KEYCHAINPATH	@"~/Documents/tmpKeyChain"
- (void) testCreateDeleteKeychain
{
	OSStatus error;

		// create keychain with password
	SecKeychainRef kc = [KCSUser newKeychain:KEYCHAINPATH withPassword:@"testpassword" orPrompt:FALSE error:&error];
	STAssertTrue((kc != Nil), @"new keychainRef is not allocated");
	STAssertTrue((error == noErr), @"keychain create error = %d", error);
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *fullpath = [KEYCHAINPATH stringByExpandingTildeInPath];
	BOOL keyisExist = [fm fileExistsAtPath:fullpath];
	STAssertTrue(keyisExist, @"Create KeyChain Failed");

		// delete keychain
	error = [KCSUser deleteKeychain:kc];
	STAssertTrue((error == noErr), @"Delete Keychain Failed");
	keyisExist = [fm fileExistsAtPath:fullpath];
	STAssertFalse(keyisExist, @"Delete KeyChain file Failed");

		// create keychain with prompt
	kc = [KCSUser newKeychain:KEYCHAINPATH withPassword:@"testpassword" orPrompt:TRUE error:&error];
	STAssertTrue((kc != Nil), @"new keychainRef is not allocated");
	STAssertTrue((error == noErr), @"keychain create error = %d", error);
	fm = [NSFileManager defaultManager];
	fullpath = [KEYCHAINPATH stringByExpandingTildeInPath];
	keyisExist = [fm fileExistsAtPath:fullpath];
	STAssertTrue(keyisExist, @"Create KeyChain Failed");
	
		// delete keychain (again)
	error = [KCSUser deleteKeychain:kc];
	STAssertTrue((error == noErr), @"Delete Keychain Failed");
	keyisExist = [fm fileExistsAtPath:fullpath];
	STAssertFalse(keyisExist, @"Delete KeyChain file Failed");
}// end - (void) testCreateKeychain

@end
