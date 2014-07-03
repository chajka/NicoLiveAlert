//
//  NicoLiveAlerte.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/25/14.
//  Copyright (c) 2014 Instrumentality of mankind. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NLStatusbar.h"

@interface NicoLiveAlert : NSObject <NSApplicationDelegate> {
		// menu outlet
	IBOutlet	NSMenu		*statusBarMenu;

		//
	NLStatusbar				*statusBar;
	NSWindowController		*preferenceWindowController;
}
#pragma mark - actions
- (IBAction) openPreferences:(id)sender;
@end
