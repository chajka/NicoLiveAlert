//
//  NLNotiryPreferenceViewController.mm
//  NicoLiveAlert
//
//  Created by Чайка on 7/3/14.
//  Copyright (c) 2014 Instrumentality of mankind. All rights reserved.
//

#import "NLANotiryPreferenceViewController.h"

@interface NLANotiryPreferenceViewController ()

@end

@implementation NLANotiryPreferenceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:NotifyPrefNibName bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

#pragma mark - MASPreferencesViewController
- (NSString *)identifier
{
    return NotifyPrefIdentifier;
}// end - (NSString *)identifier

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NotifyImageName];
}// end - (NSImage *)toolbarItemImage

- (NSString *)toolbarItemLabel
{
    return NotifyToolBarTitle;
}// end - (NSString *)toolbarItemLabel
@end
