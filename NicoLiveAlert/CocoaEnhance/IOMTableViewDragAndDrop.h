//
//  IOMTableViewDragAndDrop.h
//  NicoLiveAlert
//
//  Created by Чайка on 4/25/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>

@interface IOMTableViewDragAndDrop : NSTableView {
	BOOL draggingOut;
	NSPoint startPoint;
	NSPoint offset;
}

@end
