//
//  NicoLiveAlert.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/25/14.
//  Copyright (c) 2014 Instrumentality of mankind. All rights reserved.
//

#import "NicoLiveAlert.h"
#import "MASPreferencesWindowController.h"
#import "NLAGeneralPreferenceViewController.h"
#import "NLAWatchlistPreferenceViewController.h"
#import "NLANotiryPreferenceViewController.h"
#import "NLAAccountPreferenceViewController.h"

@interface NicoLiveAlert ()

#ifdef __cplusplus
extern "C" {
#endif
static void uncaughtExceptionHandler(NSException *exception);
#ifdef __cplusplus
} //end extern "C"
#endif

@end

static NSString *StatusBarIconName = @"sbicon";

@implementation NicoLiveAlert
#pragma mark - synthesize properties
#pragma mark - class method
#pragma mark - constructor / destructor
#pragma mark - override
- (void) awakeFromNib
{
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
}// end - (void) awakeFromNib

#pragma mark - delegate
- (void) applicationWillFinishLaunching:(NSNotification *)notification
{
}// end - (void) applicationWillFinishLaunching:(NSNotification *)notification

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
	statusBar = [[NLStatusbar alloc] initWithMenu:statusBarMenu andIconName:StatusBarIconName];
}// end - (void) applicationDidFinishLaunching:(NSNotification *)aNotification

- (void) applicationWillTerminate:(NSNotification *)notification
{
	
}// end - (void) applicationWillFinishLaunching:(NSNotification *)notification

#pragma mark - actions
- (IBAction) openPreferences:(id)sender
{
	@autoreleasepool {
		if (preferenceWindowController == nil) {
			preferenceWindowController = [self buildPreferencePanel];
			[(MASPreferencesWindowController *)preferenceWindowController selectControllerAtIndex:0];
		}// end if not build preference window yet.

		[preferenceWindowController showWindow:nil];
	}// end autorelease pool block
}// end - (IBAction) openPreferences:(id)sender

#pragma mark - instance method
#pragma mark - properties
#pragma mark - messages
#pragma mark - private
- (NSWindowController *) buildPreferencePanel
{
	NLAGeneralPreferenceViewController *general = [[NLAGeneralPreferenceViewController alloc] init];
	NLAWatchlistPreferenceViewController *watchlist = [[NLAWatchlistPreferenceViewController alloc] init];
	NLANotiryPreferenceViewController *notify = [[NLANotiryPreferenceViewController alloc] init];
	NLAAccountPreferenceViewController *accounts = [[NLAAccountPreferenceViewController alloc] init];
	NSArray *preferencePanels = [NSArray arrayWithObjects:general, watchlist, notify, accounts, nil];

	NSWindowController *preferences = [[MASPreferencesWindowController alloc] initWithViewControllers:preferencePanels title:@"Preferences"];

	return preferences;
}// end - (void) setupPreferencePanel

#pragma mark - C functions
static
void uncaughtExceptionHandler(NSException *exception)
{
    NSLog(@"Exception Name %@, Reason %@", exception.name, exception.reason);
	NSLog(@"Exception Description %@", exception.description);
    NSLog(@"Exception Call Stack Symbols %@", exception.callStackSymbols);
}// end void uncaughtExceptionHandler(NSException *exception)

@end
