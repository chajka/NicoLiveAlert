//
//  NLAccountInfo.h
//  NicoLiveAlert
//
//  Created by Чайка on 5/10/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NLAccount.h"

@interface NLAccountInfo : NSObject {
	BOOL		enableAtStart;
	NSNumber	*userid;
	NSString	*nickname;
	NSString	*mailaddr;
}
@property (assign, readonly) BOOL		enableAtStart;
@property (copy, readonly) NSNumber	*userid;
@property (copy, readonly) NSString	*nickname;
@property (copy, readonly) NSString	*mailaddr;

- (id) initWithAccountDict:(NSDictionary *)accountInfo;
- (id) initWithAccount:(NLAccount *)account enableWatchAtNext:(BOOL)enable;

@end
