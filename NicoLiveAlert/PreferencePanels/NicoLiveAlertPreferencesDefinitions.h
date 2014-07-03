//
//  NicoLiveAlertPreferencesDefinitions.h
//  NicoLiveAlert
//
//  Created by Чайка on 7/3/14.
//  Copyright (c) 2014 Instrumentality of mankind. All rights reserved.
//

#ifndef NicoLiveAlert_NicoLiveAlertPreferencesDefinitions_h
#define NicoLiveAlert_NicoLiveAlertPreferencesDefinitions_h
#pragma mark - General
#define GeneralPrefNibName							@"NLAGeneralPreferenceView"
#define GeneralPrefIdentifier						@"GeneralPreferences"
#define GeneralImageName							NSImageNamePreferencesGeneral
#define	GeneralToolBarTitle							NSLocalizedString(@"GeneralPreferences", @"General")

#pragma mark - Watchlist
#define WatchlistPrefNibName						@"NLAWatchlistPreferenceView"
#define	WatchlistPrefIdentifier						@"WatchlistPreferences"
#define WatchlistImageName							@"watch"
#define	WatchlistToolBarTitle						NSLocalizedString(@"WatchlistPreferences", @"Watchlist")

#pragma mark - Notify
#define NotifyPrefNibName							@"NLANotiryPreferenceView"
#define	NotifyPrefIdentifier						@"NotifyPreferences"
#define NotifyImageName								@"Bell"
#define	NotifyToolBarTitle							NSLocalizedString(@"NotifyPreferences", @"Notify")

#pragma mark - Account
#define AccountPrefNibName							@"NLAAccountPreferenceView"
#define	AccountPrefIdentifier						@"AccountPreferences"
#define AccountImageName							@"keys"
#define	AccountToolBarTitle							NSLocalizedString(@"AccountPreferences", @"Account")

#endif
