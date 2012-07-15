//
//  NLProgramList.m
//  NicoLiveAlert
//
//  Created by Чайка on 4/4/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLProgramList.h"
#import "Growl/Growl.h"

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
- (void) connectionRised:(NSString *)reason;
- (void) connectionLost:(NSString *)reason;
- (void) growlProgramNotify:(NSString *)kind notify:(NSString *)notificationName reason:(NSString *)reason;
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
		streamIsOpen = NO;
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
	center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self name:NLNotificationConnectionRised object:nil];
	[center removeObserver:self name:NLNotificationConnectionLost object:nil];
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

- (void) reset
{
	[self stopListen:nil];
	[self startListen:nil];
}// end - (void) reset

- (void) startListen:(NSNotification *)note
{
	if (connected == YES)
		return;

	if (serverInfo == nil)
		serverInfo = [[NLMessageServerInfo alloc] init];
	[self stopConnectionRiseMonitor];
	if ((serverInfo == nil) || (serverInfo.maintenance == YES))
	{
#if __has_feature(objc_arc) == 0
		[serverInfo release];
#endif
		serverInfo = nil;
		[self resetConnectionRiseMonitor];
		[connectionRiseMonitor fire];
		connected = NO;
		return;
	}// end if cannot correct server information.

	[self connectionRised:NLNotificationServerCanResponce];
	programListSocket = [[CFSocketConnection alloc] initWithServerName:[serverInfo serveName] andPort:[serverInfo port]];
	[programListSocket setInputStreamDelegate:self];
	[programListSocket setOutputStreamDelegate:self];
	if ([programListSocket connect] == YES)
	{
		if (connected == NO)
			[self connectionRised:NLNotificationStartListen];
		[self resetKeepAliveMonitor];
		[keepAliveMonitor fire];
	}// end if connect to program server success

#if __has_feature(objc_arc) == 0
	if (lastTime != nil)		[lastTime release];
#endif
	lastTime = [[NSDate alloc] init];

}// end - (void) startListen

- (BOOL) restartListen
{
	BOOL success = NO;
	
	if (serverInfo == nil)
		serverInfo = [[NLMessageServerInfo alloc] init];
	[self stopConnectionRiseMonitor];
	if ((serverInfo == nil) || (serverInfo.maintenance == YES))
	{
#if __has_feature(objc_arc) == 0
		[serverInfo release];
#endif
		serverInfo = nil;
		[self resetConnectionRiseMonitor];
		[connectionRiseMonitor fire];
		connected = NO;
		return success;
	}// end if cannot correct server information.

	programListSocket = [[CFSocketConnection alloc] initWithServerName:[serverInfo serveName] andPort:[serverInfo port]];
	[programListSocket setInputStreamDelegate:self];
	[programListSocket setOutputStreamDelegate:self];
	if ([programListSocket connect] == YES)
	{
		success = YES;
		if ([connectionRiseMonitor isValid] == YES)
		{
			[connectionRiseMonitor invalidate];
			connectionRiseMonitor = nil;
			if (connected == NO)
				[self connectionRised:NLNotificationStartListen];
		}
		[self resetKeepAliveMonitor];
		[keepAliveMonitor fire];
	}// end if connect to program server success
#if __has_feature(objc_arc) == 0
	if (lastTime != nil)		[lastTime release];
#endif
	lastTime = [[NSDate alloc] init];
	
	return success;
}// end - (void) restartListen

- (void) stopListen:(NSNotification *)note
{		//
	[programListSocket disconnect];
#if __has_feature(objc_arc) == 0
	if (programListSocket != nil)		[programListSocket release];
	if (serverInfo != nil)				[serverInfo release];
#endif
	programListSocket = nil;
	serverInfo = nil;
		// stop & reset keepAliveMonitor
	[self stopKeepAliveMonitor];

	streamIsOpen = NO;
	connected = NO;
	sendrequest = NO;
}// end - (void) stopListen

- (void) waitListen:(NSNotification *)note
{		//
	[programListSocket disconnect];
#if __has_feature(objc_arc) == 0
	if (programListSocket != nil)	[programListSocket release];
	if (serverInfo != nil)			[serverInfo release];
#endif
	programListSocket = nil;
	serverInfo = nil;
	
		// stop & reset keepAliveMonitor
	[self stopKeepAliveMonitor];
	[self resetConnectionRiseMonitor];
	[connectionRiseMonitor fire];
	
	streamIsOpen = NO;
	connected = NO;
	sendrequest = NO;
}// end - (void) waitListen


#pragma mark -
#pragma mark internal
#pragma mark program sieve method
- (void) checkProgram:(NSString *)progInfo withDate:(NSDate *)date
{
		//NSLog(@"]%@[", progInfo);
	NSArray *program = [progInfo componentsSeparatedByString:dataSeparator];
	NSString *live = [program objectAtIndex:offsetLiveNo];
		// check official program
	if ((watchOfficial == YES) && ([program count] == 2))
	{
		BOOL autoOpenFlag = [[watchList valueForKey:live] boolValue];
		NSNumber *autoOpen = [NSNumber numberWithBool:autoOpenFlag];
		[activePrograms addOfficialProgram:live withDate:date autoOpen:autoOpen isOfficial:YES];
		return;
	}// end if program is official program

		// iterate program info
	for (NSString *prog in program)
	{			// check official channel
		if ([prog isEqualToString:liveOfficialString] == YES)
		{
			BOOL autoOpenFlag = [[watchList valueForKey:live] boolValue];
			NSNumber *autoOpen = [NSNumber numberWithBool:autoOpenFlag];
			if (watchChannel == YES)
				[activePrograms addOfficialProgram:live withDate:date autoOpen:autoOpen isOfficial:NO];
			return;
		}// end if program is official channel
		
			// check watchlist
		NSNumber *needNotify = [watchList valueForKey:prog];
		if (needNotify != nil)
		{		// calc need open flag
			BOOL mustOpen = NO;
			for (NSString *info in program)
				mustOpen |= [[watchList valueForKey:info] boolValue];
			// endforeach
			NSNumber *needOpen = [NSNumber numberWithBool:mustOpen];
				// found in watchlist or memberd communities program
			NSString *prefix = [[program objectAtIndex:offsetCommuCh] substringWithRange:rangePrefix];
			NSInteger kind = ([prefix isEqualToString:kindChannel] ? bradcastKindChannel :
							  (([prefix isEqualToString:kindOfficial] ? bradcastKindOfficial : bradcastKindUser)));
			if (kind == bradcastKindChannel)
				[activePrograms addOfficialProgram:live withDate:date autoOpen:needOpen isOfficial:NO];
			else if (kind == bradcastKindOfficial)
				[activePrograms addOfficialProgram:live withDate:date autoOpen:needOpen isOfficial:YES];
			else
				[activePrograms addUserProgram:live withDate:date community:[program objectAtIndex:offsetCommuCh] owner:[program objectAtIndex:offsetOwner] autoOpen:needOpen isChannel:NO];
			return;
		}// end if program found
	}// end foreach program information items
}// end - (void) checkProgram:(NSString *)progInfo

#pragma mark -
#pragma mark timer control methods
- (void) stopKeepAliveMonitor
{		// stop & reset keepAliveMonitor
	if ([keepAliveMonitor isValid] == YES)
		[keepAliveMonitor invalidate];
	// end if keepAliveMonitor is running
	keepAliveMonitor = nil;
}// end - (void) stopKeepAliveMonitor

- (void) resetKeepAliveMonitor
{		// stop & reset keepAliveMonitor
	if ([keepAliveMonitor isValid] == YES)
		[keepAliveMonitor invalidate];
	// end if keepAliveMonitor is running
	keepAliveMonitor = nil;
	
		// re-setup keepAliveMonitor for fire
	keepAliveMonitor = [NSTimer scheduledTimerWithTimeInterval:ConnectionAliveCheckInterval target:self selector:@selector(checkConnectionActive:) userInfo:nil repeats:YES];
}// end - (void) resetKeepAliveMonitor

- (void) stopConnectionRiseMonitor
{		// stop & reset connectionRiseMonitor
	if ([connectionRiseMonitor isValid] == YES)
		[connectionRiseMonitor invalidate];
	// end if connectionRiseMonitor is running
	connectionRiseMonitor = nil;
}// end - (void) stopConnectionRiseMonitor

- (void) resetConnectionRiseMonitor
{		// stop & reset connectionRiseMonitor
	if ([connectionRiseMonitor isValid] == YES)
		[connectionRiseMonitor invalidate];
	// end if connectionRiseMonitor is running
	connectionRiseMonitor = nil;
	
		// re-setup connectionRiseMonitor for fire
	connectionRiseMonitor = [NSTimer scheduledTimerWithTimeInterval:checkRiseInterval target:self selector:@selector(checkConnectionRised:) userInfo:nil repeats:YES];
}// end - (void) resetConnectionRiseMonitor

#pragma mark periodial action methods
- (void) checkConnectionActive:(NSTimer *)theTimer
{
	NSTimeInterval diff = fabs([lastTime timeIntervalSinceNow]);
	if ((connected == NO) || (diff < ServerTimeOut))
		return;
	// end if check connection is alive
	
	NSString *msResult = [HTTPConnection HTTPSource:[NSURL URLWithString:MSQUERYAPI] response:nil];
	OnigResult *msStatus = [maintRegex search:msResult];
	if (msStatus != nil)
		checkRiseInterval = MaintainfromReactiveInterval;

		// start wait a connection regain
	[self connectionLost:NLNotificationProginfoStall];
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
	[self connectionRised:NLNotificationServerCanResponce];
}// end - (void) checkConnectionRised

#pragma mark -
#pragma mark Notify
- (void) connectionRised:(NSString *)reason
{
	connected = YES;
	[center postNotificationName:NLNotificationConnectionRised object:reason];
	[self growlProgramNotify:GrowlRiseTitle notify:GrowlNotifyStartMonitoring reason:reason];
}// end - (void) connectionRised:(NSString *)reason

- (void) connectionLost:(NSString *)reason
{
	[center postNotificationName:NLNotificationConnectionLost object:reason];
	[self growlProgramNotify:GrowlLostTitle notify:GrowlNotifyDisconnected reason:reason];
}// end - (void) connectionLost:(NSString *)reason

#pragma mark Growling
- (void) growlProgramNotify:(NSString *)kind notify:(NSString *)notificationName reason:(NSString *)reason
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
	NSNumber *priority = [NSNumber numberWithInt:0];
	NSNumber *isStickey = [NSNumber numberWithBool:NO];
	[dict setValue:kind forKey:GROWL_NOTIFICATION_TITLE];
	[dict setValue:notificationName forKey:GROWL_NOTIFICATION_NAME];
	[dict setValue:notificationName forKey:GROWL_NOTIFICATION_DESCRIPTION];
/*
#ifdef GROWL_NOTIFICATION_ICON_DATA
	[dict setValue:[thumbnail TIFFRepresentation] forKey:GROWL_NOTIFICATION_ICON_DATA];
#else
	[dict setValue:[thumbnail TIFFRepresentation] forKey:GROWL_NOTIFICATION_ICON];
#endif
*/
	[dict setValue:priority forKey:GROWL_NOTIFICATION_PRIORITY];
	[dict setValue:isStickey forKey:GROWL_NOTIFICATION_STICKY];
	
	[GrowlApplicationBridge notifyWithDictionary:dict];
}// end - (void) growlProgramNotify:(NSString *)notificationName

#pragma mark -
#pragma mark InputStreamConnectionDelegate methods
- (void) iStreamOpenCompleted:(NSInputStream *)iStream
{
	if (connected == NO)
	{
#if __has_feature(objc_arc) == 0
		if (lastTime != nil)		[lastTime release];
#endif
		lastTime = [[NSDate alloc] init];
		connected = YES;
		if (streamIsOpen == NO)
		{
			streamIsOpen = YES;
			[self connectionRised:NLNotificationStreamOpen];
		}
	}
}// end - (void) iStreamOpenCompleted:(NSInputStream *)iStream

- (void) iStreamHasBytesAvailable:(NSInputStream *)iStream
{
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
	if (lastTime != nil)		[lastTime release];
#endif
	lastTime = [[NSDate alloc] init];
	
#if __has_feature(objc_arc)
	@autoreleasepool {
#else
	NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
#endif
			// store last data recieve time;
			// databyte is terminator
		NSString *msg = [[NSString alloc] initWithData:programListDataBuffer encoding:NSUTF8StringEncoding];
		int tokenNumber = 0;
		const char *sep = [ChatContentCharset UTF8String];
		char *phrase, *brkb;
		NSTimeInterval unixtime;
		NSDate *broadcastDate = nil;
		NSString *liveInfo = nil;
		char *live;
		for (phrase = strtok_r((char *)[msg UTF8String], sep, &brkb);
			 phrase;
			 phrase = strtok_r(NULL, sep, &brkb))
		{	
			switch (++tokenNumber) {
				case TokenUnixTime:
					unixtime = atof(phrase);
					break;
				case TokenProgramInfo:
					asprintf(&live, "lv%s", phrase);
					liveInfo = [NSString stringWithCString:live encoding:NSUTF8StringEncoding];
					free(live);
					broadcastDate = [NSDate dateWithTimeIntervalSince1970:unixtime];
					[self checkProgram:liveInfo withDate:broadcastDate];
					break;
				default:
					break;
			}// end switch by token
		}// end foreach token
		
#if __has_feature(objc_arc)
		programListDataBuffer = nil;
		msg = nil;
	}
#else
	[msg release];						msg = nil;
	[programListDataBuffer release];	programListDataBuffer = nil;
	[arp drain];
#endif
}// end - (void) iStreamHasBytesAvailable:(NSInputStream *)iStream

- (void) iStreamEndEncounted:(NSInputStream *)iStream
{
	connected = NO;
	sendrequest = NO;
	checkRiseInterval = ConnectionReactiveCheckInterval;
	[self connectionLost:NLNotificationStreamError];
}// end - (void) iStreamEndEncounted:(NSStream *)iStream

- (void) iStreamErrorOccured:(NSInputStream *)iStream
{
	connected = NO;
	sendrequest = NO;
	checkRiseInterval = ConnectionReactiveCheckInterval;
	[self connectionLost:NLNotificationStreamError];
}// end - (void) iStreamErrorOccured:(NSInputStream *)iStream

#pragma mark OutputStreamConnectionDelegate methods
- (void) oStreamCanAcceptBytes:(NSOutputStream *)oStream
{
	if (sendrequest == NO)
	{
		NSInteger byteToWrite = 0;
		NSString *request = [NSString stringWithFormat:REQUESTFORMAT,[serverInfo thread]];
		byteToWrite = [oStream write:(uint8_t *)[request UTF8String] maxLength:[request length]];
		
		if (byteToWrite == [request length])
			sendrequest = YES;
	}
	else
	{
		[programListSocket closeWriteStream];
	}
}// end - (void) oStreamCanAcceptBytes:(NSInputStream *)oStream

- (void) oStreamEndEncounted:(NSOutputStream *)oStream
{
	connected = NO;
	sendrequest = NO;
	checkRiseInterval = ConnectionReactiveCheckInterval;
	[self connectionLost:NLNotificationStreamError];
}// end - (void) oStreamEndEncounted:(NSStream *)oStream

- (void) oStreamErrorOccured:(NSOutputStream *)oStream
{
	connected = NO;
	sendrequest = NO;
	checkRiseInterval = ConnectionReactiveCheckInterval;
	[self connectionLost:NLNotificationStreamError];
}// end - (void) oStreamErrorOccured:(NSInputStream *)oStream

@end
