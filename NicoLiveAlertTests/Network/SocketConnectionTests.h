//
//  SocketConnectionTests.h
//  NicoLiveAlert
//
//  Created by Чайка on 4/2/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "SocketConnection.h"
#import "NLMessageServerData.h"

#define TICKET @"<thread thread=\"%@\" version=\"20061206\" res_from=\"-1\"/>\0"

@interface SocketConnectionTests : SenTestCase <NSStreamDelegate, StreamEventDelegate> {
	NSMutableData *dataBuffer;
	NSInteger	currentTestNo;
	NSString	*dataString;
	NLMessageServerData *ms;
}

@end
