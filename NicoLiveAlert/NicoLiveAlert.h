//
//  NicoLiveAlert.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NicoLivePrefManager.h"
#import "NLStatusbar.h"
#import "NLUsers.h"
#import "NLProgramList.h"
#import "NLActivePrograms.h"
#import "IOMTableViewDragAndDrop.h"
#import "NLArrayControllerDragAndDrop.h"
#import "Growl/Growl.h"

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
			// manual wath list items
	__strong IBOutlet NSButton					*chkboxWatchOfficialProgram;
	__strong IBOutlet NSButton					*chkboxWatchOfficialChannel;
	__strong IBOutlet IOMTableViewDragAndDrop	*tblManualWatchList;
	__strong IBOutlet NSTextField				*watchItemName;
	__strong IBOutlet NSTextField				*watchItemComment;
	__strong IBOutlet NSButton					*btnAddWatchListItem;
	__strong IBOutlet NSButton					*btnRemoveWatchListItem;

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

			// tiny launcher item
	__strong IBOutlet IOMTableViewDragAndDrop		*tblTinyLauncher;

			// array controller items
	__strong IBOutlet NLArrayControllerDragAndDrop	*aryManualWatchlist;
	__strong IBOutlet NLArrayControllerDragAndDrop	*aryAccountItems;
	__strong IBOutlet NLArrayControllerDragAndDrop	*aryLauncherItems;
	
	__strong NSStatusItem							*sbItem;
	NLStatusbar										*statusBar;
	NicoLivePrefManager								*prefs;
	NLUsers											*nicoliveAccounts;
	NLProgramList									*programSieves;

	BOOL											enableAutoOpen;
	BOOL											watchOfficialProgram;
	BOOL											watchOfficialChannel;
		// application collaboration flags
	BOOL											dontOpenWhenImBroadcast;
	BOOL											kickFMELauncher;
	BOOL											kickCharlestonOnMyBroadcast;
	BOOL											kickCharlestonAtAutoOpen;
	BOOL											kickCharlestonOpenByMe;
		// my status
	BOOL											broadCasting;
	BOOL											notificationPosted;

}
@property (retain, readonly)	NSMenu				*menuStatusbar;
@property (assign,readwrite)	NSPanel				*prefencePanel;
@property (readonly)			NicoLivePrefManager	*prefs;
@property (assign, readwrite)	BOOL				broadCasting;

		// IBAction’s prototypes
- (IBAction)menuSelectAutoOpen:(id)sender;
- (IBAction)launchApplicaions:(id)sender;
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
