//
//  NicoLiveAlert.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/25/14.
//  Copyright (c) 2014 Instrumentality of mankind. All rights reserved.
//

#import "NicoLiveAlert.h"

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
	firstTimePreference = YES;
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
	
}// end - (IBAction) openPreferences:(id)sender

#pragma mark - instance method
#pragma mark - properties
#pragma mark - messages
#pragma mark - private
- (void) setupPreferencePanel
{
	@autoreleasepool {
		if (firstTimePreference) {
			firstTimePreference = NO;
		}// end if first time open preference window
		
	}// end autorelease pool
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
