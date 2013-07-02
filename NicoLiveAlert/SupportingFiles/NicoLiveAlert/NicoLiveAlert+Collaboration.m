//
//  NicoLiveAlert+Collaboration.m
//  NicoLiveAlert
//
//  Created by Чайка on 5/18/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NicoLiveAlert+Collaboration.h"
#import "NicoLiveAlertCollaboration.h"

@interface NSDistantObject (Collaboration)
- (void) startFMLE:(NSString *)live;
- (void) stopFMLE;
- (void) joinToLive:(NSString *)live;
@end

@implementation NicoLiveAlert (Collaboration)
#pragma mark Other application collaboration
- (void) connectToProgram:(NSDictionary *)program
{
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:NLABroadcastStartNotification object:NLAApplicationName userInfo:program];

	NSString *liveno = [program valueForKey:LiveNumber];
	BOOL toCommentViewr = [[program valueForKey:CommentViewer] boolValue];
	BOOL toStreamer = [[program valueForKey:BroadcastStreamer] boolValue];
	if (toCommentViewr == YES)
		[self joinToLive:liveno];
	// endif
	if (toStreamer == YES)
		[self startFMLE:liveno];

}// end - (void) connectToProgram:(NSAttributedString *)program

- (void) disconnectFromProgram:(NSDictionary *)program
{
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:NLABroadcastEndNotification object:NLAApplicationName userInfo:program];
	[self stopFMLE];
}// end - (void) disconnectFromProgram:(NSString *)program

#pragma mark application collaboration by classic interface
- (void) startFMLE:(NSString *)live
{
	NSDistantObject *fmle = [NSConnection rootProxyForConnectionWithRegisteredName:ServerFMELauncher host:NULL];
	[fmle startFMLE:live];
}// end - (void) startFMLE:(NSString *)live

- (void) stopFMLE
{
	NSDistantObject *fmle = [NSConnection rootProxyForConnectionWithRegisteredName:ServerFMELauncher host:NULL];
	[fmle stopFMLE];
}// end - (void) stopFMLE

- (void) joinToLive:(NSString *)live
{
	NSDistantObject *charleston = [NSConnection rootProxyForConnectionWithRegisteredName:ServerCharleston host:NULL];
	[charleston joinToLive:live];
}// - (void) joinToLive:(NSString *)live
@end
