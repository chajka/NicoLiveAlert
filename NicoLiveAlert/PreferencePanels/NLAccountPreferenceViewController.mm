//
//  NLAccountPreferenceViewController.mm
//  NicoLiveAlert
//
//  Created by Чайка on 7/3/14.
//  Copyright (c) 2014 Instrumentality of mankind. All rights reserved.
//

#import "NLAccountPreferenceViewController.h"

@interface NLAccountPreferenceViewController ()

@end

@implementation NLAccountPreferenceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

#pragma mark - MASPreferencesViewController
- (NSString *)identifier
{
    return @"IdentifierName";
}// end - (NSString *)identifier

- (NSImage *)toolbarItemImage
{
    return nil;	// NSImage
}// end - (NSImage *)toolbarItemImage

- (NSString *)toolbarItemLabel
{
    return @"ToolbarTitle";
}// end - (NSString *)toolbarItemLabel
@end
