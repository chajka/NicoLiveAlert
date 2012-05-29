//
//  NicoLiveAlert+XPC.m
//  NicoLiveAlert
//
//  Created by Чайка on 5/20/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NicoLiveAlert+XPC.h"
#import "NicoLiveAlertDefinitions.h"
#import "NSObject+XPCHelpers.h"


@implementation NicoLiveAlert (XPC)

- (xpc_connection_t) _connectionForServiceNamed:(const char *)serviceName
                       connectionInvalidHandler:(dispatch_block_t)handler
{
    __block xpc_connection_t serviceConnection =
	xpc_connection_create(serviceName, dispatch_get_main_queue());
	
    if (!serviceConnection) {
        NSLog(@"Can't connect to XPC service");
        self.statusMessage = @"Can't connect to XPC service";
        return (NULL);
    }
	
    statusMessage = @"Created connection to XPC service";
	
    xpc_connection_set_event_handler(serviceConnection, ^(xpc_object_t event) {
        xpc_type_t type = xpc_get_type(event);
		
        if (type == XPC_TYPE_ERROR) {
			
            if (event == XPC_ERROR_CONNECTION_INTERRUPTED) {
					// The service has either cancaled itself, crashed, or been
					// terminated.  The XPC connection is still valid and sending a
					// message to it will re-launch the service.  If the service is
					// state-full, this is the time to initialize the new service.
				
                self.statusMessage = @"Interrupted connection to XPC service";
            } else if (event == XPC_ERROR_CONNECTION_INVALID) {
					// The service is invalid. Either the service name supplied to
					// xpc_connection_create() is incorrect or we (this process) have
					// canceled the service; we can do any cleanup of appliation
					// state at this point.
                self.statusMessage = @"Connection Invalid error for XPC service";
                xpc_release(serviceConnection);
                if (handler) {
                    handler();
                }
            } else {
                self.statusMessage = @"Unexpected error for XPC service";
            }
        } else {
            self.statusMessage = @"Received unexpected event for XPC service";
        }
    });
	
		// Need to resume the service in order for it to process messages.
    xpc_connection_resume(serviceConnection);
    return (serviceConnection);
}// end  _connectionForServiceNamed:(const char *)serviceName connectionInvalidHandler:(dispatch_block_t)handler


- (void) connectToProgram:(NSDictionary *)program
{
	if (_collaborationServiceConnection == NULL)
		return;
	
    xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
    assert(message != NULL);
	xpc_dictionary_set_string(message, 
		[XPCNotificationName UTF8String], [TypeProgramStart UTF8String]);

	xpc_object_t collaboInfo = [(NSObject *)program newXPCObject];
	xpc_dictionary_set_value(message, [Information UTF8String], collaboInfo);
	xpc_release(collaboInfo);

	xpc_connection_send_message(_collaborationServiceConnection, message);
	xpc_release(message);
	
}// end - (void) connectToProgram:(NSDictionary *)program

- (void) disconnectFromProgram:(NSDictionary *)program
{
	if (_collaborationServiceConnection == NULL)
		return;

    xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
    assert(message != NULL);
	xpc_dictionary_set_string(message, 
							  [XPCNotificationName UTF8String], [TypeProgramEnd UTF8String]);
	
	xpc_object_t collaboInfo = [(NSObject *)program newXPCObject];
	xpc_dictionary_set_value(message, [Information UTF8String], collaboInfo);
	xpc_release(collaboInfo);
	
	xpc_connection_send_message(_collaborationServiceConnection, message);
	xpc_release(message);
}// - (void) disconnectFromProgram:(NSDictionary *)program

- (void) setupCollaboreationService
{
	self->_collaborationServiceConnection = [self _connectionForServiceNamed:CollaboratorXPCName
			connectionInvalidHandler:^{
				self->_collaborationServiceConnection = NULL;
			}];
}// end - (void) setupCollaboreationService
@end
