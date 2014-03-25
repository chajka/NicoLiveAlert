//
//  NLStatusbar.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/25/14.
//  Copyright (c) 2014 Instrumentality of mankind. All rights reserved.
//

#import "NLStatusbar.h"

@interface NLStatusbar ()
- (void) installStatusBarMenu:(NSMenu *)menu iconName:(NSString *)iconName;
@end

@implementation NLStatusbar
#pragma mark - synthesize properties
#pragma mark - class method
#pragma mark - constructor / destructor
- (id) initWithMenu:(NSMenu *)menu andIconName:(NSString *)iconName
{
	self = [super init];
	if (self) {
		[self installStatusBarMenu:menu iconName:iconName];
	}// end if self

	return self;
}// end - (id) initWithMenu:(NSMenu *)menu iconName:(NSString *)iconName
#pragma mark - override
#pragma mark - delegate
#pragma mark - instance method
#pragma mark constructor
#pragma mark - properties
#pragma mark - messages
#pragma mark - private
- (void) installStatusBarMenu:(NSMenu *)menu iconName:(NSString *)iconName
{
	systemStatusBar = [NSStatusBar systemStatusBar];
	statusMenuItem = [systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
	[statusMenuItem setHighlightMode:YES];
	[statusMenuItem setImage:[NSImage imageNamed:iconName]];
	[statusMenuItem setMenu:menu];
}// end - (void) installStatusBarMenu
#pragma mark - C functions
@end
