//
//  NicoLiveAlert+Collaboration.h
//  NicoLiveAlert
//
//  Created by Чайка on 5/18/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NicoLiveAlert.h"

@interface NicoLiveAlert (Collaboration)
- (void) connectToProgram:(NSDictionary *)program;
- (void) disconnectFromProgram:(NSDictionary *)program;
- (void) startFMLE:(NSString *)live;
- (void) stopFMLE;
- (void) joinToLive:(NSString *)live;
@end
