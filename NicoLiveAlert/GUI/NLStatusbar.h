//
//  NLStatusbar.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/25/14.
//  Copyright (c) 2014 Instrumentality of mankind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NLStatusbar : NSObject {
	__strong	NSStatusItem	*statusMenuItem;
	__strong	NSStatusBar		*systemStatusBar;
}

- (id) initWithMenu:(NSMenu *)menu andIconName:(NSString *)iconName;
@end
