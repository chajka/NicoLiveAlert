//
//  main.m
//  Collaborator
//
//  Created by Чайка on 5/19/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <xpc/xpc.h>
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "NicoLiveAlertDefinitions.h"
#import "NicoLiveAlertCollaboration.h"
#import "NSObject+XPCHelpers.h"

@interface NSDistantObject ()
- (void) startFMLE:(NSString *)live;
- (void) stopFMLE;
- (void) joinToLive:(NSString *)live;
@end

@interface NicoLiveAlertCollaboration : NSObject {
}
- (void) connectToProgram:(NSDictionary *)program;
- (void) disconnectFromProgram:(NSDictionary *)program;
- (void) startFMLE:(NSString *)live;
- (void) stopFMLE;
- (void) joinToLive:(NSString *)live;
@end

@implementation NicoLiveAlertCollaboration

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

	BOOL toStreamer = [[program valueForKey:BroadcastStreamer] boolValue];
	if (toStreamer == YES)
		[self stopFMLE];

}// end - (void) disconnectFromProgram:(NSString *)program

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

static NicoLiveAlertCollaboration* collaborator = nil;

static void Collaborator_peer_event_handler(xpc_connection_t peer, xpc_object_t event) 
{
	xpc_type_t type = xpc_get_type(event);
	if (type == XPC_TYPE_ERROR) {
		if (event == XPC_ERROR_CONNECTION_INVALID) {
			// The client process on the other end of the connection has either
			// crashed or cancelled the connection. After receiving this error,
			// the connection is in an invalid state, and you do not need to
			// call xpc_connection_cancel(). Just tear down any associated state
			// here.
		} else if (event == XPC_ERROR_TERMINATION_IMMINENT) {
			// Handle per-connection termination cleanup.
		}
	} else {
		assert(type == XPC_TYPE_DICTIONARY);
		// Handle the message.
		NSDictionary *progInfo = [NSObject xpcObjectToNSObject:event];
		NSString *message = [progInfo valueForKey:XPCNotificationName];
		NSDictionary *info = [progInfo valueForKey:Information];
		if (info == NULL)
			return;
		if ([message isEqualToString:TypeProgramStart] == YES)
			[collaborator connectToProgram:info];
		else if ([message isEqualToString:TypeProgramEnd] == YES)
			[collaborator disconnectFromProgram:info];
		// end if
	}
}

static void Collaborator_event_handler(xpc_connection_t peer) 
{
	// By defaults, new connections will target the default dispatch
	// concurrent queue.
	xpc_connection_set_event_handler(peer, ^(xpc_object_t event) {
		Collaborator_peer_event_handler(peer, event);
	});
	
	// This will tell the connection to begin listening for events. If you
	// have some other initialization that must be done asynchronously, then
	// you can defer this call until after that initialization is done.
	xpc_connection_resume(peer);
}

int main(int argc, const char *argv[])
{
	collaborator = [[NicoLiveAlertCollaboration alloc] init];
	xpc_main(Collaborator_event_handler);
	return 0;
}
