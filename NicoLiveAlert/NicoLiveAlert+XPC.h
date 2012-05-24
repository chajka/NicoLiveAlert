//
//  NicoLiveAlert+XPC.h
//  NicoLiveAlert
//
//  Created by Чайка on 5/20/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NicoLiveAlert.h"

@interface NicoLiveAlert (XPC)
- (void) connectToProgram:(NSDictionary *)program;
- (void) disconnectFromProgram:(NSDictionary *)program;
- (void) setupCollaboreationService;
@end
