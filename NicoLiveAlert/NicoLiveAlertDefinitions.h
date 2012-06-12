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
#define NICOLOGINPATH		@"/secure/login_form"
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
#define ImporterAutoOpen	@"autoOpen"
#define ImporertWatchItem	@"community"
#define ImporterNote		@"comment"

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
#define WatchKindRegex		@"^((co|ch|lv)\\d+)"

	//
#define rangePrefix			NSMakeRange(0, 2)
#define kindCommunity		@"co"
#define kindChannel			@"ch"
#define kindOfficial		@"of"
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
#define IMPORTWATCHLISTKEY	@"WatchList"
#define IMPORTTAGETPATH		@"~/Library/Preferences/jp.iom.NicoLiveAlert.plist"
#define oldPrefURL			@"file://~/Library/Preferences/jp.iom.NicoLiveAlert.plist"
#define oldPrefPath			@"~/Library/Preferences/jp.iom.NicoLiveAlert.plist"
#define PARTIALPATHFORMAT	@"~/Library/Preferences/%@"
#define PARTIALPATHLION		@"~/Library/Preferences/tv.from.chajka.NicoLiveAlert/Data/Library/Preferences/%@"
#define KEYBUNDLEIDENTIFY	@"CFBundleIdentifier"
#define PREFPATHEXT			@"plist"

	// About panel custmizing keys
#define keyCredits			@"Credits"
#define keyAppName			@"ApplicationName"
#define keyAppIcon			@"ApplicationIcon"
#define keyVersion			@"Version"
#define keyCopyright		@"Copyright"
#define keyAppVersion		@"ApplicationVersion"
#define AppNameLepard		@"NicoLiveAlert (Leopard)"
#define AppNameSnowLeopard	@"NicoLiveAlert (Snow Leopard)"
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

#define systemDefaultKeychain	nil
#define NICOKEYCHAINNAMEFORMAT	@"%@ (%@)"
#define NICOKEYCHAINLABEL		@"Web form password"

#define kNoUsers				(0)

#define keyAccountWatchEnabled	@"WatchEnabled"
#define keyAccountUserID		@"UserID"
#define keyAccountNickname		@"Nickname"
#define keyAccountMailAddr		@"MailAddress"

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
#define elementKeyError		@"error"
#define elementKeyCode		@"code"
#define elementKeyDesc		@"description"

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
	indexThread,
	indexError,
	indexCode,
	indexDesc
};

#define keyXMLStatus	@"status"
#define resultOK		@"ok"

#pragma mark -
#pragma mark definitions for class NLProgramList

#define NLNotificationAutoOpen			@"NLNotificationAutoOpen"
#define NLNotificationFoundProgram		@"NLNotificationFoundProgram"
#define NLNotificationConnectionLost	@"NLNotificationConnectionLost"
#define NLNotificationConnectionRised	@"NLNotificationConnectionRised"
#define NLNotificationStreamOpen		@"NLNotificationStreamOpen"
#define NLNotificationStreamError		@"NLNotificationStreamError"
#define NLNotificationStreamEnd			@"NLNotificationStreamEnd"
#define NLNotificationServerResponce	@"NLNotificationServerResponce"
#define NLNotificationStartListen		@"NLNotificationStartListen"

#define NLChannelFormat					@"ch%@"
#define dataSeparator					@","
#define liveNoAppendFormat				@"lv%@"
#define liveOfficialString				@"official"
#define ProgramNoRegex					@"lv\\d+"
#define ServerTimeOut					(60 * 1.5)
#define ConnectionAliveCheckInterval	(3.0)
#define ConnectionReactiveCheckInterval	(60 * 0.5)
#define MaintainfromReactiveInterval	(60 * 5)
#define ChatContentCharset				@"<> /=\""
#define CountRegalChatContent			(26)
#define OffsetDateInArray				(12)
#define OffsetProgramInfoInArray		(22)
#define MaintRegex			@"<code>maintenance</code>"
#define RiseConnectRegex	@"<getalertstatus status=\"ok\" time=\"\\d+\">"
#define ProgramListRegex	@"<chat.*>(.*)</chat>"
#define DateStartTimeRegex	@"date=\"(\\d+)\""

enum {
	offsetLiveNo = 0,
	offsetCommuCh,
	offsetOwner
};

#pragma mark -
#pragma mark definitions for class NLProgram
	// Attribute literal
#define fontNameOfProgramTitle		@"HiraKakuPro-W6"
#define fontNameOfDescription		@"HiraMaruPro-W4"
#define fontNameOfCommunity			@"HiraKakuPro-W6"
#define fontNameOfPrimaryAccount	@"Futura-Medium"
#define fontNameOfElapsedTime		@"CourierNewPS-BoldMT"

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
#define ProgStateRegex		@"class=\"(before|beforeTS|onair|done|doneTS)\""

#define ONAIRSTATE			@"onair"
#define BEFORESTATE			@"before"
#define BEFORETSSTATE		@"beforeTS"
#define DONESTATE			@"done"
#define DONETSSTATE			@"doneTS"

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

	// container object definition
#define keyProgram					@"Program"
#define keyLiveNumber				@"LiveNumber"
#define keyisOfficial				@"isOfficial"
	// notification constant
#define NLNotificationTimeUpdated	@"NLNotificationTimeUpdated"
#define NLNotificationPorgramEnd	@"NLNotificationPorgramEnd"

	// exception constant
#define EmbedFetchFailed		@"EmbedFetchFailed"
#define ErrorIsNotnil			@"ErrorIsNotnil"
#define StringIsEmpty			@"StringIsEmpty"
#define StreamInforFetchFaild	@"StreamInforFetchFaild"
#define EmbedParseFailed		@"EmbedParseFailed"
#define ProgramTitleCollectFail	@"ProgramTitleCollectFail"
#define ImageURLCollectFail		@"ImageURLCollectFail"
#define ProgramURLCollectFail	@"ProgramURLCollectFail"
#define UserProgXMLParseFail	@"UserProgXMLParseFail"

#pragma mark -
#pragma mark definitions for class NLActivePrograms

#define NLNotificationMyBroadcastStart	@"NLNotificationMyBroadcastStart"
#define NLNotificationMyBroadcastEnd	@"NLNotificationMyBroadcastEnd"
#define NLNotificationBroadcastOpen		@"NLNotificationBroadcastOpen"

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
#pragma mark definitions for Preferences

#define UserDefaultsFileName	@"UserDefaults"
#define TypeDefaultsFile			@"plist"

enum TextfieldTags {
	tagWatchItemBody = 1001,
	tagWatchItemComment,
	tagAccountLoginID = 1011,
	tagAccountPassword
};

enum AppCollaboCheckBoxes {
	tagDoNotAutoOpenInMyBroadcast = 1101,
	tagKickStreamer,
	tagKickCommentViewerOnMyBroadcast,
	tagKickCommentViewerAtAutoOpen,
	tagKickCommentViewerByOpenFromMe
};

#pragma mark watchlist item keys
#define EnableAutoOpen			@"EnableAutoOpen"
#define WathListTable			@"WathListTable"
#define AccountsList			@"AccountsList"
#define CheckOfficialProgram	@"CheckOfficialProgram"
#define CheckOfficialChannel	@"CheckOfficialChannel"

#pragma mark account item keys
#define AccauntTable			@"AccauntTable"

#pragma mark application collaboration keys

#define DoNotAutoOpenInMyBroadcast	@"DoNotAutoOpenInMyBroadcast"
#define KickStreamer				@"KickStreamer"
#define KickCommentViewerOnMyBroadcast	@"KickCommentViewerOnMyBroadcast"
#define KickCommentViewerAtAutoOpen	@"KickCommentViewerAtAutoOpen"
#define KickCommentViewerByOpenFromMe	@"KickCommentViewerByOpenFromMe"
#define TinyLauncerApplicatoins		@"TinyLauncerApplicatoins"

#define keyNLNotificationLiveNumber	@"keyNLNotificationLiveNumber"
#define keyNLNotificationIsMyLive	@"keyNLNotificationIsMyLive"
#define NLNotificationMyLiveStart	@"NLNotificationMyLiveStart"
#define NLNotificationLiveStart		@"NLNotificationLiveStart"

#define LauncItemList				@"LauncItemList"

#pragma mark -
#pragma mark Application Collaboration
#pragma mark classic
#define ServerCharleston			@"Charleston"
#define ServerFMELauncher			@"FMELauncher"
#pragma mark XPC 
#define CollaboratorXPCName			"tv.from.chajka.NicoLiveAlert.Collaborator"
#define XPCNotificationName			@"XPCNotificationName"
#define TypeProgramStart			@"TypeProgramStart"
#define TypeProgramEnd				@"TypeProgramEnd"
#define Information					@"Information"
#define ImporterXPCName				"tv.from.chajka.NicoLiveAlert.Importer"
#define ImporterQueueName			"tv.from.cjajka.NicoLiveAlert.Importer.queue"
#define TypePreference				@"TypePreference"
#define PrefSource					@"source"
#define PrefDest					@"dest"
#define PreferenceData				@"PreferenceData"

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
