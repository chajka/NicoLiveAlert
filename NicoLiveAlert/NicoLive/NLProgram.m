//
//  NLProgram.m
//  NicoLiveAlert
//
//  Created by Чайка on 4/9/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLProgram.h"
#import "HTTPConnection.h"

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
const CGFloat elapesedStringHeight = 14.0;

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
const NSTimeInterval elapseCheckCycle = (5.0);

@interface NLProgram ()
- (NSDictionary *) elementDict;
- (BOOL) parseProgramInfo:(NSString *)urlString;
- (void) drawUserProgram;
- (void) drawOfficialProgram;
- (void) createMenuItem;
- (void) updateElapse;
- (void) checkBroadcasting;
@end

@implementation NLProgram
@synthesize programMenu;
@synthesize programNumber;
@synthesize isOfficial;
@synthesize isBroadCasting;
NSMutableString *dataString;
NSInteger currentElement;
NSDictionary *elementDict;

#pragma mark construct / destruct
- (id) initWithProgram:(NSString *)liveNo withDate:(NSDate *)date forAccount:(NLAccount *)account
{
	self = [super init];
	if (self)
	{		// initialize member variables
		dataString = NULL;
			//		programDataBuffer = NULL;
		programMenu = NULL;
		menuImage = NULL;
		programNumber = NULL;
		programTitle = NULL;
		programDescription = NULL;
		communityName = NULL;
		primaryAccount = [account username];
		programURL = NULL;
		programStatusTimer = NULL;
		isOfficial = NO;
		isBroadCasting = NO;

		NSString *streamQuery = [NSString stringWithFormat:STREAMINFOQUERY, liveNo];
		BOOL success = [self parseProgramInfo:streamQuery];
		if (success == NO)
		{
#if __has_feature(objc_arc) == 0
			[self dealloc];
#endif
			return NULL;
		}
		programNumber = [liveNo copy];
		startTime = [date copy];
		localeDict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
		startTimeString = [[NSString alloc] initWithString:[startTime descriptionWithCalendarFormat:StartUserTimeFormat timeZone:NULL locale:localeDict]];
		center = [NSNotificationCenter defaultCenter];
		[self drawUserProgram];
		[self createMenuItem];
		elapseTimer = [NSTimer scheduledTimerWithTimeInterval:elapseCheckCycle target:self selector:@selector(updateElapse) userInfo:NULL repeats:YES];
		programStatusTimer = [NSTimer scheduledTimerWithTimeInterval:checkActivityCycle target:self selector:@selector(checkBroadcasting) userInfo:NULL repeats:YES];
		isBroadCasting = YES;
		lastMintue = 0;
		[elapseTimer fire];
		[programStatusTimer fire];
	}// end if
	return self;
}// end - (id) initWithProgram:(NSString *)liveNo forAccount:(NLAccount *)account
- (id) initWithProgram:(NSString *)liveNo withDate:(NSDate *)date
{
	self = [super init];
	if (self)
	{		// initialize member variables
		dataString = NULL;
			//		programDataBuffer = NULL;
		programMenu = NULL;
		menuImage = NULL;
		programNumber = NULL;
		programTitle = NULL;
		programDescription = NULL;
		communityName = NULL;
		primaryAccount = [[NSString alloc] initWithString:OfficialTitleString];
		programURL = NULL;
		programStatusTimer = NULL;
		isOfficial = YES;
		isBroadCasting = NO;
		
		NSString *streamQuery = [NSString stringWithFormat:STREMEMBEDQUERY, liveNo];
		BOOL success = [self parseProgramInfo:streamQuery];
		if (success == NO)
		{
#if __has_feature(objc_arc) == 0
			[self dealloc];
#endif
			return NULL;
		}
		programNumber = [liveNo copy];
		startTime = [date copy];
		localeDict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
		startTimeString = [[NSString alloc] initWithString:[startTime descriptionWithCalendarFormat:StartOfficialTimeFormat timeZone:NULL locale:localeDict]];
		center = [NSNotificationCenter defaultCenter];
		[self drawOfficialProgram];
		[self createMenuItem];
		elapseTimer = [NSTimer scheduledTimerWithTimeInterval:elapseCheckCycle target:self selector:@selector(updateElapse) userInfo:NULL repeats:YES];
		programStatusTimer = [NSTimer scheduledTimerWithTimeInterval:checkActivityCycle target:self selector:@selector(checkBroadcasting) userInfo:NULL repeats:YES];
		isBroadCasting = YES;
		lastMintue = 0;
		[elapseTimer fire];
		[programStatusTimer fire];
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
	if (thumnbail != NULL)			[thumnbail release];
	if (stringAttributes != NULL)	[stringAttributes release];
	if (programNumber != NULL)		[programNumber release];
	if (programTitle != NULL)		[programTitle release];
	if (programDescription != NULL)	[programDescription release];
	if (communityName != NULL)		[communityName release];
	if (primaryAccount != NULL)		[primaryAccount release];
	if (startTime != NULL)			[startTime release];
	if (startTimeString != NULL)	[startTimeString release];
	if (programURL != NULL)			[programURL release];

	[super dealloc];
#endif
}// end - (void) dealloc

#pragma mark -
#pragma mark construction support

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

- (BOOL) parseProgramInfo:(NSString *)urlString
{
	BOOL success = NO;
	elementDict = [self elementDict];
	NSURL *queryURL = [NSURL URLWithString:urlString];
		//	NSURLResponse *resp = NULL;
		//	NSData *response = [HTTPConnection HTTPData:queryURL response:&resp];
	NSData *response = [[NSData alloc] initWithContentsOfURL:queryURL];
	NSXMLParser *parser = NULL;
#if __has_feature(objc_arc)
	@autoreleasepool {
#else
	NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
#endif
	if (isOfficial)
	{
		NSString *embed = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
		OnigRegexp *titleRegex = [OnigRegexp compile:ProgramTitleRegex];
		OnigResult *result = [titleRegex search:embed];
		if (result == NULL)
			success = NO;
		programTitle = [[NSString alloc] initWithString:[result stringAt:1]];

		OnigRegexp *imgRegex = [OnigRegexp compile:ThumbImageRegex];
		result = [imgRegex search:embed];
		if (result == NULL)
			success = NO;
		thumnbail = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[result stringAt:1]]];
		[thumnbail setSize:NSMakeSize(thumbnailSize, thumbnailSize)];
		
		OnigRegexp *programRegex = [OnigRegexp compile:ProgramURLRegex];
		result = [programRegex search:embed];
		if (result == NULL)
			success = NO;
		programURL = [[NSURL alloc] initWithString:[result stringAt:1]];
#if __has_feature(objc_arc) == 0
		[embed release];
#endif
		success = YES;
	}
	else
	{
		parser = [[NSXMLParser alloc] initWithData:response];
		[parser setDelegate:self];
		@try {
			success = [parser parse];
		}
		@catch (NSException *exception) {
			success = NO;
		}// end exception handling
	}
	
#if __has_feature(objc_arc) == 0
	[parser release];
	[arp release];
#else
	}
#endif
	return success;
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
	[thumnbail drawAtPoint:NSMakePoint(originX, originY) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fract];
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
	[thumnbail drawAtPoint:NSMakePoint(originX, originY) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fract];
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
- (void) updateElapse
{
	NSUInteger now = (NSUInteger)-[startTime timeIntervalSinceNow];
	NSUInteger elapsedMinute = (now / 60) % 60;	
	if (elapsedMinute == lastMintue)
		return;

	NSUInteger elapsedHour = now / (60 *60);
	NSString *elapesdTime = [NSString stringWithFormat:ElapsedTimeFormat, elapsedHour, elapsedMinute];
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

- (void) checkBroadcasting
{
	NSString *urlStr = [NSString stringWithFormat:STREMEMBEDQUERY, programNumber];
	NSURL *url = [NSURL URLWithString:urlStr];
	NSError *err;
	NSString *embed = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
	OnigRegexp *liveAlive = [OnigRegexp compile:OnAirRegex];
	OnigResult *result = [liveAlive search:embed];
	if (result == NULL)
	{
		isBroadCasting = NO;
		[elapseTimer invalidate];			elapseTimer = NULL;
		[programStatusTimer invalidate];	programStatusTimer = NULL;
		[center postNotification:[NSNotification notificationWithName:NLNotificationPorgramEnd object:NULL]];
	}
}// end - (void) checkBroadcasting

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
			@throw [NSException exceptionWithName:RESULTERRORNAME reason:RESULTERRORREASON userInfo:NULL];
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
	switch (currentElement) {
		case indexRequestID:
			programURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:PROGRAMURLFORMAT, dataString]];
			break;
		case indexDescription:
			programDescription = [[NSString alloc] initWithString:dataString];
			break;
		case indexTitle:
			programTitle = [[NSString alloc] initWithString:dataString];
			break;
		case indexComuName:
			if (communityName == NULL)
				communityName = [[NSString alloc] initWithString:dataString];
			break;
		case indexThumbnail:
			thumnbail = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:dataString]];
			[thumnbail setSize:NSMakeSize(thumbnailSize, thumbnailSize)];
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
