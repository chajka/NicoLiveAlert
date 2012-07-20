//
//  NLProgram+Parsing.h
//  NicoLiveAlert
//
//  Created by Чайка on 7/20/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLProgram.h"

extern NSMutableString *dataString;
extern NSInteger currentElement;
extern NSDictionary *elementDict;
extern NSString *embedContent;

@interface NLProgram (Parsing)
- (NSDictionary *) elementDict;
- (void) parseOfficialProgram;
- (void) parseProgramInfo:(NSString *)liveNo;
- (void) parseOwnerNickname:(NSString *)owner;
@end
