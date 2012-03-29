//
//  NLUsers.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/25/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NicoLiveAlertDefinitions.h"
#import "KCSUser.h"
#import "NLAccount.h"

/*!
	@header NLUsers.h

	This header file describes the user management class for NicoLiveAlert.

	this class for working
	• correct internet password for nicovideo
	• calcurate wathclist from active and deactive users 
	• cleate user status menu
*/

@interface NLUsers : NSObject {
	NSNumber			*active;
	NSNumber			*deactive;
	NSMutableDictionary	*usersState;
	NSMutableDictionary	*accounts;
	NSDictionary		*originalWatchList;
	NSMutableDictionary	*watchlist;
	NSMenu				*usersMenu;
}
@property (readonly) NSMutableDictionary	*watchlist;
@property (readonly) NSMenu					*usersMenu;

#pragma mark constructor / destructor
/*!
	@method initWithActiveUsers:andManualWatchList:
	@abstract create nicolive account list with active usrs and manual wathlist.
	@param array of mailaddress (login account) for watch joind community.
	@param manually added watchlist with autoOpen flag.
	@result active and deactive user management object
*/
- (id) initWithActiveUsers:(NSArray *)users andManualWatchList:(NSDictionary *)manualWatchList;

#pragma mark -
#pragma mark user management
/*!
	@method addUser:andPassword:
	@abstract add user account by maila ddress with password.
	This user hold by NLAccount instance in reciever.
	this account store to keychain for nicovideo.
	@result status for store to keychain.
	Or 1 is failed to login nicovideo.
 */
- (OSStatus) addUser:(NSString *)useraccount withPassword:(NSString *)userpassword;

#pragma mark -
#pragma mark menu management
/*!
 @method toggleUserState:
 @abstract switch sender to watch or unwatch.
 result status shown by users menuItem's check mark.
 It effect to reconstruct content of watchlist of reciever.
*/
- (void) toggleUserState:(id)sender;

@end
