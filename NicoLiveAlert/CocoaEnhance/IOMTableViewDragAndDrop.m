//
//  IOMTableViewDragAndDrop.m
//  NicoLiveAlert
//
//  Created by Чайка on 4/25/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "IOMTableViewDragAndDrop.h"

@implementation IOMTableViewDragAndDrop
#pragma mark override
- (void)dragImage:(NSImage *)anImage at:(NSPoint)imageLoc offset:(NSSize)mouseOffset event:(NSEvent *)theEvent pasteboard:(NSPasteboard *)pboard source:(id)sourceObject slideBack:(BOOL)slideBack
{
		// store mouse cliced point
	startPoint = [[self window] convertBaseToScreen:[theEvent locationInWindow]];
		// call super with slideback effect off
	[super dragImage:anImage at:imageLoc offset:mouseOffset event:theEvent pasteboard:pboard source:sourceObject slideBack:NO];
	
}// end - (void)dragImage:(NSImage *)anImage at:(NSPoint)imageLoc offset:(NSSize)mouseOffset event:(NSEvent *)theEvent pasteboard:(NSPasteboard *)pboard source:(id)sourceObject slideBack:(BOOL)slideBack

#pragma mark -
#pragma mark NSDraggingSource
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	return  isLocal ? NSDragOperationEvery : NSDragOperationCopy;
}// end - (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal

- (void) draggedImage:(NSImage *)image beganAt:(NSPoint)screenPoint
{
	draggingOut = NO;
	offset.x = startPoint.x - screenPoint.x;
	offset.y = startPoint.y - screenPoint.y;
}// end - (void) draggedImage:(NSImage *)image beganAt:(NSPoint)screenPoint

- (void) draggedImage:(NSImage *)image movedTo:(NSPoint)screenPoint
{
	BOOL pointInView;
	NSPoint windowPoint;
	NSPoint viewPoint;
	
	windowPoint = [[self window] convertScreenToBase:screenPoint];
		// offset to mouse point
	windowPoint.x += offset.x;
	windowPoint.y += offset.y;
	viewPoint = [self convertPoint:windowPoint fromView:nil];
	pointInView = NSPointInRect(viewPoint, [self bounds]);
	if ((draggingOut == YES) && (pointInView == YES))
	{
		[[NSCursor arrowCursor] set];
		draggingOut = NO;
	}// end if
	if ((draggingOut == NO) && (pointInView == NO))
	{
		[[NSCursor disappearingItemCursor] set];
		draggingOut = YES;
	}// end if
		//  if ((pointInView == NO) && ([NSCursor currentCursor] != [NSCursor disappearingItemCursor]))
	if (pointInView == NO)
		[[NSCursor disappearingItemCursor] set];    
}// end - (void) draggedImage:(NSImage *)image movedTo:(NSPoint)screenPoint

- (void) draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
	if ((operation == NSDragOperationNone) && draggingOut)
	{
		NSShowAnimationEffect(NSAnimationEffectPoof, NSMakePoint(screenPoint.x + offset.x, screenPoint.y + offset.y), NSMakeSize(32.0f, 32.0f), [self dataSource], @selector(animationEffectDidEnd:), nil);
	}// end if
}// end - (void) draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation
@end
