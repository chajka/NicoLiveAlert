//
//  NLArrayControllerDragAndDrop.h
//  NicoLiveAlert
//
//  Created by Чайка on 4/25/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IOMTableViewDragAndDrop.h"

#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
@interface NLArrayControllerDragAndDrop : NSArrayController <NSTableViewDataSource, NSTableViewDelegate> {
	IOMTableViewDragAndDrop *watchListTable;
	IOMTableViewDragAndDrop *accountInfoTable;
	IOMTableViewDragAndDrop *launchListTable;
}
@property (retain, readwrite) IOMTableViewDragAndDrop *watchListTable;
@property (retain, readwrite) IOMTableViewDragAndDrop *accountInfoTable;
@property (retain, readwrite) IOMTableViewDragAndDrop *launchListTable;
#else
@interface NLArrayControllerDragAndDrop : NSArrayController
#endif

@end
