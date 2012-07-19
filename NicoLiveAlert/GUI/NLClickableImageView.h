//
//  NLClickableImageView.h
//  NicoLiveAlert
//
//  Created by Чайка on 7/19/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NLClickableImageView : NSImageView {
	id	target;
	id	representedObject;
	SEL	selector;
}
@property (retain, readwrite) id	target;
@property (retain, readwrite) id	representedObject;

- (void) setAction:(SEL)aSelector toTarget:(id)object;

@end
