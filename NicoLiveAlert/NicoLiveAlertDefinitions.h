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

#define EMPTYSTRING		@""
#define WatchListPasteboardType		@"tv.from.chajka.NicoLiveAlert.watchlist"
#define AccountListPasteboardType	@"tv.from.chajka.NicoLiveAlert.account"
#define LauncherPasteboardType		@"tv.from.chajka.NicoLiveAlert.launcher"


/*!
 @defined 
*/
#define NICOVIDEOURI		@"https://secure.nicovideo.jp"
#define NICOLOGINSERVER		@"secure.nicovideo.jp"
#define NICOLOGINPATH		@""
#define NICOLOGINURL		@"https://secure.nicovideo.jp/secure/login"
#define NICOLOGINPARAM		@"?site=nicolive_antenna"
#define LOGINQUERYMAIL		@"mail"
#define LOGINQUERYPASS		@"password"
#define ALERTAPIURL			@"http://live.nicovideo.jp/api/getalertstatus"
#define ALERTQUERY			@"http://live.nicovideo.jp/api/getalertstatus?ticket=%@"
#define MSQUERYAPI			@"http://live.nicovideo.jp/api/getalertinfo"
#define REQUESTFORMAT		@"<thread thread=\"%@\" version=\"20061206\" res_from=\"-1\"/>\0"
#define STREAMINFOQUERY		@"http://live.nicovideo.jp/api/getstreaminfo/%@"
#define STREMEMBEDQUERY		@"http://live.nicovideo.jp/embed/%@"
#define PROGRAMURLFORMAT	@"http://live.nicovideo.jp/watch/%@"

#pragma mark -
#pragma makr defaultKey definition
	// watch array
#define keyManualWatchList	@"ManualWatchList"

#pragma mark -
#pragma makr xib item definition
	// watch array
#define keyAutoOpen			@"AutoOpen"
#define keyWatchItem		@"WatchItem"
#define keyNote				@"Note"

#pragma mark -
#pragma mark definitions for class NicoLiveAlert
	// Tag indexes of Status Bar Menu items
/*!
 @enum statusBarMenuItems
*/
enum statusBarMenuItems {
	tagAutoOpen = 1001,
	tagPorgrams,
	tagOfficial,
	tagSep1 = 1010,
	tagAccounts,
	tagLaunchApplications,
	tagPreference,
	tagSep2 = 1020,
	tagAbout,
	tagQuit
};

	// Status Bar menu's localized string definition
#define TITLEAUTOOPEN			NSLocalizedString(@"TitleAutoOpen", @"")
#define	TITLEPROGRAMS			NSLocalizedString(@"TitlePrograms", @"")
#define	TITLEACCOUNTS			NSLocalizedString(@"TitleAccounts", @"")
#define	TITLELAUNCHER			NSLocalizedString(@"TitleLauncher", @"")
#define	TITLEPREFERENCE			NSLocalizedString(@"TitlePreference", @"")
#define TITLEABOUT				NSLocalizedString(@"TitleAbout", @"")
#define	TITLEQUIT				NSLocalizedString(@"TitleQuit", @"")
	// Status Bar menu's alternative strings definition
#define TITLEUSERNOPROG			NSLocalizedString(@"TitleUserNoProgram", @"")
#define TITLEUSERSINGLEPROG		NSLocalizedString(@"TitleUserSingleProgram", @"")
#define TITLEUSERSOMEPROG		NSLocalizedString(@"TitleUserSomePrograms", @"")
#define TITLEOFFICIALNOPROG		NSLocalizedString(@"TitleOfficialNoProgram", @"")
#define TITLEOFFICIALSINGLEPROG	NSLocalizedString(@"TitleOfficialSingleProgram", @"")
#define TITLEOFFICIALSOMEPROG	NSLocalizedString(@"TitleOfficialSomePrograms", @"")

	// regular expression definition
#define WatchKindRegex		@"^(co|ch|lv)\\d+"

	//
#define kindCommunity		@"co"
#define kindChannel			@"ch"
#define kindProgram			@"lv"

enum WatchTargetKind {
	indexWatchCommunity = 1,
	indexWatchChannel,
	indexWatchProgram
};
	// url format definition
#define URLFormatCommunity	@"http://com.nicovideo.jp/community/%@"
#define URLFormatChannel	@"http://ch.nicovideo.jp/channel/%@"
#define URLFormatLive		@"http://live.nicovideo.jp/watch/%@"
#define URLFormatUser		@"http://www.nicovideo.jp/user/%@"

	// string riteral definition
#define PARTIALPATHFORMAT	@"~/Library/Preferences/%@"
#define KEYBUNDLEIDENTIFY	@"CFBundleIdentifier"

	// About panel custmizing keys
#define keyCredits			@"Credits"
#define keyAppName			@"ApplicationName"
#define keyAppIcon			@"ApplicationIcon"
#define keyVersion			@"Version"
#define keyCopyright		@"Copyright"
#define keyAppVersion		@"ApplicationVersion"
#define AppNameLepard		@"NicoLiveAlert (Leopard)"
#define AppnameLion			@"NicoLiveAlert (Lion)"

#pragma mark -
#pragma mark definitions for NLStatusbar

#define DeactiveConnection	@"Disconnected"
#define ActiveNoprogString	@"Monitoring"
#define userProgramOnly		@"%ld User program"
#define officialProgramOnly	@"%ld Official program"
#define TwoOrMoreSuffix		@"s"
#define StringConcatinater	@", "


#pragma mark -
#pragma mark definitions for class NLUsers

#define systemDefaultKeychain	NULL
#define NICOKEYCHAINNAMEFORMAT	@"%@ (%@)"
#define NICOKEYCHAINLABEL		@"Web form password"

#define kNoUsers				(0)

#define keyAccountWatchEnabled	@"WatchEnabled"
#define keyAccountUserID		@"UserID"
#define keyAccountNickname		@"Nickname"

#define OriginalWatchList		NSLocalizedString(@"OriginalWatchList", @"")


#pragma mark definitions for XMLParsing
	// Exception definition
#define RESULTERRORNAME		@"XML parse error"
#define RESULTERRORREASON	@"XML result is not ok"

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
	indexResponse = 1,
	indexTicket,
	indexStatus,
	indexUserID,
	indexHash,
	indexUserName,
	indexCommunity,
	indexAddress,
	indexPort,
	indexThread
};

#define keyXMLStatus	@"status"
#define resultOK		@"ok"

#pragma mark -
#pragma mark definitions for class NLProgramList

#define NLNotificationOpenByLiveNo		@"NLNotificationOpenByLiveNo"
#define NLNotificationConnectionLost	@"NLNotificationConnectionLost"
#define NLNotificationConnectionRised	@"NLNotificationConnectionRised"
#define NLNotificationAutoOpen			@"NLNotificationAutoOpen"
#define dataSeparator					@","
#define liveNoAppendFormat				@"lv%@"
#define liveOfficialString				@"official"
#define ProgramNoRegex					@"lv\\d+"
#define ServerTimeOut					(60 * 1.5)
#define ConnectionAliveCheckInterval	(3.0)
#define ConnectionReactiveCheckInterval	(60 * 0.5)
#define MaintainfromReactiveInterval	(60 * 5)
#define MaintRegex			@"<code>maintenance</code>"
#define RiseConnectRegex	@"<getalertstatus status=\"ok\" time=\"\\d+\">"

enum {
	offsetLiveNo = 0,
	offsetCommuCh,
	offsetOwner
};

#pragma mark -
#pragma mark definitions for class NLProgram

#define OfficialTitleString	NSLocalizedString(@"OfficialTitleString", @"")
#define StartUserTimeFormat			@" %H:%M + 00:00"
#define ReserveUserTimeFormat		@" %%H:%%M - 00:%02ld"
#define StartOfficialTimeFormat		@"  %H:%M + 00:00"
#define ReserveOfficialTimeFormat	@"  %%H:%%M - 00:%02ld"
#define ElapsedTimeFormat			@"%02ld:%02ld"
#define CountDownTimeFormat			@"%02ld:%02ld"
#define TimeFormatString			@"%H:%M"
	// reguler expressions
#define ProgramTitleRegex	@"title=\"(.*)\""
#define ThumbImageRegex		@"<img src=\"(http://.*)\" class=\"banner\">"
#define ProgStartTimeRegex	@"(\\d+:\\d+)</div></?[ap]>"
#define ProgramURLRegex		@"<a href=\"(http://live.nicovideo.jp/watch/lv\\d+)\""
#define ProgStateRegex		@"class=\"(beforeTS|onair|done)\""

#define ONAIRSTATE			@"onair"
#define BEFORESTATE			@"beforeTS"
#define DONESTATE			@"done"

	// XML element literal
#define elementStreaminfo	@"getstreaminfo"
#define elementRequestID	@"request_id"
#define elementTitle		@"title"
#define elementDescription	@"description"
#define elementComuName		@"name"
#define elementComuID		@"default_community"
#define elementThumbnail	@"thumbnail"

enum elementStreamInfoIndex {
	indexStreaminfo = 1,
	indexRequestID,
	indexTitle,
	indexDescription,
	indexComuName,
	indexComuID,
	indexThumbnail,
};

	// notification constant
#define NLNotificationTimeUpdated	@"NLNotificationTimeUpdated"
#define NLNotificationPorgramEnd	@"NLNotificationPorgramEnd"

	// exception constant
#define EmbedFetchFailed		@"EmbedFetchFailed"
#define ErrorIsNotNULL			@"ErrorIsNotNULL"
#define StringIsEmpty			@"StringIsEmpty"
#define StreamInforFetchFaild	@"StreamInforFetchFaild"
#define EmbedParseFailed		@"EmbedParseFailed"
#define ProgramTitleCollectFail	@"ProgramTitleCollectFail"
#define ImageURLCollectFail		@"ImageURLCollectFail"
#define ProgramURLCollectFail	@"ProgramURLCollectFail"
#define UserProgXMLParseFail	@"UserProgXMLParseFail"

#pragma mark -
#pragma mark GUI
#pragma mark NLArrayControllerDragAndDrop

#define NLNotificationSelectRow	@"NLNotificationSelectRow"
#define keyRow					@"Row"
#define KeyTableView			@"Table"

#pragma mark -
#pragma mark Definitions for NLLauncherTableDelegate

#define ApplicationExtension	@"app"
#define keyLauncherIcon			@"Icon"
#define keyLauncherAppName		@"ApplicationName"
#define keyLauncherAppPath		@"ApplicationPath"

#pragma mark -
#pragma mark Preference definition

enum TextfieldTags {
	tagWatchItemBody = 1001,
	tagWatchItemComment,
	tagAccountLoginID = 1011,
	tagAccountPassword
};

enum AppCollaboCheckBoxes {
	tagDoNotAutoOpenInMyBroadcast = 1101,
	tagKickFMELauncher,
	tagKickCharlestonOnMyBroadcast,
	tagKickCharlestonAtAutoOpen,
	tagKickCharlestonByOpenFromMe
};

#pragma mark watchlist item keys
#define WathListTable			@"WathListTable"
#define AccountsList			@"AccountsList"
#define CheckOfficialChannel	@"CheckOfficialChannel"

#pragma mark account item keys
#define AccauntTable			@"AccauntTable"

#pragma mark application collaboration keys
#define DoNotAutoOpenInMyBroadcast	@"DoNotAutoOpenInMyBroadcast"
#define KickFMELauncher				@"KickFMELauncher"
#define KickCharlestonOnMyBroadcast	@"KickCharlestonOnMyBroadcast"
#define KickCharlestonAtAutoOpen	@"KickCharlestonAtAutoOpen"
#define KickCharlestonByOpenFromMe	@"KickCharlestonByOpenFromMe"
#define TinyLauncerApplicatoins		@"TinyLauncerApplicatoins"

#define LauncItemList				@"LauncItemList"

#pragma mark -
#pragma mark Growling

#define GrowlNotifyStartMonitoring		@"Start monitoring"
#define GrowlNotifyDisconnected			@"Disconnected"
#define GrowlNotifyFoundOfficialProgram	@"Found Official Program"
#define GrowlNotifyStartOfficialProgram	@"Start Official Program"
#define GrowlNotifyFoundUserProgram		@"Found User Program"
#define GrowlNotifyStartUserProgram		@"Start User Program"
#define	GrowlNotifyFoundListedProgram	@"Found in Manual Watch List"
#define GrowlNotifyStartListedProgram	@"Start in Manual watch List"
#define GrowlNotifyStartOfficialProgram	@"Start Official Program"

#pragma mark -
#pragma mark debugging

#ifdef TRACECALL
#define TRACEFUNC   NSLog(@"%@ : %@", NSStringFromSelector(_cmd), [self class]);
#else
#define TRACEFUNC
#endif /* TRACECALL */


#endif	/* NicoLiveAlert_NicoLiveAlertDefinitions_h */
