//
//  NicoLiveAlertTests.m
//  NicoLiveAlertTests
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NicoLiveAlertTests.h"

@implementation NicoLiveAlertTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
	NSString *string1 = [NSString stringWithString:@"test1"];
	NSString *string2 = [NSString stringWithString:@"test2"];
	NSString *string3 = [NSString stringWithString:@"test3"];
	NSString *string4 = [NSString stringWithString:@"test4"];
	NSString *string5 = [NSString stringWithString:@"test5"];
	NSString *string6 = [NSString stringWithString:@"test6"];
	NSString *string7 = [NSString stringWithString:@"test2"];

	NSArray *array = [NSMutableArray arrayWithObjects:string1, string2, string3, string4, string5, string6, nil];
	BOOL found = [array containsObject:string7];
	STAssertTrue(found, @"different object but contains same can findable");
}

@end
