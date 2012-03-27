//
//  NicoLiveAlertDefinitions.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/22/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#ifndef NicoLiveAlert_NicoLiveAlertDefinitions_h
#define NicoLiveAlert_NicoLiveAlertDefinitions_h

// common definition
#define NICOLOGINURL	@"https://secure.nicovideo.jp/secure/login"
#define NICOLOGINPARAM	@"?site=nicolive_antenna"
#define LOGINQUERYMAIL	@"mail"
#define LOGINQUERYPASS	@"password"
#define ALERTAPIURL		@"http://live.nicovideo.jp/api/getalertstatus"
#define ALERTQUERY		@"http://live.nicovideo.jp/api/getalertstatus?ticket=%@"

#pragma mark definitions for class NicoLiveAlert
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

	// string riteral definition
#define PARTIALPATHFORMAT	@"~/Library/Preferences/%@"
#define KEYBUNDLEIDENTIFY	@"CFBundleIdentifier"

#pragma mark definitions for class NLAccount

	// XML element literal
#define elementKeyResponse	@"nicovideo_user_response"
#define elementKeyTicket	@"ticket"
#define elementKeyStatus	@"getalertstatus"
#define elementKeyUserID	@"user_id"
#define elementKeyHash		@"user_hash"
#define elementKeyUserName	@"user_name"
#define elementKeyCommunity	@"community_id"
#define elementKeyAddress	@"addr"
#define elementKeyPort		@"port"
#define elementKeyThread	@"thread"

enum elementLiteralIndex {
	elementIndexResponse = 1,
	elementIndexTicket,
	elementIndexStatus,
	elementIndexUserID,
	elementIndexHash,
	elementIndexUserName,
	elementIndexCommunity,
	elementIndexAddress,
	elementIndexPort,
	elementIndexThread
};

#define keyXMLStatus	@"status"
#define resultOK		@"ok"

#endif
