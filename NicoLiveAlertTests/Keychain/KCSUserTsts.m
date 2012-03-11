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

- (void) initializeKCSUserTest
{
	KCSUser *user = [[KCSUser alloc] init];
	STAssertNotNil(user, @"Genarate KCSUser instance failed");
	NSString *username = [user account];
	STAssertNil(username, @"Fail initial accout is not NILL");
	NSString *password = [user password];
	STAssertNil(password, @"Fail initial password is not NILL");
	[user setAccount:USERNAME];
	username = [user account];
	STAssertEquals(USERNAME, username, @"Fail set and get user name is not match");
	[user setPassword:PASSWORD];
	password = [user password];
	STAssertEquals(PASSWORD, password, @"Fail set and get password is not match");	
}// end - (void) initializeTest

- (void)testExample
{
//    STFail(@"Unit tests are not implemented yet in NicoLiveAlertTests");
}

@end
