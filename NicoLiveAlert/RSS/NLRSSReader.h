//
//  NLRSSReader.h
//  NicoLiveAlert
//
//  Created by Чайка on 7/23/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NLActivePrograms.h"
#import "OnigRegexp.h"

#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_6
@protocol NSXMLParserDelegate <NSObject>
@end
#endif

@interface NLRSSReader : NSObject <NSXMLParserDelegate> {
	NLActivePrograms	*activePrograms;
	NSMutableDictionary	*watchList;
	NSDictionary		*ownerList;
	NSDictionary		*ownerNames;
	NSString			*cachedProgramNumber;
	NSZone				*parseZone;
	NSDictionary		*elementDict;
	NSString			*programNumber;
	NSString			*community;
	NSString			*ownerName;
	NSString			*ownerID;
	NSDate				*startTime;
	NSString			*broadcastType;
	BOOL				watchOfficial;
	BOOL				watchChannel;
	BOOL				needPick;
	BOOL				repeat;
	BOOL				dump;
}
@property (retain, readwrite) NLActivePrograms		*activePrograms;
@property (retain, readwrite) NSMutableDictionary	*watchList;
@property (assign, readwrite) BOOL					watchOfficial;
@property (assign, readwrite) BOOL					watchChannel;

- (void) startScnan;

@end
