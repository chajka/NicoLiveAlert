//
//  NLAccountPreferenceViewController.mm
//  NicoLiveAlert
//
//  Created by Чайка on 7/3/14.
//  Copyright (c) 2014 Instrumentality of mankind. All rights reserved.
//

#import "NLAAccountPreferenceViewController.h"

@interface NLAAccountPreferenceViewController ()

@end

@implementation NLAAccountPreferenceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:AccountPrefNibName bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

#pragma mark - MASPreferencesViewController
- (NSString *)identifier
{
    return AccountPrefIdentifier;
}// end - (NSString *)identifier

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:AccountImageName];
}// end - (NSImage *)toolbarItemImage

- (NSString *)toolbarItemLabel
{
    return AccountToolBarTitle;
}// end - (NSString *)toolbarItemLabel
@end
