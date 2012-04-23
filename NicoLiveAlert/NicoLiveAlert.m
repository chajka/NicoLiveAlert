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
- (void) setupAccounts;
- (void) hookNotifications;
- (void) removeNotifications;
- (void) listenHalt:(NSNotification *)note;
- (void) listenRestart:(NSNotification *)note;
@end

@implementation NicoLiveAlert
@synthesize menuStatusbar;
@synthesize prefencePanel;

#pragma mark -
#pragma mark override / delegate

- (void) awakeFromNib
{
	statusBar = [[NLStatusbar alloc] initWithMenu:menuStatusbar andImageName:@"sbicon"];
#if __has_feature(objc_arc) == 0
	[statusBar retain];
#endif
}// end - (void) awakeFromNib

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{		// setup for account
	[self setupAccounts];

		// hook notifications
	[self hookNotifications];

		// start monitor
	[self setupMonitor];
	[programSieves kick];
	[statusBar setConnected:YES];
}// end - (void) applicationDidFinishLaunching:(NSNotification *)aNotification

- (void) applicationWillTerminate:(NSNotification *)notification
{
	[programSieves stopListen];

	[self removeNotifications];

#if __has_feature(objc_arc) == 0
	[statusBar release];
	[programSieves release];
	programSieves = NULL;
#endif
}// end - (void) applicationWillTerminate:(NSNotification *)notification

#pragma mark -

- (void) setupAccounts
{
	nicoliveAccounts = [[NLUsers alloc] initWithActiveUsers:NULL andManualWatchList:[NSDictionary dictionary]];
	NSMenuItem *accountsItem = [menuStatusbar itemWithTag:tagAccounts];
	[accountsItem setSubmenu:[nicoliveAccounts usersMenu]];
	[accountsItem setState:[nicoliveAccounts userState]];
	[accountsItem setEnabled:YES];
}// end - (void) setupAccounts

- (void) setupMonitor
{
	programSieves = [[NLProgramList alloc] init];
	NLActivePrograms *activeprograms = [[NLActivePrograms alloc] init];
	[activeprograms setSbItem:statusBar];
	[activeprograms setUsers:nicoliveAccounts];
	[programSieves setWatchList:[nicoliveAccounts watchlist]];
	[programSieves setActivePrograms:activeprograms];
#if __has_feature(objc_arc) == 0
		// activeprograms keep in programSieves
	[activeprograms release];
#endif
}// end - (void) setupMonitor

- (void) hookNotifications
{
	NSNotificationCenter *shared = [[NSWorkspace sharedWorkspace] notificationCenter];
	NSNotificationCenter *application = [NSNotificationCenter defaultCenter];
		// sleep and wakeup notification hook
			// hook to sleep notification
	[shared addObserver:self selector: @selector(listenHalt:) name: NSWorkspaceWillSleepNotification object: NULL];
			// hook to wakeup notification
	[shared addObserver:self selector: @selector(listenRestart:) name: NSWorkspaceDidWakeNotification object: NULL];
		// Connection Notification Hook
			// hook to connection lost notification
	[application addObserver:self selector:@selector(listenHalt:) name:NLNotificationConnectionLost object:NULL];
			// hook to connection reactive notification
	[application addObserver:self selector:@selector(listenRestart:) name:NLNotificationConnectionRised object:NULL];
}// end - (void) hookNotifications

- (void) removeNotifications
{
	NSNotificationCenter *shared = [[NSWorkspace sharedWorkspace] notificationCenter];
	NSNotificationCenter *application = [NSNotificationCenter defaultCenter];
		// release sleep and wakeup notifidation
			// remove sleep notification
	[shared removeObserver:self name:NSWorkspaceWillSleepNotification object:NULL];
			// remove wakeup notification
	[shared removeObserver:self name:NSWorkspaceDidWakeNotification object:NULL];
		// Connection Notification Hook
			// remove Connection lost notification
	[application removeObserver:self name:NLNotificationConnectionLost object:NULL];
			// remove Connection Rised notification
	[application removeObserver:self name:NLNotificationConnectionRised object:NULL];
}// end - (void) hookNotifications

- (void) listenHalt:(NSNotification *)note
{
	[statusBar toggleConnected];
	if ([[note name] isEqualToString:NSWorkspaceWillSleepNotification])
		[programSieves stopListen];
}// end - (void) listenHalt:(NSNotification *)note

- (void) listenRestart:(NSNotification *)note
{
	[statusBar toggleConnected];
	if ([[note name] isEqualToString:NSWorkspaceDidWakeNotification])
		[programSieves startListen];
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
#if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_7
		// open by NSWorkspace
	[[NSWorkspace sharedWorkspace] openURL:[sender representedObject]];
#else
		// open by XPC
#endif
}// end - (IBAction) openProgram:(id)sender

- (IBAction) toggleUserState:(id)sender
{
	[nicoliveAccounts toggleUserState:(NSMenuItem *)sender];
	[menuAccounts setState:[nicoliveAccounts userState]];
	[statusBar setUserState:[nicoliveAccounts userState]];
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
