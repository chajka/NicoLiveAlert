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
		// Insert code here to initialize your application
}// end - (void) applicationDidFinishLaunching:(NSNotification *)aNotification

- (void) applicationWillTerminate:(NSNotification *)notification
{
	
}// end - (void) applicationWillFinishLaunching:(NSNotification *)notification

#pragma mark - instance method
#pragma mark constructor
#pragma mark - properties
#pragma mark - messages
#pragma mark - private
#pragma mark - C functions
static
void uncaughtExceptionHandler(NSException *exception)
{
    NSLog(@"Exception Name %@, Reason %@", exception.name, exception.reason);
	NSLog(@"Exception Description %@", exception.description);
    NSLog(@"Exception Call Stack Symbols %@", exception.callStackSymbols);
}// end void uncaughtExceptionHandler(NSException *exception)

@end
