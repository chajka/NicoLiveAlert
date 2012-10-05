//
//  NicoLiveAlert.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import "NicoLivePrefManager.h"
#import "NLStatusbar.h"
#import "NLUsers.h"
#import "NLProgramList.h"
#import "NLActivePrograms.h"
#import "NLRSSReader.h"
#import "IOMTableViewDragAndDrop.h"
#import "NLArrayControllerDragAndDrop.h"

#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
@interface NicoLiveAlert : NSObject <NSApplicationDelegate, GrowlApplicationBridgeDelegate> {
#else
@interface NicoLiveAlert : NSObject <GrowlApplicationBridgeDelegate> {
#endif
		// all over interface items
	__strong IBOutlet NSMenu					*menuStatusbar;
	__strong IBOutlet NSPanel					*preferencePanel;
	
		// menu access item
	__strong IBOutlet NSMenuItem				*menuItemAutoOpen;
	__strong IBOutlet NSMenuItem				*menuItemPrograms;
	__strong IBOutlet NSMenuItem				*menuItemOfficalPrograms;
	__strong IBOutlet NSMenuItem				*menuAccounts;
	__strong IBOutlet NSMenuItem				*manuLauncApplications;

		// Preference Panel items
	__strong IBOutlet NSTabView					*tabviewPreferences;
			// manual wath list items
	__strong IBOutlet IOMTableViewDragAndDrop	*tblManualWatchList;
	__strong IBOutlet NSTextField				*watchItemName;
	__strong IBOutlet NSTextField				*watchItemComment;
	__strong IBOutlet NSButton					*chkboxAutoOpen;
	__strong IBOutlet NSButton					*btnAddWatchListItem;
	__strong IBOutlet NSButton					*btnRemoveWatchListItem;
	__strong IBOutlet NSButton					*chkboxWatchOfficialProgram;
	__strong IBOutlet NSButton					*chkboxWatchOfficialChannel;

			// login information items
	__strong IBOutlet NSComboBox				*comboLoginID;
	__strong IBOutlet NSSecureTextField			*secureFieldPassword;
	__strong IBOutlet IOMTableViewDragAndDrop	*tblAccountList;
	__strong IBOutlet NSView					*viewNoAccountNotify;
	__strong IBOutlet NSButton					*btnAddAccount;
	__strong IBOutlet NSButton					*btnRemoveAccount;
	__strong IBOutlet NSButton					*btnUpdateAccountInfo;

			// other application relation information items
	__strong IBOutlet NSButton		*chkboxDonotAutoOpenAtBroadcasting;
	__strong IBOutlet NSButton		*chkboxRelationWithFMELauncher;
	__strong IBOutlet NSButton		*chkboxRelationWithCharlestonMyBroadcast;
	__strong IBOutlet NSButton		*chkboxRelationAutoOpenAndCharleston;
	__strong IBOutlet NSButton		*chkboxRelationChooseFromMenuAndCharleston;
	__strong IBOutlet NSButton		*btnAddApplication;
	__strong IBOutlet NSButton		*btnRemoveApplication;

			// tiny launcher item
	__strong IBOutlet NSBox							*boxTinyLauncher;
	__strong IBOutlet IOMTableViewDragAndDrop		*tblTinyLauncher;

			// array controller items
	__strong IBOutlet NLArrayControllerDragAndDrop	*aryManualWatchlist;
	__strong IBOutlet NLArrayControllerDragAndDrop	*aryAccountItems;
	__strong IBOutlet NLArrayControllerDragAndDrop	*aryLauncherItems;

			// user's defaults object
	__strong IBOutlet NSUserDefaultsController		*userDefaults;
	
	NLStatusbar										*statusBar;
	NicoLivePrefManager								*prefs;
	NLUsers											*nicoliveAccounts;
	NLProgramList									*programSieves;
	NLRSSReader										*rssManager;

		// application control flags
	BOOL											enableAutoOpen;
	BOOL											watchOfficialProgram;
	BOOL											watchOfficialChannel;
		// application collaboration flags
	BOOL											dontOpenWhenImBroadcast;
	BOOL											kickStreamer;
	BOOL											kickCommentViewerOnMyBroadcast;
	BOOL											kickCommentViewerAtAutoOpen;
	BOOL											kickCommentViewerOpenByMe;
		// application status flag
	BOOL											logined;
		// my status
	BOOL											broadcasting;
	NSString										*myLiveNumber;
	NSMutableDictionary								*growlDuplicateAnnihilator;
	NSArray											*oldWatchlists;
#if MAC_OS_X_VERSION_MIN_REQUIRED == MAC_OS_X_VERSION_10_7
		// xpc variable definition
	NSString										*statusMessage;
	xpc_connection_t								_collaborationServiceConnection;
	xpc_connection_t								_prefImportServiceConnection;
#endif

}
@property (retain, readonly)	NSMenu				*menuStatusbar;
@property (readonly)			NSPanel				*preferencePanel;
@property (readonly)			NicoLivePrefManager	*prefs;
@property (assign, readwrite)	BOOL				broadcasting;
@property (assign, readwrite)	BOOL				dontOpenWhenImBroadcast;
@property (assign, readwrite)	BOOL				kickStreamer;
@property (assign, readwrite)	BOOL				kickCommentViewerOnMyBroadcast;
@property (assign, readwrite)	BOOL				kickCommentViewerAtAutoOpen;
@property (assign, readwrite)	BOOL				kickCommentViewerOpenByMe;
#if MAC_OS_X_VERSION_MIN_REQUIRED == MAC_OS_X_VERSION_10_7
@property (copy) NSString *statusMessage;
#endif
		// prototypes of IBActions
- (IBAction) menuSelectAutoOpen:(id)sender;
- (IBAction) resetConnection:(id)sender;
- (IBAction) rescanRSS:(id)sender;
- (IBAction) launchApplicaions:(id)sender;
- (IBAction) openProgram:(id)sender;
- (IBAction) toggleUserState:(id)sender;
- (IBAction) showAboutPanel:(id)sender;
- (IBAction) autoOpenChecked:(id)sender;
- (IBAction) watchOfficialProgram:(id)sender;
- (IBAction) watchOfficialChannel:(id)sender;
- (IBAction) addToWatchList:(id)sender;
- (IBAction) removeFromWatchList:(id)sender;
- (IBAction) loginNameSelected:(id)sender;
- (IBAction) addAccount:(id)sender;
- (IBAction) removeAccount:(id)sender;
- (IBAction) updateAccountInfo:(id)sender;
- (IBAction) appColaboChecked:(id)sender;
@end
