//
//  NLMessageServerInfoTests.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/31/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLMessageServerInfoTests.h"
#import "NLMessageServerInfo.h"

@implementation NLMessageServerInfoTests

- (void) test_01_allocation
{
	NLMessageServerInfo *data = [[NLMessageServerInfo alloc] init];
	STAssertNotNil(data, @"NLMessageServerInfo allocation fail");
	STAssertNotNil([data serveName], @"Server's name parse fail");
	STAssertNotNil([data thread], @"Server's thread ID parse fail");
	STAssertTrue(([data port] != 0), @"Server's Port no parse fail");	
}// end - (void) test_01_allocation

@end
