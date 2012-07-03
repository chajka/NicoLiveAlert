//
//  NLProgram.m
//  NicoLiveAlert
//
//  Created by Чайка on 4/9/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLProgram.h"
#import "HTTPConnection.h"
#import "Growl/Growl.h"
#import "NicoLiveAlertCollaboration.h"

@interface NLProgram ()
	// construction support methods
- (void) clearAllMember;
- (void) setupEachMember:(NSString *)liveNo;
- (NSDictionary *) elementDict;
- (void) checkStartTime:(NSDate *)date forLive:(NSString *)liveNo;
- (NSString *) makeStartString;
- (NSDictionary *)createNotificationDict:(NSString *)liveNo kind:(NSNumber *)kind;
- (void) postPorgramStartNotification:(NSNumber *)autoOpen;
- (void) parseOfficialProgram;
- (void) parseProgramInfo:(NSString *)liveNo;
- (void) parseOwnerNickname:(NSString *)owner;
	// activity control method
- (BOOL) isBroadCasting;
	// drawing methods
- (void) drawUserProgram;
- (void) drawOfficialProgram;
- (void) createMenuItem;
	// timer driven methods
- (void) updateElapse:(NSTimer *)theTimer;
- (void) checkBroadcasting:(NSTimer *)theTimer;
	// timer management methods
- (void) stopProgramStatusTimer;
- (void) stopElapsedTimer;
- (void) resetProgramStatusTimer;
- (void) resetElapsedTimer;
	// growling;
- (void) growlProgramNotify:(NSString *)notificationName;
@end

@implementation NLProgram
@synthesize menuImage;
@synthesize programMenu;
@synthesize programNumber;
@synthesize communityID;
@synthesize broadcastOwner;
@synthesize isOfficial;
@synthesize broadCasting;
@synthesize info;

NSMutableString *dataString;
NSInteger currentElement;
NSDictionary *elementDict;
NSString *embedContent;

static const CGFloat originX = 0.0;
static const CGFloat originY = 0.0;
static const CGFloat thumbnailSize = 50.0;
static const CGFloat exteriorLineWidth = 1.0;
static const CGFloat titleKernValue = 0.0;
static const CGFloat kernValue = 0.0;
static const CGFloat titleComuKernValue = 0.0;
static const CGFloat timeStringWidth = 110.0;
static const CGFloat timeStringHeight = 14.0;
static const CGFloat elapesedStringWidth = 39;
static const CGFloat elapesedStringHeight = timeStringHeight;

#pragma mark user program constant
static const CGFloat programBoundsW = 293.0;
static const CGFloat programBoundsH = 77.0;
static const CGFloat accountOffsetX = 52.0;
static const CGFloat accountOffsetY = 0.0;
static const CGFloat accountWitdth = 120.0;
static const CGFloat accountHeight = 18.0;
static const CGFloat communityOffsetX = 52.0;
static const CGFloat communityOffsetY = 12.0;
static const CGFloat progTitleOffsetX = 0.0;
static const CGFloat progTitleOffsetY = programBoundsH - 13;
static const CGFloat progOwnerOffsetX = 12.0;
static const CGFloat progOwnerOffsetY = programBoundsH - 26;
static const CGFloat progDescOffsetX = 52.0;
static const CGFloat progDescOffsetY = 24.0;
static const CGFloat progDescWidth = (programBoundsW - thumbnailSize);
static const CGFloat progDescHeight = 28.0;
static const CGFloat userTimeOffsetX = (programBoundsW - timeStringWidth);
static const CGFloat userTimeOffsetY = 0.0;
static const CGFloat userElapsedOffsetX = (programBoundsW - elapesedStringWidth);

#pragma mark official program constant
static const CGFloat officialBoundsW = 293.0;
static const CGFloat officialBoundsH = 50.0;
static const CGFloat officialDescX = 52.0;
static const CGFloat officialDescY = 24.0;
static const CGFloat officialDescW = (officialBoundsW - thumbnailSize);
static const CGFloat officialDescH = (officialBoundsH - officialDescY);
static const CGFloat officialTimeOffsetX = (officialBoundsW - timeStringWidth);
static const CGFloat officialTimeOffsetY = 0.0;
static const CGFloat officialElapsedOffsetX = (officialBoundsW - elapesedStringWidth);

#pragma mark color constant
static const CGFloat alpha = 1.0;
static const CGFloat fract = 1.0;
	// program title color
static const CGFloat ProgramTitleColorRed = (0.0 / 255);
static const CGFloat ProgramTitleColorGreen = (0.0 / 255);
static const CGFloat ProgramTitleColorBlue = (255.0 / 255);
	// program owner color
static const CGFloat ProgramOwnerColorRed = (128.0 / 255);
static const CGFloat ProgramOwnerColorGreen = (64.0 / 255);
static const CGFloat ProgramOwnerColorBlue = (0.0 / 255);
	// program description color
static const CGFloat ProgramDescColorRed = (64.0 / 255);
static const CGFloat ProgramDescColorGreen = (64.0 / 255);
static const CGFloat ProgramDescColorBlue = (64.0 / 255);
	// commnunity name color
static const CGFloat CommunityNameColorRed = (204.0 / 255);
static const CGFloat CommunityNameColorGreen = (102.0 / 255);
static const CGFloat CommunityNameColorBlue = (255.0 / 255);
	// account color
static const CGFloat AccountColorRed = (0.0 / 255);
static const CGFloat AccountColorGreen = (128.0 / 255);
static const CGFloat AccountColorBlue = (128.0 / 255);
	// remain time color
static const CGFloat TimeColorRed = (128.0 / 255);
static const CGFloat TimeColorGreen = (0.0 / 255);
static const CGFloat TimeColorBlue = (64.0 / 255);

#pragma timer constant
static const NSTimeInterval checkActivityCycle = (60.0 * 3);
static const NSTimeInterval elapseCheckCycle = (10.0);

#pragma mark construct / destruct
	// constructor for user program
- (id) initWithProgram:(NSString *)liveNo withDate:(NSDate *)date forAccount:(NLAccount *)account owner:(NSString *)owner autoOpen:(NSNumber *)autoOpen isMine:(BOOL)mine isChannel:(BOOL) isChannel
{
	self = [super init];
	if (self)
	{		// initialize member variables
		[self clearAllMember];
		isMyProgram = mine;
		iconWasValid = NO;
		iconIsValid = NO;
		@try {
			[self checkStartTime:date forLive:liveNo];
			if (isChannel == YES)
			{
				[self parseOfficialProgram];
			}
			else
			{
				broadcastOwner = [owner copy];
				[self parseOwnerNickname:broadcastOwner];
				[self parseProgramInfo:liveNo];
			}// end if program is channel or user
		}
		@catch (NSException *exception) {
			NSLog(@"Catch %@ : %@\n%@", NSStringFromSelector(_cmd), [self class], exception);
#if __has_feature(objc_arc) == 0
			[self dealloc];
#endif
			return nil;
		}
		if (account != nil)
			primaryAccount = [[account nickname] copy];
		else
			primaryAccount = [OriginalWatchList copy];
		[self setupEachMember:liveNo];
		info = [[NSDictionary alloc] initWithDictionary:[self createNotificationDict:liveNo kind:[NSNumber numberWithInteger:(isChannel ? bradcastKindChannel : bradcastKindUser)]]];
		[self postPorgramStartNotification:autoOpen];
		[elapseTimer fire];
		[programStatusTimer fire];
		@try {
			if ([startTime isEqualToDate:date] == YES)
				[self growlProgramNotify:GrowlNotifyStartUserProgram];
			else
				[self growlProgramNotify:GrowlNotifyFoundUserProgram];
		}
		@catch (NSException *exception) {
			NSLog(@"Catch %@ : %@\n%@", NSStringFromSelector(_cmd), [self class], exception);
		}
	}// end if
	return self;
}// end - (id) initWithProgram:(NSString *)liveNo withDate:(NSDate *)date forAccount:(NLAccount *)account owner:(NSString *)owner autoOpen:(NSNumber *)autoOpen isMine:(BOOL)mine isChannel:(BOOL) isChanne

	// constructor for official or channel program
- (id) initWithProgram:(NSString *)liveNo withDate:(NSDate *)date autoOpen:(NSNumber *)autoOpen isOfficial:(BOOL)official
{
	self = [super init];
	if (self)
	{		// initialize member variables
		[self clearAllMember];
		
		isOfficial = YES;
		iconWasValid = NO;
		iconIsValid = NO;
		@try {
			[self checkStartTime:date forLive:liveNo];
			[self parseOfficialProgram];
		}
		@catch (NSException *exception) {
			NSLog(@"Catch %@ : %@\n%@", NSStringFromSelector(_cmd), [self class], exception);
#if __has_feature(objc_arc) == 0
			[self dealloc];
#endif
			return nil;
		}
		primaryAccount = [[NSString alloc] initWithString:OfficialTitleString];
		[self setupEachMember:liveNo];
		info = [[NSDictionary alloc] initWithDictionary:[self createNotificationDict:liveNo kind:[NSNumber numberWithInteger:(isOfficial ? bradcastKindOfficial : bradcastKindChannel)]]];
		[self postPorgramStartNotification:autoOpen];
		[elapseTimer fire];
		[programStatusTimer fire];
		if ([startTime isEqualToDate:date] == YES)
			[self growlProgramNotify:GrowlNotifyStartOfficialProgram];
		else
			[self growlProgramNotify:GrowlNotifyFoundOfficialProgram];
	}// end if
	return self;
}// end - (id) initWithOfficial:(NSString *)liveNo


- (void) dealloc
{
	if (isMyProgram == YES)
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:NLNotificationMyBroadcastEnd object:info]];

#if __has_feature(objc_arc) == 0
	if (programMenu != nil)			[programMenu release];
	if (menuImage != nil)			[menuImage release];
	if (background != nil)			[background release];
	if (timeMask != nil)			[timeMask release];
	if (thumbnail != nil)			[thumbnail release];
	if (stringAttributes != nil)	[stringAttributes release];
	if (programNumber != nil)		[programNumber release];
	if (programTitle != nil)		[programTitle release];
	if (programDescription != nil)	[programDescription release];
	if (communityName != nil)		[communityName release];
	if (primaryAccount != nil)		[primaryAccount release];
	if (communityID != nil)			[communityID release];
	if (broadcastOwner != nil)		[broadcastOwner release];
	if (broadcastOwnerName != nil)	[broadcastOwnerName release];
	if (startTime != nil)			[startTime release];
	if (startTimeString != nil)		[startTimeString release];
	if (programURL != nil)			[programURL release];
	if (info != nil)				[info release];

	if (embedContent != nil)		[embedContent release];

	[super dealloc];
#endif
}// end - (void) dealloc

#pragma mark -
#pragma mark construction support
- (void) clearAllMember
{
	programMenu = nil;
	menuImage = nil;
	thumbnail = nil;
	background = nil;
	timeMask = nil;
	stringAttributes = nil;
	programNumber = nil;
	programTitle = nil;
	programDescription = nil;
	communityName = nil;
	primaryAccount = nil;
	communityID = nil;
	broadcastOwner = nil;
	broadcastOwnerName = nil;
	startTime = nil;
	startTimeString = nil;
	lastMintue = 0;
	localeDict = nil;
	programURL = nil;
	thumbnailURL = nil;
	programStatusTimer = nil;
	elapseTimer = nil;
	center = nil;
	isReservedProgram = NO;
	isOfficial = NO;
	broadCasting = NO;
	info = nil;

	dataString = nil;
	currentElement = 0;
	elementDict = nil;
	embedContent = nil;
}// end - (void) clearAllMember

- (void) setupEachMember:(NSString *)liveNo
{
	programNumber = [liveNo copy];
	localeDict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	center = [NSNotificationCenter defaultCenter];
	startTimeString = [[self makeStartString] copy];

	if (isOfficial == YES)
		[self drawOfficialProgram];
	else
		[self drawUserProgram];
	// end if is official or user.

	if (isMyProgram == YES)
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:NLNotificationMyBroadcastStart object:self]];
	// end if program owner is me or not.
	
	[self createMenuItem];
	[self resetElapsedTimer];
	[self resetProgramStatusTimer];
	broadCasting = YES;
}// end - (void) setupEachMember:(NSString *)liveNo

- (NSDictionary *) elementDict
{
	NSDictionary *elementDict = [NSDictionary dictionaryWithObjectsAndKeys:
		 [NSNumber numberWithInteger:indexStreaminfo], elementStreaminfo,
		 [NSNumber numberWithInteger:indexRequestID], elementRequestID,
		 [NSNumber numberWithInteger:indexTitle], elementTitle,
		 [NSNumber numberWithInteger:indexDescription], elementDescription,
		 [NSNumber numberWithInteger:indexComuName], elementComuName,
		 [NSNumber numberWithInteger:indexComuID], elementComuID,
		 [NSNumber numberWithInteger:indexThumbnail], elementThumbnail, 
		 [NSNumber numberWithInteger:indexNickname], elementNickname, nil];

	return elementDict;
}// end - (NSDictionary *) elementDict

- (void) checkStartTime:(NSDate *)date forLive:(NSString *)liveNo
{
	OnigRegexp *liveStateRegex = [OnigRegexp compile:ProgStateRegex];
	OnigRegexp *broadcastTimeRegex = [OnigRegexp compile:ProgStartTimeRegex];
	NSURL *embedURL = [NSURL URLWithString:[NSString stringWithFormat:STREMEMBEDQUERY, liveNo]];

	NSError *err = nil;
	embedContent = [[NSString alloc] initWithContentsOfURL:embedURL encoding:NSUTF8StringEncoding error:&err];
	if (embedContent == nil)
		@throw [NSException exceptionWithName:EmbedFetchFailed reason:StringIsEmpty userInfo:nil];

	OnigResult *checkOnair = [liveStateRegex search:embedContent];
	OnigResult *broadcastTime = [broadcastTimeRegex search:embedContent];
	if (([[checkOnair stringAt:1] isEqualToString:ONAIRSTATE] == YES)
		|| (broadcastTime == nil))
	{
		startTime = [date copy];
		return;
	}

	NSDate *broadcastDate = [NSDate dateWithNaturalLanguageString:[broadcastTime stringAt:1] locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
	
	NSTimeInterval diff = [broadcastDate timeIntervalSinceDate:date];
	if (([[checkOnair stringAt:1] isEqualToString:BEFORESTATE] == YES) ||
		([[checkOnair stringAt:1] isEqualToString:BEFORETSSTATE] == YES) || 
		((abs(((NSInteger)diff) / 60) != 0)))
	{
		NSTimeInterval startUnixTime = [date timeIntervalSince1970] + diff;
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
		startTime = [[NSDate alloc] initWithTimeIntervalSince1970:startUnixTime];
#else
		startTime = [NSDate dateWithTimeIntervalSince1970:startUnixTime];
		[startTime retain];
#endif
		lastMintue = ((NSInteger)([startTime timeIntervalSinceDate:date] / 60)) % 60;
		isReservedProgram = YES;

		return;
	}// endif befor program start

	startTime = [date copy];
	lastMintue = 0;
}// end - (void) checkStartTime:(NSDate *)date forLive:(NSString *)liveNo

- (NSString *) makeStartString
{
	NSString *startString = nil;
	NSUInteger minute = 0;
	if (isReservedProgram == YES)
		minute = abs([[NSDate date] timeIntervalSinceDate:startTime] / 60);
	
	if (isOfficial != YES)
	{		// user program check reserve or not
		if (isReservedProgram == YES)
		{
			NSString *calFromat = [NSString stringWithFormat:ReserveUserTimeFormat, minute];
			startString = [startTime descriptionWithCalendarFormat:calFromat timeZone:nil locale:localeDict];
		}
		else
		{
			startString = [startTime descriptionWithCalendarFormat:StartUserTimeFormat timeZone:nil locale:localeDict];
		}
	}
	else
	{		// official program it must reserved
		if (isReservedProgram == YES)
		{
			NSString *calFromat = [NSString stringWithFormat:ReserveOfficialTimeFormat, minute];
			startString = [startTime descriptionWithCalendarFormat:calFromat timeZone:nil locale:localeDict];
		}
		else
		{
			startString = [startTime descriptionWithCalendarFormat:StartOfficialTimeFormat timeZone:nil locale:localeDict];
		}
	}// end if official or user program

	return startString;
}// end - (NSString *) makeStartString

- (NSDictionary *)createNotificationDict:(NSString *)liveNo kind:(NSNumber *)kind
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setValue:[NSURL URLWithString:[NSString stringWithFormat:PROGRAMURLFORMAT, liveNo]] forKey:ProgramURL];
	[dict setValue:liveNo forKey:LiveNumber];
	[dict setValue:kind forKey:BroadCastKind];

	return [NSDictionary dictionaryWithDictionary:dict];
}// end - (NSMutableDictionary *)createNotificationDict(NSString *)liveNo kind:(NSNumber *)kind

- (void) postPorgramStartNotification:(NSNumber *)autoOpen
{
	[[NSNotificationCenter defaultCenter] postNotificationName:NLNotificationFoundProgram object:autoOpen userInfo:info];
}// end - (void) postPorgramStartNotification:(NSMutableDictionary *)info autoOpen:(NSNumber *)autoOpen

- (void) parseOfficialProgram
{
	OnigRegexp *titleRegex = [OnigRegexp compile:ProgramTitleRegex];
	OnigRegexp *imgRegex = [OnigRegexp compile:ThumbImageRegex];
	OnigRegexp *programRegex = [OnigRegexp compile:ProgramURLRegex];
	OnigResult *result = nil;

	result = [titleRegex search:embedContent];
	if (result == nil)
		@throw [NSException exceptionWithName:EmbedParseFailed reason:ProgramTitleCollectFail userInfo:[NSDictionary dictionaryWithObject:embedContent forKey:@"embedContent"]];
	programTitle = [[NSString alloc] initWithString:[result stringAt:1]];

	result = [imgRegex search:embedContent];
	if (result == nil)
		@throw [NSException exceptionWithName:EmbedParseFailed reason:ImageURLCollectFail userInfo:[NSDictionary dictionaryWithObject:embedContent forKey:@"embedContent"]];
	thumbnail = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[result stringAt:1]]];
	if ([thumbnail isValid] == YES)
	{
		[thumbnail setSize:NSMakeSize(thumbnailSize, thumbnailSize)];
		iconWasValid = YES;
		iconIsValid = YES;
	}
	else
	{
#if __has_feature(objc_arc) == 0
		[thumbnail release];
#endif
		thumbnail = nil;
		thumbnailURL = [[NSURL alloc] initWithString:[result stringAt:1]];
	}
	
	result = [programRegex search:embedContent];
	if (result == nil)
		@throw [NSException exceptionWithName:EmbedParseFailed reason:ProgramURLCollectFail userInfo:[NSDictionary dictionaryWithObject:embedContent forKey:@"embedContent"]];
	programURL = [[NSString alloc] initWithString:[result stringAt:1]];
#if __has_feature(objc_arc) == 0
	[embedContent release];
	embedContent = nil;
#endif
}// end - (void) parseOfficialProgram

- (void) parseProgramInfo:(NSString *)liveNo
{
#if __has_feature(objc_arc) == 0
	if (embedContent != nil)	[embedContent release];
	embedContent = nil;
#endif
	BOOL success = NO;
	NSXMLParser *parser = nil;
#if __has_feature(objc_arc)
	@autoreleasepool {
#else
	NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
#endif
	elementDict = [self elementDict];
	NSString *streamQueryURL = [NSString stringWithFormat:STREAMINFOQUERY, liveNo];
	NSURL *queryURL = [NSURL URLWithString:streamQueryURL];
	NSData *response = [[NSData alloc] initWithContentsOfURL:queryURL];
	parser = [[NSXMLParser alloc] initWithData:response];
	if (parser != nil)
	{
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
		[parser setDelegate:self];
#else
		[parser setDelegate:(id)self];
#endif
		@try {
			success = [parser parse];
		}
		@catch (NSException *exception) {
			NSLog(@"Catch %@ : %@\n%@", NSStringFromSelector(_cmd), [self class], exception);
		}// end exception handling
	}// end if parser is allocated
#if __has_feature(objc_arc)
	}
#else
	[response release];
	[parser release];
	[arp drain];
#endif
	if (success != YES)
		@throw [NSException exceptionWithName:StreamInforFetchFaild reason:UserProgXMLParseFail userInfo:nil];
}// end - (BOOL) parseProgramInfo:(NSString *)urlString

- (void) parseOwnerNickname:(NSString *)owner
{
#if __has_feature(objc_arc)
	@autoreleasepool {
#else
	NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
#endif
	elementDict = [self elementDict];
	NSError *err;
	NSString *nicknameQueryURL = [NSString stringWithFormat:NICKNAMEQUERY, owner];
	NSURL *queryURL = [NSURL URLWithString:nicknameQueryURL];
	NSString *nicknameXML = [NSString stringWithContentsOfURL:queryURL encoding:NSUTF8StringEncoding error:&err];
	OnigRegexp *nicknameRegex = [OnigRegexp compile:NicknameRegex];
	OnigResult *nicknameResult = [nicknameRegex search:nicknameXML];
	if (nicknameResult != nil)
		broadcastOwnerName = [[NSString alloc] initWithString:[nicknameResult stringAt:1]];
	else
		broadcastOwnerName = [[NSString alloc] initWithString:owner];
	// end if
#if __has_feature(objc_arc)
	}
#else
	[arp drain];
#endif
}// end - (void) parseOwnerNickname:(NSString *)owner

- (BOOL) isEqual:(id)object
{
	if ([object isKindOfClass:[self class]])
	{
		if ([[object programNumber] isEqualToString:programNumber] == YES)
			return YES;
		else
			return NO;
	}
	else if ([object isKindOfClass:[NSString class]])
	{
		if ([programNumber isEqualToString:object] == YES)
			return YES;
		else
			return NO;
	}
	return NO;
}// end - (BOOL) isEqual:(id)object

- (BOOL) isSame:(NLProgram *)program
{
	if (isOfficial == YES)
		return NO;

	if (([[program communityID] isEqualToString:communityID] == YES) &&
		([[program broadcastOwner] isEqualToString:broadcastOwner] == YES))
		return YES;
	else
		return NO;
}// end - (BOOL) isSame:(NLProgram *)program

#pragma mark -
#pragma mark activity control
- (void) terminate
{
	broadCasting = NO;
	[self stopElapsedTimer];
	[self stopProgramStatusTimer];
	if (isMyProgram == YES)
		[center postNotification:[NSNotification notificationWithName:NLNotificationMyBroadcastEnd object:info]];
	[center postNotification:[NSNotification notificationWithName:NLNotificationPorgramEnd object:self]];
}// end - (void) terminate

- (void) suspend
{
	[self resetElapsedTimer];
	[self resetProgramStatusTimer];
}// end - (void) suspend;

- (BOOL) resume
{
	BOOL status = YES;
	if ([self isBroadCasting] == YES)
	{
		[elapseTimer fire];
		[programStatusTimer fire];
	}
	else
	{
		[self stopElapsedTimer];
		[self stopProgramStatusTimer];
		if (isMyProgram == YES)
			[center postNotification:[NSNotification notificationWithName:NLNotificationMyBroadcastEnd object:info]];
		[center postNotification:[NSNotification notificationWithName:NLNotificationPorgramEnd object:self]];
		status = NO;
	}

	return status;
}// end - (void) resume

#pragma mark -
#pragma mark drawing
- (void) drawUserProgram
{
#if __has_feature(objc_arc)
	@autoreleasepool {
#else
	NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
#endif
	NSColor *titleColor = [NSColor colorWithCalibratedRed:ProgramTitleColorRed green:ProgramTitleColorGreen blue:ProgramTitleColorBlue alpha:alpha];
	NSColor *nickColor = [NSColor colorWithCalibratedRed:ProgramOwnerColorRed green:ProgramOwnerColorGreen blue:ProgramOwnerColorBlue alpha:alpha];
	NSColor *descColor = [NSColor colorWithCalibratedRed:ProgramDescColorRed green:ProgramDescColorGreen blue:ProgramDescColorBlue alpha:alpha];
	NSColor *commnunityColor = [NSColor colorWithCalibratedRed:CommunityNameColorRed green:CommunityNameColorGreen blue:CommunityNameColorBlue alpha:alpha];
	NSColor *accountColor = [NSColor colorWithCalibratedRed:AccountColorRed green:AccountColorGreen blue:AccountColorBlue alpha:alpha];
	NSColor *timeColor = [NSColor colorWithCalibratedRed:TimeColorRed green:TimeColorGreen blue:TimeColorBlue alpha:alpha];
	NSBezierPath *exterior = [NSBezierPath bezierPathWithRect:NSMakeRect(originX, originY, programBoundsW, programBoundsH)];

	[exterior setLineWidth:exteriorLineWidth];
	background = [[NSBezierPath alloc] init];
	[background	moveToPoint:NSMakePoint(0, 0)];
	[background lineToPoint:NSMakePoint(programBoundsW, 0)];
	[background lineToPoint:NSMakePoint(programBoundsW, programBoundsH)];
	[background lineToPoint:NSMakePoint(0, programBoundsH)];
	[background	lineToPoint:NSMakePoint(0, 0)];
	[background closePath];

	timeMask = [[NSBezierPath alloc] init];
	[timeMask moveToPoint:NSMakePoint(userElapsedOffsetX, userTimeOffsetY)];
	[timeMask lineToPoint:NSMakePoint(programBoundsW, userTimeOffsetY)];
	[timeMask lineToPoint:NSMakePoint(programBoundsW, elapesedStringHeight)];
	[timeMask lineToPoint:NSMakePoint(userElapsedOffsetX, elapesedStringHeight)];
	[timeMask lineToPoint:NSMakePoint(userElapsedOffsetX, userTimeOffsetY)];
	[timeMask closePath];

	stringAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
		 [NSFont fontWithName:fontNameOfProgramTitle size:11], NSFontAttributeName,
		 commnunityColor, NSForegroundColorAttributeName,
		 [NSNumber numberWithInteger:2], NSLigatureAttributeName,
		 [NSNumber numberWithFloat:titleKernValue], NSKernAttributeName, nil];

	menuImage = [[NSImage alloc] initWithSize:NSMakeSize(programBoundsW, programBoundsH)];

	[menuImage lockFocus];
	[[NSColor whiteColor] set];
	[background fill];
		// draw thumbnail
	if (iconIsValid == YES)
		[thumbnail drawAtPoint:NSMakePoint(originX, originY) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fract];
		// draw program title
	[stringAttributes setValue:titleColor forKey:NSForegroundColorAttributeName];
	[programTitle drawAtPoint:NSMakePoint(progTitleOffsetX, progTitleOffsetY) withAttributes:stringAttributes];
		// draw program owner nickname
	[stringAttributes setValue:nickColor forKey:NSForegroundColorAttributeName];
	[stringAttributes setValue:[NSNumber numberWithFloat:kernValue] forKey:NSKernAttributeName];
	[stringAttributes setValue:[NSFont fontWithName:fontNameOfProgramOwner size:12] forKey:NSFontAttributeName];
	[broadcastOwnerName drawAtPoint:NSMakePoint(progOwnerOffsetX, progOwnerOffsetY) withAttributes:stringAttributes];
		// draw program description
	[stringAttributes setValue:descColor forKey:NSForegroundColorAttributeName];
	[stringAttributes setValue:[NSFont fontWithName:fontNameOfDescription size:10] forKey:NSFontAttributeName];
	[programDescription drawInRect:NSMakeRect(progDescOffsetX, progDescOffsetY, progDescWidth, progDescHeight) withAttributes:stringAttributes];
		// draw community name
	[stringAttributes setValue:[NSFont fontWithName:fontNameOfCommunity size:11] forKey:NSFontAttributeName];
	[stringAttributes setValue:commnunityColor forKey:NSForegroundColorAttributeName];
	[stringAttributes setValue:[NSNumber numberWithFloat:titleComuKernValue] forKey:NSKernAttributeName];
	[communityName drawAtPoint:NSMakePoint(communityOffsetX, communityOffsetY) withAttributes:stringAttributes];
		// draw primary account
	[stringAttributes setValue:[NSFont fontWithName:fontNameOfPrimaryAccount size:11] forKey:NSFontAttributeName];
	[stringAttributes setValue:accountColor forKey:NSForegroundColorAttributeName];
	[primaryAccount drawInRect:NSMakeRect(accountOffsetX, accountOffsetY, accountWitdth, accountHeight) withAttributes:stringAttributes];
		// draw remain time
	[stringAttributes setValue:[NSFont fontWithName:fontNameOfElapsedTime size:12] forKey:NSFontAttributeName];
	[stringAttributes setValue:timeColor forKey:NSForegroundColorAttributeName];
	[startTimeString drawAtPoint:NSMakePoint(userTimeOffsetX, userTimeOffsetY) withAttributes:stringAttributes];
	[menuImage unlockFocus];
#if __has_feature(objc_arc)
	}
#else
	[arp drain];
#endif
}// end - (void) drawUserProgram

- (void) drawOfficialProgram
{
#if __has_feature(objc_arc)
	@autoreleasepool {
#else
	NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
#endif
	NSColor *titleColor = [NSColor colorWithCalibratedRed:ProgramTitleColorRed green:ProgramTitleColorGreen blue:ProgramTitleColorBlue alpha:alpha];
	NSColor *accountColor = [NSColor colorWithCalibratedRed:AccountColorRed green:AccountColorGreen blue:AccountColorBlue alpha:alpha];
	NSColor *timeColor = [NSColor colorWithCalibratedRed:TimeColorRed green:TimeColorGreen blue:TimeColorBlue alpha:alpha];
	NSBezierPath *exterior = [NSBezierPath bezierPathWithRect:NSMakeRect(originX, originY, programBoundsW, programBoundsH)];

	[exterior setLineWidth:exteriorLineWidth];

	background = [[NSBezierPath alloc] init];
	[background	moveToPoint:NSMakePoint(0, 0)];
	[background lineToPoint:NSMakePoint(officialBoundsW, 0)];
	[background lineToPoint:NSMakePoint(officialBoundsW, officialBoundsH)];
	[background lineToPoint:NSMakePoint(0, officialBoundsH)];
	[background	lineToPoint:NSMakePoint(0, 0)];
	[background closePath];

	timeMask = [[NSBezierPath alloc] init];
	[timeMask moveToPoint:NSMakePoint(officialElapsedOffsetX, officialTimeOffsetY)];
	[timeMask lineToPoint:NSMakePoint(officialBoundsW, officialTimeOffsetY)];
	[timeMask lineToPoint:NSMakePoint(officialBoundsW, elapesedStringHeight)];
	[timeMask lineToPoint:NSMakePoint(officialElapsedOffsetX, elapesedStringHeight)];
	[timeMask lineToPoint:NSMakePoint(officialElapsedOffsetX, officialTimeOffsetY)];
	[timeMask closePath];

	stringAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
		[NSFont fontWithName:fontNameOfProgramTitle size:10], NSFontAttributeName,
		titleColor, NSForegroundColorAttributeName,
		[NSNumber numberWithInteger:2], NSLigatureAttributeName,
		[NSNumber numberWithFloat:-0.5], NSKernAttributeName, nil];

	menuImage = [[NSImage alloc] initWithSize:NSMakeSize(officialBoundsW, officialBoundsH)];

	[menuImage lockFocus];
	[[NSColor whiteColor] set];
	[background fill];
		// draw thumbnail
	if (iconIsValid == YES)
		[thumbnail drawAtPoint:NSMakePoint(originX, originY) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fract];
		// draw title / description
	[programTitle drawInRect:NSMakeRect(officialDescX, officialDescY, officialDescW, officialDescH) withAttributes:stringAttributes];
		// draw official announce
	[stringAttributes setValue:[NSFont fontWithName:fontNameOfPrimaryAccount size:11] forKey:NSFontAttributeName];
	[stringAttributes setValue:accountColor forKey:NSForegroundColorAttributeName];
	[primaryAccount drawInRect:NSMakeRect(accountOffsetX, accountOffsetY, accountWitdth, accountHeight) withAttributes:stringAttributes];
		// draw remain
	[stringAttributes setValue:[NSFont fontWithName:fontNameOfElapsedTime size:12] forKey:NSFontAttributeName];
	[stringAttributes setValue:timeColor forKey:NSForegroundColorAttributeName];
	[startTimeString drawAtPoint:NSMakePoint(officialTimeOffsetX, officialTimeOffsetY) withAttributes:stringAttributes];
	[menuImage unlockFocus];
#if __has_feature(objc_arc)
	}
#else
	[arp drain];
#endif
}// end - (void) drawOfficialProgram

#pragma mark -
#pragma mark menuItem
- (void) createMenuItem
{
	programMenu = [[NSMenuItem alloc] initWithTitle:@"" action:@selector(openProgram:) keyEquivalent:@""];
	NSDictionary *rep = [NSDictionary dictionaryWithObjectsAndKeys:
						 self, keyProgram, programURL, keyLiveNumber, nil];
	[programMenu setImage:menuImage];
	[programMenu setEnabled:YES];
	[programMenu setRepresentedObject:rep];
}// - (void) createMenuItem

#pragma mark-
#pragma mark timer driven methods
- (void) updateElapse:(NSTimer*)theTimer
{
	NSInteger now = (NSInteger)[[NSDate date] timeIntervalSinceDate:startTime];
	NSUInteger elapsedMinute = abs((now / 60) % 60);	
	NSUInteger elapsedHour = abs(now / (60 * 60));
	if (elapsedMinute == lastMintue)
		return;

	if (iconWasValid == NO)
	{
		thumbnail = [[NSImage alloc] initWithContentsOfURL:thumbnailURL];
		if ([thumbnail isValid] == YES)
		{
			iconIsValid = YES;
#if __has_feature(objc_arc) == 0
			[thumbnailURL release];
#endif
			thumbnailURL = nil;
		}
		else
		{
#if __has_feature(objc_arc) == 0
			[thumbnail release];
#endif
			thumbnail = nil;
		}// end if fetched thumbnail is valid
	}// end if fetch thumbnail
#if __has_feature(objc_arc)
	@autoreleasepool {
#else
	NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
#endif
	if ((isReservedProgram == YES) && ((elapsedMinute + elapsedHour) == 0))
	{
		if (isOfficial == YES)
		{
			if (isReservedProgram == YES)
				[self growlProgramNotify:GrowlNotifyStartOfficialProgram];
			
			NSBezierPath *path = [NSBezierPath bezierPath];
			[path moveToPoint:NSMakePoint(officialTimeOffsetX, (timeStringHeight / 2))];
			[path lineToPoint:NSMakePoint(officialBoundsW, (timeStringHeight / 2))];
			[path setLineWidth:timeStringHeight];
			NSString *string = [startTime descriptionWithCalendarFormat:StartOfficialTimeFormat timeZone:nil locale:localeDict];
			[menuImage lockFocus];
			if ((iconWasValid == NO) && (iconIsValid == YES))
			{
				[thumbnail drawAtPoint:NSMakePoint(originX, originY) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fract];
				iconWasValid = YES;
			}// end if redraw icon
			[[NSColor whiteColor] set];
			[path stroke];
			[string drawAtPoint:NSMakePoint(userTimeOffsetX, userTimeOffsetY) withAttributes:stringAttributes];
			[menuImage unlockFocus];
		}
		else
		{
			if (isReservedProgram == YES)
				[self growlProgramNotify:GrowlNotifyStartUserProgram];
			NSBezierPath *path = [NSBezierPath bezierPath];
			[path moveToPoint:NSMakePoint(userTimeOffsetX, (timeStringHeight / 2))];
			[path lineToPoint:NSMakePoint(programBoundsW, (timeStringHeight / 2))];
			[path setLineWidth:timeStringHeight];
			NSString *string = [startTime descriptionWithCalendarFormat:StartUserTimeFormat timeZone:nil locale:localeDict];
			[menuImage lockFocus];
			if ((iconWasValid == NO) && (iconIsValid == YES))
			{
				[thumbnail drawAtPoint:NSMakePoint(originX, originY) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fract];
				iconWasValid = YES;
			}// end if redraw icon
			[[NSColor whiteColor] set];
			[path stroke];
			[string drawAtPoint:NSMakePoint(userTimeOffsetX, userTimeOffsetY) withAttributes:stringAttributes];
			[menuImage unlockFocus];
		}
		lastMintue = elapsedMinute;
	}
	else
	{
		NSString *elapesdTime = nil;
		elapesdTime = [NSString stringWithFormat:ElapsedTimeFormat, elapsedHour, elapsedMinute];
		lastMintue = elapsedMinute;
		[menuImage lockFocus];
		if ((iconWasValid == NO) && (iconIsValid == YES))
		{
			[thumbnail drawAtPoint:NSMakePoint(originX, originY) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fract];
			iconWasValid = YES;
		}// end if redraw icon
		[[NSColor whiteColor] set];
		[timeMask fill];
		if (isOfficial == YES)
			[elapesdTime drawAtPoint:NSMakePoint(officialElapsedOffsetX, officialTimeOffsetY) withAttributes:stringAttributes];
		else
			[elapesdTime drawAtPoint:NSMakePoint(userElapsedOffsetX, userTimeOffsetY) withAttributes:stringAttributes];
		[menuImage unlockFocus];
	}// end if just start reserved program
#if __has_feature(objc_arc)
	}
#else
	[arp drain];
#endif
	[center postNotification:[NSNotification notificationWithName:NLNotificationTimeUpdated object:self]];
}// end - (void) updateRemain

- (void) checkBroadcasting:(NSTimer*)theTimer
{
	if ([self isBroadCasting] == NO)
	{	// program is done stop each timer and post notification
		broadCasting = NO;
		[self stopElapsedTimer];
		[self stopProgramStatusTimer];
		if (isMyProgram == YES)
			[center postNotification:[NSNotification notificationWithName:NLNotificationMyBroadcastEnd object:info]];
		[center postNotification:[NSNotification notificationWithName:NLNotificationPorgramEnd object:self]];
	}
}// end - (void) checkBroadcasting

- (BOOL) isBroadCasting
{
	NSString *urlStr = [NSString stringWithFormat:STREMEMBEDQUERY, programNumber];
	NSURL *url = [NSURL URLWithString:urlStr];
	NSError *err = nil;
	NSString *embed = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
	if ((err != nil) || ([embed length] == 0))
		return YES;

	OnigRegexp *liveStateRegex = [OnigRegexp compile:ProgStateRegex];
	OnigResult *result = [liveStateRegex search:embed];
	if (([[result stringAt:1] isEqualToString:DONESTATE] == YES) ||
		([[result stringAt:1] isEqualToString:DONETSSTATE] == YES))
		return NO;
	else
		return YES;
}// end - (BOOL) isBroadCasting:(BOOL)needPost

#pragma mark -
#pragma mark timer management methods
- (void) stopProgramStatusTimer
{		// check timer is running
	if ([programStatusTimer isValid] == YES)
		[programStatusTimer invalidate];
	programStatusTimer = nil;
}// end - (void) stopProgramStatusTimer

- (void) stopElapsedTimer
{		// check timer is running
	if ([elapseTimer isValid] == YES)
		[elapseTimer invalidate];
	elapseTimer = nil;
	
}// end - (void) stopElapsedTimer

- (void) resetProgramStatusTimer
{		// check timer is running
	if ([programStatusTimer isValid] == YES)
		[programStatusTimer invalidate];

		// setup timer object
	programStatusTimer = [NSTimer scheduledTimerWithTimeInterval:checkActivityCycle target:self selector:@selector(checkBroadcasting:) userInfo:nil repeats:YES];
}// end - (void) resetProgramStatusTimer

- (void) resetElapsedTimer
{		// check timer is running
	if ([elapseTimer isValid] == YES)
		[elapseTimer invalidate];

		// setup timer object
	elapseTimer = [NSTimer scheduledTimerWithTimeInterval:elapseCheckCycle target:self selector:@selector(updateElapse:) userInfo:nil repeats:YES];
}// end - (void) resetElapsedTimer

#pragma mark -
#pragma mark Growling
- (void) growlProgramNotify:(NSString *)notificationName
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
	NSNumber *priority = [NSNumber numberWithInt:0];
	NSNumber *isStickey = [NSNumber numberWithBool:NO];
	NSData *context = [NSArchiver archivedDataWithRootObject:info];
	[dict setValue:notificationName forKey:GROWL_NOTIFICATION_NAME];
	[dict setValue:programTitle forKey:GROWL_NOTIFICATION_TITLE];
	if (programDescription != nil)
		[dict setValue:programDescription forKey:GROWL_NOTIFICATION_DESCRIPTION];
#ifdef GROWL_NOTIFICATION_ICON_DATA
	[dict setValue:[thumbnail TIFFRepresentation] forKey:GROWL_NOTIFICATION_ICON_DATA];
#else
	[dict setValue:[thumbnail TIFFRepresentation] forKey:GROWL_NOTIFICATION_ICON];
#endif
	[dict setValue:priority forKey:GROWL_NOTIFICATION_PRIORITY];
	[dict setValue:isStickey forKey:GROWL_NOTIFICATION_STICKY];
	[dict setValue:context forKey:GROWL_NOTIFICATION_CLICK_CONTEXT];

	[GrowlApplicationBridge notifyWithDictionary:dict];
}// end - (void) growlProgramNotify:(NSString *)notificationName

#pragma mark -
#pragma mark NSXMLParserDelegate methods
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
}// end - (void)parserDidStartDocument:(NSXMLParser *)parser

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}// end - (void)parserDidEndDocument:(NSXMLParser *)parser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:elementStreaminfo] == YES)
		if ([[attributeDict valueForKey:keyXMLStatus] isEqualToString:resultOK] == NO)
			@throw [NSException exceptionWithName:RESULTERRORNAME reason:RESULTERRORREASON userInfo:attributeDict];
		// end if result is not ok
	// end if element is status

	currentElement = [[elementDict valueForKey:elementName] integerValue];
	if (currentElement != 0)
	{
		dataString = [NSMutableString string];
			//		programDataBuffer = [NSMutableData data];
	}// end if
}// end - (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
	NSError *err = nil;
#endif
	NSData *thumbData = nil;
	switch (currentElement) {
		case indexRequestID:
			programURL = [[NSString alloc] initWithString:[NSString stringWithFormat:PROGRAMURLFORMAT, dataString]];
			break;
		case indexTitle:
			programTitle = [[NSString alloc] initWithString:dataString];
			break;
		case indexDescription:
			programDescription = [[NSString alloc] initWithString:dataString];
			break;
		case indexComuName:
			if (communityName == nil)
				communityName = [[NSString alloc] initWithString:dataString];
			break;
		case indexComuID:
			communityID = [[NSString alloc] initWithString:dataString];
			break;
		case indexThumbnail:
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
			thumbData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dataString] options:NSDataReadingUncached error:&err];
#else
			thumbData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dataString]];
#endif
			thumbnail = [[NSImage alloc] initWithData:thumbData];
			if ([thumbnail isValid] == YES)
			{
				[thumbnail setSize:NSMakeSize(thumbnailSize, thumbnailSize)];
				iconWasValid = YES;
				iconIsValid = YES;
			}
			else
			{	// retry fetch image
#if __has_feature(objc_arc) == 0
				[thumbnail release];
#endif
				thumbnail = nil;
				thumbnailURL = [[NSURL alloc] initWithString:dataString];

			}
			break;
		case indexNickname:
			broadcastOwnerName = [[NSString alloc] initWithString:dataString];
			break;
		default:
			break;
	}
}// end - (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	[dataString appendString:string];
}// end - (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue
{
}// end - (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
}// end - (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError
{
}// end - (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix
{
}// end - (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI
{
}// end - (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
}// end - (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
}// end - (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment

- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model
{
}// end - (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model

- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)entityName publicID:(NSString *)publicID systemID:(NSString *)systemID
{
}// end - (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)entityName publicID:(NSString *)publicID systemID:(NSString *)systemID

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{
}// end - (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString

- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value
{
}// end - (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value

- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{
}// end - (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
{
}// end - (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data

- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName
{
}// end - (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName
/*
- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)entityName systemID:(NSString *)systemID
{
	return nil;
}// end - (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)entityName systemID:(NSString *)systemID
*/
@end
