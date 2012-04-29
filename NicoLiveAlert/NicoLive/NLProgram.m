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

const CGFloat originX = 0.0;
const CGFloat originY = 0.0;
const CGFloat thumbnailSize = 50.0;
const CGFloat titleImageWidth = 280.0;
const CGFloat exteriorLineWidth = 1.0;
const CGFloat titleKernValue = 0.0;
const CGFloat descKernValue = 0.0;
const CGFloat titleComuKernValue = 0.0;
const CGFloat timeStringWidth = 110.0;
const CGFloat timeStringHeight = 14.0;
const CGFloat elapesedStringWidth = 39;
const CGFloat elapesedStringHeight = timeStringHeight;

#pragma mark user program constant
const CGFloat programBoundsW = 293.0;
const CGFloat programBoundsH = 64.0;
const CGFloat accountOffsetX = 52.0;
const CGFloat accountOffsetY = 0.0;
const CGFloat accountWitdth = 120.0;
const CGFloat accountHeight = 18.0;
const CGFloat communityOffsetX = 52.0;
const CGFloat communityOffsetY = 12.0;
const CGFloat progTitleOffsetX = 0.0;
const CGFloat progTitleOffsetY = 51.0;
const CGFloat progDescOffsetX = 52.0;
const CGFloat progDescOffsetY = 24.0;
const CGFloat progDescWidth = (programBoundsW - thumbnailSize);
const CGFloat progDescHeight = 28.0;
const CGFloat userTimeOffsetX = (programBoundsW - timeStringWidth);
const CGFloat userTimeOffsetY = 0.0;
const CGFloat userElapsedOffsetX = (programBoundsW - elapesedStringWidth);

#pragma mark official program constant
const CGFloat officialBoundsW = 293.0;
const CGFloat officialBoundsH = 50.0;
const CGFloat officialDescX = 52.0;
const CGFloat officialDescY = 24.0;
const CGFloat officialDescW = (officialBoundsW - thumbnailSize);
const CGFloat officialDescH = (officialBoundsH - officialDescY);
const CGFloat officialTimeOffsetX = (officialBoundsW - timeStringWidth);
const CGFloat officialTimeOffsetY = 0.0;
const CGFloat officialElapsedOffsetX = (officialBoundsW - elapesedStringWidth);

#pragma mark color constant
const CGFloat alpha = 1.0;
const CGFloat fract = 1.0;
	// program title color
const CGFloat ProgramTitleColorRed = (0.0 / 255);
const CGFloat ProgramTitleColorGreen = (0.0 / 255);
const CGFloat ProgramTitleColorBlue = (255.0 / 255);
	// program description color
const CGFloat ProgramDescColorRed = (64.0 / 255);
const CGFloat ProgramDescColorGreen = (64.0 / 255);
const CGFloat ProgramDescColorBlue = (64.0 / 255);
	// commnunity name color
const CGFloat CommunityNameColorRed = (204.0 / 255);
const CGFloat CommunityNameColorGreen = (102.0 / 255);
const CGFloat CommunityNameColorBlue = (255.0 / 255);
	// account color
const CGFloat AccountColorRed = (0.0 / 255);
const CGFloat AccountColorGreen = (128.0 / 255);
const CGFloat AccountColorBlue = (128.0 / 255);
	// remain time color
const CGFloat TimeColorRed = (128.0 / 255);
const CGFloat TimeColorGreen = (0.0 / 255);
const CGFloat TimeColorBlue = (64.0 / 255);

#pragma timer constant
const NSTimeInterval checkActivityCycle = (60.0 * 3);
const NSTimeInterval elapseCheckCycle = (10.0);

@interface NLProgram ()
	// construction support methods
- (void) clearAllMember;
- (void) setupEachMember:(NSString *)liveNo;
- (NSDictionary *) elementDict;
- (void) checkStartTime:(NSDate *)date forLive:(NSString *)liveNo;
- (NSString *) makeStartString;
- (void) parseOfficialProgram;
- (void) parseProgramInfo:(NSString *)liveNo;
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
- (void) notifyUserToUser;
- (void) notifyOfficialToUser;
@end

@implementation NLProgram
@synthesize programMenu;
@synthesize programNumber;
@synthesize communityID;
@synthesize broadcastOwner;
@synthesize isOfficial;
@synthesize broadCasting;
NSMutableString *dataString;
NSInteger currentElement;
NSDictionary *elementDict;
NSString *embedContent;

#pragma mark construct / destruct
- (id) initWithProgram:(NSString *)liveNo withDate:(NSDate *)date forAccount:(NLAccount *)account owner:(NSString *)owner
{
	self = [super init];
	if (self)
	{		// initialize member variables
		[self clearAllMember];

		@try {
			[self checkStartTime:date forLive:liveNo];
			[self parseProgramInfo:liveNo];
		}
		@catch (NSException *exception) {
			NSLog(@"Catch %@ : %@", NSStringFromSelector(_cmd), [self class]);
			NSLog(@"Exception : %@, %@, %@", [exception name], [exception reason], [exception userInfo]);
#if __has_feature(objc_arc) == 0
			[self dealloc];
#endif
			return NULL;
		}
		primaryAccount = [[account username] copy];
		[self setupEachMember:liveNo];
		broadcastOwner = [owner copy];
		[elapseTimer fire];
		[programStatusTimer fire];
		[self notifyUserToUser];
	}// end if
	return self;
}// end - (id) initWithProgram:(NSString *)liveNo forAccount:(NLAccount *)account

- (id) initWithProgram:(NSString *)liveNo withDate:(NSDate *)date
{
	self = [super init];
	if (self)
	{		// initialize member variables
		[self clearAllMember];
		
		isOfficial = YES;
		@try {
			[self checkStartTime:date forLive:liveNo];
			[self parseOfficialProgram];
		}
		@catch (NSException *exception) {
			NSLog(@"Catch %@ : %@", NSStringFromSelector(_cmd), [self class]);
			NSLog(@"Exception : %@, %@, %@", [exception name], [exception reason], [exception userInfo]);
#if __has_feature(objc_arc) == 0
			[self dealloc];
#endif
			return NULL;
		}
		primaryAccount = [[NSString alloc] initWithString:OfficialTitleString];
		[self setupEachMember:liveNo];
		[elapseTimer fire];
		[programStatusTimer fire];
		[self notifyOfficialToUser];
	}// end if
	return self;
}// end - (id) initWithOfficial:(NSString *)liveNo


- (void) dealloc
{
#if __has_feature(objc_arc) == 0
	if (programMenu != NULL)		[programMenu release];
	if (menuImage != NULL)			[menuImage release];
	if (background != NULL)			[background release];
	if (timeMask != NULL)			[timeMask release];
	if (thumbnail != NULL)			[thumbnail release];
	if (stringAttributes != NULL)	[stringAttributes release];
	if (programNumber != NULL)		[programNumber release];
	if (programTitle != NULL)		[programTitle release];
	if (programDescription != NULL)	[programDescription release];
	if (communityName != NULL)		[communityName release];
	if (primaryAccount != NULL)		[primaryAccount release];
	if (communityID != NULL)		[communityID release];
	if (broadcastOwner != NULL)		[broadcastOwner release];
	if (startTime != NULL)			[startTime release];
	if (startTimeString != NULL)	[startTimeString release];
	if (programURL != NULL)			[programURL release];
	if (liveStateRegex != NULL)		[liveStateRegex release];

	if (embedContent != NULL)		[embedContent release];

	[super dealloc];
#endif
}// end - (void) dealloc

#pragma mark -
#pragma mark construction support
- (void) clearAllMember
{
	programMenu = NULL;
	menuImage = NULL;
	thumbnail = NULL;
	background = NULL;
	timeMask = NULL;
	stringAttributes = NULL;
	programNumber = NULL;
	programTitle = NULL;
	programDescription = NULL;
	communityName = NULL;
	primaryAccount = NULL;
	communityID = NULL;
	broadcastOwner = NULL;
	startTime = NULL;
	startTimeString = NULL;
	lastMintue = 0;
	localeDict = NULL;
	programURL = NULL;
	programStatusTimer = NULL;
	elapseTimer = NULL;
	center = NULL;
	isReservedProgram = NO;
	isOfficial = NO;
	broadCasting = NO;
	liveStateRegex = NULL;

	dataString = NULL;
	currentElement = 0;
	elementDict = NULL;
	embedContent = NULL;
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
	[self createMenuItem];
	[self resetElapsedTimer];
	[self resetProgramStatusTimer];
	liveStateRegex = [OnigRegexp compile:ProgStateRegex];
#if __has_feature(objc_arc) == 0
	[liveStateRegex retain];
#endif
	broadCasting = YES;
}// end - (void) setupEachMember:(NSString *)liveNo

- (NSDictionary *) elementDict
{
	NSDictionary *elementDict = [NSDictionary dictionaryWithObjectsAndKeys:
		 [NSNumber numberWithInteger:indexStreaminfo], elementStreaminfo,
		 [NSNumber numberWithInteger:indexRequestID], elementRequestID,
		 [NSNumber numberWithInteger:indexDescription], elementDescription,
		 [NSNumber numberWithInteger:indexTitle], elementTitle,
		 [NSNumber numberWithInteger:indexComuName], elementComuName,
		 [NSNumber numberWithInteger:indexThumbnail], elementThumbnail, nil];

	return elementDict;
}// end - (NSDictionary *) elementDict

- (void) checkStartTime:(NSDate *)date forLive:(NSString *)liveNo
{
	OnigRegexp *broadcastTimeRegex = [OnigRegexp compile:ProgStartTimeRegex];
	NSURL *embedURL = [NSURL URLWithString:[NSString stringWithFormat:STREMEMBEDQUERY, liveNo]];

	NSError *err = NULL;
	embedContent = [[NSString alloc] initWithContentsOfURL:embedURL encoding:NSUTF8StringEncoding error:&err];
	if (embedContent == NULL)
		@throw [NSException exceptionWithName:EmbedFetchFailed reason:StringIsEmpty userInfo:NULL];
/*
	if (err != NULL)
	{
		NSLog(@"Error %@ : %@", NSStringFromSelector(_cmd), [self class]);
		NSLog(@"%@", err);
		NSLog(@"%ld, %@, %@", [err code], [err domain], [err userInfo]);
			//		@throw [NSException exceptionWithName:EmbedFetchFailed reason:ErrorIsNotNULL userInfo:[NSDictionary dictionaryWithObject:err forKey:@"OSError"]];
	}
*/
	OnigResult *checkOnair = [liveStateRegex search:embedContent];
	OnigResult *broadcastTime = [broadcastTimeRegex search:embedContent];
	if (broadcastTime == NULL)
	{
		startTime = [date copy];
		return;
	}

	NSDate *broadcastDate = [NSDate dateWithNaturalLanguageString:[broadcastTime stringAt:1] locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
	NSInteger diff = (NSInteger)[date timeIntervalSinceDate:broadcastDate];
	if (([[checkOnair stringAt:1] isEqualToString:BEFORESTATE] == YES)
		|| ((abs(diff / 60) != 0)))
	{
		startTime = [broadcastDate copy];
		lastMintue = (diff / 60) % 60;
		isReservedProgram = YES;

		return;
	}// endif befor program start

	startTime = [date copy];
	lastMintue = 0;
}// end - (void) checkStartTime:(NSDate *)date forLive:(NSString *)liveNo

- (NSString *) makeStartString
{
	NSString *startString = NULL;
	NSUInteger minute = 0;
	if (isReservedProgram == YES)
		minute = abs([[NSDate date] timeIntervalSinceDate:startTime] / 60);
	
	if (isOfficial != YES)
	{		// user program check reserve or not
		if (isReservedProgram == YES)
		{
			NSString *calFromat = [NSString stringWithFormat:ReserveUserTimeFormat, minute];
			startString = [startTime descriptionWithCalendarFormat:calFromat timeZone:NULL locale:localeDict];
		}
		else
		{
			startString = [startTime descriptionWithCalendarFormat:StartUserTimeFormat timeZone:NULL locale:localeDict];
		}
	}
	else
	{		// official program it must reserved
		if (isReservedProgram == YES)
		{
			NSString *calFromat = [NSString stringWithFormat:ReserveOfficialTimeFormat, minute];
			startString = [startTime descriptionWithCalendarFormat:calFromat timeZone:NULL locale:localeDict];
		}
		else
		{
			startString = [startTime descriptionWithCalendarFormat:StartOfficialTimeFormat timeZone:NULL locale:localeDict];
		}
	}// end if official or user program

	return startString;
}// end - (NSString *) makeStartString

- (void) parseOfficialProgram
{
	OnigRegexp *titleRegex = [OnigRegexp compile:ProgramTitleRegex];
	OnigRegexp *imgRegex = [OnigRegexp compile:ThumbImageRegex];
	OnigRegexp *programRegex = [OnigRegexp compile:ProgramURLRegex];
	OnigResult *result = NULL;

	result = [titleRegex search:embedContent];
	if (result == NULL)
		@throw [NSException exceptionWithName:EmbedParseFailed reason:ProgramTitleCollectFail userInfo:[NSDictionary dictionaryWithObject:embedContent forKey:@"embedContent"]];
	programTitle = [[NSString alloc] initWithString:[result stringAt:1]];

	result = [imgRegex search:embedContent];
	if (result == NULL)
		@throw [NSException exceptionWithName:EmbedParseFailed reason:ImageURLCollectFail userInfo:[NSDictionary dictionaryWithObject:embedContent forKey:@"embedContent"]];
	thumbnail = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[result stringAt:1]]];
NSLog(@"thumbnail isValid : %c", ([thumbnail isValid] == YES ? 'Y' : 'N'));
	[thumbnail setSize:NSMakeSize(thumbnailSize, thumbnailSize)];
	
	result = [programRegex search:embedContent];
	if (result == NULL)
		@throw [NSException exceptionWithName:EmbedParseFailed reason:ProgramURLCollectFail userInfo:[NSDictionary dictionaryWithObject:embedContent forKey:@"embedContent"]];
	programURL = [[NSURL alloc] initWithString:[result stringAt:1]];
#if __has_feature(objc_arc) == 0
	[embedContent release];
	embedContent = NULL;
#endif
}// end - (void) parseOfficialProgram

- (void) parseProgramInfo:(NSString *)liveNo
{
#if __has_feature(objc_arc) == 0
	[embedContent release];
	embedContent = NULL;
#endif
	BOOL success = NO;
	NSXMLParser *parser = NULL;
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
	[parser setDelegate:self];
	@try {
		success = [parser parse];
	}
	@catch (NSException *exception) {
		NSLog(@"Catch %@ : %@", NSStringFromSelector(_cmd), [self class]);
		NSLog(@"Exception : %@, %@, %@", [exception name], [exception reason], [exception userInfo]);
		success = NO;
	}// end exception handling
	
#if __has_feature(objc_arc) == 0
	[parser release];
	[arp release];
#else
	}
#endif
	if (success != YES)
		@throw [NSException exceptionWithName:StreamInforFetchFaild reason:UserProgXMLParseFail userInfo:NULL];
}// end - (BOOL) parseProgramInfo:(NSString *)urlString

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
	if (([[program communityID] isEqualToString:communityID] == YES) &&
		([[program broadcastOwner] isEqualToString:broadcastOwner]))
		return YES;
	else
		return NO;
}// end - (BOOL) isSame:(NLProgram *)program

#pragma mark -
#pragma mark activity control
- (void) terminate
{
	broadCasting = NO;
	if ([elapseTimer isValid] == YES)			[elapseTimer invalidate];
	if ([programStatusTimer isValid] == YES)	[programStatusTimer invalidate];
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
		[center postNotification:[NSNotification notificationWithName:NLNotificationPorgramEnd object:self]];
		status = NO;
	}

	return status;
}// end - (void) resume

#pragma mark -
#pragma mark drawing
- (void) drawUserProgram
{
	NSColor *titleColor = [NSColor colorWithCalibratedRed:ProgramTitleColorRed green:ProgramTitleColorGreen blue:ProgramTitleColorBlue alpha:alpha];
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
		 [NSFont fontWithName:@"HiraKakuPro-W6" size:11], NSFontAttributeName,
		 commnunityColor, NSForegroundColorAttributeName,
		 [NSNumber numberWithInteger:2], NSLigatureAttributeName,
		 [NSNumber numberWithFloat:titleKernValue], NSKernAttributeName, nil];

	menuImage = [[NSImage alloc] initWithSize:NSMakeSize(programBoundsW, programBoundsH)];

	[menuImage lockFocus];
	[[NSColor whiteColor] set];
	[background fill];
		// draw thumbnail
	[thumbnail drawAtPoint:NSMakePoint(originX, originY) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fract];
		// draw program title
	[stringAttributes setValue:titleColor forKey:NSForegroundColorAttributeName];
	[programTitle drawAtPoint:NSMakePoint(progTitleOffsetX, progTitleOffsetY) withAttributes:stringAttributes];
		// draw program description
	[stringAttributes setValue:descColor forKey:NSForegroundColorAttributeName];
	[stringAttributes setValue:[NSFont fontWithName:@"HiraMaruPro-W4" size:10] forKey:NSFontAttributeName];
	[stringAttributes setValue:[NSNumber numberWithFloat:descKernValue] forKey:NSKernAttributeName];
	[programDescription drawInRect:NSMakeRect(progDescOffsetX, progDescOffsetY, progDescWidth, progDescHeight) withAttributes:stringAttributes];
		// draw community name
	[stringAttributes setValue:[NSFont fontWithName:@"HiraKakuPro-W6" size:11] forKey:NSFontAttributeName];
	[stringAttributes setValue:commnunityColor forKey:NSForegroundColorAttributeName];
	[stringAttributes setValue:[NSNumber numberWithFloat:titleComuKernValue] forKey:NSKernAttributeName];
	[communityName drawAtPoint:NSMakePoint(communityOffsetX, communityOffsetY) withAttributes:stringAttributes];
		// draw primary account
	[stringAttributes setValue:[NSFont fontWithName:@"Futura-Medium" size:11] forKey:NSFontAttributeName];
	[stringAttributes setValue:accountColor forKey:NSForegroundColorAttributeName];
	[primaryAccount drawInRect:NSMakeRect(accountOffsetX, accountOffsetY, accountWitdth, accountHeight) withAttributes:stringAttributes];
		// draw remain time
	[stringAttributes setValue:[NSFont fontWithName:@"CourierNewPS-BoldMT" size:12] forKey:NSFontAttributeName];
	[stringAttributes setValue:timeColor forKey:NSForegroundColorAttributeName];
	[startTimeString drawAtPoint:NSMakePoint(userTimeOffsetX, userTimeOffsetY) withAttributes:stringAttributes];
	[menuImage unlockFocus];
}// end - (void) drawUserProgram

- (void) drawOfficialProgram
{
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
		[NSFont fontWithName:@"HiraKakuPro-W6" size:10], NSFontAttributeName,
		titleColor, NSForegroundColorAttributeName,
		[NSNumber numberWithInteger:2], NSLigatureAttributeName,
		[NSNumber numberWithFloat:-0.5], NSKernAttributeName, nil];

	menuImage = [[NSImage alloc] initWithSize:NSMakeSize(officialBoundsW, officialBoundsH)];

	[menuImage lockFocus];
	[[NSColor whiteColor] set];
	[background fill];
		// draw thumbnail
	[thumbnail drawAtPoint:NSMakePoint(originX, originY) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fract];
		// draw title / description
	[programTitle drawInRect:NSMakeRect(officialDescX, officialDescY, officialDescW, officialDescH) withAttributes:stringAttributes];
		// draw official announce
	[stringAttributes setValue:[NSFont fontWithName:@"Futura-Medium" size:11] forKey:NSFontAttributeName];
	[stringAttributes setValue:accountColor forKey:NSForegroundColorAttributeName];
	[primaryAccount drawInRect:NSMakeRect(accountOffsetX, accountOffsetY, accountWitdth, accountHeight) withAttributes:stringAttributes];
		// draw remain
	[stringAttributes setValue:[NSFont fontWithName:@"CourierNewPS-BoldMT" size:12] forKey:NSFontAttributeName];
	[stringAttributes setValue:timeColor forKey:NSForegroundColorAttributeName];
	[startTimeString drawAtPoint:NSMakePoint(officialTimeOffsetX, officialTimeOffsetY) withAttributes:stringAttributes];
	[menuImage unlockFocus];
}// end - (void) drawOfficialProgram

#pragma mark -
#pragma mark menuItem
- (void) createMenuItem
{
	programMenu = [[NSMenuItem alloc] initWithTitle:@"" action:@selector(openProgram:) keyEquivalent:@""];
	[programMenu setImage:menuImage];
	[programMenu setEnabled:YES];
	[programMenu setRepresentedObject:programURL];
}// - (void) createMenuItem

#pragma mark-
#pragma mark timer driven methods
- (void) updateElapse:(NSTimer*)theTimer
{
	NSInteger now = (NSInteger)[[NSDate date] timeIntervalSinceDate:startTime];
	NSUInteger elapsedMinute = abs((now / 60) % 60);	
	if (elapsedMinute == lastMintue)
		return;

	if ((elapsedMinute == 0) && (isReservedProgram == YES))
	{
		if (isOfficial == YES)
		{
			NSBezierPath *path = [NSBezierPath bezierPath];
			[path moveToPoint:NSMakePoint(officialTimeOffsetX, (timeStringHeight / 2))];
			[path lineToPoint:NSMakePoint(officialBoundsW, (timeStringHeight / 2))];
			[path setLineWidth:timeStringHeight];
			NSString *string = [startTime descriptionWithCalendarFormat:StartOfficialTimeFormat timeZone:NULL locale:localeDict];
			[menuImage lockFocus];
			[[NSColor whiteColor] set];
			[path stroke];
			[string drawAtPoint:NSMakePoint(userTimeOffsetX, userTimeOffsetY) withAttributes:stringAttributes];
			[menuImage unlockFocus];
		}
		else
		{
			NSBezierPath *path = [NSBezierPath bezierPath];
			[path moveToPoint:NSMakePoint(userTimeOffsetX, (timeStringHeight / 2))];
			[path lineToPoint:NSMakePoint(programBoundsW, (timeStringHeight / 2))];
			[path setLineWidth:timeStringHeight];
			NSString *string = [startTime descriptionWithCalendarFormat:StartUserTimeFormat timeZone:NULL locale:localeDict];
			[menuImage lockFocus];
			[[NSColor whiteColor] set];
			[path stroke];
			[string drawAtPoint:NSMakePoint(userTimeOffsetX, userTimeOffsetY) withAttributes:stringAttributes];
			[menuImage unlockFocus];
		}
		lastMintue = elapsedMinute;
		return;
	}// end if just start reserved program

	NSUInteger elapsedHour = abs(now / (60 * 60));
	NSString *elapesdTime = NULL;
	elapesdTime = [NSString stringWithFormat:ElapsedTimeFormat, elapsedHour, elapsedMinute];
	lastMintue = elapsedMinute;
	[menuImage lockFocus];
	[[NSColor whiteColor] set];
	[timeMask fill];
	if (isOfficial == YES)
		[elapesdTime drawAtPoint:NSMakePoint(officialElapsedOffsetX, officialTimeOffsetY) withAttributes:stringAttributes];
	else
		[elapesdTime drawAtPoint:NSMakePoint(userElapsedOffsetX, userTimeOffsetY) withAttributes:stringAttributes];
	[menuImage unlockFocus];
	[center postNotification:[NSNotification notificationWithName:NLNotificationTimeUpdated object:self]];
}// end - (void) updateRemain

- (void) checkBroadcasting:(NSTimer*)theTimer
{
	if ([self isBroadCasting] == NO)
	{	// program is done stop each timer and post notification
NSLog(@"%@ Program done", programNumber);
		broadCasting = NO;
		[self stopElapsedTimer];
		[self stopProgramStatusTimer];
		[center postNotification:[NSNotification notificationWithName:NLNotificationPorgramEnd object:self]];
	}
}// end - (void) checkBroadcasting

- (BOOL) isBroadCasting
{
	NSString *urlStr = [NSString stringWithFormat:STREMEMBEDQUERY, programNumber];
	NSURL *url = [NSURL URLWithString:urlStr];
	NSError *err;
	NSString *embed = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
	OnigResult *result = [liveStateRegex search:embed];
	if ((result == NULL) || ([[result stringAt:1] isEqualToString:DONESTATE]== YES))
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
	programStatusTimer = NULL;
}// end - (void) stopProgramStatusTimer

- (void) stopElapsedTimer
{		// check timer is running
	if ([elapseTimer isValid] == YES)
		[elapseTimer invalidate];
	elapseTimer = NULL;
	
}// end - (void) stopElapsedTimer

- (void) resetProgramStatusTimer
{		// check timer is running
	if ([programStatusTimer isValid] == YES)
		[programStatusTimer invalidate];

		// setup timer object
	programStatusTimer = [NSTimer scheduledTimerWithTimeInterval:checkActivityCycle target:self selector:@selector(checkBroadcasting:) userInfo:NULL repeats:YES];
}// end - (void) resetProgramStatusTimer

- (void) resetElapsedTimer
{		// check timer is running
	if ([elapseTimer isValid] == YES)
		[elapseTimer invalidate];

		// setup timer object
	elapseTimer = [NSTimer scheduledTimerWithTimeInterval:elapseCheckCycle target:self selector:@selector(updateElapse:) userInfo:NULL repeats:YES];
}// end - (void) resetElapsedTimer

#pragma mark -
#pragma mark Growling
- (void) notifyUserToUser
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
	NSNumber *priority = [NSNumber numberWithInt:2];
	NSNumber *isStickey = [NSNumber numberWithBool:NO];
	[dict setObject:GrowlNotifyFoundUserProgram forKey:GROWL_NOTIFICATION_NAME];
	[dict setObject:programTitle forKey:GROWL_NOTIFICATION_TITLE];
	[dict setObject:programDescription forKey:GROWL_NOTIFICATION_DESCRIPTION];
#ifdef GROWL_NOTIFICATION_ICON_DATA
	[dict setObject:thumbnail forKey:GROWL_NOTIFICATION_ICON_DATA];
#else
	[dict setObject:thumbnail forKey:GROWL_NOTIFICATION_ICON];
#endif
	[dict setObject:priority forKey:GROWL_NOTIFICATION_PRIORITY];
	[dict setObject:isStickey forKey:GROWL_NOTIFICATION_STICKY];
	[dict setObject:[programURL absoluteString] forKey:GROWL_NOTIFICATION_CLICK_CONTEXT];
	
	[GrowlApplicationBridge notifyWithDictionary:dict];
}// end - (void) notifyToUser

- (void) notifyOfficialToUser
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
	NSNumber *priority = [NSNumber numberWithInt:2];
	NSNumber *isStickey = [NSNumber numberWithBool:NO];
	[dict setObject:GrowlNotifyFoundOfficialProgram forKey:GROWL_NOTIFICATION_NAME];
	[dict setObject:programTitle forKey:GROWL_NOTIFICATION_TITLE];
	[dict setObject:programDescription forKey:GROWL_NOTIFICATION_DESCRIPTION];
#ifdef GROWL_NOTIFICATION_ICON_DATA
	[dict setObject:thumbnail forKey:GROWL_NOTIFICATION_ICON_DATA];
#else
	[dict setObject:thumbnail forKey:GROWL_NOTIFICATION_ICON];
#endif
	[dict setObject:priority forKey:GROWL_NOTIFICATION_PRIORITY];
	[dict setObject:isStickey forKey:GROWL_NOTIFICATION_STICKY];
	[dict setObject:[programURL absoluteString] forKey:GROWL_NOTIFICATION_CLICK_CONTEXT];
	
	[GrowlApplicationBridge notifyWithDictionary:dict];
}// end - (void) notifyToUser

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
	NSError *err = NULL;
	NSData *thumbData = NULL;
	switch (currentElement) {
		case indexRequestID:
			programURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:PROGRAMURLFORMAT, dataString]];
			break;
		case indexTitle:
			programTitle = [[NSString alloc] initWithString:dataString];
			break;
		case indexDescription:
			programDescription = [[NSString alloc] initWithString:dataString];
			break;
		case indexComuName:
			if (communityName == NULL)
				communityName = [[NSString alloc] initWithString:dataString];
			break;
		case indexComuID:
			communityID = [[NSString alloc] initWithString:dataString];
			break;
		case indexThumbnail:
			thumbData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dataString] options:NSDataReadingUncached error:&err];
			thumbnail = [[NSImage alloc] initWithData:thumbData];
			if ([thumbnail isValid] == NO)
			{	// retry fetch image
			}
			[thumbnail setSize:NSMakeSize(thumbnailSize, thumbnailSize)];
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
	return NULL;
}// end - (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)entityName systemID:(NSString *)systemID
*/
@end
