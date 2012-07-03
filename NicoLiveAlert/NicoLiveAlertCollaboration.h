//
//  NicoLiveAlertCollaboration.h
//  NicoLiveAlert
//
//  Created by Чайка on 5/20/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#ifndef NicoLiveAlertCollaboration_h
#define NicoLiveAlertCollaboration_h

#define NLAApplicationName				@"NicoLiveAlert"
#define NLABroadcastStartNotification	@"NLABroadcastStart"
#define NLABroadcastEndNotification		@"NLABroadcastEnd"

/*!
 @abstract dictionary keys of NLABroadcastStartNotification
 */
/*!
 @define ProgramURL
 @abstract program url by NSURL object
 */
#define ProgramURL						@"ProgramURL"
/*!
 @define LiveNumber
 @abstract program number (lv....) by NSString object
 */
#define LiveNumber						@"LiveNumber"
/*!
 @define CommentViewr
 @abstract Wish to Open Comment Viewr by BOOL value of NSNumber object
 */
#define CommentViewer					@"CommentViewer"
/*!
 @define BroadcastStreamer
 @abstract Wish to Open Straming program by BOOL value of NSNumber object
 ex. Flash Media Live Encoder
 */
#define BroadcastStreamer				@"BroadcastStreamer"
/*!
 @define BroadcastKind
 @abstract tell a kind of this program by described enumlation Number 
 by NSNumber object
 */
#define BroadCastKind					@"BroadCastKind"

typedef NSInteger	BroadcastKind;
enum BroadcastKind {
	bradcastKindChannel = -1,
	bradcastKindUser = 0,
	bradcastKindOfficial = 1
};


#endif
