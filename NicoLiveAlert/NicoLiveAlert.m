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
- (void) loadPreferences;
- (void) savePreferences;
- (void) hookNotifications;
- (void) removeNotifications;
- (void) listenHalt:(NSNotification *)note;
- (void) listenRestart:(NSNotification *)note;
- (void) removeProgramNoFromTable:(NSNotification *)note;
- (void) doOutoOpen:(NSNotification *)note;
- (void) rowSelected:(NSNotification *)note;
@end

@implementation NicoLiveAlert
@synthesize menuStatusbar;
@synthesize prefencePanel;
@synthesize prefs;
@synthesize broadCasting;

#pragma mark -
#pragma mark override / delegate

- (void) awakeFromNib
{
	statusBar = [[NLStatusbar alloc] initWithMenu:menuStatusbar andImageName:@"sbicon"];
#if __has_feature(objc_arc) == 0
	[statusBar retain];
#endif
	broadCasting = NO;
}// end - (void) awakeFromNib

- (void) applicationWillFinishLaunching:(NSNotification *)aNotification
{
	[GrowlApplicationBridge setGrowlDelegate:self];
	prefs = [[NicoLivePrefManager alloc] init];
}// end 

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{		// restore preference
	[self loadPreferences];
		// setup for account
	[self setupAccounts];
		// setup drag & dorp table in preference panel
	[self setupTables];
		// hook notifications
	[self hookNotifications];
		// start monitor
	[self setupMonitor];
	[programSieves kick];
}// end - (void) applicationDidFinishLaunching:(NSNotification *)aNotification

- (void) applicationWillTerminate:(NSNotification *)notification
{
	[programSieves stopListen];

	[self removeNotifications];

	[self savePreferences];

#if __has_feature(objc_arc) == 0
	[statusBar release];
	[programSieves release];
	programSieves = NULL;
	[prefs release];
#endif
}// end - (void) applicationWillTerminate:(NSNotification *)notification

#pragma mark -

- (void) setupAccounts
{
		// make active accounts
	NSMutableArray *activeAccounts = [NSMutableArray array];
	NSDictionary *savedAccounts = [prefs loadAccounts];
	for (NSNumber *userid in [savedAccounts allKeys])
	{
		if ([[savedAccounts objectForKey:userid] boolValue] == YES)
			[activeAccounts addObject:userid];
	}// end foreach watchList items

		// make watch list dictionary
	NSMutableDictionary *watchList = [NSMutableDictionary dictionary];
	for (NSDictionary *watchItem in [aryManualWatchlist arrangedObjects])
		[watchList setValue:[watchItem valueForKey:keyAutoOpen]
							forKey:[[watchItem valueForKey:keyWatchItem] string]];
	// end foreach watch item

	nicoliveAccounts = [[NLUsers alloc] initWithActiveUsers:activeAccounts andManualWatchList:watchList];
		//	[nicoliveAccounts syncAccountAndTable:aryAccountItems];
	[comboLoginID setUsesDataSource:YES];
	[comboLoginID setDataSource:nicoliveAccounts];
	NSMenuItem *accountsItem = [menuStatusbar itemWithTag:tagAccounts];
	[accountsItem setSubmenu:[nicoliveAccounts usersMenu]];
	[accountsItem setState:[nicoliveAccounts userState]];
	[accountsItem setEnabled:YES];

		// store accounts to table
	NSMutableDictionary *entry = NULL;
	NSNumber *enabledAtStartup = NULL;
	for (NLAccount *account in [nicoliveAccounts users])
	{
		enabledAtStartup = [savedAccounts objectForKey:[account userid]];
		entry = [NSMutableDictionary dictionary];
		if (enabledAtStartup != NULL)
		{		// already entried accounts
			[entry setObject:enabledAtStartup forKey:keyAccountWatchEnabled];
			[entry setObject:[account userid] forKey:keyAccountUserID];
			[entry setObject:[account username] forKey:keyAccountNickname];
		}
		else
		{		// newly fetch from keychain
			[entry setObject:[NSNumber numberWithBool:YES] forKey:keyAccountWatchEnabled];
			[entry setObject:[account userid] forKey:keyAccountUserID];
			[entry setObject:[account username] forKey:keyAccountNickname];
		}// end if known or new entry
			// add entry to table
		[aryAccountItems addObject:entry];
			// cleanup entry for reuse
	}// end foreach account
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

- (void) loadPreferences
{
	NSArray *ary = NULL;
		// watch list
	ary = [prefs loadManualWatchList];
	if ([ary count] != 0)
		[aryManualWatchlist	addObjects:ary];

		// launcher items
	ary = [prefs loadLauncherDict];
	if ([ary count] != 0)
		[aryLauncherItems addObjects:ary];

		// collaboration flags
	dontOpenWhenImBroadcast = [prefs dontOpenWhenImBroadcast];
	kickFMELauncher = [prefs kickFMELauncher];
	kickCharlestonOnMyBroadcast = [prefs kickCharlestonOnMyBroadcast];
	kickCharlestonAtAutoOpen = [prefs kickCharlestonAtAutoOpen];
	kickCharlestonOpenByMe = [prefs kickCharlestonOpenByMe];
}// end - (void) loadPreferences

- (void) savePreferences
{
		// watch list
	[prefs saveManualWatchList:[aryManualWatchlist arrangedObjects]];
		// account list
	[prefs saveAccountsList:[aryAccountItems arrangedObjects]];
		// launcher items
	[prefs saveLauncherList:[aryLauncherItems arrangedObjects]];
		// collaboration flags
	[prefs setDontOpenWhenImBroadcast:dontOpenWhenImBroadcast];
	[prefs setKickFMELauncher:kickFMELauncher];
	[prefs setKickCharlestonOnMyBroadcast:kickCharlestonOnMyBroadcast];
	[prefs setKickCharlestonAtAutoOpen:kickCharlestonAtAutoOpen];
	[prefs setKickCharlestonOpenByMe:kickCharlestonOpenByMe];

}// end - (void) savePreferences

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
		// open by program number hook
	[application addObserver:self selector:@selector(removeProgramNoFromTable:) name:NLNotificationOpenByLiveNo object:NULL];
		// AutoOpen Notification hook
	[application addObserver:self selector:@selector(doOutoOpen:) name:NLNotificationAutoOpen object:NULL];
		// Tableview Notification hook
	[application addObserver:self selector:@selector(rowSelected:) name:NLNotificationSelectRow object:NULL];
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
		// remove open by program number hook
	[application removeObserver:self name:NLNotificationOpenByLiveNo object:NULL];
		// AutoOpen Notification
	[application removeObserver:self name:NLNotificationAutoOpen object:NULL];
		// TableView Notification
	[application removeObserver:self name:NLNotificationSelectRow object:NULL];
}// end - (void) hookNotifications

- (void) listenHalt:(NSNotification *)note
{
	if ([[note name] isEqualToString:NSWorkspaceWillSleepNotification])
		[programSieves stopListen];
}// end - (void) listenHalt:(NSNotification *)note

- (void) listenRestart:(NSNotification *)note
{
	if ([[note name] isEqualToString:NSWorkspaceDidWakeNotification])
		[programSieves startListen];
}// end - (void) listenRestart:(NSNotification *)note

- (void) removeProgramNoFromTable:(NSNotification *)note
{
	NSString *liveNo = [note object];
	for (NSDictionary *watchiItem in [aryManualWatchlist arrangedObjects])
		if ([[[watchiItem objectForKey:keyWatchItem] string] isEqualToString:liveNo] == YES)
			[aryManualWatchlist removeObject:watchiItem];
		// end if find notified program number
	// end foreach watchlist item
}// end - (void) removeProgramNoFromTable:(NSNotification *)note

- (void) doOutoOpen:(NSNotification *)note
{
	[[NSWorkspace sharedWorkspace] openURL:[note object]];
}// end - (void) doOutoOpen:(NSNotification *)note

- (void) rowSelected:(NSNotification *)note
{
	IOMTableViewDragAndDrop *targetTable = [[note object] objectForKey:KeyTableView];
	NSInteger selectedRow = [[[note object] objectForKey:keyRow] integerValue];

	if (targetTable == tblTinyLauncher)
		return;

	if (targetTable == tblAccountList)
		if (selectedRow != -1)
			[btnRemoveAccount setEnabled:YES];
		else
			[btnRemoveAccount setEnabled:NO];
	//end if 

	if (targetTable == tblManualWatchList)
		if (selectedRow != -1)
			[btnRemoveAccount setEnabled:YES];
		else
			[btnRemoveAccount setEnabled:NO];
	//end if 
}// end - (void) rowSelected:(NSNotification *)note

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
	NSDictionary *watchListItem = [[aryManualWatchlist arrangedObjects] objectAtIndex:[sender selectedRow]];
	BOOL autoOpen = [[watchListItem valueForKey:keyAutoOpen] boolValue];
	NSString *watchItem = [[watchListItem valueForKey:keyWatchItem] string];
	
	[nicoliveAccounts switchWatchListItemProperty:watchItem autoOpen:autoOpen];
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

		// add to watchlist
	[nicoliveAccounts addWatchListItem:[watchItem string] autoOpen:NO];
		// add to table
	NSMutableDictionary *watchListItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				   [NSNumber numberWithBool:NO], keyAutoOpen,
				   watchItem, keyWatchItem,
				   itemComment, keyNote, nil];
	[aryManualWatchlist addObject:watchListItem];

		// cleanup textfields
	[watchItemName setStringValue:EMPTYSTRING];
	[watchItemComment setStringValue:EMPTYSTRING];
	[btnAddWatchListItem setEnabled:NO];
}// end - (IBAction) addToWatchList:(id)sender

- (IBAction) removeFromWatchList:(id)sender
{
	NSInteger row = [tblManualWatchList selectedRow];
	if (row == -1)
		return;

		// get removed item
	NSDictionary *watchItem = [[aryManualWatchlist arrangedObjects] objectAtIndex:row];
	NSString *item = [[watchItem valueForKey:keyWatchItem] string];

		// remove from watch list
	[nicoliveAccounts removeWatchListItem:item];

		// remove from watch list table
	[[aryManualWatchlist arrangedObjects] removeObjectAtIndex:row];
}// end - (IBAction) deleteFromWatchList:(id)sender

	// login informaion box actions
- (IBAction) loginNameSelected:(id)sender
{
	NSString *userAccount = [sender stringValue];
	for (NLAccount *user in [nicoliveAccounts users])
		if ([userAccount isEqualToString:[user mailaddr]] == YES)
			[secureFieldPassword setStringValue:[user password]];
		// end if account found
	// end foreach accounts
}// end - (IBAction) loginNameSelected:(id)sender

- (IBAction) addAccount:(id)sender
{
	NSString *account = [comboLoginID stringValue];
	NSString *password = [secureFieldPassword stringValue];
	OSStatus status;
	status = [nicoliveAccounts addUser:account withPassword:password];
	if (status == noErr)
		for (NLAccount *user in [nicoliveAccounts users])
		{
			if ([[user mailaddr] isEqualToString:account] == YES)
			{
				NSMutableDictionary *entry = [NSMutableDictionary dictionary];
				[entry setValue:[NSNumber numberWithBool:YES] forKey:keyAccountWatchEnabled];
				[entry setValue:[user userid] forKey:keyAccountUserID];
				[entry setValue:[user username] forKey:keyAccountNickname];
				[aryAccountItems addObject:entry];

				break;
			}// end if user is now added
		}// end foreach user
}// end - (IBAction) addAccount:(id)sender

- (IBAction) removeAccount:(id)sender
{
	
}// end - (IBAction) removeAccount:(id)sender

- (IBAction) updateAccountInfo:(id)sender
{
	BOOL success = [nicoliveAccounts updateUserAccountInforms];
	if (success == NO)	// update faild nothing about to do
		return;

		// update table
			// create userid - nickname table
	NSMutableDictionary *nicknames = [NSMutableDictionary dictionary];
	for (NLAccount *user in [nicoliveAccounts users])
		[nicknames setObject:[user username] forKey:[user userid]];
	// end foreach users

	for (NSMutableDictionary *info in [aryAccountItems arrangedObjects])
		[info setValue:[nicknames objectForKey:[info valueForKey:keyAccountUserID]]
				forKey:keyAccountNickname];
	// end foreach tableview entry
}// end - (IBAction) updateAccountInfo:(id)sender

	// application collaboration actions
- (IBAction) appColaboChecked:(id)sender
{
	switch ([sender tag]) {
		case tagDoNotAutoOpenInMyBroadcast:
			dontOpenWhenImBroadcast = !dontOpenWhenImBroadcast;
			break;
		case tagKickFMELauncher:
			kickFMELauncher = !kickFMELauncher;
			break;
		case tagKickCharlestonOnMyBroadcast:
			kickCharlestonOnMyBroadcast = !kickCharlestonOnMyBroadcast;
			break;
		case tagKickCharlestonAtAutoOpen:
			kickCharlestonAtAutoOpen = !kickCharlestonAtAutoOpen;
			break;
		case tagKickCharlestonByOpenFromMe:
			kickCharlestonOpenByMe = !kickCharlestonOpenByMe;
			break;
		default:
			break;
	}// end switch by checkbox's tag
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
			[secureFieldPassword setStringValue:@""];
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

- (void) growlNotificationTimedOut:(id)clickContext
{
}// end - (void) growlNotificationTimedOut:(id)clickContext;

- (BOOL) hasNetworkClientEntitlement
{
	return YES;
}// end - (BOOL) hasNetworkClientEntitlement
@end
