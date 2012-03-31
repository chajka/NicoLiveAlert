//
//  HTTPConnection.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/23/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "HTTPConnection.h"

	// for HTTP connection method literal
#define RequestMethodPost	@"POST"
#define RequestMethodGet	@"GET"
	//	for creating query literal
#define ParamConcatFormat	@"%@=%@"
#define ParamsConcatSymbol	@"&"
#define QueryConcatFormat	@"?%@"

const NSTimeInterval defaultTimeout = 30; // second

#pragma mark private methods
@interface HTTPConnection ()
/*!
	@method buildParam
	@abstract clear readonly response object.
	@discussion this method might be call after post/get method.
	because response store last value.
	@result new HTTPConnection object with URL. 
 */
- (NSString *) buildParam;

/*!
	@method stringByPost:
	@abstract get contents of URL by string format with posted own parameters.
	@param error result.
	@result new HTTPConnection object with URL. 
 */
- (NSData *) post:(NSError **)err;
@end

@implementation HTTPConnection
@synthesize url;
@synthesize path;
@synthesize params;
@synthesize response;
@synthesize timeout;

#pragma mark class methods
+ (NSString *) HTTPSource:(NSURL *)url response:(NSURLResponse **)resp
{		// create detamine encoding constant array 
	NSArray *encodings = [NSArray arrayWithObjects:
			  [NSNumber numberWithUnsignedInt:NSUTF8StringEncoding],
			  [NSNumber numberWithUnsignedInt:NSShiftJISStringEncoding], 
			  [NSNumber numberWithUnsignedInt:NSJapaneseEUCStringEncoding], 
			  [NSNumber numberWithUnsignedInt:NSISO2022JPStringEncoding], 
			  [NSNumber numberWithUnsignedInt:NSUnicodeStringEncoding], 
			  [NSNumber numberWithUnsignedInt:NSASCIIStringEncoding], nil];

		// check have data
	NSData *receivedData = [HTTPConnection HTTPData:url response:resp];
	if (receivedData == NULL)
		return NULL;

		// datamine encoding
	NSString *data_str = NULL;
	for (NSNumber *enc in encodings)
	{
#if __has_feature(objc_arc)
		data_str = [[NSString alloc] initWithData:receivedData encoding:[enc unsignedIntValue]];
#else
		data_str = [[[NSString alloc] initWithData:receivedData encoding:[enc unsignedIntValue]] autorelease];
#endif
		if (data_str!=nil)
			break;
	}// end for each encodings
	return data_str;
}// end + (NSString *) HTTPSource:(NSURL *)url

+ (NSData *) HTTPData:(NSURL *)url response:(NSURLResponse **)resp
{
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSError *error = nil;
	NSURLResponse *re;
	NSData *receivedData = [NSURLConnection sendSynchronousRequest:request
												 returningResponse:&re
															 error:&error];
	if (resp != NULL)
		*resp = re;
	// endif 
	
		// error check
	if ([error code] != noErr)
		return NULL;
	else
		return receivedData;
}// end + (NSString *) HTTPSource:(NSURL *)url

#pragma mark -
#pragma mark construct/destruct
- (id) init
{
	self = [super init];
	if (self)
	{
		url = NULL;
		path = NULL;
		params = NULL;
		response = NULL;
		timeout = defaultTimeout;
	}// end if self
	return self;
}// end - (id) init

- (id) initWithURL:(NSURL *)url_ withParams:(NSDictionary *)param
{
	self = [super init];
	if (self)
	{
		url = [url_ copy];
		path = NULL;
		params = [param copy];
		response = NULL;
		timeout = defaultTimeout;
	}// end if self
	return self;
}// end - (id) initWithURL:(NSURL *)url_ withParams:(NSDictionary *)param

- (void) dealloc
{
#if __has_feature(objc_arc) == 0
    if (url != NULL)		[url release];
	if (path != NULL)		[path release];
	if (params != NULL)		[params release];
	if (response != NULL)	[response release];
	[super dealloc];
#endif
}// end - (void) dealloc
#pragma mark -
#pragma mark instance methods
- (void) clearResponse
{
#if __has_feature(objc_arc) == 0
	[response autorelease];
#endif
	response = NULL;
}// end - (void) clearResponse

- (NSString *) stringByGet
{
	NSURL *queryURL = NULL;
	NSString *query = NULL;
	if (params != NULL)
		query = [NSString stringWithFormat:QueryConcatFormat, [self buildParam]];
	queryURL = [NSURL URLWithString:[NSString stringWithFormat:QueryConcatFormat, [url absoluteString], query]];
	NSURLResponse *resp = NULL;
	NSString *string = NULL;
	string = [HTTPConnection HTTPSource:queryURL response:&resp];
	response = [resp copy];
	
	return string;
}// end - (NSString *) stringByGet:(NSError **)error

- (NSData *) dataByGet
{
	NSURL *queryURL = NULL;
	NSString *query = NULL;
	if (params != NULL)
		query = [NSString stringWithFormat:QueryConcatFormat, [self buildParam]];
	queryURL = [NSURL URLWithString:[NSString stringWithFormat:QueryConcatFormat, [url absoluteString], query]];
	NSURLResponse *resp;
	NSData *data = [HTTPConnection HTTPData:queryURL response:&resp];
	response = [resp copy];
	return data;
}// end - (NSData *) dataByGet:(NSError **)error

- (NSString *) stringByPost:(NSError **)error
{
	NSData *receivedData = [self post:error];
	if ([*error code] != noErr)
		return NULL;
		// create detamine encoding constant array 
	NSArray *encodings = [NSArray arrayWithObjects:
						  [NSNumber numberWithUnsignedInt:NSUTF8StringEncoding],
						  [NSNumber numberWithUnsignedInt:NSShiftJISStringEncoding], 
						  [NSNumber numberWithUnsignedInt:NSJapaneseEUCStringEncoding], 
						  [NSNumber numberWithUnsignedInt:NSISO2022JPStringEncoding], 
						  [NSNumber numberWithUnsignedInt:NSUnicodeStringEncoding], 
						  [NSNumber numberWithUnsignedInt:NSASCIIStringEncoding], nil];

	// datamine encoding
	NSString *data_str = NULL;
	for (NSNumber *enc in encodings)
	{
#if __has_feature(objc_arc)
		data_str = [[NSString alloc] initWithData:receivedData encoding:[enc unsignedIntValue]];
#else
		data_str = [[[NSString alloc] initWithData:receivedData encoding:[enc unsignedIntValue]] autorelease];
#endif
		if (data_str!=nil)
			break;
	}// end for each encodings

	return data_str;
}// end - (NSString *) stringByPost:(NSError **)error

- (NSData *) dataByPost:(NSError **)error
{
	NSData *data = NULL;
	NSError *err = NULL;
	data = [self post:&err];
	if (error != NULL)
		*error = err;

	return data;
}// end - (NSData *) dataByPost:(NSError **)error

- (NSURLConnection *) httpDataAsyncWithDelegate:(id)target
{
	if (target == NULL)
		return NULL;
	// end if target isn't there, because self cannot become delegator.

	NSURLRequest *request;
	request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy
						   timeoutInterval:timeout];
	NSURLConnection *connection;
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:target];
#if __has_feature(objc_arc) == 0
	[connection autorelease];
#endif
	
	return connection;
}// end - (NSURLConnection *) httpDataAsync:(NSURL *)url delegate:(id)target

#pragma mark private methods
- (NSData*) post:(NSError **)err;
{
		// create request
	NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
		// create psot body
	NSString *message = [self buildParam];
	NSURLResponse *resp = NULL;
	NSData *httpBody = [message dataUsingEncoding:NSUTF8StringEncoding];
	NSError *error = NULL;
	[urlRequest setHTTPMethod:RequestMethodPost];
	[urlRequest setHTTPBody:httpBody];
	NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
										   returningResponse:&resp
													   error:&error];
	response = [resp copy];
#if __has_feature(objc_arc) == 0
	[urlRequest release];
#endif
	if (err != NULL)
		*err = error;
	if ([error code] != noErr)
		return NULL;
	else
		return result;
}// end - (NSData*) post

- (NSString *) buildParam
{
	NSString *param = NULL;
	NSMutableArray *messages = [NSMutableArray array];
	for (NSString *key in [params allKeys])
	{
		[messages addObject:[NSString stringWithFormat:ParamConcatFormat, key, [params objectForKey:key]]];
	}// end for
	param = [[messages componentsJoinedByString:ParamsConcatSymbol] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	return param;
}// end - (NSString *) buildParam
@end
