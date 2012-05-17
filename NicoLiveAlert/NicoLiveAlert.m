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
- (void) openLiveProgram:(NSString *)URLString;
- (void) hookNotifications;
- (void) removeNotifications;
- (void) listenHalt:(NSNotification *)note;
- (void) listenRestart:(NSNotification *)note;
- (void) removeProgramNoFromTable:(NSNotification *)note;
- (void) startMyProgram:(NSNotification *)note;
- (void) endMyProgram:(NSNotification *)note;
- (void) doAutoOpen:(NSNotification *)note;
- (void) rowSelected:(NSNotification *)note;
@end

@implementation NicoLiveAlert
@synthesize menuStatusbar;
@synthesize prefencePanel;
@synthesize prefs;
@synthesize broadCasting;
@synthesize dontOpenWhenImBroadcast;
@synthesize kickFMELauncher;
@synthesize kickCharlestonOnMyBroadcast;
@synthesize kickCharlestonAtAutoOpen;
@synthesize kickCharlestonOpenByMe;

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
	prefs = [[NicoLivePrefManager alloc] initWithDefaults:userDefaults];
	notificationPosted = NO;
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
	[programSieves halt];

	[self removeNotifications];

	[self savePreferences];

#if __has_feature(objc_arc) == 0
	[statusBar release];
	[programSieves release];
	programSieves = nil;
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

	nicoliveAccounts = [[NLUsers alloc] initWithActiveUsers:activeAccounts
										 andManualWatchList:watchList];
	[statusBar setUserState:[nicoliveAccounts userState]];
	[comboLoginID setUsesDataSource:YES];
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
	[comboLoginID setDataSource:nicoliveAccounts];
#else
	[comboLoginID setDataSource:(id)nicoliveAccounts];
#endif
	NSMenuItem *accountsItem = [menuStatusbar itemWithTag:tagAccounts];
	[accountsItem setSubmenu:[nicoliveAccounts usersMenu]];
	[accountsItem setState:[nicoliveAccounts userState]];
	[accountsItem setEnabled:YES];

		// store accounts to table
	NSMutableDictionary *entry = nil;
	NSNumber *enabledAtStartup = nil;
	for (NLAccount *account in [nicoliveAccounts users])
	{
		enabledAtStartup = [savedAccounts objectForKey:[account userid]];
		entry = [NSMutableDictionary dictionary];
		if (enabledAtStartup != nil)
		{		// already entried accounts
			[entry setValue:enabledAtStartup forKey:keyAccountWatchEnabled];
			[entry setValue:[account userid] forKey:keyAccountUserID];
			[entry setValue:[account nickname] forKey:keyAccountNickname];
			[entry setValue:[account mailaddr] forKey:keyAccountMailAddr];
		}
		else
		{		// newly fetch from keychain
			[entry setValue:[NSNumber numberWithBool:YES] forKey:keyAccountWatchEnabled];
			[entry setValue:[account userid] forKey:keyAccountUserID];
			[entry setValue:[account nickname] forKey:keyAccountNickname];
			[entry setValue:[account mailaddr] forKey:keyAccountMailAddr];
		}// end if known or new entry
			// add entry to table
		[aryAccountItems addObject:entry];
			// cleanup entry for reuse
	}// end foreach account
}// end - (void) setupAccounts

- (void) setupTables
{
		// setup Wachlist drag & drop reordering
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
	[tblManualWatchList registerForDraggedTypes:[NSArray arrayWithObject:WatchListPasteboardType]];
	[aryManualWatchlist setWatchListTable:tblManualWatchList];
		// setup AccountList drag & drop reordering
	[tblAccountList registerForDraggedTypes:[NSArray arrayWithObject:AccountListPasteboardType]];
	[aryManualWatchlist setAccountInfoTable:tblAccountList];
		// setup LauncherList drag, dorp and reordering
	[tblTinyLauncher registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, LauncherPasteboardType, nil]];
	[aryLauncherItems setLaunchListTable:tblTinyLauncher];
#endif
}// end - (void) setupTables

- (void) setupMonitor
{
	programSieves = [[NLProgramList alloc] init];
	NLActivePrograms *activeprograms = [[NLActivePrograms alloc] init];
	[activeprograms setSbItem:statusBar];
	[activeprograms setUsers:nicoliveAccounts];
	[programSieves setWatchList:[nicoliveAccounts watchlist]];
	[programSieves setActivePrograms:activeprograms];
	[programSieves setWatchOfficial:watchOfficialProgram];
	[programSieves setWatchChannel:watchOfficialChannel];
#if __has_feature(objc_arc) == 0
		// activeprograms keep in programSieves
	[activeprograms release];
#endif
}// end - (void) setupMonitor

- (void) loadPreferences
{
	NSArray *ary = nil;
		// watch list
	ary = [prefs loadManualWatchList];
	if ([ary count] != 0)
		[aryManualWatchlist	addObjects:ary];
	enableAutoOpen = [prefs loadAutoOpenMenuState];
	[menuItemAutoOpen setState:enableAutoOpen];
	watchOfficialProgram = [prefs loadWatchOfficialProgramState];
	[chkboxWatchOfficialProgram setState:watchOfficialProgram];
	watchOfficialChannel = [prefs loadWatchOfficialChannelState];
	[chkboxWatchOfficialChannel setState:watchOfficialChannel];

		// launcher items
	ary = [prefs loadLauncherDict];
	if ([ary count] != 0)
		[aryLauncherItems addObjects:ary];

		// auto open state
	enableAutoOpen = ([menuItemAutoOpen state] == NSOnState) ? YES : NO;
		// collaboration flags
	dontOpenWhenImBroadcast = ([chkboxDonotAutoOpenAtBroadcasting state] == NSOnState) ? YES : NO;
	kickFMELauncher = ([chkboxRelationWithFMELauncher state] == NSOnState) ? YES : NO;
	kickCharlestonOnMyBroadcast = ([chkboxRelationWithCharlestonMyBroadcast state] == NSOnState) ? YES : NO;
	kickCharlestonAtAutoOpen = ([chkboxRelationAutoOpenAndCharleston state] == NSOnState) ? YES : NO;
	kickCharlestonOpenByMe = ([chkboxRelationChooseFromMenuAndCharleston state] == NSOnState) ? YES : NO;
}// end - (void) loadPreferences

- (void) savePreferences
{		// watch list
	[prefs saveManualWatchList:[aryManualWatchlist arrangedObjects]];
	[prefs saveAutoOpenMenuState:enableAutoOpen];
	[prefs saveWatchOfficialProgramState:watchOfficialProgram];
	[prefs saveWatchOfficialChannelState:watchOfficialChannel];
		// account list
	[prefs saveAccountsList:[aryAccountItems arrangedObjects]];
		// launcher items
	[prefs saveLauncherList:[aryLauncherItems arrangedObjects]];
}// end - (void) savePreferences

- (void) openLiveProgram:(NSString *)URLString
{
	NSURL *url = [NSURL URLWithString:URLString];
	[[NSWorkspace sharedWorkspace] openURL:url];
	notificationPosted = NO;
}// end - (void) openLiveProgram:(NSString *)URLString

- (void) hookNotifications
{
	NSNotificationCenter *myMac = [[NSWorkspace sharedWorkspace] notificationCenter];
	NSNotificationCenter *this = [NSNotificationCenter defaultCenter];
		// sleep and wakeup notification hooks
			// hook to sleep notification
	[myMac addObserver:self selector: @selector(listenHalt:) name: NSWorkspaceWillSleepNotification object: nil];
			// hook to wakeup notification
	[myMac addObserver:self selector: @selector(listenRestart:) name: NSWorkspaceDidWakeNotification object: nil];
		// Connection Notification hooks
			// hook to connection lost notification
	[this addObserver:self selector:@selector(listenHalt:) name:NLNotificationConnectionLost object:nil];
			// hook to connection reactive notification
	[this addObserver:self selector:@selector(listenRestart:) name:NLNotificationConnectionRised object:nil];
		// open by program number hook
	[this addObserver:self selector:@selector(removeProgramNoFromTable:) name:NLNotificationFoundLiveNo object:nil];
		// broadcast kind notification
	[this addObserver:self selector:@selector(startMyProgram:) name:NLNotificationMyBroadcastStart object:nil];
	[this addObserver:self selector:@selector(endMyProgram:) name:NLNotificationMyBroadcastStart object:nil];
		// AutoOpen Notification hook
	[this addObserver:self selector:@selector(doAutoOpen:) name:NLNotificationAutoOpen object:nil];
		// Tableview Notification hook
	[this addObserver:self selector:@selector(rowSelected:) name:NLNotificationSelectRow object:nil];
}// end - (void) hookNotifications

- (void) removeNotifications
{
	NSNotificationCenter *myMac = [[NSWorkspace sharedWorkspace] notificationCenter];
	NSNotificationCenter *this = [NSNotificationCenter defaultCenter];
		// release sleep and wakeup notifidation
			// remove sleep notification
	[myMac removeObserver:self name:NSWorkspaceWillSleepNotification object:nil];
			// remove wakeup notification
	[myMac removeObserver:self name:NSWorkspaceDidWakeNotification object:nil];
		// Connection Notification Hook
			// remove Connection lost notification
	[this removeObserver:self name:NLNotificationConnectionLost object:nil];
			// remove Connection Rised notification
	[this removeObserver:self name:NLNotificationConnectionRised object:nil];
		// remove open by program number hook
	[this removeObserver:self name:NLNotificationFoundLiveNo object:nil];
		// broadcast kind notification
	[this removeObserver:self name:NLNotificationMyBroadcastStart object:nil];
	[this removeObserver:self name:NLNotificationMyBroadcastEnd object:nil];
		// AutoOpen Notification
	[this removeObserver:self name:NLNotificationAutoOpen object:nil];
		// TableView Notification
	[this removeObserver:self name:NLNotificationSelectRow object:nil];
}// end - (void) hookNotifications

#pragma mark -
#pragma mark callback by notification

- (void) listenHalt:(NSNotification *)note
{
	if ([[note name] isEqualToString:NSWorkspaceWillSleepNotification])
		[programSieves halt];
}// end - (void) listenHalt:(NSNotification *)note

- (void) listenRestart:(NSNotification *)note
{
	if ([[note name] isEqualToString:NSWorkspaceDidWakeNotification])
		[programSieves kick];
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

- (void) startMyProgram:(NSNotification *)note
{
	broadCasting = YES;
}// end - (void) startMyProgram:(NSNotification *)note

- (void) endMyProgram:(NSNotification *)note
{
	broadCasting = NO;
}// end - (void) endMyProgram:(NSNotification *)note

	// TODO: implement check need kick FMELauncher
	// TODO: implement check need kick charleston at my program
	// TODO: implement check need kick charleston at default
- (void) doAutoOpen:(NSNotification *)note
{
	NSNotificationCenter *myMac = [[NSWorkspace sharedWorkspace] notificationCenter];
	if (broadCasting == YES)
	{		// check need kick charleston
		if (kickCharlestonAtAutoOpen == YES)
			;
			// check need kick FMELauncher
		if (kickFMELauncher == YES)
			;
		NSDictionary *info = 
			[NSDictionary dictionaryWithObjectsAndKeys:
				[note object], keyNLNotificationLiveNumber,
				[NSNumber numberWithBool:YES], keyNLNotificationIsMyLive, nil];
		if ((kickCharlestonAtAutoOpen == YES) || (kickFMELauncher == YES))
		{
			[myMac postNotification:[NSNotification notificationWithName:NLNotificationMyLiveStart object:info]];
			notificationPosted = YES;
		}// end if
			// check never want auto open when I'm broadcasting
		if (dontOpenWhenImBroadcast == YES)
			return;
	}// end if

		// check need kick charleston
	if ((notificationPosted == NO) && 
		(dontOpenWhenImBroadcast == NO) && 
		(kickCharlestonAtAutoOpen == YES))
	{
		NSDictionary *info = 
			[NSDictionary dictionaryWithObjectsAndKeys:
				[note object], keyNLNotificationLiveNumber,
				[NSNumber numberWithBool:NO], keyNLNotificationIsMyLive, nil];
		[myMac postNotification:[NSNotification notificationWithName:NLNotificationLiveStart object:info]];
	}// end if

	[self openLiveProgram:[note object]];
	notificationPosted = NO;
}// end - (void) doAutoOpen:(NSNotification *)note

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
	enableAutoOpen = ([sender state] == NSOnState) ? YES : NO;
	[sender setState:enableAutoOpen];
	[programSieves setEnableAutoOpen:enableAutoOpen];
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

	// TODO: implement check need kick charlestion
- (IBAction) openProgram:(id)sender
{
/* #if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_7 */
		// check need kick charlestion
	NSString *program = [[sender representedObject] valueForKey:keyLiveNumber];
	if (kickCharlestonOpenByMe == YES)
	{
		NSNotificationCenter *myMac = [[NSWorkspace sharedWorkspace] notificationCenter];
		NSDictionary *info = 
			[NSDictionary dictionaryWithObjectsAndKeys:
				program, keyNLNotificationLiveNumber,
				[NSNumber numberWithBool:NO], keyNLNotificationIsMyLive, nil];
		[myMac postNotification:[NSNotification notificationWithName:NLNotificationLiveStart object:info]];
	}
		// open by NSWorkspace
	[self openLiveProgram:program];
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
	NSDictionary *dict = nil;
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
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

- (IBAction) watchOfficialProgram:(id)sender
{		// sender is chkboxWatchOfficialProgram
	watchOfficialProgram = ([sender state] == NSOnState) ? YES : NO;
	
	[programSieves setWatchOfficial:watchOfficialProgram];
	[statusBar setWatchOfficial:[programSieves officialState]]; 
}// end - (IBAction) watchOfficialProgram:(id)sender

- (IBAction) watchOfficialChannel:(id)sender
{		// sender is chkboxWatchOfficialChannel
	watchOfficialChannel = ([sender state] == NSOnState) ? YES : NO;

	[programSieves setWatchChannel:watchOfficialChannel];
	[statusBar setWatchOfficial:[programSieves officialState]]; 
}//end - (IBAction) watchOfficialChannel:(id)sender

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

	NSURL *url = nil;
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
	BOOL autoOpen = ([chkboxAutoOpen state] == NSOnState) ? YES : NO;
	[nicoliveAccounts addWatchListItem:[watchItem string] autoOpen:autoOpen];
		// add to table
	NSMutableDictionary *watchListItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				   [NSNumber numberWithBool:autoOpen], keyAutoOpen,
				   watchItem, keyWatchItem,
				   itemComment, keyNote, nil];
	[aryManualWatchlist addObject:watchListItem];

		// cleanup textfields
	[watchItemName setStringValue:EMPTYSTRING];
	[watchItemComment setStringValue:EMPTYSTRING];
	[chkboxAutoOpen setState:NSOffState];
	[chkboxAutoOpen setEnabled:NO];
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
	NLAccount *user = [nicoliveAccounts addUser:account withPassword:password status:&status];
	if (status == noErr)
	{		// feedback to account table
		NSMutableDictionary *entry = [NSMutableDictionary dictionary];
		[entry setValue:[NSNumber numberWithBool:YES] forKey:keyAccountWatchEnabled];
		[entry setValue:[user userid] forKey:keyAccountUserID];
		[entry setValue:[user nickname] forKey:keyAccountNickname];
		[entry setValue:[user mailaddr] forKey:keyAccountMailAddr];
		[aryAccountItems addObject:entry];
	}
	else
	{		// error : show error sheet
	}// end if create account success
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
		[nicknames setObject:[user nickname] forKey:[user userid]];
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
			dontOpenWhenImBroadcast = ([chkboxDonotAutoOpenAtBroadcasting state] == NSOnState) ? YES : NO;
			break;
		case tagKickFMELauncher:
			kickFMELauncher = ([chkboxRelationWithFMELauncher state] == NSOnState) ? YES : NO;
			break;
		case tagKickCharlestonOnMyBroadcast:
			kickCharlestonOnMyBroadcast = ([chkboxRelationWithCharlestonMyBroadcast state] == NSOnState) ? YES : NO;
			break;
		case tagKickCharlestonAtAutoOpen:
			kickCharlestonAtAutoOpen = ([chkboxRelationAutoOpenAndCharleston state] == NSOnState) ? YES : NO;
			break;
		case tagKickCharlestonByOpenFromMe:
			kickCharlestonOpenByMe = ([chkboxRelationChooseFromMenuAndCharleston state] == NSOnState) ? YES : NO;
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
			{
				[btnAddWatchListItem setEnabled:YES];
				[chkboxAutoOpen setEnabled:YES];
			}
			else
			{
				[btnAddWatchListItem setEnabled:NO];
				[chkboxAutoOpen setEnabled:NO];
			}
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

#pragma mark Other application collaboration
- (void) startFMLE:(NSString *)live
{
	NSDistantObject *fmle = [NSConnection rootProxyForConnectionWithRegisteredName:FMELauncher host:@""];
	[fmle startFMLE:live];
}// end - (void) startFMLE:(NSString *)live

- (void) stopFMLE
{
	NSDistantObject *fmle = [NSConnection rootProxyForConnectionWithRegisteredName:FMELauncher host:@""];
	[fmle stopFMLE];
}// end - (void) stopFMLE

- (void) joinToLive:(NSString *)live
{
	NSDistantObject *charleston = [NSConnection rootProxyForConnectionWithRegisteredName:Charleston host:@""];
	[charleston joinToLive:live];
}// - (void) joinToLive:(NSString *)live

#pragma mark -
#pragma mark GrowlApplicationBridge delegate
- (void) growlNotificationWasClicked:(id)clickContext
{
	NSString *url = [NSString stringWithString:clickContext];
	[self openLiveProgram:url];
}// end - (void) growlNotificationWasClicked:(id)clickContext

- (void) growlNotificationTimedOut:(id)clickContext
{
}// end - (void) growlNotificationTimedOut:(id)clickContext;

- (BOOL) hasNetworkClientEntitlement
{
	return YES;
}// end - (BOOL) hasNetworkClientEntitlement
@end
