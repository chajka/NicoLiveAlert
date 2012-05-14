//
//  NLProgram.h
//  NicoLiveAlert
//
//  Created by Чайка on 4/9/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NicoLiveAlertDefinitions.h"
#import "NLAccount.h"
#import "OnigRegexp.h"

@interface NLProgram : NSObject <NSXMLParserDelegate> {
	NSMenuItem				*programMenu;
	NSImage					*menuImage;
	NSImage					*thumbnail;
	NSBezierPath			*background;
	NSBezierPath			*timeMask;
	NSMutableDictionary		*stringAttributes;
	NSString				*programNumber;
	NSString				*programTitle;
	NSString				*programDescription;
	NSString				*communityName;
	NSString				*primaryAccount;
	NSString				*communityID;
	NSString				*broadcastOwner;
	NSDate					*startTime;
	NSString				*startTimeString;
	NSInteger				lastMintue;
	NSDictionary			*localeDict;
	NSString				*programURL;
	NSTimer					*programStatusTimer;
	NSTimer					*elapseTimer;
	NSNotificationCenter	*center;
	BOOL					isReservedProgram;
	BOOL					isOfficial;
	BOOL					isMyProgram;
	BOOL					broadCasting;
}
@property (readonly) NSMenuItem			*programMenu;
@property (readonly) NSString			*programNumber;
@property (readonly) NSString			*communityID;
@property (readonly) NSString			*broadcastOwner;
@property (readonly) BOOL				broadCasting;
@property (readonly) BOOL				isOfficial;

- (id) initWithProgram:(NSString *)liveNo withDate:(NSDate *)date;
- (id) initWithProgram:(NSString *)liveNo withDate:(NSDate *)date forAccount:(NLAccount *)account owner:(NSString *)owner isMine:(BOOL)mine;
- (BOOL) isEqual:(id)object;
- (BOOL) isSame:(NLProgram *)program;
- (void) terminate;
- (void) suspend;
- (BOOL) resume;
@end
