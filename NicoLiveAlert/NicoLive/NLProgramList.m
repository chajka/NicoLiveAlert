//
//  NLProgramList.m
//  NicoLiveAlert
//
//  Created by Чайка on 4/4/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLProgramList.h"

@interface NLProgramList ()
- (void) restartKeepAliveMonitor;
- (void) restartConnectionRiseMonitor;
- (void) checkProgram:(NSString *)progInfo withDate:(NSDate *)date;
- (void) checkConnectionActive:(NSTimer *)theTimer;
- (void) checkConnectionRised:(NSTimer *)theTimer;
@end

@implementation NLProgramList
@synthesize watchList;
@synthesize activePrograms;
@synthesize watchOfficial;
@synthesize enableAutoOpen;
NSMutableData		*programListDataBuffer;
BOOL sendrequest;
OnigRegexp			*programRegex;
OnigRegexp			*maintRegex;
OnigRegexp			*checkstatus;

- (id) init
{
	self = [super init];
	if (self)
	{
		programListSocket = NULL;
		watchList = NULL;
		serverInfo = NULL;
		center = [NSNotificationCenter defaultCenter];
#if __has_feature(objc_arc) == 0
		[center retain];
#endif
		lastTime = NULL;
		checkRiseInterval = ConnectionReactiveCheckInterval;
		keepAliveMonitor = NULL;
		connectionRiseMonitor = NULL;
		programListDataBuffer = NULL;
		sendrequest = NO;
		isOfficial = NO;
		watchOfficial = YES;
		connected = NO;
		programRegex = [OnigRegexp compile:ProgramNoRegex];
		maintRegex = [OnigRegexp compile:MaintRegex];
		checkstatus = [OnigRegexp compile:RiseConnectRegex];
		[center addObserver:self selector:@selector(startListen) name:NLNotificationConnectionRised object:NULL];
		[center addObserver:self selector:@selector(stopListen) name:NLNotificationConnectionLost object:NULL];
#if __has_feature(objc_arc) == 0
		[programRegex retain];
		[checkstatus retain];
#endif
	}// end if self
	return self;
}// end - (id) init

- (void) dealloc
{
	[programListSocket disconnect];
	if ([keepAliveMonitor isValid])			[keepAliveMonitor invalidate];
	if ([connectionRiseMonitor isValid])	[connectionRiseMonitor invalidate];
#if __has_feature(objc_arc) == 0
	if (watchList != NULL)					[watchList release];
	if (serverInfo != NULL)					[serverInfo release];
	if (center != NULL)						[center release];
	if (lastTime != NULL)					[lastTime release];
	if (programListSocket != NULL)			[programListSocket release];
	if (programRegex != NULL)				[programRegex release];

	[super dealloc];
#endif
}// end - (void) dealloc

#pragma mark -
#pragma mark controll methods

- (void) kick
{
	[self startListen];
}// end - (void) kick

- (void) halt
{
	[programListSocket disconnect];
#if __has_feature(objc_arc) == 0
	[programListSocket release];
#endif
	programListSocket = NULL;
	connected = NO;	
}// end - (void) halt

- (BOOL) startListen
{
	BOOL success = NO;
	if ([connectionRiseMonitor isValid] == YES)
	{
		[connectionRiseMonitor invalidate];
		connectionRiseMonitor = NULL;
	}
	serverInfo = [[NLMessageServerInfo alloc] init];
	if (serverInfo == NULL)
		return success;
	// end if cannot correct server information.

	programListSocket = [[SocketConnection alloc] initWithServer:[serverInfo serveName] andPort:[serverInfo port] direction:SCDirectionBoth];
	[programListSocket setStreamEventDelegate:self];
	if ([programListSocket connect] == YES)
	{
		success = YES;
		[self restartKeepAliveMonitor];
		[keepAliveMonitor fire];
	}// end if connect to program server success

#if __has_feature(objc_arc) == 0
	if (lastTime != NULL)
		[lastTime release];
#endif
	lastTime = [[NSDate alloc] init];

	return success;
}// end - (void) startListen

- (BOOL) restartListen
{
	BOOL success = NO;
	
	programListSocket = [[SocketConnection alloc] initWithServer:[serverInfo serveName] andPort:[serverInfo port] direction:SCDirectionBoth];
	[programListSocket setStreamEventDelegate:self];
	if ([programListSocket connect] == YES)
	{
		success = YES;
		if ([connectionRiseMonitor isValid] == YES)
		{
			[connectionRiseMonitor invalidate];
			connectionRiseMonitor = NULL;
		}
		[self restartKeepAliveMonitor];
		[keepAliveMonitor fire];
	}// end if connect to program server success
#if __has_feature(objc_arc) == 0
	if (lastTime != NULL)
		[lastTime release];
#endif
	lastTime = [[NSDate alloc] init];
	
	return success;
}// end - (void) restartListen

- (void) stopListen
{		//
	[self halt];

		// stop & reset keepAliveMonitor
	if ([keepAliveMonitor isValid] == YES)
	{
		[keepAliveMonitor invalidate];
		keepAliveMonitor = NULL;
	}
	[self restartConnectionRiseMonitor];
	[connectionRiseMonitor fire];

#if __has_feature(objc_arc) == 0
	if (programListSocket != NULL)
		[programListSocket release];
	// end if not connection
	if (serverInfo != NULL)
		[serverInfo release];
	// end if for serverInfo reallocate
#endif
	serverInfo = NULL;
	connected = NO;
}// end - (void) stopListen

#pragma mark -
#pragma mark internal
#pragma mark program sieve method
- (void) checkProgram:(NSString *)progInfo withDate:(NSDate *)date
{
	NSArray *program = [progInfo componentsSeparatedByString:dataSeparator];
		// check official program
	if ((watchOfficial == YES) && ([program count] == 2))
	{
NSLog(@"WatchOfficial %@",progInfo);
		NSString *live = [program objectAtIndex:offsetLiveNo];
		[activePrograms addOfficialProgram:live withDate:date];
		return;
	}

	NSString *live = NULL;
		// iterate program info
	for (NSString *prog in program)
	{
		live = [program objectAtIndex:offsetLiveNo];
			// process official
		if (isOfficial == YES)
			isOfficial = NO;

			// check official channel
		if ((watchOfficial == YES) && ([prog isEqualToString:liveOfficialString] == YES))
		{
NSLog(@"WatchOfficial Channel %@",progInfo);
			isOfficial = YES;
			[activePrograms addOfficialProgram:live withDate:date];
			break;
		}
			// check watchlist
		NSNumber *needOpen = [watchList valueForKey:prog];
		if (needOpen != NULL)
		{		// found in watchlist or memberd communities program
NSLog(@"watchUser %@",progInfo);
			if (isOfficial == YES)
				[activePrograms addOfficialProgram:live withDate:date];
			else
				[activePrograms addUserProgram:live withDate:date community:[program objectAtIndex:offsetCommuCh] owner:[program objectAtIndex:offsetOwner]];
			// end if Official program or User program
			
				// check mutch is program number
			OnigResult *isPorgram = [programRegex search:prog];
			if (isPorgram != NULL)
				[center postNotification:[NSNotification notificationWithName:NLNotificationOpenByLiveNo object:prog]];

				// check auto open of this program
			if (enableAutoOpen == YES)
			{
				BOOL autoOpen = [needOpen boolValue];
				if (autoOpen == YES)
				{	// open program
					NSURL *liveURL = [NSURL URLWithString:[NSString stringWithFormat:URLFormatLive, live]];
					[center postNotificationName:NLNotificationAutoOpen object:liveURL];
				}// end if program is auto open
			}// end if need check auto opend program

			break;
		}// end if program found
	}// end foreach program information items

}// end - (void) checkProgram:(NSString *)progInfo

#pragma mark -
#pragma mark timer control methods
- (void) restartKeepAliveMonitor
{		// stop & reset keepAliveMonitor
	if ([keepAliveMonitor isValid] == YES)
	{
		[keepAliveMonitor invalidate];
		keepAliveMonitor = NULL;
	}// end if keepAliveMonitor is running
	
		// re-setup keepAliveMonitor for fire
	keepAliveMonitor = [NSTimer scheduledTimerWithTimeInterval:ConnectionAliveCheckInterval target:self selector:@selector(checkConnectionActive:) userInfo:NULL repeats:YES];
}// end - (void) resetKeepAliveMonitor

- (void) restartConnectionRiseMonitor
{		// stop & reset connectionRiseMonitor
	if ([connectionRiseMonitor isValid] == YES)
	{
		[connectionRiseMonitor invalidate];
		connectionRiseMonitor = NULL;
	}// end if connectionRiseMonitor is running
	
		// re-setup connectionRiseMonitor for fire
	connectionRiseMonitor = [NSTimer scheduledTimerWithTimeInterval:checkRiseInterval target:self selector:@selector(checkConnectionRised:) userInfo:NULL repeats:YES];
}// end - (void) resetConnectionRiseMonitor

#pragma mark periodial action methods
- (void) checkConnectionActive:(NSTimer *)theTimer
{
	NSTimeInterval diff = [lastTime timeIntervalSinceNow];
	if ((connected == NO) || (diff > -ServerTimeOut))
		return;
	// end if check connection is alive
	
	NSString *msResult = [HTTPConnection HTTPSource:[NSURL URLWithString:MSQUERYAPI] response:NULL];
	OnigResult *msStatus = [maintRegex search:msResult];
	if (msStatus != NULL)
		checkRiseInterval = MaintainfromReactiveInterval;

		// start wait a connection regain
	[self stopListen];
}// end - (void) checkConnectionActive

- (void) checkConnectionRised:(NSTimer *)theTimer
{
	serverInfo = [[NLMessageServerInfo alloc] init];
	if (serverInfo == NULL)
		return;

	sendrequest = NO;
	[connectionRiseMonitor invalidate];
	connectionRiseMonitor = NULL;
	[center postNotificationName:NLNotificationConnectionRised object:NULL];
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

#if __has_feature(objc_arc) == 0
	if (lastTime != NULL)
		[lastTime release];
#endif
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
	if ((sendrequest == NO) && [programListSocket isOutputStream:stream] == YES)
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
	connected = NO;
	sendrequest = NO;
	checkRiseInterval = ConnectionReactiveCheckInterval;
	[center postNotificationName:NLNotificationConnectionLost object:NULL];
}// end - (void) streamEventErrorOccurred:(NSStream *)stream

#pragma mark StreamEventDelegate (optional)
- (void) streamEventOpenCompleted:(NSStream *)stream
{
	if ((connected == NO) && ([programListSocket isInputStream:stream]))
	{
#if __has_feature(objc_arc) == 0
		if (lastTime != NULL)
			[lastTime release];
#endif
		lastTime = [[NSDate alloc] init];
		[center postNotificationName:NLNotificationConnectionRised object:NULL];
		connected = YES;
	}
}// end - (void) streamEventOpenCompleted:(NSStream *)stream

- (void) streamEventEndEncountered:(NSStream *)stream
{
	if ((connected == YES) && ([programListSocket isInputStream:stream]))
	{
		connected = NO;
		sendrequest = NO;
		[center postNotificationName:NLNotificationConnectionLost object:NULL];
	}// end if
}// end - (void) streamEventEndEncountered:(NSStream *)stream

- (void) streamEventNone:(NSStream *)stream
{
}// end - (void) streamEventNone:(NSStream *)stream
@end
