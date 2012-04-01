//
//  NLAccountTests.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/25/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLAccountTests.h"
#import "KCSUser.h"

#define SERVER	@"secure.nicovideo.jp"
#define PATH	@"/"

@implementation NLAccountTests

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

- (void) test_01_allocationFail
{
	NLAccount *user = NULL;
	STAssertNil(user, @"stack variable initialize failed");
	user = [[NLAccount alloc] initWithAccount:@"dummyAccount@gmail.com" andPassword:@"dummyPassword"];
	STAssertNil(user, @"dummy account but object allocated");
}// end - (void) test_01_allocationFail

- (void) test_02_allocation
{
	NSArray *users = [KCSInternetUser usersOfAccountsForServer:SERVER path:PATH forAuthType:kSecAuthenticationTypeAny inKeychain:NULL];
	STAssertNotNil(users, @"fetch user failed");

	NLAccount *account = NULL;
	for (KCSInternetUser *user in users)
	{
			// check internet keychain (again)
		NSString *userid = [user account];
		STAssertNotNil(userid, @"User ID fetch fail");
		NSString *password = [user password];
			// allocation check
		STAssertNotNil(password, @"password fetch fail");
		account = [[NLAccount alloc] initWithAccount:userid andPassword:password];
		STAssertNotNil(account, @"NLAccount initialize Fail");
			// property check
		STAssertNotNil([account mailaddr], @"property mail addr is NULL");
		STAssertNotNil([account password], @"property password is NULL");
		STAssertNotNil([account username], @"property username is NULL");
		STAssertNotNil([account userid], @"property useridis NULL");
		STAssertNotNil([account channels], @"property channels is NULL");
		STAssertNotNil([account userid], @"property password is NULL");
	}// end for
	account = NULL;
}// end - (void) test_01_allocation

@end
