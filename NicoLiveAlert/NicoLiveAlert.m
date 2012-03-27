//
//  NicoLiveAlert.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NicoLiveAlert.h"
#import "NicoLiveAlertDefinitions.h"

@implementation NicoLiveAlert
@synthesize prefencePanel;
@synthesize menuStatusbar;

- (void) awakeFromNib
{
	statusBar = [[NLStatusbarIcon alloc] initWithMenu:menuStatusbar andImageName:@"sbicon"];
#if __has_feature(objc_arc) == 0
	[statusBar retain];
#endif
}// end - (void) awakeFromNib

NSTimer *timer;
- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
    timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(timerFireMethod) userInfo:nil repeats:YES];
    [timer fire];
	// Insert code here to initialize your application
	if (![self checkFirstLaunch])
		NSLog(@"Not found Prefernce");
	else
		NSLog(@"Found preference");
}

- (void) timerFireMethod
{
	[statusBar incleaseProgCount];
}

- (void) applicationWillTerminate:(NSNotification *)notification
{
#if __has_feature(objc_arc) == 0
	[statusBar release];
#endif
	[timer invalidate];
}

- (BOOL) checkFirstLaunch
{
	NSBundle *mb = [NSBundle mainBundle];
	NSDictionary *infoDict = [mb infoDictionary];
	NSString *prefPath = [NSString stringWithFormat:PARTIALPATHFORMAT, [infoDict objectForKey:KEYBUNDLEIDENTIFY]];
	NSString *fullPath = [prefPath stringByExpandingTildeInPath];

	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL isThere = [fm fileExistsAtPath:fullPath];
	
	return isThere;
}// end - (BOOL) checkFirstLaunch

@end
