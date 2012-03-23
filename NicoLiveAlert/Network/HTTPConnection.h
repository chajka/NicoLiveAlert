//
//  HTTPConnection.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/23/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPConnection : NSObject {
	NSURL			*url;
	NSString		*path;
	NSDictionary	*params;
}

@end
