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
- (BOOL) getLoginTicket;
- (BOOL) getAccountInfo;
@end

// connection information member variables
NSString			*ticket;

	// internal use variables (when initialize only)
NSDictionary		*elements;
NSMutableString	*stringBuffer;
NSUInteger		currentElement;
NSNumber		*notAutoOpen;

@implementation NLAccount
@synthesize mailaddr;
@synthesize password;
@synthesize username;
@synthesize userid;
@synthesize channels;

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
		channels = NULL;
			// initialize connection internal variables
		ticket = NULL;
			// initialize internal variable
		elements = [self generateElementDict]; 
#if __has_feature(objc_arc) == 0
		[elements retain];
#endif
		stringBuffer = NULL;
		currentElement = 0;
		notAutoOpen = [NSNumber numberWithBool:NO];
		if ([self getLoginTicket] != YES)
		{
#if __has_feature(objc_arc) == 0
			[self dealloc];
#endif
			return NULL;
		}// end if getAccountInfo is failed
		if ([self getAccountInfo] != YES)
		{
#if __has_feature(objc_arc) == 0
			[self dealloc];
#endif
			return NULL;
		}// end if get Account info was failed
			// cleanup initialize only variables
		[self cleanupInternalVariables];
	}// end if self
	return self;
}// end - (id) initWithAccount:(NSString *)account andPassword:(NSString *)pass

- (void) dealloc
{
#if __has_feature(objc_arc) == 0
		// cleanup user information variables.
	if (mailaddr != NULL)		[mailaddr release];
	if (password != NULL)		[password release];
	if (username != NULL)		[username release];
	if (userid != NULL)			[userid release];
		// cleanup connection information variables.
	if (ticket != NULL)			[ticket release];
	if (channels != NULL)		[channels release];
	if (stringBuffer != NULL)	[stringBuffer release];

	[super dealloc];
#endif
}// end - (void) dealloc

#pragma mark constructor support
- (NSDictionary *) generateElementDict
{
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInteger:indexResponse], elementKeyResponse,
		[NSNumber numberWithInteger:indexTicket], elementKeyTicket,
		[NSNumber numberWithInteger:indexStatus], elementKeyStatus,
		[NSNumber numberWithInteger:indexUserID], elementKeyUserID, 
		[NSNumber numberWithInteger:indexUserName], elementKeyUserName, 
		[NSNumber numberWithInteger:indexCommunity], elementKeyCommunity, 
	nil];

	return dict;
}// end - (NSDictionary *) generateElementDict

- (void) cleanupInternalVariables
{		// clanup login ticket
#if __has_feature(objc_arc) == 0
	if (ticket != NULL)
	{
		[ticket autorelease];
		ticket = NULL;
	}// end cleanup ticket

		// clanup elements
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

- (BOOL) getLoginTicket
{
	BOOL success = NO;
#if __has_feature(objc_arc)
	@autoreleasepool {
#else
	NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
#endif
	// login and get ticket
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
	// start parse for get ticket.
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:response];
#if __has_feature(objc_arc) == 0
	[parser autorelease];
#endif
	if (parser == NULL)
		return success;
	// end if not parser allocated.
	[parser setDelegate:(id)self];
	@try {
		success = [parser parse];
	}
	@catch (NSException *exception) {
		return success;
	}// end parse get ticket
#if __has_feature(objc_arc)
	}
#else
	[arp release];
#endif
	return success;
}// end - (BOOL) getLoginTicket

- (BOOL) getAccountInfo
{
	BOOL success = NO;
#if __has_feature(objc_arc)
	@autoreleasepool {
#else
	NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
#endif
	NSXMLParser *parser = NULL;
		// fetch userdata
	NSURLResponse *resp = NULL;
	NSString *userInfoQueryString = [NSString stringWithFormat:ALERTQUERY, ticket];
	NSURL *userInfoQuery = [NSURL URLWithString:userInfoQueryString];
	NSData *response = [HTTPConnection HTTPData:userInfoQuery response:&resp];
	if (response == NULL)
		return success;
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
	@try {
		success = [parser parse];
	}
	@catch (NSException *exception) {
		return success;
	}// end parse get ticket
#if __has_feature(objc_arc)
	}
#else
	[arp release];
#endif
	return success;
}// end - (void) getAccountInfo

#pragma mark -
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
	if ((indexResponse == currentElement) || (indexStatus == currentElement))
	{
		if ([[attributeDict valueForKey:keyXMLStatus] isEqualToString:resultOK] != YES)
			@throw [NSException exceptionWithName:RESULTERRORNAME reason:RESULTERRORREASON userInfo:attributeDict];
		// end if status attribute is not OK
			// allocate channels dictionary
		if (indexStatus == currentElement)
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
		case indexTicket:
			ticket = [[NSString alloc] initWithString:stringBuffer];
			break;
		case indexUserID:
			uid = [stringBuffer integerValue];
			userid = [[NSNumber alloc] initWithUnsignedInteger:uid];
			break;
		case indexUserName:
			username = [[NSString alloc] initWithString:stringBuffer];
			break;
		case indexCommunity:
			channel = [NSString stringWithString:stringBuffer];
			[channels setValue:notAutoOpen forKey:channel];
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
