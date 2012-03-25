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
static CGFloat haveProgWidth = 50.0;
static CGFloat noProgPower = 0.3;
static CGFloat progCountFontSize = 11;
static CGFloat progCountPointY = 1.5;
static CGFloat progCountPointSingleDigitX = 31.0;
static CGFloat progCountPointDoubleDigitX = 28.0;
static CGFloat progCountPointTripleDigitX = 20.0;

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
		noProgSize = NSMakeSize(noProgWidth, iconHeight);
		haveProgSize = NSMakeSize(haveProgWidth, iconHeight);
		sourceImage = [self createFromResource:imageName];
		destImage = NULL;
		statusbarIcon = [[NSImage alloc] initWithSize:noProgSize];
		statusbarAlt = [[NSImage alloc] initWithSize:noProgSize];
		gammaFilter = [CIFilter filterWithName:@"CIGammaAdjust"];
		gammaPower = [NSNumber numberWithFloat:noProgPower];
		cropFilter = [CIFilter filterWithName:@"CICrop"];
		noProgVect = [CIVector vectorWithX:origin Y:origin Z:noProgWidth W:iconHeight];
		haveProgVect = [CIVector vectorWithX:origin Y:origin Z:haveProgWidth W:iconHeight];
		invertFilter = [CIFilter filterWithName:@"CIColorInvert"];
		progCountFont = [NSFont fontWithName:@"CourierNewPS-BoldItalicMT" size:progCountFontSize];
		fontAttrDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, progCountFont,NSFontAttributeName, nil];
		fontAttrInvertDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSColor blackColor], NSForegroundColorAttributeName, progCountFont ,NSFontAttributeName, nil];
#if __has_feature(objc_arc) == 0
		[sourceImage retain];
		[gammaFilter retain];
		[cropFilter retain];
		[invertFilter retain];
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
	[destImage release];
	[statusbarIcon release];
	[statusbarAlt release];
	[gammaFilter release];
	[cropFilter release];
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
	//#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
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
	[cropFilter setValue:sourceImage forKey:@"inputImage"];
	if (numberOfPrograms == 0)
	{		// crop image
		[statusbarIcon setSize:noProgSize];
		[statusbarAlt setSize:noProgSize];
		[cropFilter setValue:noProgVect forKey:@"inputRectangle"];
		destImage = [cropFilter valueForKey:@"outputImage"];
			// gamma adjust image
		[gammaFilter setValue:destImage forKey:@"inputImage"];
		[gammaFilter setValue:gammaPower forKey:@"inputPower"];
		destImage = [gammaFilter valueForKey:@"outputImage"];
	}
	else
	{
		[statusbarIcon setSize:haveProgSize];
		[statusbarAlt setSize:haveProgSize];
		destImage = [sourceImage copy];
	}// end if number of programs

	[invertFilter setValue:destImage forKey:@"inputImage"];
	invertImage = [invertFilter valueForKey:@"outputImage"];

	NSCIImageRep *sb = [NSCIImageRep imageRepWithCIImage:destImage];
	NSCIImageRep *alt = [NSCIImageRep imageRepWithCIImage:invertImage];
	NSArray *sbreps = [statusbarIcon representations];
	NSArray *altreps = [statusbarAlt representations];
	[statusbarIcon addRepresentation:sb];
	for (NSImageRep *aRep in sbreps)
		[statusbarIcon removeRepresentation:aRep];
	[statusbarAlt addRepresentation:alt];
	for (NSImageRep *aRep in altreps)
		[statusbarAlt removeRepresentation:aRep];

		// draw program count on image
	if (numberOfPrograms > 0)
	{
		NSString *progCountStr = [NSString stringWithFormat:@"%d", numberOfPrograms];
		NSPoint drawPoint;
		if (numberOfPrograms > 99)
			drawPoint = NSMakePoint(progCountPointTripleDigitX, progCountPointY);
		else if (numberOfPrograms > 9)
			drawPoint = NSMakePoint(progCountPointDoubleDigitX, progCountPointY);
		else 
			drawPoint = NSMakePoint(progCountPointSingleDigitX, progCountPointY);
		// draw for image
		[statusbarIcon lockFocus];
		[progCountStr drawAtPoint:drawPoint withAttributes:fontAttrDict];
		[statusbarIcon unlockFocus];
		// draw for alt image
		[statusbarAlt lockFocus];
		[progCountStr drawAtPoint:drawPoint withAttributes:fontAttrInvertDict];
		[statusbarAlt unlockFocus];
	}// end if program count is not zero
	
	[statusBarItem setImage:statusbarIcon];
    [statusBarItem setAlternateImage:statusbarAlt];
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
