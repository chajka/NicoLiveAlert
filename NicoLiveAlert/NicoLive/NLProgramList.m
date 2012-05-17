//
//  NLProgramList.m
//  NicoLiveAlert
//
//  Created by Чайка on 4/4/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLProgramList.h"

@interface NLProgramList ()
- (void) startListen:(NSNotification *)note;
- (void) stopListen:(NSNotification *)note;
- (void) waitListen:(NSNotification *)note;
- (void) stopKeepAliveMonitor;
- (void) resetKeepAliveMonitor;
- (void) stopConnectionRiseMonitor;
- (void) resetConnectionRiseMonitor;
- (void) checkProgram:(NSString *)progInfo withDate:(NSDate *)date;
- (void) checkConnectionActive:(NSTimer *)theTimer;
- (void) checkConnectionRised:(NSTimer *)theTimer;
@end

@implementation NLProgramList
@synthesize watchList;
@synthesize activePrograms;
@synthesize officialState;
@synthesize enableAutoOpen;

NSMutableData		*programListDataBuffer;
BOOL sendrequest;
__strong OnigRegexp			*programRegex;
__strong OnigRegexp			*maintRegex;
__strong OnigRegexp			*checkstatus;
__strong OnigRegexp			*progInfoRegex;
__strong OnigRegexp			*startTimeRegex;

- (id) init
{
	self = [super init];
	if (self)
	{
		programListSocket = nil;
		watchList = nil;
		serverInfo = nil;
		center = [NSNotificationCenter defaultCenter];
		chatSeparator = [NSCharacterSet characterSetWithCharactersInString:ChatContentCharset];
#if __has_feature(objc_arc) == 0
		[center retain];
		[chatSeparator retain];
#endif
		lastTime = nil;
		checkRiseInterval = ConnectionReactiveCheckInterval;
		keepAliveMonitor = nil;
		connectionRiseMonitor = nil;
		programListDataBuffer = nil;
		sendrequest = NO;
		isOfficial = NO;
		watchOfficial = NO;
		watchChannel = NO;
		officialState = NO;
		connected = NO;
		programRegex = [OnigRegexp compile:ProgramNoRegex];
		maintRegex = [OnigRegexp compile:MaintRegex];
		checkstatus = [OnigRegexp compile:RiseConnectRegex];
		progInfoRegex = [OnigRegexp compile:ProgramListRegex];
		startTimeRegex = [OnigRegexp compile:DateStartTimeRegex];
		[center addObserver:self selector:@selector(startListen:) name:NLNotificationConnectionRised object:nil];
		[center addObserver:self selector:@selector(waitListen:) name:NLNotificationConnectionLost object:nil];
#if __has_feature(objc_arc) == 0
		[programRegex retain];
		[maintRegex retain];
		[checkstatus retain];
		[progInfoRegex retain];
		[startTimeRegex retain];
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
	if (watchList != nil)					[watchList release];
	if (serverInfo != nil)					[serverInfo release];
	if (center != nil)						[center release];
	if (chatSeparator != nil)				[chatSeparator release];
	if (lastTime != nil)					[lastTime release];
	if (programListSocket != nil)			[programListSocket release];
	if (programRegex != nil)				[programRegex release];
	if (maintRegex != nil)					[maintRegex release];
	if (checkstatus != nil)				[checkstatus release];
	if (progInfoRegex != nil)				[progInfoRegex release];
	if (startTimeRegex != nil)				[startTimeRegex release];
	[super dealloc];
#endif
}// end - (void) dealloc

#pragma mark -
#pragma mark accessor
#pragma mark watchOfficial’s accessor
- (BOOL) watchOfficial
{
	return watchOfficial;
}// end - (BOOL) watchOfficial

- (void) setWatchOfficial:(BOOL)watch
{
	watchOfficial = watch;
	officialState = (watchOfficial | watchChannel);
}// end - (void) setWatchOfficial:(BOOL)watch

#pragma mark watchChannel’s accessor
- (BOOL) watchChannel
{
	return watchChannel;
}// end - (BOOL) watchChannel

- (void) setWatchChannel:(BOOL)watch
{
	watchChannel = watch;
	officialState = (watchOfficial | watchChannel);
}// end - (void) setWatchChannel:(BOOL)watch

#pragma mark -
#pragma mark controll methods

- (void) kick
{
	[self startListen:nil];
}// end - (void) kick

- (void) halt
{
	[self stopListen:nil];
}// end - (void) halt

- (void) startListen:(NSNotification *)note
{
	[self stopConnectionRiseMonitor];
	serverInfo = [[NLMessageServerInfo alloc] init];
	if ((serverInfo == nil) || (serverInfo.maintenance == YES))
	{
#if __has_feature(objc_arc) == 0
		[serverInfo release];
#endif
		serverInfo = nil;
		[center postNotificationName:NLNotificationConnectionLost object:nil];
		return;
	}
	// end if cannot correct server information.

	programListSocket = [[SocketConnection alloc] initWithServer:[serverInfo serveName] andPort:[serverInfo port] direction:SCDirectionBoth];
	[programListSocket setStreamEventDelegate:self];
	if ([programListSocket connect] == YES)
	{
		[self resetKeepAliveMonitor];
		[keepAliveMonitor fire];
	}// end if connect to program server success

#if __has_feature(objc_arc) == 0
	if (lastTime != nil)
		[lastTime release];
#endif
	lastTime = [[NSDate alloc] init];

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
			connectionRiseMonitor = nil;
		}
		[self resetKeepAliveMonitor];
		[keepAliveMonitor fire];
	}// end if connect to program server success
#if __has_feature(objc_arc) == 0
	if (lastTime != nil)
		[lastTime release];
#endif
	lastTime = [[NSDate alloc] init];
	
	return success;
}// end - (void) restartListen

- (void) stopListen:(NSNotification *)note
{		//
	[programListSocket disconnect];
#if __has_feature(objc_arc) == 0
	[programListSocket release];
#endif
	programListSocket = nil;
	connected = NO;	

		// stop & reset keepAliveMonitor
	[self stopKeepAliveMonitor];

#if __has_feature(objc_arc) == 0
	if (programListSocket != nil)
		[programListSocket release];
	// end if not connection
	if (serverInfo != nil)
		[serverInfo release];
	// end if for serverInfo reallocate
#endif
	serverInfo = nil;
	connected = NO;
}// end - (void) stopListen

- (void) waitListen:(NSNotification *)note
{		//
	[programListSocket disconnect];
#if __has_feature(objc_arc) == 0
	[programListSocket release];
#endif
	programListSocket = nil;
	connected = NO;	
	
		// stop & reset keepAliveMonitor
	[self stopKeepAliveMonitor];
	[self resetConnectionRiseMonitor];
	[connectionRiseMonitor fire];
	
#if __has_feature(objc_arc) == 0
	if (programListSocket != nil)
		[programListSocket release];
		// end if not connection
	if (serverInfo != nil)
		[serverInfo release];
		// end if for serverInfo reallocate
#endif
	serverInfo = nil;
	connected = NO;
}// end - (void) waitListen


#pragma mark -
#pragma mark internal
#pragma mark program sieve method
- (void) checkProgram:(NSString *)progInfo withDate:(NSDate *)date
{
	NSArray *program = [progInfo componentsSeparatedByString:dataSeparator];
	NSString *live = [program objectAtIndex:offsetLiveNo];
		// check official program
	if ((watchOfficial == YES) && ([program count] == 2))
	{
		[activePrograms addOfficialProgram:live withDate:date];

			// check in watchlist
		NSNumber *isInWatchList = [watchList valueForKey:live];
		if (isInWatchList != nil)
		{		// item is in watchlist
			[center postNotification:[NSNotification notificationWithName:NLNotificationFoundLiveNo object:live]];
			if ([isInWatchList boolValue] == YES)
			{
				NSString *liveURL = [NSString stringWithFormat:URLFormatLive, live];
				[center postNotificationName:NLNotificationAutoOpen object:liveURL];
			}// end if need auto open
		}// end if program is entry in watchlist

		return;
	}// end if program is official program

		// iterate program info
	for (NSString *prog in program)
	{
			// process official
		if (isOfficial == YES)
		{
			isOfficial = NO;
			return;
		}// endif

			// check official channel
		if ([prog isEqualToString:liveOfficialString] == YES)
		{
			isOfficial = YES;
			if (watchChannel == YES)
				[activePrograms addOfficialProgram:live withDate:date];
			continue;
		}// end if program is official channel
		
			// check watchlist
		NSNumber *needOpen = [watchList valueForKey:prog];
		if (needOpen != nil)
		{		// found in watchlist or memberd communities program
NSLog(@"Enable AutoOpen : %c", enableAutoOpen ? 'Y' : 'N');
NSLog(@"autoOpen : %@", needOpen);
			if (isOfficial == YES)
				[activePrograms addOfficialProgram:live withDate:date];
			else
				[activePrograms addUserProgram:live withDate:date community:[program objectAtIndex:offsetCommuCh] owner:[program objectAtIndex:offsetOwner]];
			// end if Official program or User program
			
				// check mutch is program number
			OnigResult *isPorgram = [programRegex search:prog];
			if (isPorgram != nil)
				[center postNotification:[NSNotification notificationWithName:NLNotificationFoundLiveNo object:prog]];
			// end if found in watch list

				// check auto open of this program
			if ((enableAutoOpen == YES) && ([needOpen boolValue] == YES))
			{		// open program
				NSString *liveURL = [NSString stringWithFormat:URLFormatLive, live];
				[center postNotificationName:NLNotificationAutoOpen object:liveURL];
			}// end if need check auto opend program

			break;
		}// end if program found
	}// end foreach program information items

}// end - (void) checkProgram:(NSString *)progInfo

#pragma mark -
#pragma mark timer control methods
- (void) stopKeepAliveMonitor
{		// stop & reset keepAliveMonitor
	if ([keepAliveMonitor isValid] == YES)
	{
		[keepAliveMonitor invalidate];
		keepAliveMonitor = nil;
	}// end if keepAliveMonitor is running
	keepAliveMonitor = nil;
}// end - (void) stopKeepAliveMonitor

- (void) resetKeepAliveMonitor
{		// stop & reset keepAliveMonitor
	if ([keepAliveMonitor isValid] == YES)
	{
		[keepAliveMonitor invalidate];
		keepAliveMonitor = nil;
	}// end if keepAliveMonitor is running
	
		// re-setup keepAliveMonitor for fire
	keepAliveMonitor = [NSTimer scheduledTimerWithTimeInterval:ConnectionAliveCheckInterval target:self selector:@selector(checkConnectionActive:) userInfo:nil repeats:YES];
}// end - (void) resetKeepAliveMonitor

- (void) stopConnectionRiseMonitor
{		// stop & reset connectionRiseMonitor
	if ([connectionRiseMonitor isValid] == YES)
	{
		[connectionRiseMonitor invalidate];
	}// end if connectionRiseMonitor is running
	connectionRiseMonitor = nil;
}// end - (void) stopConnectionRiseMonitor

- (void) resetConnectionRiseMonitor
{		// stop & reset connectionRiseMonitor
	if ([connectionRiseMonitor isValid] == YES)
	{
		[connectionRiseMonitor invalidate];
		connectionRiseMonitor = nil;
	}// end if connectionRiseMonitor is running
	
		// re-setup connectionRiseMonitor for fire
	connectionRiseMonitor = [NSTimer scheduledTimerWithTimeInterval:checkRiseInterval target:self selector:@selector(checkConnectionRised:) userInfo:nil repeats:YES];
}// end - (void) resetConnectionRiseMonitor

#pragma mark periodial action methods
- (void) checkConnectionActive:(NSTimer *)theTimer
{
	NSTimeInterval diff = [lastTime timeIntervalSinceNow];
	if ((connected == NO) || (diff > -ServerTimeOut))
		return;
	// end if check connection is alive
	
	NSString *msResult = [HTTPConnection HTTPSource:[NSURL URLWithString:MSQUERYAPI] response:nil];
	OnigResult *msStatus = [maintRegex search:msResult];
	if (msStatus != nil)
		checkRiseInterval = MaintainfromReactiveInterval;

		// start wait a connection regain
	[self waitListen:nil];
}// end - (void) checkConnectionActive

- (void) checkConnectionRised:(NSTimer *)theTimer
{
	serverInfo = [[NLMessageServerInfo alloc] init];
	if ((serverInfo == nil) || (serverInfo.maintenance == YES))
	{
#if __has_feature(objc_arc) == 0
		[serverInfo release];
#endif
		serverInfo = nil;
		return;
	}// end if 

	sendrequest = NO;
	[self stopConnectionRiseMonitor];
	[center postNotificationName:NLNotificationConnectionRised object:NLNotificationServerResponce];
}// end - (void) checkConnectionRised

#pragma mark -
#pragma mark StreamEventDelegate
- (void) streamEventHasBytesAvailable:(NSStream *)stream
{
	NSInputStream *iStream = (NSInputStream *)stream;
	uint8_t oneByte;
	NSUInteger actuallyRead = 0;
	if (programListDataBuffer == nil)
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
	if (lastTime != nil)
		[lastTime release];
	lastTime = [[NSDate alloc] init];
#endif
	
#if __has_feature(objc_arc)
	@autoreleasepool {
#else
	NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
#endif
		// store last data recieve time;
		// databyte is terminator
	NSString *msg = [[NSString alloc] initWithData:programListDataBuffer encoding:NSUTF8StringEncoding];
	NSArray *result = [msg componentsSeparatedByCharactersInSet:chatSeparator];
	if ([result count] == CountRegalChatContent)
	{
		NSDate *broadcastDate = [NSDate dateWithTimeIntervalSince1970:[[result objectAtIndex:OffsetDateInArray] longLongValue]];
		[self checkProgram:[NSString stringWithFormat:liveNoAppendFormat,[result objectAtIndex:OffsetProgramInfoInArray]] withDate:broadcastDate];
	}// end if <chat></chat>

/*
	OnigResult *chatResult = [progInfoRegex search:msg];
	if (chatResult != nil)
	{
		OnigResult *dateResult = [startTimeRegex search:msg];
		NSDate *broadcastDate = [NSDate dateWithTimeIntervalSince1970:[[dateResult stringAt:1] longLongValue]];
		[self checkProgram:[NSString stringWithFormat:liveNoAppendFormat,[chatResult stringAt:1]] withDate:broadcastDate];
	}
*/
/*
#if __has_feature(objc_arc) == 0
	[msg release];
#endif
*/	

#if __has_feature(objc_arc)
	programListDataBuffer = nil;
	msg = nil;
	}
#else
	[msg release];						msg = nil;
	[programListDataBuffer release];	programListDataBuffer = nil;
	[arp drain];
#endif

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
	[center postNotificationName:NLNotificationConnectionLost object:nil];
}// end - (void) streamEventErrorOccurred:(NSStream *)stream

#pragma mark StreamEventDelegate (optional)
- (void) streamEventOpenCompleted:(NSStream *)stream
{
	if ((connected == NO) && ([programListSocket isInputStream:stream]))
	{
#if __has_feature(objc_arc) == 0
		if (lastTime != nil)
			[lastTime release];
#endif
		lastTime = [[NSDate alloc] init];
		connected = YES;
		[center postNotificationName:NLNotificationConnectionRised object:NLNotificationStreamOpen];
	}
}// end - (void) streamEventOpenCompleted:(NSStream *)stream

- (void) streamEventEndEncountered:(NSStream *)stream
{
	if ((connected == YES) && ([programListSocket isInputStream:stream]))
	{
		connected = NO;
		sendrequest = NO;
		[center postNotificationName:NLNotificationConnectionLost object:nil];
	}// end if
}// end - (void) streamEventEndEncountered:(NSStream *)stream

- (void) streamEventNone:(NSStream *)stream
{
}// end - (void) streamEventNone:(NSStream *)stream
@end
