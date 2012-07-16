//
//  NLAccount.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/22/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPConnection.h"
#import "KCSUser.h"

#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
@interface NLAccount : NSObject <NSXMLParserDelegate> {
#else
@interface NLAccount : NSObject {
#endif
		// user information member variables
	NSString			*mailaddr;
	NSString			*password;
	NSString			*nickname;
	NSNumber			*userid;
	NSString			*ticket;
	NSMutableDictionary	*channels;
	NSMenuItem			*accountMenu;
	__strong KCSInternetUser		*keychainItem;
}
@property (readonly)			NSString			*mailaddr;
@property (readonly)			NSString			*password;
@property (readonly)			NSString			*nickname;
@property (readonly)			NSNumber			*userid;
@property (readonly)			NSString			*ticket;
@property (readonly)			NSMutableDictionary	*channels;
@property (readonly)			NSMenuItem			*accountMenu;
@property (retain, readwrite)	KCSInternetUser		*keychainItem;
	
#pragma mark construct
- (id) initWithKeychainAccount:(KCSInternetUser *)keychainAccount;
- (id) initWithAccount:(NSString *)account andPassword:(NSString *)pass;
- (id) initOfflineAccount:(NSString *)account andPassword:(NSString *)pass isNickname:(NSString *)nick;
- (BOOL) changePasswordTo:(NSString *)pass;
- (BOOL) updateAccountInfo;
@end
