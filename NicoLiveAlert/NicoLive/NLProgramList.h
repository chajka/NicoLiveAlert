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
	NSMutableDictionary	*watchList;
	NLMessageServerInfo	*serverInfo;
	NLActivePrograms	*activePrograms;
	NSDate				*lastTime;
	NSTimer				*keepAliveMonitor;
	NSTimer				*connectionRiseMonitor;
	BOOL				watchOfficial;
	BOOL				isOfficial;
#ifdef DEBUG
	NSFileHandle		*xmllog;
	NSFileHandle		*watchlog;
#endif
}
@property (assign, readwrite) NSMutableDictionary	*watchList;
@property (retain, readwrite) NLActivePrograms		*activePrograms;
@property (assign, readwrite) BOOL					watchOfficial;

- (BOOL) startListen;
- (void) stopListen;

@end
