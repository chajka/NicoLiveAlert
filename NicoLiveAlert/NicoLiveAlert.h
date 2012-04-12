//
//  NicoLiveAlert.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NLStatusbarIcon.h"
#import "NLUsers.h"
#import "NLProgramList.h"

#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
@interface NicoLiveAlert : NSObject <NSApplicationDelegate> {
#else
@interface NicoLiveAlert : NSObject {
#endif
		// allover interface items
	__strong IBOutlet NSMenu *menuStatusbar;
	__strong IBOutlet NSPanel *preferencePanel;
	
		// menu access item
	__strong IBOutlet NSMenuItem *menuPrograms;
	__strong IBOutlet NSMenuItem *menuOfficalPrograms;
	__strong IBOutlet NSMenuItem *menuAccounts;
	__strong IBOutlet NSMenuItem *manuLauncApplications;

		// login information items
	__strong IBOutlet NSComboBox *comboLoginID;
	__strong IBOutlet NSSecureTextField *secureFieldPassword;
	__strong IBOutlet NSButton *btnIsWatch;

		// other application relation information items
	__strong IBOutlet NSButton *chkboxDonotAutoOpenAtBroadcasting;
	__strong IBOutlet NSButton *chkboxRelationWithFMELauncher;
	__strong IBOutlet NSButton *chkboxRelationWithCharlestonMyBroadcast;
	__strong IBOutlet NSButton *chkboxRelationAutoOpenAndCharleston;
	__strong IBOutlet NSButton *chkboxRelationChooseFromMenuAndCharleston;

		// tiny launcher item
	__strong IBOutlet NSTableView *tblTinyLauncher;

		// manual wath list items
	__strong IBOutlet NSTableView	*tblManualWatchList;
	__strong IBOutlet NSTextField	*watchItemName;
	__strong IBOutlet NSTextField	*watchItemComment;
	__strong IBOutlet NSButton		*chkboxWatchOfficialProgram;

		// array controller items
	__strong IBOutlet NSArrayController *aryLauncherItems;
	__strong IBOutlet NSArrayController *aryManualWatchlist;
	
	__strong NSStatusItem *sbItem;
	NLStatusbarIcon	*statusBar;
	NLUsers			*nicoliveAccounts;
	NLProgramList	*programListServer;
}
@property (retain) NSMenu *menuStatusbar;
@property (assign) NSPanel *prefencePanel;

@end
