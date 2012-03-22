//
//  NicoLiveAlertDefinitions.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/22/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#ifndef NicoLiveAlert_NicoLiveAlertDefinitions_h
#define NicoLiveAlert_NicoLiveAlertDefinitions_h

// Tag indexes of Status Bar Menu items
enum statusBarMenuItems {
	tagAutoOpen = 1001,
	tagPorgrams,
	tagSep1,
	tagAccounts,
	tagLaunchApplications,
	tagPreference,
	tagSep2,
	tagAbout,
	tagQuit
};
// Status Bar menu's localized string definition
#define TITLEAUTOOPEN	NSLocalizedString(@"TitleAutoOpen", @"")
#define	TITLEPROGRAMS	NSLocalizedString(@"TitlePrograms", @"")
#define	TITLEACCOUNTS	NSLocalizedString(@"TitleAccounts", @"")
#define	TITLELAUNCHER	NSLocalizedString(@"TitleLauncher", @"")
#define	TITLEPREFERENCE	NSLocalizedString(@"TitlePreference", @"")
#define TITLEABOUT		NSLocalizedString(@"TitleAbout", @"")
#define	TITLEQUIT		NSLocalizedString(@"TitleQuit", @"")



#endif
