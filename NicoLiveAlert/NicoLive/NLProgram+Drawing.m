//
//  NLProgram+Drawing.m
//  NicoLiveAlert
//
//  Created by Чайка on 7/16/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLProgram+Drawing.h"
#import "Growl/Growl.h"

static const CGFloat originX = 0.0;
static const CGFloat originY = 0.0;
static const CGFloat exteriorLineWidth = 1.0;
static const CGFloat titleKernValue = 0.0;
static const CGFloat kernValue = 0.0;
static const CGFloat titleComuKernValue = 0.0;
static const CGFloat timeStringWidth = 110.0;
static const CGFloat timeStringHeight = 14.0;
static const CGFloat elapesedStringWidth = 39;
static const CGFloat elapesedStringHeight = timeStringHeight;

#pragma mark user program constant
static const CGFloat accountOffsetX = 52.0;
static const CGFloat accountOffsetY = 0.0;
static const CGFloat accountWitdth = 120.0;
static const CGFloat accountHeight = 18.0;
static const CGFloat communityOffsetX = 52.0;
static const CGFloat communityOffsetY = 12.0;
static const CGFloat progTitleOffsetX = 0.0;
static const CGFloat progTitleOffsetY = programBoundsH - 13;
static const CGFloat progDescOffsetX = 52.0;
static const CGFloat progDescOffsetY = 24.0;
static const CGFloat progDescWidth = (programBoundsW - thumbnailSize);
static const CGFloat progDescHeight = 28.0;
static const CGFloat userTimeOffsetX = (programBoundsW - timeStringWidth);
static const CGFloat userTimeOffsetY = 0.0;
static const CGFloat userElapsedOffsetX = (programBoundsW - elapesedStringWidth);

#pragma mark official program constant
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


@implementation NLProgram (Drawing)

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
						[NSNumber numberWithInteger:1], NSLigatureAttributeName,
						[NSNumber numberWithFloat:titleKernValue], NSKernAttributeName, nil];
	
	menuImage = [[NSImage alloc] initWithSize:NSMakeSize(programBoundsW, programBoundsH)];
	
	[menuImage lockFocus];
	[[NSColor whiteColor] set];
	[background fill];
/*
		// draw thumbnail
	if (iconIsValid == YES)
		[thumbnail drawAtPoint:NSMakePoint(originX, originY) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fract];
*/
		// draw program title
	[stringAttributes setValue:titleColor forKey:NSForegroundColorAttributeName];
	[programTitle drawAtPoint:NSMakePoint(progTitleOffsetX, progTitleOffsetY) withAttributes:stringAttributes];
	[menuImage unlockFocus];
		// draw program owner nickname
	[stringAttributes setValue:nickColor forKey:NSForegroundColorAttributeName];
	[stringAttributes setValue:[NSNumber numberWithFloat:kernValue] forKey:NSKernAttributeName];
	[stringAttributes setValue:[NSFont fontWithName:fontNameOfProgramOwner size:10] forKey:NSFontAttributeName];
	NSSize ownerNameSize = [broadcastOwnerName sizeWithAttributes:stringAttributes];
	ownerName = [[NSImage alloc] init];
	[ownerName setSize:NSMakeSize(ownerNameSize.width + 5, ownerNameSize.height)];
	[ownerName lockFocus];
	[broadcastOwnerName drawAtPoint:NSMakePoint(Zero, Zero) withAttributes:stringAttributes];
	[ownerName unlockFocus];
		// draw program description
	[menuImage lockFocus];
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
						[NSNumber numberWithInteger:1], NSLigatureAttributeName,
						[NSNumber numberWithFloat:-0.5], NSKernAttributeName, nil];
	
	menuImage = [[NSImage alloc] initWithSize:NSMakeSize(officialBoundsW, officialBoundsH)];
	
	[menuImage lockFocus];
	[[NSColor whiteColor] set];
	[background fill];
/*
		// draw thumbnail
	if (iconIsValid == YES)
		[thumbnail drawAtPoint:NSMakePoint(originX, originY) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fract];
*/
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
/*
			 if ((iconWasValid == NO) && (iconIsValid == YES))
			 {
			 [thumbnail drawAtPoint:NSMakePoint(originX, originY) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fract];
			 iconWasValid = YES;
			 }// end if redraw icon
*/
			[menuImage lockFocus];
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
/*
			if ((iconWasValid == NO) && (iconIsValid == YES))
			{
				[thumbnail drawAtPoint:NSMakePoint(originX, originY) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fract];
				iconWasValid = YES;
			}// end if redraw icon
*/
			[menuImage lockFocus];
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
/*
		 if ((iconWasValid == NO) && (iconIsValid == YES))
		 {
		 [thumbnail drawAtPoint:NSMakePoint(originX, originY) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fract];
		 iconWasValid = YES;
		 }// end if redraw icon
*/
		[menuImage lockFocus];
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

@end
