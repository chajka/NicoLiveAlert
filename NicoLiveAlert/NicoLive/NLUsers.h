//
//  NLUsers.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/25/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NicoLiveAlertDefinitions.h"
#import "KCSUser.h"
#import "NLAccount.h"

@interface NLUsers : NSObject {
	NSMutableArray		*enabledUsers;
	NSMutableArray		*disabledUsers;
	NSDictionary		*accounts;
	NSMutableDictionary	*originalWatchList;
	NSMutableDictionary	*watchlist;
}
@property (readonly)	NSDictionary	*watchlist;

#pragma mark constructor / destructor
- (id) initWithActiveUsers:(NSArray *)users andManualWatchList:(NSDictionary *)manualWatchList;

@end
