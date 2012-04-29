//
//  NicoLiveAlert.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NicoLiveAlert.h"
#import "NicoLiveAlertDefinitions.h"
#import "OnigRegexp.h"
#import "NSAttributedStringAdditions.h"

@interface NicoLiveAlert ()
- (BOOL) checkFirstLaunch;
- (void) setupAccounts;
- (void) setupTables;
- (void) setupMonitor;
- (void) hookNotifications;
- (void) removeNotifications;
- (void) listenHalt:(NSNotification *)note;
- (void) listenRestart:(NSNotification *)note;
- (void) doOutoOpen:(NSNotification *)note;
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

- (void) applicationWillFinishLaunching:(NSNotification *)aNotification
{
	[GrowlApplicationBridge setGrowlDelegate:self];
}// end 

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{		// setup for account
	[self setupAccounts];
		// setup drag & dorp table in preference panel
	[self setupTables];
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
	[comboLoginID setUsesDataSource:YES];
	[comboLoginID setDataSource:nicoliveAccounts];
	NSMenuItem *accountsItem = [menuStatusbar itemWithTag:tagAccounts];
	[accountsItem setSubmenu:[nicoliveAccounts usersMenu]];
	[accountsItem setState:[nicoliveAccounts userState]];
	[accountsItem setEnabled:YES];
}// end - (void) setupAccounts

- (void) setupTables
{
		// setup Wachlist drag & drop reordering
	[tblManualWatchList registerForDraggedTypes:[NSArray arrayWithObject:WatchListPasteboardType]];
	[aryManualWatchlist setWatchListTable:tblManualWatchList];
		// setup AccountList drag & drop reordering
	[tblAccountList registerForDraggedTypes:[NSArray arrayWithObject:AccountListPasteboardType]];
	[aryManualWatchlist setAccountInfoTable:tblAccountList];
		// setup LauncherList drag, dorp and reordering
	[tblTinyLauncher registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, LauncherPasteboardType, nil]];
	[aryLauncherItems setLaunchListTable:tblTinyLauncher];
}// end - (void) setupTables

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
		// sleep and wakeup notification hooks
			// hook to sleep notification
	[shared addObserver:self selector: @selector(listenHalt:) name: NSWorkspaceWillSleepNotification object: NULL];
			// hook to wakeup notification
	[shared addObserver:self selector: @selector(listenRestart:) name: NSWorkspaceDidWakeNotification object: NULL];
		// Connection Notification hooks
			// hook to connection lost notification
	[application addObserver:self selector:@selector(listenHalt:) name:NLNotificationConnectionLost object:NULL];
			// hook to connection reactive notification
	[application addObserver:self selector:@selector(listenRestart:) name:NLNotificationConnectionRised object:NULL];
		// AutoOpen Notification hook
	[application addObserver:self selector:@selector(doOutoOpen:) name:NLNotificationAutoOpen object:NULL];
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
		// AutoOpen Notification
	[application removeObserver:self name:NLNotificationAutoOpen object:NULL];
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

- (void) doOutoOpen:(NSNotification *)note
{
	[[NSWorkspace sharedWorkspace] openURL:[note object]];
}// end - (void) doOutoOpen:(NSNotification *)note

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
	NSCellStateValue state = [sender state];
	if (state == NSOnState)
		[programSieves setEnableAutoOpen:YES];
	else
		[programSieves setEnableAutoOpen:NO];
}// end - (IBAction) menuSelectAutoOpen:(id)sender

- (IBAction)launchApplicaions:(id)sender
{
	NSArray *applicationInfo = [aryLauncherItems arrangedObjects];
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	for (NSDictionary *app in applicationInfo)
	{
		[ws launchApplication:[app valueForKey:keyLauncherAppPath]];
	}// end for
}// end - (IBAction) launchApplicaions:(id)sender

- (IBAction) openProgram:(id)sender
{
/* #if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_7 */
		// open by NSWorkspace
	[[NSWorkspace sharedWorkspace] openURL:[sender representedObject]];
/*
#else
		// open by XPC
#endif
*/
}// end - (IBAction) openProgram:(id)sender

- (IBAction) toggleUserState:(id)sender
{
	NSCellStateValue usersState = NSOffState;
	usersState = [nicoliveAccounts toggleUserState:(NSMenuItem *)sender];
	[menuAccounts setState:usersState];
	[statusBar setUserState:usersState];
}// end - (IBAction) toggleUserState:(id)sender

- (IBAction) showAboutPanel:(id)sender
{
	NSDictionary *dict = NULL;
#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_7
	dict = [NSDictionary dictionaryWithObject:AppnameLion forKey:keyAppName];
#else
	dict = [NSDictionary dictionaryWithObject:AppNameLepard forKey:keyAppName];
#endif
	[NSApp orderFrontStandardAboutPanelWithOptions:dict];
}// end - (IBAction) showAboutPanel:(id)sender

#pragma mark -
#pragma mark preference panel interface
	// manual watch list box actions
- (IBAction) autoOpenChecked:(id)sender
{
}// end - (IBAction) autoOpenChecked:(id)sender

- (IBAction) watchOfficialChannels:(id)sender
{		// sender is chkboxWatchOfficialProgram
	BOOL state = ([sender state] == NSOnState) ? YES : NO;
		
	[programSieves setWatchOfficial:state];
	[statusBar setWatchOfficial:state]; 
}//end - (IBAction) watchOfficialChannels:(id)sender

- (IBAction) addToWatchList:(id)sender
{
	NSDictionary *watchTargetKindDict = [NSDictionary dictionaryWithObjectsAndKeys:
		 [NSNumber numberWithInteger:indexWatchCommunity], kindCommunity,
		 [NSNumber numberWithInteger:indexWatchChannel], kindChannel,
		 [NSNumber numberWithInteger:indexWatchProgram], kindProgram, nil];
	NSString *itemName = [watchItemName stringValue];
	NSString *itemComment = [watchItemComment stringValue];
	NSAttributedString *watchItem;
	OnigRegexp *watchKindRegex = [OnigRegexp compile:WatchKindRegex];
	OnigResult *targetKind = [watchKindRegex search:itemName];

	NSURL *url = NULL;
	switch ([[watchTargetKindDict valueForKey:[targetKind stringAt:1]] integerValue])
	{
		case indexWatchCommunity:
			url = [NSURL URLWithString:[NSString stringWithFormat:URLFormatCommunity, itemName]];
			watchItem = [NSAttributedString attributedStringWithLinkToURL:url title:itemName];
			break;
		case indexWatchChannel:
			url = [NSURL URLWithString:[NSString stringWithFormat:URLFormatChannel, itemName]];
			watchItem = [NSAttributedString attributedStringWithLinkToURL:url title:itemName];
			break;
		case indexWatchProgram:
			url = [NSURL URLWithString:[NSString stringWithFormat:URLFormatLive, itemName]];
			watchItem = [NSAttributedString attributedStringWithLinkToURL:url title:itemName];
			break;
		default:
			url = [NSURL URLWithString:[NSString stringWithFormat:URLFormatUser, itemName]];
			watchItem = [NSAttributedString attributedStringWithLinkToURL:url title:itemName];
			break;
	}// end switch by watch item kind

		// add to table
	NSMutableDictionary *watchListItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				   [NSNumber numberWithBool:NO], keyAutoOpen,
				   watchItem, keyWatchItem,
				   itemComment, keyNote, nil];
	[aryManualWatchlist addObject:watchListItem];

		// cleanup textfields
	[watchItemName setStringValue:EMPTYSTRING];
	[watchItemComment setStringValue:EMPTYSTRING];
}// end - (IBAction) addToWatchList:(id)sender

- (IBAction) removeFromWatchList:(id)sender
{
}// end - (IBAction) deleteFromWatchList:(id)sender

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

#pragma mark -
#pragma mark delegate
#pragma mark NSControl delegate
- (void) controlTextDidChange:(NSNotification *)aNotification
{
	switch ([[aNotification object] tag]) {
		case tagWatchItemBody:
			if ([[watchItemName stringValue] isEqualToString:EMPTYSTRING] == NO)
				[btnAddWatchListItem setEnabled:YES];
			else
				[btnAddWatchListItem setEnabled:NO];
			break;

		case tagAccountLoginID:
		case tagAccountPassword:
			if (([[comboLoginID stringValue] isEqualToString:EMPTYSTRING] == NO)
				&& ([[secureFieldPassword stringValue] isEqualToString:EMPTYSTRING] == NO))
				[btnAddAccount setEnabled:YES];
			else 
				[btnAddAccount setEnabled:NO];
			break;
			
		default:
			break;
	}// end switch by text field
}// end - (void) controlTextDidChange:(NSNotification *)aNotification

#pragma mark -
#pragma mark GrowlApplicationBridge delegate
- (void) growlNotificationWasClicked:(id)clickContext
{
	NSURL *url = [NSURL URLWithString:clickContext];
	[[NSWorkspace sharedWorkspace] openURL:url];
}// end - (void) growlNotificationWasClicked:(id)clickContext

@end
