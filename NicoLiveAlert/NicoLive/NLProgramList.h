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

@interface NLProgramList : NSObject <NSXMLParserDelegate, StreamEventDelegate> {
	SocketConnection	*programListSocket;
	NSMutableDictionary	*watchList;
	NLMessageServerInfo	*serverInfo;
	NSDate				*lastTime;
	NSTimer				*aliveMonitor;
	BOOL				watchOfficial;
	BOOL				isOfficial;
#ifdef DEBUG
	NSFileHandle		*xmllog;
	NSFileHandle		*watchlog;
#endif
}
@property (retain, readwrite) NSMutableDictionary	*watchList;
@property (assign, readwrite) BOOL					watchOfficial;

- (BOOL) startListen;
- (void) stopListen;

@end
