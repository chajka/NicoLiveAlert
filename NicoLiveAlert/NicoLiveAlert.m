//
//  NicoLiveAlert.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NicoLiveAlert.h"
#import "NicoLiveAlertDefinitions.h"

@interface NicoLiveAlert ()
- (void) doBeforeSleep:(NSNotification *)note;
- (void) doAfterSleep:(NSNotification *)note;
@end

@implementation NicoLiveAlert
@synthesize prefencePanel;
@synthesize menuStatusbar;

int count = 0;
int threath = 15;
- (void) awakeFromNib
{
	statusBar = [[NLStatusbarIcon alloc] initWithMenu:menuStatusbar andImageName:@"sbicon"];
#if __has_feature(objc_arc) == 0
	[statusBar retain];
#endif
}// end - (void) awakeFromNib

NSTimer *timer;
- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{		// setup for account
	nicoliveAccounts = [[NLUsers alloc] initWithActiveUsers:NULL andManualWatchList:[NSDictionary dictionary]];
	[[menuStatusbar itemWithTag:tagAccounts] setSubmenu:[nicoliveAccounts usersMenu]];
	[[menuStatusbar itemWithTag:tagAccounts] setEnabled:YES];

		// sleep and wakeup notification hook
			// hook to sleep notification
	[[[NSWorkspace sharedWorkspace] notificationCenter]
		addObserver: self selector: @selector(receiveSleepNote:)
	 name: NSWorkspaceWillSleepNotification object: NULL];
			// hook to wakeup notification
	[[[NSWorkspace sharedWorkspace] notificationCenter]
	 addObserver: self selector: @selector(receiveSleepNote:)
	 name: NSWorkspaceDidWakeNotification object: NULL];
}

- (void) doBeforeSleep:(NSNotification *)note
{
}// end - (void) doBeforeSleep:(NSNotification *)note

- (void) doAfterSleep:(NSNotification *)note
{
}// end - (void) doAfterSleep:(NSNotification *)note

- (void) applicationWillTerminate:(NSNotification *)notification
{
		// release sleep and wakeup notifidation
			// release sleep notification
	[[[NSWorkspace sharedWorkspace] notificationCenter]
	 removeObserver:self 
	 name:NSWorkspaceWillSleepNotification object:NULL];
		// release wakeup notification
	[[[NSWorkspace sharedWorkspace] notificationCenter]
	 removeObserver:self 
	 name:NSWorkspaceDidWakeNotification object:NULL];
#if __has_feature(objc_arc) == 0
	[statusBar release];
#endif
	[timer invalidate];
}

- (BOOL) checkFirstLaunch
{
	NSBundle *mb = [NSBundle mainBundle];
	NSDictionary *infoDict = [mb infoDictionary];
	NSString *prefPath = [NSString stringWithFormat:PARTIALPATHFORMAT, [infoDict objectForKey:KEYBUNDLEIDENTIFY]];
	NSString *fullPath = [prefPath stringByExpandingTildeInPath];

	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL isThere = [fm fileExistsAtPath:fullPath];
	
	return isThere;
}// end - (BOOL) checkFirstLaunch

- (IBAction) toggleUserState:(id)sender
{
	[nicoliveAccounts toggleUserState:sender];
}// end - (IBAction) toggleUserState:(id)sender
@end
