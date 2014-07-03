//
//  NLAGeneralPreferenceViewController.mm
//  NicoLiveAlert
//
//  Created by Чайка on 7/3/14.
//  Copyright (c) 2014 Instrumentality of mankind. All rights reserved.
//

#import "NLAGeneralPreferenceViewController.h"

@interface NLAGeneralPreferenceViewController ()

@end

@implementation NLAGeneralPreferenceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:GeneralPrefNibName bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

#pragma mark - MASPreferencesViewController
- (NSString *)identifier
{
    return GeneralPrefIdentifier;
}// end - (NSString *)identifier

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:GeneralImageName];
}// end - (NSImage *)toolbarItemImage

- (NSString *)toolbarItemLabel
{
    return GeneralToolBarTitle;
}// end - (NSString *)toolbarItemLabel
@end
