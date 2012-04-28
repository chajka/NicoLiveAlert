//
//  NLArrayControllerDragAndDrop.h
//  NicoLiveAlert
//
//  Created by Чайка on 4/25/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IOMTableViewDragAndDrop.h"

@interface NLArrayControllerDragAndDrop : NSArrayController <NSTableViewDataSource, NSTableViewDelegate> {
	IOMTableViewDragAndDrop *watchListTable;
	IOMTableViewDragAndDrop *accountInfoTable;
	IOMTableViewDragAndDrop *launchListTable;
}
@property (retain, readwrite) IOMTableViewDragAndDrop *watchListTable;
@property (retain, readwrite) IOMTableViewDragAndDrop *accountInfoTable;
@property (retain, readwrite) IOMTableViewDragAndDrop *launchListTable;

@end
