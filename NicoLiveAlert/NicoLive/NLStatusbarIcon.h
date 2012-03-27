//
//  NLStatusbarIcon.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/24/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NicoLiveAlertDefinitions.h"
/*!
	@header NLStatusbarIcon.h

	This header file describes the constructs used to stasusbar management.
	bur currently useable by NicoLiveAlert.
*/

@interface NLStatusbarIcon : NSObject {
	__strong	NSStatusItem	*statusBarItem;
	__strong	NSStatusBar		*statusBar;
	NSMenu						*statusbarMenu;
	NSInteger					numberOfPrograms;
	NSSize						iconSize;
	CIImage						*sourceImage;
	NSImage						*statusbarIcon;
	NSImage						*statusbarAlt;
	CIFilter					*gammaFilter;
	NSNumber					*gammaPower;
	CIVector					*noProgVect;
	CIVector					*haveProgVect;
	CIFilter					*invertFilter;
	NSPoint						drawPoint;
	NSFont						*progCountFont;
	NSDictionary				*fontAttrDict;
	NSDictionary				*fontAttrInvertDict;
	NSBezierPath				*progCountBackground;
	NSColor						*progCountBackColor;
}
@property (readonly) NSInteger	numberOfPrograms;

/*!
	@method initWithMenu:andImageName:
	@abstract initialize statusbar menu and install it.
	@param menu menu of install to stataus bar.
	@param imageName point a image it show on statusbar.
	@result A newly-created statusbar manager instance.
*/
- (id) initWithMenu:(NSMenu *)menu andImageName:(NSString *)imageName;

#pragma mark accessor
/*!
	@method incleaseProgCount
	@abstract notify pogram count need inclease.
*/
- (void) incleaseProgCount;

/*!
 @method decleaseProgCount
 @abstract notify pogram count need declease.
 */
- (void) decleaseProgCount;
@end
