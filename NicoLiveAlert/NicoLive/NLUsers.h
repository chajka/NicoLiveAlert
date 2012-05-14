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

@interface NLUsers : NSObject <NSComboBoxDataSource> {
	NSMutableDictionary	*usersState;	// value : (in)active - key : nickname
	NSMutableDictionary	*accounts;		// value : NLAccount object - key : nickname
	NSMutableArray		*users;			// array of NLAccount object
	NSMutableDictionary	*originalWatchList;
	NSMutableDictionary	*watchlist;
	NSMenu				*usersMenu;
	NSInteger			userState;
}
@property (readonly) NSMutableArray			*users;
@property (readonly) NSMutableDictionary	*originalWatchList;
@property (readonly) NSMutableDictionary	*watchlist;
@property (readonly) NSMenu					*usersMenu;
@property (readonly) NSInteger				userState;

#pragma mark constructor / destructor
/*!
	@method initWithActiveUsers:andManualWatchList:
	@abstract create nicolive account list with active usrs and manual wathlist.
	@param array of mailaddress (login account) for watch joind community.
	@param manually added watchlist with autoOpen flag.
	@result active and deactive user management object
*/
- (id) initWithActiveUsers:(NSArray *)activeUsers andManualWatchList:(NSDictionary *)manualWatchList;

#pragma mark -
#pragma mark user management
/*!
	@method addUser:andPassword:
	@abstract add user account by maila ddress with password.
	This user hold by NLAccount instance in reciever.
	this account store to keychain for nicovideo.
	@param mailaddress for login to niconico live
	@param password for login to niconico live
	@result status for store to keychain.
	Or 1 is failed to login nicovideo.
 */
- (OSStatus) addUser:(NSString *)useraccount withPassword:(NSString *)userpassword;

/*!
*/
- (BOOL) updateUserAccountInforms;

/*!
	@method primaryAccountForCommunity:
	@abstract return primary account of reciever stored accounts communities.
	@param community no of program.
	@result account information by NLAccount.
 */
- (NLAccount *) primaryAccountForCommunity:(NSString *)community;

/*!
	@method activeUsers
	@abstract return array of active user's username
	@result NSArray contains user's name by NSString.
*/
- (NSArray *) activeUsers;

#pragma mark -
#pragma mark menu management
/*!
	@method toggleUserState:
	@abstract switch sender to watch or unwatch.
	result status shown by users menuItem's check mark.
	It effect to reconstruct content of watchlist of reciever.
	@result new userState
*/
- (NSCellStateValue) toggleUserState:(NSMenuItem *)item;

#pragma mark -
#pragma mark watchlist management
/*!
	@method addWatchListItem:autoOpen:
	@abstract Add a single watchlist item with autoOpen property.
	@param watchlist item as User ID, Community No., ChannelNo. or liveNo.
	@param item need auto open
 */
- (void) addWatchListItem:(NSString *)item autoOpen:(BOOL)autoOpen;

/*!
	@method addWatchListItems:
	@abstract add two or more watchlist item
	@param watchlist item by dictionary
*/
- (void) addWatchListItems:(NSMutableDictionary *)watchDict;

/*!
	@method switchWatchListItemProperty:autoOpen:
	@abstract set/reset autoOpen property of indexed item
	@param item name
	@param autoOpen property
*/
- (void) switchWatchListItemProperty:(NSString *)item autoOpen:(BOOL)autoOpen;

/*!
	@method removeWatchListItem:
	@param watchlist item as User ID, Community No., ChannelNo. or liveNo.
*/
- (void) removeWatchListItem:(NSString *)item;

@end
