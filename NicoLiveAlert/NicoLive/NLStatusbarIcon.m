//
//  NLStatusbarIcon.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/24/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLStatusbarIcon.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat origin = 0.0;
static CGFloat iconSizeH = 20.0;
static CGFloat iconSizeW = 20.0;
static CGFloat noProgWidth = 20.0;
static CGFloat disconnectPathWidth = 3.0;
static CGFloat disconnectPathOffset = 5.0;
static CGFloat haveProgWidth = 41.0;
static CGFloat noProgPower = 0.3;
static CGFloat progCountFontSize = 11;
static CGFloat progCountPointY = 1.5;
static CGFloat progCountPointSingleDigitX = 27.0;
static CGFloat progCountBackGroundWidth = 14.8;
static CGFloat progCountBackGrountFromX = 28.0;
static CGFloat progCountBackGrountFromY = 8.5;
static CGFloat progCountBackGrountToX = 34.0;
static CGFloat progCountBackGrountToY = 8.5;
static CGFloat progCountBackDigitOffset = 6.5;
static CGFloat progCountBackColorRed = 000.0/256.0;
static CGFloat progCountBackColorGreen = 153.0/256.0;
static CGFloat progCountBackColorBlue = 051.0/256.0;
static CGFloat progCountBackColorAlpha = 1.00;
static CGFloat disconnectedColorRed = 256.0/256.0;
static CGFloat disconnectedColorGreen = 000.0/256.0;
static CGFloat disconnectedColorBlue = 000.0/256.0;
static CGFloat disconnectedColorAlpha = 0.70;

#pragma mark internal constant

@interface NLStatusbarIcon ()
#pragma mark constructor support
- (CIImage *) createFromResource:(NSString *)imageName;
- (void) installStatusbarMenu;
- (void) makeStatusbarIcon;
@end

@implementation NLStatusbarIcon
@synthesize numberOfPrograms;

#pragma mark construct / destruct
- (id) initWithMenu:(NSMenu *)menu andImageName:(NSString *)imageName
{
	self = [super init];
	if (self)
	{
		connected = NO;
		numberOfPrograms = 0;
		statusbarMenu = menu;
		drawPoint = NSMakePoint(progCountPointSingleDigitX, progCountPointY);
		iconSize = NSMakeSize(iconSizeW, iconSizeH);
		sourceImage = [self createFromResource:imageName];
		statusbarIcon = [[NSImage alloc] initWithSize:iconSize];
		statusbarAlt = [[NSImage alloc] initWithSize:iconSize];
		gammaFilter = [CIFilter filterWithName:@"CIGammaAdjust"];
		gammaPower = [NSNumber numberWithFloat:noProgPower];
		invertFilter = [CIFilter filterWithName:@"CIColorInvert"];
		progCountFont = [NSFont fontWithName:@"CourierNewPS-BoldItalicMT" size:progCountFontSize];
		fontAttrDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, progCountFont,NSFontAttributeName, nil];
		fontAttrInvertDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSColor blackColor], NSForegroundColorAttributeName, progCountFont ,NSFontAttributeName, nil];
			// create bezier path for program number's background
		progCountBackground = [NSBezierPath bezierPath];
		[progCountBackground setLineCapStyle:NSRoundLineCapStyle];
		[progCountBackground setLineWidth:progCountBackGroundWidth];
		[progCountBackground moveToPoint:NSMakePoint(progCountBackGrountFromX, progCountBackGrountFromY)];
		[progCountBackground lineToPoint:NSMakePoint(progCountBackGrountToX, progCountBackGrountToY)];

			// create bezier path for dissconect cross mark
		disconnectPath = [NSBezierPath bezierPath];
		[disconnectPath setLineCapStyle:NSRoundLineCapStyle];
		[disconnectPath setLineWidth:disconnectPathWidth];
		[disconnectPath moveToPoint:NSMakePoint(disconnectPathOffset, disconnectPathOffset)];
		[disconnectPath lineToPoint:NSMakePoint((iconSizeW - disconnectPathOffset), (iconSizeH - disconnectPathOffset))];
		[disconnectPath moveToPoint:NSMakePoint(disconnectPathOffset, (iconSizeH - disconnectPathOffset))];
		[disconnectPath lineToPoint:NSMakePoint(iconSizeH - disconnectPathOffset, disconnectPathOffset)];

			// make each color for background and disconnect cross
		progCountBackColor = [NSColor colorWithCalibratedRed:progCountBackColorRed green:progCountBackColorGreen blue:progCountBackColorBlue alpha:progCountBackColorAlpha];
		disconnectColor = [NSColor colorWithCalibratedRed:disconnectedColorRed green:disconnectedColorGreen blue:disconnectedColorBlue alpha:disconnectedColorAlpha];
		
#if __has_feature(objc_arc) == 0
		[sourceImage retain];
		[gammaFilter retain];
		[invertFilter retain];
		[progCountBackground retain];
		[progCountBackColor retain];
		[disconnectPath retain];
		[disconnectColor retain];
#endif
		[self installStatusbarMenu];
		[self makeStatusbarIcon];
	}// end if
	return self;
}// end - (id) initWithImage:(NSString *)imageName

- (void) dealloc
{
	[statusBar removeStatusItem:statusBarItem];
#if __has_feature(objc_arc) == 0
	[statusBarItem release];
    [sourceImage release];
	[statusbarIcon release];
	[statusbarAlt release];
	[gammaFilter release];
	[noProgVect release];
	[haveProgVect release];
	[invertFilter release];
	[fontAttrDict release];
	[fontAttrInvertDict release];
	[disconnectPath release];
	[disconnectColor release];
    [super dealloc];
#endif
}// end - (void) dealloc

#pragma mark constructor support
- (CIImage *) createFromResource:(NSString *)imageName
{
	NSImage *image = [NSImage imageNamed:imageName];
	NSData *imageData = [image TIFFRepresentation];

	return [CIImage imageWithData:imageData];
}// end - (CIImage *) createFromResource:(NSString *)imageName

- (void) installStatusbarMenu
{
	statusBar = [NSStatusBar systemStatusBar];
	statusBarItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
#if __has_feature(objc_arc) == 0
	[statusBarItem retain];
	[statusBar retain];
#endif
	[statusBarItem setTitle:@""];
	[statusBarItem setImage:statusbarIcon];
    [statusBarItem setAlternateImage:statusbarAlt];
	[statusBarItem setToolTip:@"NicoLiveAlert"];
	[statusBarItem setHighlightMode:YES];
    // localize
    [[statusbarMenu itemWithTag:tagAutoOpen] setTitle:TITLEAUTOOPEN];
    [[statusbarMenu itemWithTag:tagPorgrams] setTitle:TITLEPROGRAMS];
    [[statusbarMenu itemWithTag:tagAccounts] setTitle:TITLEACCOUNTS];
    [[statusbarMenu	itemWithTag:tagLaunchApplications] setTitle:TITLELAUNCHER];
    [[statusbarMenu itemWithTag:tagPreference] setTitle:TITLEPREFERENCE];
    [[statusbarMenu itemWithTag:tagAbout] setTitle:TITLEABOUT];
    [[statusbarMenu itemWithTag:tagQuit] setTitle:TITLEQUIT];
    
	[statusBarItem setMenu:statusbarMenu];
}// end - (void) installStatusbarMenu

#pragma mark -
- (void) makeStatusbarIcon
{
	CIImage *invertImage = NULL;
	CIImage *destImage = NULL;
	if (numberOfPrograms == 0)
	{		// crop image
		[statusbarIcon setSize:iconSize];
		[statusbarAlt setSize:iconSize];
			// gamma adjust image
		[gammaFilter setValue:sourceImage forKey:@"inputImage"];
		[gammaFilter setValue:gammaPower forKey:@"inputPower"];
		destImage = [gammaFilter valueForKey:@"outputImage"];
	}
	else
	{
		destImage = [sourceImage copy];
	}// end if number of programs

	[invertFilter setValue:destImage forKey:@"inputImage"];
	invertImage = [invertFilter valueForKey:@"outputImage"];

	NSCIImageRep *sb = [NSCIImageRep imageRepWithCIImage:destImage];
	NSCIImageRep *alt = [NSCIImageRep imageRepWithCIImage:invertImage];

		// draw program count on image
	NSString *progCountStr = [NSString stringWithFormat:@"%d", numberOfPrograms];
	if (numberOfPrograms > 99)
	{
		[progCountBackground removeAllPoints];
		[progCountBackground removeAllPoints];
		[progCountBackground moveToPoint:NSMakePoint(progCountBackGrountFromX, progCountBackGrountFromY)];
		[progCountBackground lineToPoint:NSMakePoint(progCountBackGrountToX + (progCountBackDigitOffset * 2), progCountBackGrountToY)];
		statusbarIcon = [[NSImage alloc] initWithSize:NSMakeSize(haveProgWidth + (progCountBackDigitOffset * 2), iconSizeW)];
		statusbarAlt = [[NSImage alloc] initWithSize:NSMakeSize(haveProgWidth + (progCountBackDigitOffset * 2), iconSizeW)];
	}
	else if (numberOfPrograms > 9)
	{
		[progCountBackground removeAllPoints];
		[progCountBackground moveToPoint:NSMakePoint(progCountBackGrountFromX, progCountBackGrountFromY)];
		[progCountBackground lineToPoint:NSMakePoint(progCountBackGrountToX + progCountBackDigitOffset, progCountBackGrountToY)];
		statusbarIcon = [[NSImage alloc] initWithSize:NSMakeSize(haveProgWidth + progCountBackDigitOffset, iconSizeW)];
		statusbarAlt = [[NSImage alloc] initWithSize:NSMakeSize(haveProgWidth + progCountBackDigitOffset, iconSizeW)];
	}
	else if (numberOfPrograms > 0)
	{
		[progCountBackground removeAllPoints];
		[progCountBackground moveToPoint:NSMakePoint(progCountBackGrountFromX, progCountBackGrountFromY)];
		[progCountBackground lineToPoint:NSMakePoint(progCountBackGrountToX, progCountBackGrountToY)];
		statusbarIcon = [[NSImage alloc] initWithSize:NSMakeSize(haveProgWidth, iconSizeW)];
		statusbarAlt = [[NSImage alloc] initWithSize:NSMakeSize(haveProgWidth, iconSizeW)];
	}
	else
	{
		statusbarIcon = [[NSImage alloc] initWithSize:NSMakeSize(noProgWidth, iconSizeW)];
		statusbarAlt = [[NSImage alloc] initWithSize:NSMakeSize(noProgWidth, iconSizeW)];
	}// end if adjust icon withd by program count.

		// draw for image.
	[statusbarIcon lockFocus];
	[sb drawAtPoint:NSMakePoint(origin, origin)];
	// set connect/disconnect status
	if (connected == NO)
	{
		[disconnectColor set];
		[disconnectPath stroke];
	}// end if disconnected
	[progCountBackColor set];
	[progCountBackground stroke];
	[progCountStr drawAtPoint:drawPoint withAttributes:fontAttrDict];
	[statusbarIcon unlockFocus];

		// draw for alt image.
	[statusbarAlt lockFocus];
	[alt drawAtPoint:NSMakePoint(origin, origin)];
	[[NSColor whiteColor] set];
	if (connected == NO)
	{
		[disconnectPath stroke];
	}// end if disconnected
	[progCountBackground stroke];
	[progCountStr drawAtPoint:drawPoint withAttributes:fontAttrInvertDict];
	[statusbarAlt unlockFocus];
	
		// update status bar icon.
	[statusBarItem setImage:statusbarIcon];
    [statusBarItem setAlternateImage:statusbarAlt];

#if __has_feature(objc_arc) == 0
	[statusbarIcon release];
	[statusbarAlt release];
	if (numberOfPrograms != 0)
		[destImage release];
#endif
}// end - (CIImage *) makeStatusbarIcon

#pragma mark accessor
- (void) addUserMenu:(NSMenuItem *)item
{
	[[[statusbarMenu itemWithTag:tagPorgrams] submenu] addItem:item];
	[self incleaseProgCount];
}

- (void) addOfficialMenu:(NSMenuItem *)item
{
	[[[statusbarMenu itemWithTag:tagOfficial] submenu] addItem:item];
	[self incleaseProgCount];
}

- (void) incleaseProgCount
{
	numberOfPrograms++;
	connected = YES;
	[self makeStatusbarIcon];
}// end - (BOOL) incleaseProgCount

- (void) decleaseProgCount
{
	if (numberOfPrograms > 0)
		numberOfPrograms--;
	[self makeStatusbarIcon];
}// end - (BOOL) decleaseProgCount

#pragma mark accessor for connected
- (BOOL) connected
{
	return connected;
}// - (BOOL) connected

- (void) setConnected:(BOOL)connected_
{
	connected = connected_;
	[self makeStatusbarIcon];
}// - (void) setConnected:(BOOL)connected_

- (void) toggleConnected
{
	connected = !connected;
	[self makeStatusbarIcon];
}// end - (void) toggleConnected

@end
