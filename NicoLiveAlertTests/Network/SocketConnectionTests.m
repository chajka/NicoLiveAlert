//
//  SocketConnectionTests.m
//  NicoLiveAlert
//
//  Created by Чайка on 4/2/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "SocketConnectionTests.h"

@implementation SocketConnectionTests

- (void) setUp
{
	dataBuffer = nil;
}// end - (void) setUp

- (void) tearDown
{
#if __has_feature(objc_arc) == 0
	if (dataBuffer != nil)
		[dataBuffer release];
#endif
}// end - (void) tearDown

- (void) test_01_allocation
{
	SocketConnection *socket = [[SocketConnection alloc] init];
	STAssertNotNil(socket, @"socket allocate fail");
}// end - (void) test_01_allocation

- (void) test_02_init
{
	ms = [[NLMessageServerInfo alloc] init];
	STAssertNotNil(ms, @"message server allocate fail");
	SocketConnection *socket = [[SocketConnection alloc] init];
	STAssertNotNil(socket, @"socket allocate fail");

	[socket setServer:[ms serveName]];
	STAssertEquals([socket server], [ms serveName], @"server name is not mutch");

	[socket setPort:[ms port]];
	STAssertTrue(([ms port] == [socket port]) , @"port number is not mutch");
	
	[socket setStreamEventDelegate:self];
	STAssertEquals([socket streamEventDelegate], self, @"class name is not mutch");

	[socket setStreamDelegate:self];
	STAssertEquals([socket streamDelegate], self, @"socket is invalid");
}// end - (void) test_02_initWith

- (void) test_03_initWith
{
	currentTestNo = 3;
	ms = [[NLMessageServerInfo alloc] init];
	STAssertNotNil(ms, @"message server allocate fail");
	SocketConnection *socket = [[SocketConnection alloc] initWithServer:[ms serveName] andPort:[ms port] direction:SCDirectionBoth];
	STAssertNotNil(socket, @"socket allocate fail");

	[socket setStreamEventDelegate:self];
	STAssertEquals([socket streamEventDelegate], self, @"socket is invalid");

	BOOL success = [socket connect];
	STAssertTrue(success, @"connection fail");
}// end - (void) test_02_connection

#pragma mark -
#pragma mark SocketConnectionDelegate
- (void) streamEventHasBytesAvailable:(NSStream *)stream
{
	if (currentTestNo == 2)
	{
		
	}// end if
}// end - (void) NSStreamEventHasBytesAvailable:(NSStream *)stream

- (void) streamEventHasSpaceAvailable:(NSStream *)stream
{
	if (currentTestNo == 2)
	{
		NSString *ticket = [NSString stringWithFormat:TICKET, [ms thread]];
		[(NSOutputStream *)stream write:(const uint8_t *)[ticket UTF8String] maxLength:[ticket length]];
	}
}// end - (void) streamEventHasSpaceAvailable:(NSStream *)stream

- (void) streamEventErrorOccurred:(NSStream *)stream
{
}// end - (void) streamEventErrorOccurred:(NSStream *)stream

#pragma mark SocketConnectionDelegate (optional)
- (void) streamEventOpenCompleted:(NSStream *)stream
{
}// end - (void) streamEventOpenCompleted:(NSStream *)stream

- (void) streamEventEndEncountered:(NSStream *)stream
{
}// end - (void) streamEventEndEncountered:(NSStream *)stream

- (void) streamEventNone:(NSStream *)stream
{
}// end - (void) streamEventNone:(NSStream *)stream
@end
