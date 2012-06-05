//
//  HTTPConnectionTests.m
//  NicoLiveAlert
//
//  Created by Чайка on 6/3/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "HTTPConnectionTests.h"
#import "HTTPConnection.h"

@implementation HTTPConnectionTests

- (void) test_01_RequestHeader
{
	NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://chajka.from.tv"]];
	NSLog(@"%@", [req allHTTPHeaderFields]);
}// end - (void) test_01_RequestHeader

@end
