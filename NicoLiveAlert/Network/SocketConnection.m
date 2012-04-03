//
//  SocketConnection.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/31/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "SocketConnection.h"

@interface SocketConnection ()
- (void) createStreams;
- (void) openStream;
- (void) closeStream;
@end

@implementation SocketConnection
@synthesize direction;
@synthesize server;
@synthesize port;

#pragma mark construct / destruct
- (id) init
{
	self = [super init];
	if (self)
	{
		streamDelegate = self;
		streamEventDelegate = self;
		iStream = NULL;
		oStream = NULL;
		direction = SCDirectionBoth;
		server = NULL;
		port = 0;
	}// end if self
	return self;
}// end - (id) init

- (id) initWithServer:(NSString *)server_ andPort:(NSInteger)port_ direction:(SCDirection)direction_
{
	self = [super init];
	if (self)
	{
		streamDelegate = self;
		streamEventDelegate = self;
		iStream = NULL;
		oStream = NULL;
		direction = direction_;
		server = [server_ copy];
		port = port_;
	}// end if self
	return self;
}// end - (id) initWithServer:(NSString *)server andPort:(NSInteger)port

- (void) dealloc
{
	if ((iStream != NULL) || (oStream != NULL))
		[self closeStream];
#if __has_feature(objc_arc) == 0
	if (iStream != NULL) {	[iStream release]; }
	if (oStream != NULL) {	[oStream release]; }
	if (server != NULL) {	[server release]; }
	if (streamDelegate != self) {	[streamDelegate release]; }
	if (streamEventDelegate != self) {	[streamEventDelegate release]; }
	[super dealloc];
#endif
}// end - (void) dealloc

#ifdef __OBJC_GC__
- (void) finalize
{
	if ((iStream != NULL) || (oStream != NULL))
		[self closeStream];
	[super finalize];
}// end - (void) finalize
#endif

#pragma mark -
#pragma mark constructor support
- (void) createStreams
{
	if (direction == SCDirectionNothing)
		return;
	
	NSHost *host = [NSHost hostWithName:server];
	if (direction == SCDirectionListen)
	{
#if __has_feature(objc_arc)
		__strong NSInputStream *_iStream;
		[NSStream getStreamsToHost:host port:port inputStream:&_iStream outputStream:NULL];
		iStream = _iStream;
#else
		[NSStream getStreamsToHost:host port:port inputStream:&iStream outputStream:NULL];
		[iStream retain];
#endif
		[iStream setDelegate:streamDelegate];
//		oStream = NULL;
	}
	else if (direction == SCDirectionBroadcast)
	{
#if __has_feature(objc_arc)
		__strong NSOutputStream *_oStream;
		[NSStream getStreamsToHost:host port:port inputStream:NULL outputStream:&_oStream];
		oStream = _oStream;
#else
		[NSStream getStreamsToHost:host port:port inputStream:NULL outputStream:&oStream];
		[oStream retain];
#endif
		[oStream setDelegate:streamDelegate];
//		iStream = NULL;
	}
	else if (direction == SCDirectionBoth)
	{
#if __has_feature(objc_arc)
		__strong NSInputStream *_iStream;
		__strong NSOutputStream *_oStream;
		[NSStream getStreamsToHost:host port:port inputStream:&_iStream outputStream:&_oStream];
		iStream = _iStream;
		oStream = _oStream;
#else
		[NSStream getStreamsToHost:host port:port inputStream:&iStream outputStream:&oStream];
		[iStream retain];
		[oStream retain];
#endif
		[iStream setDelegate:streamDelegate];
		[oStream setDelegate:streamDelegate];
	}// end if
}// end - (void) getStreams

#pragma mark -
#pragma mark streamDelegate's accessor
- (id) streamDelegate
{
	return streamDelegate;
}// end - (id) streamDelegate

- (void) setStreamDelegate:(id<NSStreamDelegate>)sd
{
#if __has_feature(objc_arc) == 0
	if (streamDelegate != self)
		[streamDelegate release];
#endif
	if (sd == NULL)
		streamDelegate = self;
	else
		streamDelegate = sd;
#if __has_feature(objc_arc) == 0
	if (streamDelegate != self)
		[streamDelegate retain];
#endif
}// end - (void) setStreamDelegate:(id<NSStreamDelegate>)sd

#pragma mark socketDelegate's accessor
- (id) streamEventDelegate
{
	return streamEventDelegate;
}// end - (id) socketDelegate

- (void) setStreamEventDelegate:(id<StreamEventDelegate>)sd
{
#if __has_feature(objc_arc) == 0
	if (streamEventDelegate != self)
		[streamEventDelegate release];
#endif
	if (sd == NULL)
		streamEventDelegate = self;
	else
		streamEventDelegate = sd;
#if __has_feature(objc_arc) == 0
	if (streamEventDelegate != self)
		[streamEventDelegate retain];
#endif
}// end - (void) setStreamEventDelegate:(id<StreamEventDelegate>)sd

#pragma mark -
#pragma mark acction
- (BOOL) connect
{
	if (server == NULL)
		return NO;

	if ((iStream == NULL) && (oStream == NULL))
		[self createStreams];
	
	if ((iStream != NULL) || (oStream != NULL))
	{
		[self openStream];
		return YES;
	}
	else
		return NO;
	// endif create stream failed
}// end - (BOOL) connect

- (void) disconnect
{
	[self closeStream];
}// end - (void) disconnect

#pragma mark -
#pragma mark internal
- (void) openStream
{
	if (iStream != NULL)
		[iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	if (oStream != NULL)
		[oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[iStream open];
	[oStream open];
}// end - (void) openStream
	
- (void) closeStream
{
	[iStream close];
	[oStream close];
	if (iStream != NULL)
		[iStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	if (oStream != NULL)
		[oStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[iStream setDelegate:NULL];
	[oStream setDelegate:NULL];
#if __has_feature(objc_arc) == 0
	[iStream release];
	[oStream release];
#endif
	iStream = NULL;
	oStream = NULL;
}// end - (void) closeStream

#pragma mark -
#pragma mark SocketConnectionDelegate
- (void) streamEventHasBytesAvailable:(NSStream *)stream
{	
}// end - (void) NSStreamEventHasBytesAvailable:(NSStream *)stream

- (void) streamEventHasSpaceAvailable:(NSStream *)stream
{
}// end - (void) streamEventHasSpaceAvailable:(NSStream *)stream

- (void) streamEventErrorOccurred:(NSStream *)stream
{
}// end - (void) streamEventErrorOccurred:(NSStream *)stream

- (void) streamEventOpenCompleted:(NSStream *)stream
{
}// end - (void) streamEventOpenCompleted:(NSStream *)stream

- (void) streamEventEndEncountered:(NSStream *)stream
{
}// end - (void) streamEventEndEncountered:(NSStream *)stream

- (void) streamEventNone:(NSStream *)stream
{
}// end - (void) streamEventNone:(NSStream *)stream

#pragma mark -
#pragma mark NSStreamDelegate
NSNotification *note = NULL;
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent
{
	switch (streamEvent) {
		case NSStreamEventNone:
			[streamEventDelegate streamEventNone:aStream];
			break;
		case NSStreamEventOpenCompleted:
			[streamEventDelegate streamEventOpenCompleted:aStream];
			break;
		case NSStreamEventHasBytesAvailable:
			[streamEventDelegate streamEventHasSpaceAvailable:aStream];
			break;
		case NSStreamEventHasSpaceAvailable:
			[streamEventDelegate streamEventHasSpaceAvailable:aStream];
			break;
		case NSStreamEventErrorOccurred:
			note = [NSNotification notificationWithName:SocketConnectionErrorNoficationName object:aStream];
			[[NSNotificationCenter defaultCenter] postNotification:note];
			note = NULL;
			[streamEventDelegate streamEventErrorOccurred:aStream];
			break;
		case NSStreamEventEndEncountered:
			[streamEventDelegate streamEventEndEncountered:aStream];
			break;
		default:
			break;
	}// end switch by streamEvent
}// end - (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent
@end
