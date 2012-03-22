//
//  NicoLiveAlert.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NicoLiveAlert.h"
#import "NicoLiveAlertDefinitions.h"

@implementation NicoLiveAlert
@synthesize menuStatusbar;

- (void) awakeFromNib
{
	[self installStatusbarMenu];
}// end - (void) awakeFromNib

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
}

- (void) installStatusbarMenu
{
	NSStatusBar *bar = [NSStatusBar systemStatusBar];
	sbItem = [bar statusItemWithLength:NSVariableStatusItemLength];
	//#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
#if __has_feature(objc_arc) == 0
	[sbItem retain];
#endif
	NSImage *nicoLiveIcon = [NSImage imageNamed:@"sbicon"];
    NSImage *nicoLiveAlt = [NSImage imageNamed:@"sbiconalt"];
	[sbItem setTitle:@""];
	[sbItem setImage:nicoLiveIcon];
    [sbItem setAlternateImage:nicoLiveAlt];
	[sbItem setToolTip:@"NicoLiveAlert"];
	[sbItem setHighlightMode:YES];
    // localize
    [[menuStatusbar itemWithTag:tagAutoOpen] setTitle:TITLEAUTOOPEN];
    [[menuStatusbar itemWithTag:tagPorgrams] setTitle:TITLEPROGRAMS];
    [[menuStatusbar itemWithTag:tagAccounts] setTitle:TITLEACCOUNTS];
    [[menuStatusbar	itemWithTag:tagLaunchApplications] setTitle:TITLELAUNCHER];
    [[menuStatusbar itemWithTag:tagPreference] setTitle:TITLEPREFERENCE];
    [[menuStatusbar itemWithTag:tagAbout] setTitle:TITLEABOUT];
    [[menuStatusbar itemWithTag:tagQuit] setTitle:TITLEQUIT];
    
	[sbItem setMenu:menuStatusbar];
}// end - (void) installStatusbarMenu
@end
