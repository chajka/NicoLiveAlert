//
//  NLMessageServerInfo.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/31/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPConnection.h"

#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
@interface NLMessageServerInfo : NSObject <NSXMLParserDelegate> {
#else
@interface NLMessageServerInfo : NSObject {
#endif
	NSString	*serveName;
	int			port;
	NSString	*thread;
	BOOL		maintenance;
}
@property (readonly) NSString	*serveName;
@property (readonly) int		port;
@property (readonly) NSString	*thread;
@property (readonly) BOOL		maintenance;

@end
