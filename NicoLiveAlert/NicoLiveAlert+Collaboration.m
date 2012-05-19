//
//  NicoLiveAlert+Collaboration.m
//  NicoLiveAlert
//
//  Created by Чайка on 5/18/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NicoLiveAlert+Collaboration.h"

@interface NSDistantObject (Collaboration)
- (void) startFMLE:(NSString *)live;
- (void) stopFMLE;
- (void) joinToLive:(NSString *)live;
@end

@implementation NicoLiveAlert (Collaboration)
#pragma mark Other application collaboration
- (void) startFMLE:(NSString *)live
{
	NSDistantObject *fmle = [NSConnection rootProxyForConnectionWithRegisteredName:FMELauncher host:NULL];
	[fmle startFMLE:live];
}// end - (void) startFMLE:(NSString *)live

- (void) stopFMLE
{
	NSDistantObject *fmle = [NSConnection rootProxyForConnectionWithRegisteredName:FMELauncher host:NULL];
	[fmle stopFMLE];
}// end - (void) stopFMLE

- (void) joinToLive:(NSString *)live
{
	NSDistantObject *charleston = [NSConnection rootProxyForConnectionWithRegisteredName:Charleston host:NULL];
	[charleston joinToLive:live];
}// - (void) joinToLive:(NSString *)live
@end
