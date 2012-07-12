//
//  NicoLiveAlert.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NicoLiveAlert.h"
#import "NicoLiveAlertDefinitions.h"
#import "NicoLiveAlertCollaboration.h"
#import "OnigRegexp.h"
#import "NSAttributedStringAdditions.h"
#import "NLProgram.h"
#if MAC_OS_X_VERSION_MIN_REQUIRED == MAC_OS_X_VERSION_10_7
#import "NicoLiveAlert+XPC.h"
#else
#import "NicoLiveAlert+Collaboration.h"
#endif

@interface NicoLiveAlert ()
- (BOOL) checkFirstLaunch;
- (void) disableAtLeopardItems;
- (void) setupAccounts;
- (void) setupTables;
- (void) setupMonitor;
- (void) loadPreferences;
- (void) savePreferences;
- (void) openLiveProgram:(NSDictionary *)liveInfo autoOpen:(BOOL)autoOpen;
- (void) hookNotifications;
- (void) removeNotifications;
- (void) listenHalt:(NSNotification *)note;
- (void) listenRestart:(NSNotification *)note;
- (void) foundLive:(NSNotification *)note;
- (void) removeProgramNoFromTable:(NSNotification *)note;
- (void) startMyProgram:(NSNotification *)note;
- (void) endMyProgram:(NSNotification *)note;
- (void) rowSelected:(NSNotification *)note;
- (NSAttributedString *) makeLinkedWatchItem:(NSString *)item;
- (void) loadOldStylePreference;
- (void) addOldWatchList:(NSArray *)items;
@end

@implementation NicoLiveAlert
@synthesize menuStatusbar;
@synthesize preferencePanel;
@synthesize prefs;
@synthesize broadcasting;
@synthesize dontOpenWhenImBroadcast;
@synthesize kickStreamer;
@synthesize kickCommentViewerOnMyBroadcast;
@synthesize kickCommentViewerAtAutoOpen;
@synthesize kickCommentViewerOpenByMe;
#if MAC_OS_X_VERSION_MIN_REQUIRED == MAC_OS_X_VERSION_10_7
@synthesize statusMessage;
#endif
NSMutableDictionary *watchitems = nil;

#pragma mark -
#pragma mark override / delegate

- (void) awakeFromNib
{
	statusBar = [[NLStatusbar alloc] initWithMenu:menuStatusbar andImageName:@"sbicon"];
#if __has_feature(objc_arc) == 0
	[statusBar retain];
#endif
	broadcasting = NO;
	myLiveNumber = nil;
}// end - (void) awakeFromNib

- (void) applicationWillFinishLaunching:(NSNotification *)aNotification
{
	[GrowlApplicationBridge setGrowlDelegate:self];
	prefs = [[NicoLivePrefManager alloc] initWithDefaults:userDefaults];
}// end 

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{		// restore preference
	[self loadPreferences];
#if MAC_OS_X_VERSION_MIN_REQUIRED == MAC_OS_X_VERSION_10_5
		// remove Leopard unusable items
	[self disableAtLeopardItems];
#endif
		// setup for account
	[self setupAccounts];
		// setup drag & dorp table in preference panel
	[self setupTables];
		// hook notifications
	[self hookNotifications];
		// start monitor
	[self setupMonitor];
	[programSieves kick];
#if MAC_OS_X_VERSION_MIN_REQUIRED == MAC_OS_X_VERSION_10_7
	[self setupCollaboreationService];
#endif
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
- (void) disableAtLeopardItems
{		// remove application collaboration tab
/*
	NSInteger lastTab = [tabviewPreferences numberOfTabViewItems] - 1;
	NSTabViewItem *collabo = [tabviewPreferences tabViewItemAtIndex:lastTab];
	[tabviewPreferences removeTabViewItem:collabo];
*/
	[boxTinyLauncher setHidden:YES];
		// hide application collabolation menu
	[[menuStatusbar itemWithTag:tagLaunchApplications] setHidden:YES];
}

- (void) setupAccounts
{
		// make active accounts
	NSDictionary *savedAccounts = [prefs loadAccounts];
	nicoliveAccounts = [[NLUsers alloc] initWithActiveUsers:savedAccounts
										 andManualWatchList:watchitems];
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
	NSMutableArray *watch = [NSMutableArray array];;
	[watch addObjectsFromArray:[prefs loadManualWatchList]];
		// watch list
	if ([self checkFirstLaunch] == YES)
	{
		NSString *destPath = [IMPORTTAGETPATH stringByExpandingTildeInPath];
#if MAC_OS_X_VERSION_MIN_REQUIRED == MAC_OS_X_VERSION_10_7
		[self setupImportService];
		[self copyOldPref:IMPORTTAGETPATH to:destPath];
		NSThread *prefThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadOldStylePreference) object:nil];
		[prefThread start];
#else
		NSDictionary *oldpref = [NSDictionary dictionaryWithContentsOfFile:destPath];
		if (oldpref != NULL)
		{
			NSData *watchlistData = [oldpref valueForKey:IMPORTWATCHLISTKEY];
			NSArray *oldWatchlist = [NSUnarchiver unarchiveObjectWithData:watchlistData];
			for (NSDictionary *watchItem in oldWatchlist)
			{
				NSDictionary *converted = [NSMutableDictionary dictionary];
				[converted setValue:[watchItem valueForKey:ImporterAutoOpen] forKey:keyAutoOpen];
				[converted setValue:[watchItem valueForKey:ImporertWatchItem] forKey:keyWatchItem];
				[converted setValue:[watchItem valueForKey:ImporterNote] forKey:keyNote];
				[watch addObject:converted];
			}// end foreach oldwatchlist items
		}// end if 
#endif
	}// end if first launch

	if ([watch count] != 0)
	{
		watchitems = [NSMutableDictionary dictionary];
		for (NSDictionary *item in watch)
		{
			NSMutableDictionary *dic = [NSMutableDictionary dictionary];
			NSNumber *autoOpen = [item valueForKey:keyAutoOpen];
			NSString *watchitem = [item valueForKey:keyWatchItem];
			[dic setValue:autoOpen forKey:keyAutoOpen];
#if MAC_OS_X_VERSION_MIN_REQUIRED == MAC_OS_X_VERSION_10_5
			[dic setValue:watchitem forKey:keyWatchItem];
#else
			[dic setValue:[self makeLinkedWatchItem:watchitem] forKey:keyWatchItem];
#endif
			[dic setValue:[item valueForKey:keyNote] forKey:keyNote];
			[aryManualWatchlist addObject:dic];
			[watchitems setValue:autoOpen forKey:watchitem];
		}// end foreach item
	}// end if

	watchOfficialProgram = ([chkboxWatchOfficialProgram state] == NSOnState) ? YES : NO;
	watchOfficialChannel = ([chkboxWatchOfficialChannel state] == NSOnState) ? YES : NO;

		// launcher items
	NSArray *launchItems = [prefs loadLauncherDict];
	if ([launchItems count] != 0)
		[aryLauncherItems addObjects:launchItems];

		// auto open state
	enableAutoOpen = ([menuItemAutoOpen state] == NSOnState) ? YES : NO;
		// collaboration flags
	dontOpenWhenImBroadcast = ([chkboxDonotAutoOpenAtBroadcasting state] == NSOnState) ? YES : NO;
	kickStreamer = ([chkboxRelationWithFMELauncher state] == NSOnState) ? YES : NO;
	kickCommentViewerOnMyBroadcast = ([chkboxRelationWithCharlestonMyBroadcast state] == NSOnState) ? YES : NO;
	kickCommentViewerAtAutoOpen = ([chkboxRelationAutoOpenAndCharleston state] == NSOnState) ? YES : NO;
	kickCommentViewerOpenByMe = ([chkboxRelationChooseFromMenuAndCharleston state] == NSOnState) ? YES : NO;
}// end - (void) loadPreferences

- (void) savePreferences
{		// watch list
	[prefs saveManualWatchList:[aryManualWatchlist arrangedObjects]];
		// account list
	[prefs saveAccountsList:[aryAccountItems arrangedObjects]];
		// launcher items
	[prefs saveLauncherList:[aryLauncherItems arrangedObjects]];
}// end - (void) savePreferences


	// call from Growl click context and open by menuItem
- (void) openLiveProgram:(NSDictionary *)liveInfo autoOpen:(BOOL)autoOpen
{
	NSNumber *enable = [NSNumber numberWithBool:YES];
	NSNumber *disable = [NSNumber numberWithBool:NO];
	NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:liveInfo];	

	if (autoOpen == YES)
		if (kickCommentViewerAtAutoOpen == YES)
			[info setValue:enable forKey:CommentViewer];
		else
			[info setValue:disable forKey:CommentViewer];
	// end if autoOpen

	if (broadcasting == YES)
	{
		if (kickStreamer == YES)
			[info setValue:enable forKey:BroadcastStreamer];
		else
			[info setValue:disable forKey:BroadcastStreamer];
		// end if need streaming

		if (kickCommentViewerOnMyBroadcast == YES)
			[info setValue:enable forKey:CommentViewer];
		else
			[info setValue:disable forKey:CommentViewer];
		// end if need open comment viewer
	}
	else
	{
		if (kickCommentViewerOpenByMe == YES)
			[info setValue:enable forKey:CommentViewer];
		else
			[info setValue:disable forKey:CommentViewer];
		// end if open by CommentViewer
		[info setValue:disable forKey:BroadcastStreamer];
	}
	// end if need streamer isn’t set

	if ((broadcasting == NO) || (dontOpenWhenImBroadcast == NO) || (autoOpen == YES))
	{
		NSURL *url = [liveInfo valueForKey:ProgramURL];
		[[NSWorkspace sharedWorkspace] openURL:url];
	}// end if

	[self connectToProgram:[NSDictionary dictionaryWithDictionary:info]];
}// end - (void) openLiveProgram:(NSDictionary *)liveInfo

- (void) hookNotifications
{
	NSNotificationCenter *myMac = [[NSWorkspace sharedWorkspace] notificationCenter];
	NSNotificationCenter *this = [NSNotificationCenter defaultCenter];
		// sleep and wakeup notification hooks
			// hook to sleep notification
	[myMac addObserver:self selector: @selector(listenHalt:) name: NSWorkspaceWillSleepNotification object:nil];
			// hook to wakeup notification
	[myMac addObserver:self selector: @selector(listenRestart:) name: NSWorkspaceDidWakeNotification object:nil];
		// Connection Notification hooks
			// hook to connection lost notification
	[this addObserver:self selector:@selector(listenHalt:) name:NLNotificationConnectionLost object:nil];
			// hook to connection reactive notification
	[this addObserver:self selector:@selector(listenRestart:) name:NLNotificationConnectionRised object:nil];
		// open by program number hook
	[this addObserver:self selector:@selector(foundLive:) name:NLNotificationFoundProgram object:nil];
		// broadcast kind notification
	[this addObserver:self selector:@selector(startMyProgram:) name:NLNotificationMyBroadcastStart object:nil];
	[this addObserver:self selector:@selector(endMyProgram:) name:NLNotificationMyBroadcastEnd object:nil];
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
	[this removeObserver:self name:NLNotificationFoundProgram object:nil];
		// broadcast kind notification
	[this removeObserver:self name:NLNotificationMyBroadcastStart object:nil];
	[this removeObserver:self name:NLNotificationMyBroadcastEnd object:nil];
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

- (void) foundLive:(NSNotification *)note
{
NSLog(@"foundLive : %@", note);
	BOOL isAautoOpen = [[note object] boolValue];
	NSString *liveNumber = [[note userInfo] valueForKey:LiveNumber];
	BOOL myBroadcast = broadcasting & [liveNumber isEqualToString:myLiveNumber];
	BOOL autoOpen = (isAautoOpen & enableAutoOpen) & 
					!(myBroadcast & dontOpenWhenImBroadcast);
	if ((autoOpen == YES) || (myBroadcast == YES))
		[self openLiveProgram:[note userInfo] autoOpen:autoOpen];		

	if ([[nicoliveAccounts watchlist] valueForKey:liveNumber] != nil)
		[self removeFromWatchList:liveNumber];
}// end - (void) foundLive:(NSNotification *)note

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
	broadcasting = YES;
	myLiveNumber = [[NSString alloc] initWithString:[[note object] programNumber]];
}// end - (void) startMyProgram:(NSNotification *)note

- (void) endMyProgram:(NSNotification *)note
{
	NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[note object]];
	[info setValue:[NSNumber numberWithBool:NO] forKey:CommentViewer];
	[info setValue:[NSNumber numberWithBool:YES] forKey:BroadcastStreamer];
	[self disconnectFromProgram:[NSDictionary dictionaryWithDictionary:info]];
#if __has_feature(objc_arc) == 0
	[myLiveNumber release];
#endif
	myLiveNumber = nil;
	broadcasting = NO;
}// end - (void) endMyProgram:(NSNotification *)note

- (void) rowSelected:(NSNotification *)note
{
	IOMTableViewDragAndDrop *targetTable = [[note object] objectForKey:KeyTableView];
	NSInteger selectedRow = [[[note object] objectForKey:keyRow] integerValue];

	if (targetTable == tblManualWatchList)
		if (selectedRow != -1)
			[btnRemoveWatchListItem setEnabled:YES];
		else
			[btnRemoveWatchListItem setEnabled:NO];
		// end if row is selected
	// end if selected table is Manual WatchList

	if (targetTable == tblAccountList)
		if (selectedRow != -1)
			[btnRemoveAccount setEnabled:YES];
		else
			[btnRemoveAccount setEnabled:NO];
		// end if row is selected
	// end if selected table is Account list

	if (targetTable == tblTinyLauncher)
		if (selectedRow != -1)
			[btnRemoveApplication setEnabled:YES];
		else
			[btnRemoveApplication setEnabled:NO];
		// end if row is selected
	// end if selected table is tiny launcher
}// end - (void) rowSelected:(NSNotification *)note

- (BOOL) checkFirstLaunch
{
	NSBundle *mb = [NSBundle mainBundle];
	NSDictionary *infoDict = [mb infoDictionary];
	NSString *prefPath = [NSString stringWithFormat:PARTIALPATHFORMAT, [infoDict objectForKey:KEYBUNDLEIDENTIFY]];
	NSString *fullPath = [[prefPath stringByExpandingTildeInPath] stringByAppendingPathExtension:PREFPATHEXT];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL isThere = [fm fileExistsAtPath:fullPath];
	
	return !isThere;
}// end - (BOOL) checkFirstLaunch

#pragma mark -
#pragma mark gui backend
#pragma mark menu interface
	// menu item actions
- (IBAction) menuSelectAutoOpen:(id)sender
{
	enableAutoOpen = ([sender state] == NSOnState) ? YES : NO;
	[sender setState:enableAutoOpen];
	[programSieves setEnableAutoOpen:enableAutoOpen];
}// end - (IBAction) menuSelectAutoOpen:(id)sender

- (IBAction) resetConnection:(id)sender
{
	[programSieves reset];
}// end - (IBAction) resetConnection:(id)sender

- (IBAction) rescanRSS:(id)sender
{
}// end - (IBAction) rescanRSS:(id)sender

- (IBAction) launchApplicaions:(id)sender
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
	[self openLiveProgram:[[[sender representedObject] valueForKey:keyProgram] info] autoOpen:NO];
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
#if MAC_OS_X_VERSION_MIN_REQUIRED == MAC_OS_X_VERSION_10_5
	dict = [NSDictionary dictionaryWithObject:AppNameLepard forKey:keyAppName];
#elif MAC_OS_X_VERSION_MIN_REQUIRED == MAC_OS_X_VERSION_10_6
	dict = [NSDictionary dictionaryWithObject:AppNameSnowLeopard forKey:keyAppName];
#else
	dict = [NSDictionary dictionaryWithObject:AppnameLion forKey:keyAppName];
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
	NSString *itemName = [watchItemName stringValue];
	NSString *itemComment = [watchItemComment stringValue];
	NSAttributedString *watchItem = [self makeLinkedWatchItem:itemName];

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
	[btnRemoveWatchListItem setEnabled:NO];
}// end - (IBAction) addToWatchList:(id)sender

- (IBAction) removeFromWatchList:(id)sender
{
	if (sender == btnRemoveWatchListItem)
	{
		NSInteger row = [tblManualWatchList selectedRow];
		if (row == -1)
			return;

			// get remove item
		NSDictionary *watchItem = [[aryManualWatchlist arrangedObjects] objectAtIndex:row];
#if MAC_OS_X_VERSION_MIN_REQUIRED == MAC_OS_X_VERSION_10_5
		NSString *item = [watchItem valueForKey:keyWatchItem];
#else
		NSString *item = [[watchItem valueForKey:keyWatchItem] string];
#endif

			// remove from watch list
		[nicoliveAccounts removeWatchListItem:item];

			// remove from watch list table
		[aryManualWatchlist removeObject:watchItem];
		[btnRemoveWatchListItem setEnabled:NO];
	}
	else
	{
		NSString *liveNumber = [NSString stringWithString:(NSString *)sender];
			// remove from watch list
		[nicoliveAccounts removeWatchListItem:liveNumber];
			// remove from watch list table
		for (NSDictionary *item in [[aryManualWatchlist arrangedObjects] reverseObjectEnumerator])
			if ([[[item valueForKey:keyWatchItem] string] isEqualToString:liveNumber] == YES)
			{
				[aryManualWatchlist removeObject:item];
				return;
			}// end if
		// end foreach watchlist item
	}
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
- (IBAction) addApplication:(id)sender
{
	
}// end - (IBAction) addApplication:(id)sender

- (IBAction) removeApplication:(id)sender
{
	
}// end - (IBAction) removeApplication:(id)sender

- (IBAction) appColaboChecked:(id)sender
{
	switch ([sender tag]) {
		case tagDoNotAutoOpenInMyBroadcast:
			dontOpenWhenImBroadcast = ([chkboxDonotAutoOpenAtBroadcasting state] == NSOnState) ? YES : NO;
			break;
		case tagKickStreamer:
			kickStreamer = ([chkboxRelationWithFMELauncher state] == NSOnState) ? YES : NO;
			break;
		case tagKickCommentViewerOnMyBroadcast:
			kickCommentViewerOnMyBroadcast = ([chkboxRelationWithCharlestonMyBroadcast state] == NSOnState) ? YES : NO;
			break;
		case tagKickCommentViewerAtAutoOpen:
			kickCommentViewerAtAutoOpen = ([chkboxRelationAutoOpenAndCharleston state] == NSOnState) ? YES : NO;
			break;
		case tagKickCommentViewerByOpenFromMe:
			kickCommentViewerOpenByMe = ([chkboxRelationChooseFromMenuAndCharleston state] == NSOnState) ? YES : NO;
			break;
		default:
			break;
	}// end switch by checkbox's tag
}// end - (IBAction) appColaboChecked:(id)sender

- (NSAttributedString *) makeLinkedWatchItem:(NSString *)item
{
	NSDictionary *watchTargetKindDict = [NSDictionary dictionaryWithObjectsAndKeys:
					[NSNumber numberWithInteger:indexWatchCommunity], kindCommunity,
					[NSNumber numberWithInteger:indexWatchChannel], kindChannel,
					[NSNumber numberWithInteger:indexWatchProgram], kindProgram, nil];
	
	NSURL *url = nil;
	NSString *itemKind = [item substringWithRange:rangePrefix];
	NSAttributedString *watchItem;
	switch ([[watchTargetKindDict valueForKey:itemKind] integerValue])
	{
		case indexWatchCommunity:
			url = [NSURL URLWithString:[NSString stringWithFormat:URLFormatCommunity, item]];
			watchItem = [NSAttributedString attributedStringWithLinkToURL:url title:item];
			break;
		case indexWatchChannel:
			url = [NSURL URLWithString:[NSString stringWithFormat:URLFormatChannel, item]];
			watchItem = [NSAttributedString attributedStringWithLinkToURL:url title:item];
			break;
		case indexWatchProgram:
			url = [NSURL URLWithString:[NSString stringWithFormat:URLFormatLive, item]];
			watchItem = [NSAttributedString attributedStringWithLinkToURL:url title:item];
			break;
		default:
			url = [NSURL URLWithString:[NSString stringWithFormat:URLFormatUser, item]];
			watchItem = [NSAttributedString attributedStringWithLinkToURL:url title:item];
			break;
	}// end switch by watch item kind

	return watchItem;
}// end - (NSAttributedString *) makeLinkedWatchItem:(NSString *)item

- (void) loadOldStylePreference
{
#if __has_feature(objc_arc)
	@autoreleasepool {
#else
	NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
#endif
		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *oldpreference = [IMPORTTAGETPATH stringByExpandingTildeInPath];
		NSInteger limitCount = 10;
		while (([fm fileExistsAtPath:oldpreference] != YES) || (limitCount-- != 0))
			[NSThread sleepForTimeInterval:0.5f];
		// end while file copied

		NSMutableArray *watch = [NSMutableArray array];
		if ([fm fileExistsAtPath:oldpreference] == YES)
		{
			NSDictionary *oldpref = [NSDictionary dictionaryWithContentsOfFile:oldpreference];
			if (oldpref != NULL)
			{
				NSData *watchlistData = [oldpref valueForKey:IMPORTWATCHLISTKEY];
				NSArray *oldWatchlist = [NSUnarchiver unarchiveObjectWithData:watchlistData];
				for (NSDictionary *watchItem in oldWatchlist)
				{
					NSDictionary *converted = [NSMutableDictionary dictionary];
					[converted setValue:[watchItem valueForKey:ImporterAutoOpen] forKey:keyAutoOpen];
					[converted setValue:[watchItem valueForKey:ImporertWatchItem] forKey:keyWatchItem];
					[converted setValue:[watchItem valueForKey:ImporterNote] forKey:keyNote];
					[watch addObject:converted];
				}// end foreach oldwatchlist items
			
				NSError *err = nil;
				[fm removeItemAtPath:oldpreference error:&err];
				[self performSelectorOnMainThread:@selector(addOldWatchList:) withObject:watch waitUntilDone:NO];
			}
		}// end if
#if __has_feature(objc_arc)
	}
#else
	[arp drain];
#endif
}// end - (void) loadOldStylePreference

- (void) addOldWatchList:(NSArray *)items
{
#if __has_feature(objc_arc)
	@autoreleasepool {
#else
	NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
#endif
	NSMutableDictionary *watchlist = [NSMutableDictionary dictionary];
	for (NSDictionary *item in items)
	{
		NSDictionary *tableItem = [NSMutableDictionary dictionary];
		NSNumber *autoOpen = [item valueForKey:keyAutoOpen];
		NSString *watchItem = [item valueForKey:keyWatchItem];
		[tableItem setValue:autoOpen forKey:keyAutoOpen];
		[tableItem setValue:[self makeLinkedWatchItem:watchItem] forKey:keyWatchItem];
		[tableItem setValue:[item valueForKey:keyNote] forKey:keyNote];
		[aryManualWatchlist addObject:tableItem];
		[watchlist setValue:autoOpen forKey:watchItem];
	}
	[nicoliveAccounts addWatchListItems:watchlist];
#if __has_feature(objc_arc)
	}
#else
	[arp drain];
#endif
}// end - (void) addOldWatchList:(NSArray *)items

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

#pragma mark -
#pragma mark GrowlApplicationBridge delegate
- (void) growlNotificationWasClicked:(id)clickContext
{
	NSDictionary *info = [NSUnarchiver unarchiveObjectWithData:(NSData *)clickContext];
	[self openLiveProgram:info autoOpen:NO];
}// end - (void) growlNotificationWasClicked:(id)clickContext

- (void) growlNotificationTimedOut:(id)clickContext
{
}// end - (void) growlNotificationTimedOut:(id)clickContext;

- (BOOL) hasNetworkClientEntitlement
{
	return YES;
}// end - (BOOL) hasNetworkClientEntitlement
@end
