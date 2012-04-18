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
/*!
 @defined 
*/
#define NICOVIDEOURI	@"https://secure.nicovideo.jp"
#define NICOLOGINSERVER	@"secure.nicovideo.jp"
#define NICOLOGINPATH	@""
#define NICOLOGINURL	@"https://secure.nicovideo.jp/secure/login"
#define NICOLOGINPARAM	@"?site=nicolive_antenna"
#define LOGINQUERYMAIL	@"mail"
#define LOGINQUERYPASS	@"password"
#define ALERTAPIURL		@"http://live.nicovideo.jp/api/getalertstatus"
#define ALERTQUERY		@"http://live.nicovideo.jp/api/getalertstatus?ticket=%@"
#define MSQUERYAPI		@"http://live.nicovideo.jp/api/getalertinfo"
#define REQUESTFORMAT		@"<thread thread=\"%@\" version=\"20061206\" res_from=\"-1\"/>\0"
#define STREAMINFOQUERY	@"http://live.nicovideo.jp/api/getstreaminfo/%@"
#define STREMEMBEDQUERY	@"http://live.nicovideo.jp/embed/%@"
#define PROGRAMURLFORMAT	@"http://live.nicovideo.jp/watch/%@"

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


	// string riteral definition
#define PARTIALPATHFORMAT	@"~/Library/Preferences/%@"
#define KEYBUNDLEIDENTIFY	@"CFBundleIdentifier"

#pragma mark -
#pragma mark definitions for NLStatusbarIcon

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

#define NLNotificationConnectionLost	@"NLNotificationConnectionLost"
#define NLNotificationConnectionRised	@"NLNotificationConnectionRised"
#define dataSeparator					@","
#define liveNoAppendFormat				@"lv%@"
#define liveOfficialString				@"official"
#define ConnectionAliveCheckInterval	(3.0)
#define ServerTimeOut					(60 * 1.5)
#define ConnectionReactiveCheckInterval	(60 * 5)

enum {
	offsetLiveNo = 0,
	offsetCommuCh,
	offsetOwner
};

#pragma mark -
#pragma mark definitions for class NLProgram

#define OfficialTitleString	NSLocalizedString(@"OfficialTitleString", @"")
#define StartUserTimeFormat			@" %H:%M + 00:00"
#define StartOfficialTimeFormat		@"  %H:%M + 00:00"
#define ElapsedTimeFormat			@"%02ld:%02ld"
#define TimeFormatString			@"%H:%M"
	// reguler expressions
#define ProgramTitleRegex	@"title=\"(.*)\""
#define ThumbImageRegex		@"<img src=\"(http://.*)\" class=\"banner\">"
#define ProgStartTimeRegex	@"<div id=\"data\">(.*)</div>"
#define ProgramURLRegex		@"<a href=\"(http://live.nicovideo.jp/watch/lv\\d+)\""
#define OnAirRegex			@"class=\"(onair|beforeTS)\""
#define MaintRegex			@"<code>maintenance</code>"

	// XML element literal
#define elementStreaminfo	@"getstreaminfo"
#define elementRequestID	@"request_id"
#define elementDescription	@"description"
#define elementTitle		@"title"
#define elementComuName		@"name"
#define elementThumbnail	@"thumbnail"

enum elementStreamInfoIndex {
	indexStreaminfo = 1,
	indexRequestID,
	indexDescription,
	indexTitle,
	indexComuName,
	indexThumbnail,
};

#define NLNotificationTimeUpdated	@"NLNotificationTimeUpdated"
#define NLNotificationPorgramEnd	@"NLNotificationPorgramEnd"

#pragma mark -
#pragma mark for debug
#ifdef DEBUG
#define LOGPATH	@"~/Log"
#define XMLLOGFILENAME	@"XMLData.txt"
#define WATCHFILENAME	@"watchData.txt"
#define XMLTAGCHAT		@"chat"
#endif /* DEBUG */

#ifdef TRACECALL
#define TRACEFUNC   NSLog(@"%@ : %@", NSStringFromSelector(_cmd), [self class]);
#else
#define TRACEFUNC
#endif /* TRACECALL */


#endif	/* NicoLiveAlert_NicoLiveAlertDefinitions_h */
