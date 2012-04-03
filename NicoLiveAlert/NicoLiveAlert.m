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
- (void) doBeforeSleep:(NSNotification *)note;
- (void) doAfterWakeup:(NSNotification *)note;
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
		addObserver: self selector: @selector(doBeforeSleep:)
	 name: NSWorkspaceWillSleepNotification object: NULL];
			// hook to wakeup notification
	[[[NSWorkspace sharedWorkspace] notificationCenter]
	 addObserver: self selector: @selector(doAfterWakeup:)
	 name: NSWorkspaceDidWakeNotification object: NULL];
	
}// end - (void) applicationDidFinishLaunching:(NSNotification *)aNotification

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
}// end - (void) applicationWillTerminate:(NSNotification *)notification

- (void) doBeforeSleep:(NSNotification *)note
{
}// end - (void) doBeforeSleep:(NSNotification *)note

- (void) doAfterWakeup:(NSNotification *)note
{
}// end - (void) doAfterSleep:(NSNotification *)note

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
