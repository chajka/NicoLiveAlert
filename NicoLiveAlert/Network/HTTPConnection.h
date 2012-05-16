//
//  HTTPConnection.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/23/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPConnection : NSObject {
@protected
	NSURL			*url;
	NSString		*path;
	NSDictionary	*params;
	NSURLResponse	*response;
	NSTimeInterval	timeout;
}
@property (copy, readwrite)		NSURL			*url;
@property (copy, readwrite)		NSString		*path;
@property (copy, readwrite)		NSDictionary	*params;
@property (readonly)			NSURLResponse	*response;
@property (assign, readwrite)	NSTimeInterval	timeout;
	// class method
/*!
	@method HTTPSource:
	@abstract Return contents of requested URL by NSString.
	@param URL of request.
	@param resoponse from server.
	@result html data by string format.
*/
#if __has_feature(objc_arc)
+ (NSString *) HTTPSource:(NSURL *)url response:(NSURLResponse * __autoreleasing *)resp;
#else
+ (NSString *) HTTPSource:(NSURL *)url response:(NSURLResponse **)resp;
#endif

/*!
	@method HTTPData:response:
	@abstract Return contents of requested URL by NSData.
	@param URL of request.
	@param resoponse from server.
	@result html data by binary format.
 */
#if __has_feature(objc_arc)
+ (NSData *) HTTPData:(NSURL *)url response:(NSURLResponse * __autoreleasing *)resp;
#else
+ (NSData *) HTTPData:(NSURL *)url response:(NSURLResponse **)resp;
#endif

/*!
	@method HTTPDataWithRequest:response:
	@abstract Return contents of requested URL by NSData.
	@param NSURLRequest object.
	@param resoponse from server.
	@result html data by binary format.
*/
#if __has_feature(objc_arc)
+ (NSData *) HTTPDataWithRequest:(NSURLRequest *)req response:(NSURLResponse * __autoreleasing *)resp;
#else
+ (NSData *) HTTPDataWithRequest:(NSURLRequest *)req response:(NSURLResponse **)resp;
#endif

	// constructor
/*!
	@method init
	@abstract create HTTPConnection object and clear all member variable.
	@result new clean HTTPConnection object.
*/
- (id) init;

/*!
	@method initWithURL:withParams:
	@abstract create HTTPConnection object with URL and query paramerters.
	@param URL of access this object.
	@param query parameters by key-value pair dictionary or nil.
	@result new HTTPConnection object with URL. 
*/
- (id) initWithURL:(NSURL *)url_ withParams:(NSDictionary *)param;
	// instance methods
/*!
	@method clearResponse
	@abstract clear readonly response object.
	@discussion this method might be call after post/get method.
	because response store last value.
*/
- (void) clearResponse;

/*!
	@method stringByGet
	@abstract get contents of URL by string format with own parameters.
 */
- (NSString *) stringByGet;

/*!
	@method dataByGet
	@abstract get contents of URL by binary format with own parameters.
 */
- (NSData *) dataByGet;

/*!
	@method stringByPost:
	@abstract get contents of URL by string format with posted own parameters.
	@param error result.
 */
#if __has_feature(objc_arc)
- (NSString *) stringByPost:(NSError * __autoreleasing *)error;
#else
- (NSString *) stringByPost:(NSError **)error;
#endif

/*!
	@method dataByPost:
	@abstract get contents of URL by binary format with posted own parameters.
	@param error result.
*/
#if __has_feature(objc_arc)
- (NSData *) dataByPost:(NSError * __autoreleasing *)error;
#else
- (NSData *) dataByPost:(NSError **)error;
#endif

/*!
	@method httpDataAsyncWithdelegate:
	@abstract send HTTP request with async data transfer.
	@param delegate object for data recieve. if nil, it dosen’t work.
	@result NSURLConnection object of this connection;
 */
- (NSURLConnection *) httpDataAsyncWithDelegate:(id)target;
@end
