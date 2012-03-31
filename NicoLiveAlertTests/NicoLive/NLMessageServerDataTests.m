//
//  NLMessageServerDataTests.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/31/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLMessageServerDataTests.h"
#import "NLMessageServerData.h"

@implementation NLMessageServerDataTests

- (void) test_01_allocation
{
	NLMessageServerData *data = [[NLMessageServerData alloc] init];
	STAssertNotNil(data, @"NLMessageServerData allocation fail");
	STAssertNotNil([data serveName], @"Server's name parse fail");
	STAssertNotNil([data threadID], @"Server's thread ID parse fail");
	STAssertTrue(([data port] != 0), @"Server's Port no parse fail");
	STAssertNotNil([data hashID], @"Server's hash id parse fail");
	
}// end - (void) test_01_allocation

@end
