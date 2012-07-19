//
//  NLClickableImageView.m
//  NicoLiveAlert
//
//  Created by Чайка on 7/19/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLClickableImageView.h"

@implementation NLClickableImageView
@synthesize target;
@synthesize representedObject;

- (id) initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        target = nil;
		representedObject = nil;
		selector = nil;
    }// end if
    
    return self;
}// end - (id) initWithFrame:(NSRect)frame

- (void) dealloc
{
#if __has_feature(objc_arc) == 0
	if (target != nil)				[target release];
	if (representedObject != nil)	[representedObject release];

	[super dealloc];
#endif
}// end - (void) dealloc

- (void) drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}// end - (void) drawRect:(NSRect)dirtyRect

- (void) setAction:(SEL)aSelector toTarget:(id)object
{
	selector = aSelector;
	[self setTarget:object];
}// end - (void) setAction:(SEL)aSelector toTarget:(id)object

- (BOOL) acceptsFirstMouse:(NSEvent *)theEvent
{
	if ((selector == nil) || (target == nil))
		return NO;

	BOOL result = [self sendAction:selector to:target];

	return result;
}// end - (BOOL) acceptsFirstMouse:(NSEvent *)theEvent
@end
