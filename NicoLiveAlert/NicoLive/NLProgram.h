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

#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
@interface NLProgram : NSObject <NSXMLParserDelegate> {
#else
@interface NLProgram : NSObject {
#endif
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
	NSURL					*thumbnailURL;
	NSTimer					*programStatusTimer;
	NSTimer					*elapseTimer;
	NSNotificationCenter	*center;
	NSDictionary			*info;
	BOOL					iconWasValid;
	BOOL					iconIsValid;
	BOOL					isReservedProgram;
	BOOL					isOfficial;
	BOOL					isMyProgram;
	BOOL					broadCasting;
}
@property (readonly) NSImage			*menuImage;
@property (readonly) NSMenuItem			*programMenu;
@property (readonly) NSString			*programNumber;
@property (readonly) NSString			*communityID;
@property (readonly) NSString			*broadcastOwner;
@property (readonly) BOOL				broadCasting;
@property (readonly) BOOL				isOfficial;

- (id) initWithProgram:(NSString *)liveNo withDate:(NSDate *)date forAccount:(NLAccount *)account owner:(NSString *)owner autoOpen:(NSNumber *)autoOpen isMine:(BOOL)mine isChannel:(BOOL) isChannel;
- (id) initWithProgram:(NSString *)liveNo withDate:(NSDate *)date autoOpen:(NSNumber *)autoOpen isOfficial:(BOOL)official;
- (BOOL) isEqual:(id)object;
- (BOOL) isSame:(NLProgram *)program;
- (void) terminate;
- (void) suspend;
- (BOOL) resume;
@end
