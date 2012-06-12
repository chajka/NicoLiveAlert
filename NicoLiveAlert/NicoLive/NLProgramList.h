//
//  NLProgramList.h
//  NicoLiveAlert
//
//  Created by Чайка on 4/4/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketConnection.h"
#import "NicoLiveAlertCollaboration.h"
#import "HTTPConnection.h"
#import "NicoLiveAlertDefinitions.h"
#import "NLMessageServerInfo.h"
#import "NLActivePrograms.h"
#import "OnigRegexp.h"

@interface NLProgramList : NSObject <StreamEventDelegate> {
	SocketConnection	*programListSocket;
	NSMutableDictionary	*watchList;
	NLMessageServerInfo	*serverInfo;
	NLActivePrograms	*activePrograms;
	__strong NSNotificationCenter *center;
	__strong NSCharacterSet *chatSeparator;
	NSDate				*lastTime;
	NSTimeInterval		checkRiseInterval;
	NSTimer				*keepAliveMonitor;
	NSTimer				*connectionRiseMonitor;
	BOOL				watchOfficial;
	BOOL				watchChannel;
	BOOL				officialState;
	BOOL				isOfficial;
	BOOL				isMaintainance;
	BOOL				waitingConnection;
	BOOL				connected;
	BOOL				enableAutoOpen;
	BOOL				streamIsOpen;
}
@property (retain, readwrite)	NSMutableDictionary	*watchList;
@property (retain, readwrite)	NLActivePrograms	*activePrograms;
@property (assign, readwrite)	BOOL				watchOfficial;
@property (assign, readwrite)	BOOL				watchChannel;
@property (readonly)			BOOL				officialState;
@property (assign, readwrite)	BOOL				enableAutoOpen;

- (void) kick;
- (void) halt;

@end
