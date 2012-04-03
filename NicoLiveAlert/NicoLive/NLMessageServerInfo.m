//
//  NLMessageServerInfo.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/31/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLMessageServerInfo.h"
#import "NicoLiveAlertDefinitions.h"

@interface NLMessageServerInfo ()
- (BOOL) parseMessageServerData;
- (void) elementDictonary;
@end

#pragma mark -
#pragma mark tempraly variables
NSDictionary	*elementDict;
NSMutableString *contentStr;
NSUInteger		currentElement;

@implementation NLMessageServerInfo
@synthesize serveName;
@synthesize port;
@synthesize thread;
#pragma mark -
#pragma mark constructor / destructor
- (id) init
{
	self = [super init];
	if (self)
	{
		[self elementDictonary];
		contentStr = NULL;
		currentElement = 0;
		if ([self parseMessageServerData] == NO)
		{
#if __has_feature(objc_arc) == 0
			[self dealloc];
#endif
			return NULL;
		}// end if get message server information was failed
	}// end if self
	return self;
}// end - (id) init

- (void) dealloc
{
#if __has_feature(objc_arc) == 0
    if (serveName != NULL) {	[serveName release]; }
	if (thread != NULL) {		[thread release]; }
    [super dealloc];
#endif
}// end - (void) dealloc

#pragma mark -
#pragma mark constructor support
- (BOOL) parseMessageServerData
{
	BOOL success = NO;
#if __has_feature(objc_arc)
	@autoreleasepool {
#else
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#endif
	NSURL *alrtinfoURL = [NSURL URLWithString:MSQUERYAPI];
	NSURLResponse *resp = NULL;
	NSData *alertInfo = [HTTPConnection HTTPData:alrtinfoURL response:&resp];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:alertInfo];
	[parser setDelegate:self];
	@try {
		success = [parser parse];		
	}
	@catch (NSException *exception) {
		success = NO;
	}// end try parse
#if __has_feature(objc_arc)
	}
#else
	[parser release];
	[pool release];
#endif
	return success;
}// end - (BOOL) getMessageServer

- (void) elementDictonary
{
	elementDict = [NSDictionary dictionaryWithObjectsAndKeys:
	  [NSNumber numberWithInteger:elementIndexResponse], elementKeyResponse,
	  [NSNumber numberWithInteger:elementIndexStatus], elementKeyStatus,
	  [NSNumber numberWithInteger:elementIndexAddress], elementKeyAddress, 
	  [NSNumber numberWithInteger:elementIndexPort], elementKeyPort, 
	  [NSNumber numberWithInteger:elementIndexThread], elementKeyThread,
	  nil];
}// end - (NSDictionary *) contentDictonary

#pragma mark -
#pragma mark XMLParserDelegate methods
#pragma mark NSXMLParserDelegate methods
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
}// end - (void)parserDidStartDocument:(NSXMLParser *)parser

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}// end - (void)parserDidEndDocument:(NSXMLParser *)parser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	currentElement = [[elementDict valueForKey:elementName] integerValue];
	if (currentElement == elementIndexResponse)
		if ([[attributeDict valueForKey:keyXMLStatus] isEqualToString:resultOK] != YES)
		   @throw [NSException exceptionWithName:RESULTERRORNAME reason:RESULTERRORREASON userInfo:attributeDict];
		// end if result is not OK
	// end if element is server response
	
	if (currentElement != 0)
		contentStr = [NSMutableString string];
	// end if required element
}// end - (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	switch ([[elementDict valueForKey:elementName] integerValue])
	{
		case elementIndexAddress:
			serveName = [[NSString alloc] initWithString:contentStr];
			break;
		case elementIndexPort:
			port = [contentStr integerValue];
			break;
		case elementIndexThread:
			thread = [[NSString alloc] initWithString:contentStr];
			break;
		default:
			break;
	}// end switch
}// end - (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (currentElement != 0)
		[contentStr appendString:string];
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
