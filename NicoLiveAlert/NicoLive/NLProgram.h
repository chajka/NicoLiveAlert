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
	NSImage					*thumnbail;
	NSBezierPath			*background;
	NSBezierPath			*timeMask;
	NSMutableDictionary		*stringAttributes;
	NSString				*programNumber;
	NSString				*programTitle;
	NSString				*programDescription;
	NSString				*communityName;
	NSString				*primaryAccount;
	NSDate					*startTime;
	NSString				*startTimeString;
	NSUInteger				lastMintue;
	NSDictionary			*localeDict;
	NSURL					*programURL;
	NSTimer					*programStatusTimer;
	NSTimer					*elapseTimer;
	NSNotificationCenter	*center;
	BOOL					isOfficial;
	BOOL					isBroadCasting;
}
@property (readonly) NSMenuItem			*programMenu;
@property (readonly) NSString			*programNumber;
@property (readonly) BOOL				isOfficial;
@property (readonly) BOOL				isBroadCasting;

- (id) initWithProgram:(NSString *)liveNo withDate:(NSDate *)date;
- (id) initWithProgram:(NSString *)liveNo withDate:(NSDate *)date forAccount:(NLAccount *)account;
- (BOOL) isEqual:(id)object;
@end
