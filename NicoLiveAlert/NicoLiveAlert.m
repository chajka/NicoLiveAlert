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
- (BOOL) checkFirstLaunch;
- (void) listenHalt:(NSNotification *)note;
- (void) listenRestart:(NSNotification *)note;
@end

@implementation NicoLiveAlert
@synthesize menuStatusbar;
@synthesize prefencePanel;

- (void) awakeFromNib
{
	statusBar = [[NLStatusbarIcon alloc] initWithMenu:menuStatusbar andImageName:@"sbicon"];
#if __has_feature(objc_arc) == 0
	[statusBar retain];
#endif
}// end - (void) awakeFromNib

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{		// setup for account
	nicoliveAccounts = [[NLUsers alloc] initWithActiveUsers:NULL andManualWatchList:[NSDictionary dictionary]];
	NSMenuItem *accountsItem = [menuStatusbar itemWithTag:tagAccounts];
	[accountsItem setSubmenu:[nicoliveAccounts usersMenu]];
	[accountsItem setState:[nicoliveAccounts userState]];
	[accountsItem setEnabled:YES];

		// sleep and wakeup notification hook
			// hook to sleep notification
	[[[NSWorkspace sharedWorkspace] notificationCenter]
		addObserver:self selector: @selector(listenHalt:)
	 name: NSWorkspaceWillSleepNotification object: NULL];
			// hook to wakeup notification
	[[[NSWorkspace sharedWorkspace] notificationCenter]
	 addObserver:self selector: @selector(listenRestart:)
	 name: NSWorkspaceDidWakeNotification object: NULL];
			// hook to connection lost notification
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenHalt:) name:NLNotificationConnectionLost object:NULL];
			// hook to connection reactive notification
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenRestart:) name:NLNotificationConnectionRised object:NULL];
	
		// start monitor
	programListServer = [[NLProgramList alloc] init];
	[programListServer setWatchList:[nicoliveAccounts watchlist]];
	[programListServer startListen];
	[statusBar toggleConnected];
}// end - (void) applicationDidFinishLaunching:(NSNotification *)aNotification

- (void) applicationWillTerminate:(NSNotification *)notification
{
	[programListServer stopListen];

		// release sleep and wakeup notifidation
			// remove sleep notification
	[[[NSWorkspace sharedWorkspace] notificationCenter]
	 removeObserver:self 
	 name:NSWorkspaceWillSleepNotification object:NULL];
			// remove wakeup notification
	[[[NSWorkspace sharedWorkspace] notificationCenter]
	 removeObserver:self 
	 name:NSWorkspaceDidWakeNotification object:NULL];
			// remove Connection lost notification
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NLNotificationConnectionLost object:NULL];
			// remove Connection Rised notification
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NLNotificationConnectionRised object:NULL];
	
#if __has_feature(objc_arc) == 0
	[statusBar release];
	[programListServer release];
	programListServer = NULL;
#endif
}// end - (void) applicationWillTerminate:(NSNotification *)notification

- (void) listenHalt:(NSNotification *)note
{
	[statusBar toggleConnected];
	[programListServer stopListen];
}// end - (void) listenHalt:(NSNotification *)note

- (void) listenRestart:(NSNotification *)note
{
	[programListServer startListen];
	[statusBar toggleConnected];
}// end - (void) listenRestart:(NSNotification *)note

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

#pragma mark -
#pragma mark gui backend
#pragma mark menu interface
	// menu item actions
- (IBAction)menuSelectAutoOpen:(id)sender
{
}// end - (IBAction) menuSelectAutoOpen:(id)sender

- (IBAction)launchApplicaions:(id)sender
{
}// end - (IBAction) launchApplicaions:(id)sender

- (IBAction) openProgram:(id)sender
{
}// end - (IBAction) openProgram:(id)sender

- (IBAction) toggleUserState:(id)sender
{
	[nicoliveAccounts toggleUserState:(NSMenuItem *)sender];
	[menuAccounts setState:[nicoliveAccounts userState]];
}// end - (IBAction) toggleUserState:(id)sender

#pragma mark preference panel interface
	// login informaion box actions
- (IBAction) loginNameSelected:(id)sender
{
}// end - (IBAction) loginNameSelected:(id)sender

- (IBAction) toggleWatch:(id)sender
{
}// end - (IBAction) toggleWatch:(id)sender

- (IBAction) addAccount:(id)sender
{
}// end - (IBAction) addAccount:(id)sender

	// application collaboration actions
- (IBAction) appColaboChecked:(id)sender
{
}// end - (IBAction) appColaboChecked:(id)sender

	// manual watch list box actions
- (IBAction) autoOpenChecked:(id)sender
{
}// end - (IBAction) autoOpenChecked:(id)sender

- (IBAction) watchOfficialChannels:(id)sender
{
}//end - (IBAction) watchOfficialChannels:(id)sender

- (IBAction) addToWatchList:(id)sender
{
}// end - (IBAction) addToWatchList:(id)sender

- (IBAction) deleteFromWatchList:(id)sender
{
}// end - (IBAction) deleteFromWatchList:(id)sender

@end
