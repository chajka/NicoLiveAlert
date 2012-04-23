//
//  NLProgramList.h
//  NicoLiveAlert
//
//  Created by Чайка on 4/4/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketConnection.h"
#import "NicoLiveAlertDefinitions.h"
#import "NLMessageServerInfo.h"
#import "NLActivePrograms.h"
#import "OnigRegexp.h"

@interface NLProgramList : NSObject <StreamEventDelegate> {
	SocketConnection	*programListSocket;
	__unsafe_unretained NSMutableDictionary	*watchList;
	NLMessageServerInfo	*serverInfo;
	NLActivePrograms	*activePrograms;
	__strong NSNotificationCenter *center;
	NSDate				*lastTime;
	NSTimer				*keepAliveMonitor;
	NSTimer				*connectionRiseMonitor;
	BOOL				watchOfficial;
	BOOL				isOfficial;
	BOOL				connected;
#ifdef DEBUG
	NSFileHandle		*xmllog;
	NSFileHandle		*watchlog;
#endif
}
@property (assign, readwrite) NSMutableDictionary	*watchList;
@property (retain, readwrite) NLActivePrograms		*activePrograms;
@property (assign, readwrite) BOOL					watchOfficial;

- (void) kick;
- (void) halt;
- (BOOL) startListen;
- (void) stopListen;

@end
