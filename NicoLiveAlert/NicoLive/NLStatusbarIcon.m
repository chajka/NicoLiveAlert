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
static CGFloat iconHeight = 20.0;
static CGFloat noProgWidth = 20.0;	
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
		numberOfPrograms = 0;
		statusbarMenu = menu;
		drawPoint = NSMakePoint(progCountPointSingleDigitX, progCountPointY);
		iconSize = NSMakeSize(noProgWidth, iconHeight);
		sourceImage = [self createFromResource:imageName];
		statusbarIcon = [[NSImage alloc] initWithSize:iconSize];
		statusbarAlt = [[NSImage alloc] initWithSize:iconSize];
		gammaFilter = [CIFilter filterWithName:@"CIGammaAdjust"];
		gammaPower = [NSNumber numberWithFloat:noProgPower];
		invertFilter = [CIFilter filterWithName:@"CIColorInvert"];
		progCountFont = [NSFont fontWithName:@"CourierNewPS-BoldItalicMT" size:progCountFontSize];
		fontAttrDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, progCountFont,NSFontAttributeName, nil];
		fontAttrInvertDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSColor blackColor], NSForegroundColorAttributeName, progCountFont ,NSFontAttributeName, nil];
		progCountBackground = [NSBezierPath bezierPath];
		[progCountBackground setLineCapStyle:NSRoundLineCapStyle];
		[progCountBackground setLineWidth:progCountBackGroundWidth];
		[progCountBackground moveToPoint:NSMakePoint(progCountBackGrountFromX, progCountBackGrountFromY)];
		[progCountBackground lineToPoint:NSMakePoint(progCountBackGrountToX, progCountBackGrountToY)];
		
		progCountBackColor = [NSColor colorWithCalibratedRed:progCountBackColorRed green:progCountBackColorGreen blue:progCountBackColorBlue alpha:progCountBackColorAlpha];
#if __has_feature(objc_arc) == 0
		[sourceImage retain];
		[gammaFilter retain];
		[invertFilter retain];
		[progCountBackground retain];
		[progCountBackColor retain];
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
	NSArray *sbreps = [statusbarIcon representations];
	NSArray *altreps = [statusbarAlt representations];
	for (NSImageRep *aRep in sbreps)
		[statusbarIcon removeRepresentation:aRep];
	for (NSImageRep *aRep in altreps)
		[statusbarAlt removeRepresentation:aRep];

		// draw program count on image
	NSString *progCountStr = [NSString stringWithFormat:@"%d", numberOfPrograms];
	if (numberOfPrograms > 99)
	{
		[progCountBackground removeAllPoints];
		[progCountBackground moveToPoint:NSMakePoint(progCountBackGrountFromX, progCountBackGrountFromY)];
		[progCountBackground lineToPoint:NSMakePoint(progCountBackGrountToX + (progCountBackDigitOffset * 2), progCountBackGrountToY)];
		[statusbarIcon setSize:NSMakeSize(haveProgWidth + (progCountBackDigitOffset * 2), iconHeight)];
		[statusbarAlt setSize:NSMakeSize(haveProgWidth + (progCountBackDigitOffset * 2), iconHeight)];
	}
	else if (numberOfPrograms > 9)
	{
		[progCountBackground moveToPoint:NSMakePoint(progCountBackGrountFromX, progCountBackGrountFromY)];
		[progCountBackground lineToPoint:NSMakePoint(progCountBackGrountToX + progCountBackDigitOffset, progCountBackGrountToY)];
		[statusbarIcon setSize:NSMakeSize(haveProgWidth + progCountBackDigitOffset, iconHeight)];
		[statusbarAlt setSize:NSMakeSize(haveProgWidth + progCountBackDigitOffset, iconHeight)];
	}
	else if (numberOfPrograms > 0)
	{
		[progCountBackground moveToPoint:NSMakePoint(progCountBackGrountFromX, progCountBackGrountFromY)];
		[progCountBackground lineToPoint:NSMakePoint(progCountBackGrountToX, progCountBackGrountToY)];
		[statusbarIcon setSize:NSMakeSize(haveProgWidth, iconHeight)];
		[statusbarAlt setSize:NSMakeSize(haveProgWidth, iconHeight)];
	}
	else
	{
		[statusbarIcon setSize:NSMakeSize(noProgWidth, iconHeight)];
		[statusbarAlt setSize:NSMakeSize(noProgWidth, iconHeight)];
	}// end if adjust icon withd by program count.

		// draw for image.
	[statusbarIcon lockFocus];
	[sb drawAtPoint:NSMakePoint(origin, origin)];
	[progCountBackColor set];
	[progCountBackground stroke];
	[progCountStr drawAtPoint:drawPoint withAttributes:fontAttrDict];
	[statusbarIcon unlockFocus];

		// draw for alt image.
	[statusbarAlt lockFocus];
	[alt drawAtPoint:NSMakePoint(origin, origin)];
	[[NSColor whiteColor] set];
	[progCountBackground stroke];
	[progCountStr drawAtPoint:drawPoint withAttributes:fontAttrInvertDict];
	[statusbarAlt unlockFocus];
	
		// update status bar icon.
	[statusBarItem setImage:statusbarIcon];
    [statusBarItem setAlternateImage:statusbarAlt];

#if __has_feature(objc_arc) == 0
	if (numberOfPrograms != 0)
		[destImage release];
#endif
}// end - (CIImage *) makeStatusbarIcon

#pragma mark accessor
- (void) incleaseProgCount
{
	numberOfPrograms++;
	[self makeStatusbarIcon];
}// end - (BOOL) incleaseProgCount

- (void) decleaseProgCount
{
	if (numberOfPrograms > 0)
		numberOfPrograms--;
	[self makeStatusbarIcon];
}// end - (BOOL) decleaseProgCount

@end
