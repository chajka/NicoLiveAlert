//
//  NLMessageServerData.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/31/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPConnection.h"

@interface NLMessageServerData : NSObject <NSXMLParserDelegate> {
	NSString	*serveName;
	NSUInteger	port;
	NSString	*thread;
}
@property (readonly) NSString	*serveName;
@property (readonly) NSUInteger	port;
@property (readonly) NSString	*thread;

@end
