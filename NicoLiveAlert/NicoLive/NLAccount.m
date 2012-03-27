//
//  NLAccount.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/22/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLAccount.h"
#import "NicoLiveAlertDefinitions.h"

#pragma mark private method definition
@interface NLAccount ()
- (NSDictionary *) generateElementDict;
- (void) cleanupInternalVariables;
- (BOOL) getAccountInfo;
@end

@implementation NLAccount
@synthesize mailaddr;
@synthesize password;
@synthesize username;
@synthesize userid;
@synthesize ticket;
@synthesize userHash;
@synthesize channels;
@synthesize messageServerName;
@synthesize messageServerPortNo;
@synthesize messageServerThreadID;

#pragma mark construct / destruct
- (id) initWithAccount:(NSString *)account andPassword:(NSString *)pass
{
	self = [super init];
	if (self)
	{		// initialize user information member variables
		mailaddr = [account copy];
		password = [pass copy];
		username = NULL;
		userid = NULL;
			// initialize connection member variables
		ticket = NULL;
		userHash = NULL;
		channels = NULL;
		messageServerName = NULL;
		messageServerPortNo = 0;
		messageServerThreadID = NULL;
			// initialize internal variable
		elements = [self generateElementDict]; 
#if __has_feature(objc_arc) == 0
		[elements retain];
#endif
		stringBuffer = NULL;
		currentElement = 0;
		notAutoOpen = [NSNumber numberWithInteger:0];
		xmlResult = NO;
		if ([self getAccountInfo] == NO)
		{		// get user & connection information fail.
				// cleanup self and return NULL;
#if __has_feature(objc_arc) == 0
			[mailaddr release];
			[password release];
			if (username != NULL) {			[username release]; }
			if (userid != NULL)	{			[userid release]; }
			if (ticket != NULL)	{			[ticket release]; }
			if (userHash != NULL) {			[userHash release]; }
			if (channels != NULL)	{		[channels release]; }
			if (messageServerName != NULL)
				[messageServerName release];
			if (messageServerThreadID != NULL)
				[messageServerThreadID release];
			[self cleanupInternalVariables];
			[super dealloc];
#endif
			return NULL;
		}// end if getAccountInfo is failed
			// cleanup initialize only variables
		[self cleanupInternalVariables];
		
	}// end if self
	return self;
}// end - (id) initWithAccount:(NSString *)account andPassword:(NSString *)pass

- (void) dealloc
{
#if __has_feature(objc_arc) == 0
		// cleanup user information variables.
	if (mailaddr != NULL) {			[mailaddr release]; }
	if (password != NULL) {			[password release]; }
	if (username != NULL) {			[username release]; }
	if (userid != NULL)	{			[userid release]; }
		// cleanup connection information variables.
	if (ticket != NULL)	{			[ticket release]; }
	if (userHash != NULL) {			[userHash release]; }
	if (channels != NULL)	{		[channels release]; }
	if (stringBuffer != NULL)	{	[stringBuffer release]; }
	if (messageServerName != NULL)
		[messageServerName release];
	if (messageServerThreadID != NULL)
		[messageServerThreadID release];
		// internal variables are already cleanuped at constructor.
	[super dealloc];
#endif
}// end - (void) dealloc

#pragma mark constructor support
- (NSDictionary *) generateElementDict
{
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInteger:elementIndexResponse], elementKeyResponse,
		[NSNumber numberWithInteger:elementIndexTicket], elementKeyTicket,
		[NSNumber numberWithInteger:elementIndexStatus], elementKeyStatus,
		[NSNumber numberWithInteger:elementIndexUserID], elementKeyUserID, 
		[NSNumber numberWithInteger:elementIndexHash], elementKeyHash, 
		[NSNumber numberWithInteger:elementIndexUserName], elementKeyUserName, 
		[NSNumber numberWithInteger:elementIndexCommunity], elementKeyCommunity, 
		[NSNumber numberWithInteger:elementIndexAddress], elementKeyAddress, 
		[NSNumber numberWithInteger:elementIndexPort], elementKeyPort, 
		[NSNumber numberWithInteger:elementIndexThread], elementKeyThread,
	nil];

	return dict;
}// end - (NSDictionary *) generateElementDict

- (void) cleanupInternalVariables
{		// clanup elements
#if __has_feature(objc_arc) == 0
	if (elements != NULL)
	{		// cleanup elements
		[elements release];
		elements = NULL;
	}// end cleanup elements

		// cleanup stringBuffer
	if (stringBuffer != NULL)
	{
		[stringBuffer release];
		stringBuffer = NULL;
	}// end cleanup stringBuffer
#endif
}// end - (void) cleanupInternalVariables

- (BOOL) getAccountInfo
{		// login and get ticket
	NSString *loginURLStr = [NSString stringWithFormat:@"%@%@", NICOLOGINURL, NICOLOGINPARAM];
	NSURL *loginURL = [NSURL URLWithString:loginURLStr];
	NSDictionary *accountDict = [NSDictionary dictionaryWithObjectsAndKeys:mailaddr, LOGINQUERYMAIL, password, LOGINQUERYPASS, nil];
	HTTPConnection *loginServer = [[HTTPConnection alloc] initWithURL:loginURL withParams:accountDict];
	NSError *err = NULL;
	NSData *response = [loginServer dataByPost:&err];
#if __has_feature(objc_arc) == 0
	[loginServer release];
#endif
	if (([err code] != noErr) || (response == NULL))
		return NO;
	// end if login failed
		// correct ticket from xml
#if __has_feature(objc_arc)
	@autoreleasepool {
#else
	NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
#endif
			// start parse for get ticket.
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:response];
#if __has_feature(objc_arc) == 0
			[parser autorelease];
#endif
		if (parser == NULL)
			return NO;
		// end if not parser allocated.
		[parser setDelegate:(id)self];
		BOOL success = [parser parse];
		if ((success == NO) || (xmlResult == NO))
			return NO;
		// end if fail

		parser = NULL;
			// fetch userdata
		NSURLResponse *resp = NULL;
		NSString *userInfoQueryString = [NSString stringWithFormat:ALERTQUERY, ticket];
		NSURL *userInfoQuery = [NSURL URLWithString:userInfoQueryString];
		response = [HTTPConnection HTTPData:userInfoQuery response:&resp];
		if (response == NULL)
			return NO;
		// end if no response

			// start parse for get user's information from getalertstatus.
		parser = [[NSXMLParser alloc] initWithData:response];
#if __has_feature(objc_arc) == 0
			[parser autorelease];
#endif
		if (parser == NULL)
			return NO;
		// end if not parser allocated.
		[parser setDelegate:(id)self];
		success = [parser parse];
		if (success == NO)
			return NO;
		// end if
	
#if __has_feature(objc_arc)
	}
#else
	[arp release];
#endif
	return YES;
}// end - (void) getAccountInfo



#pragma mark NSXMLParserDelegate methods
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
}// end - (void)parserDidStartDocument:(NSXMLParser *)parser

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}// end - (void)parserDidEndDocument:(NSXMLParser *)parser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{		// set current element
	currentElement = [[elements valueForKey:elementName] integerValue];
		// check xml status
	if ((elementIndexResponse == currentElement) || (elementIndexStatus == currentElement))
	{		// check status attribute
		NSLog(@"%@", attributeDict);
		if ([[attributeDict valueForKey:keyXMLStatus] isEqualToString:resultOK] != YES)
			xmlResult = NO;
		else
			xmlResult = YES;
		// end if xml status is OK

			// allocate channels dictionary
		if (elementIndexStatus == currentElement)
			channels = [[NSMutableDictionary alloc] init];
		// end if alertstatus is OK
	}// end check xml status

		// initialize string;
	if (currentElement != 0)
	{
#if __has_feature(objc_arc) == 0
		if (stringBuffer != NULL)
		{
			[stringBuffer autorelease];
			stringBuffer = NULL;
		}// end if release old string buffer
#endif
		stringBuffer = [[NSMutableString alloc] init];
	}// end if known and required element

}// end - (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	NSUInteger uid = 0;
	NSString *channel = NULL;
	switch ([[elements valueForKey:elementName] integerValue])
	{
		case elementIndexTicket:
			ticket = [[NSString alloc] initWithString:stringBuffer];
			break;
		case elementIndexUserID:
			uid = [stringBuffer integerValue];
			userid = [[NSNumber alloc] initWithUnsignedInteger:uid];
			break;
		case elementIndexHash:
			userHash = [[NSString alloc] initWithString:stringBuffer];
			break;
		case elementIndexUserName:
			username = [[NSString alloc] initWithString:stringBuffer];
			break;
		case elementIndexCommunity:
			channel = [NSString stringWithString:stringBuffer];
			[channels setValue:notAutoOpen forKey:channel];
			break;
		case elementIndexAddress:
			messageServerName = [[NSString alloc] initWithString:stringBuffer];
			break;
		case elementIndexPort:
			messageServerPortNo = [stringBuffer integerValue];
			break;
		case elementIndexThread:
			messageServerThreadID = [[NSString alloc] initWithString:stringBuffer];
			break;
		default:
			break;
	}// end switch

#if __has_feature(objc_arc) == 0
	if (stringBuffer != NULL)
	{
		[stringBuffer autorelease];
		stringBuffer = NULL;
	}// end if
#endif
}// end - (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	[stringBuffer appendString:string];
//	NSLog(@"%@", string);
}// end - (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue
{
}// end - (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
}// end - (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError
{
}// end - (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix
{
}// end - (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI
{
}// end - (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
}// end - (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
}// end - (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment

- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model
{
}// end - (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model

- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)entityName publicID:(NSString *)publicID systemID:(NSString *)systemID
{
}// end - (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)entityName publicID:(NSString *)publicID systemID:(NSString *)systemID

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{
}// end - (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString

- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value
{
}// end - (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value

- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{
}// end - (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
{
}// end - (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data

- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName
{
}// end - (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName

- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)entityName systemID:(NSString *)systemID
{
	return NULL;
}// end - (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)entityName systemID:(NSString *)systemID
@end
