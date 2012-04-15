//
//  NLProgramList.m
//  NicoLiveAlert
//
//  Created by Чайка on 4/4/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLProgramList.h"

@interface NLProgramList ()
- (void) checkProgram:(NSString *)progInfo withDate:(NSDate *)date;
- (void) checkConnectionActive;
- (void) checkConnectionRised;
@end

@implementation NLProgramList
@synthesize watchList;
@synthesize activePrograms;
@synthesize watchOfficial;
NSMutableData		*programListDataBuffer;
BOOL sendrequest;

- (id) init
{
	self = [super init];
	if (self)
	{
		programListSocket = NULL;
		watchList = NULL;
		serverInfo = NULL;
		lastTime = NULL;
		keepAliveMonitor = NULL;
		connectionRiseMonitor = NULL;
		programListDataBuffer = NULL;
		sendrequest = NO;
		isOfficial = NO;
		watchOfficial = YES;
	}// end if self
	return self;
}// end - (id) init

- (BOOL) startListen
{
	BOOL success = NO;
	serverInfo = [[NLMessageServerInfo alloc] init];
	if (serverInfo == NULL)
		return success;
	// end if cannot correct server information.

	programListSocket = [[SocketConnection alloc] initWithServer:[serverInfo serveName] andPort:[serverInfo port] direction:SCDirectionBoth];
	[programListSocket setStreamEventDelegate:self];
	success = [programListSocket connect];
	keepAliveMonitor = [NSTimer scheduledTimerWithTimeInterval:ConnectionAliveCheckInterval target:self selector:@selector(checkConnectionActive) userInfo:NULL repeats:YES];
	[keepAliveMonitor fire];

	return success;
}// end - (void) startListen

- (void) stopListen
{
	[keepAliveMonitor invalidate];
	if (programListSocket == NULL)
		return;
	// end if not connection

	[programListSocket disconnect];
}// end - (void) stopListen

#pragma mark -
#pragma mark internal
- (void) checkProgram:(NSString *)progInfo withDate:(NSDate *)date
{
	NSArray *program = [progInfo componentsSeparatedByString:dataSeparator];
	if ((watchOfficial == YES) && ([program count] == 2))
	{
		[activePrograms addOfficialProgram:[program objectAtIndex:offsetLiveNo] withDate:date];
		NSLog(@"%@", progInfo);
		return;
	}

	for (NSString *prog in program)
	{		// process official
		if (isOfficial)
		{
			[activePrograms addOfficialProgram:[program objectAtIndex:offsetLiveNo] withDate:date];
			NSLog(@"%@", progInfo);
			isOfficial = NO;
		}// end is Official
			// check official
		if ((watchOfficial == YES) && ([prog isEqualToString:liveOfficialString] == YES))
			isOfficial = YES;
		if ([watchList valueForKey:prog] != NULL)
		{
			[activePrograms addUserProgram:[program objectAtIndex:offsetLiveNo] withDate:date community:[program objectAtIndex:offsetCommuCh] owner:[program objectAtIndex:offsetOwner]];
			NSLog(@"%@", progInfo);
		}
	}// end for
}// end - (void) checkProgram:(NSString *)progInfo

- (void) checkConnectionActive
{
	NSTimeInterval diff = [lastTime timeIntervalSinceNow];
	if (diff > -ServerTimeOut)
		return;
	// end if check connection is alive

		// maybe timeout stop self and start reactive checker
	[[NSNotificationCenter defaultCenter] postNotificationName:NLNotificationConnectionLost object:NULL];
	connectionRiseMonitor = [NSTimer scheduledTimerWithTimeInterval:ConnectionReactiveCheckInterval target:self selector:@selector(checkConnectionRised) userInfo:NULL repeats:YES];
	[connectionRiseMonitor fire];
	[keepAliveMonitor invalidate];
}// end - (void) checkConnectionActive

- (void) checkConnectionRised
{
	NSURL *ping = [NSURL URLWithString:MSQUERYAPI];
	NSURLResponse *resp = NULL;
	NSData *data = [HTTPConnection HTTPData:ping response:&resp];
	if ([data length] == 0)
		return;

	[[NSNotificationCenter defaultCenter] postNotificationName:NLNotificationConnectionRised object:NULL];
	[connectionRiseMonitor invalidate];
}// end - (void) checkConnectionRised

#pragma mark -
#pragma mark StreamEventDelegate
- (void) streamEventHasBytesAvailable:(NSStream *)stream
{
	NSInputStream *iStream = (NSInputStream *)stream;
	uint8_t oneByte;
	NSUInteger actuallyRead = 0;
	if (programListDataBuffer == NULL)
		programListDataBuffer = [[NSMutableData alloc] init];
	// end if data buffer is cleard

	actuallyRead = [iStream read:&oneByte maxLength:1U];
	if (actuallyRead == 1)
		[programListDataBuffer appendBytes:&oneByte length:1];
	// end if read

		// check databyte is not terminator
	if (oneByte != '\0')
		return;

	if (lastTime != NULL)
		[lastTime release];
		// store last data recieve time;
	lastTime = [[NSDate alloc] init];
		// databyte is terminator
	NSString *msg = [[NSString alloc] initWithData:programListDataBuffer encoding:NSUTF8StringEncoding];
	OnigRegexp *chat = [OnigRegexp compile:@"<chat.*>(.*)</chat>"];
	OnigResult *chatResult = [chat search:msg];
		if (chatResult != NULL)
		{
			OnigRegexp *date = [OnigRegexp compile:@"date=\"(\\d+)\""];
			OnigResult *dateResult = [date search:msg];
			NSDate *broadcastDate = [NSDate dateWithTimeIntervalSince1970:[[dateResult stringAt:1] longLongValue]];
			[self checkProgram:[NSString stringWithFormat:liveNoAppendFormat,[chatResult stringAt:1]] withDate:broadcastDate];
		}
#if __has_feature(objc_arc) == 0
	if (msg != NULL) [msg release];
	[programListDataBuffer release];
#endif
	programListDataBuffer = NULL;
}// end - (void) NSStreamEventHasBytesAvailable:(NSStream *)stream

- (void) streamEventHasSpaceAvailable:(NSStream *)stream
{
	if ((sendrequest == NO) && ([programListSocket isOutputStream:stream] == YES))
	{
		NSInteger byteToWrite = 0;
		NSString *request = [NSString stringWithFormat:REQUESTFORMAT,[serverInfo thread]];
		byteToWrite = [(NSOutputStream *)stream write:(uint8_t *)[request UTF8String] maxLength:[request length]];
		
		if (byteToWrite == [request length])
			sendrequest = YES;
	}
}// end - (void) streamEventHasSpaceAvailable:(NSStream *)stream

- (void) streamEventErrorOccurred:(NSStream *)stream
{
}// end - (void) streamEventErrorOccurred:(NSStream *)stream

#pragma mark StreamEventDelegate (optional)
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
