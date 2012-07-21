//
//  NLProgram+Parsing.m
//  NicoLiveAlert
//
//  Created by Чайка on 7/20/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLProgram+Parsing.h"
#import "NLProgram+Drawing.h"
#import "NicoLiveAlertDefinitions.h"

@implementation NLProgram (Parsing)

- (NSDictionary *) elementDict
{
	NSDictionary *elementDict = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInteger:indexStreaminfo], elementStreaminfo,
			[NSNumber numberWithInteger:indexRequestID], elementRequestID,
			[NSNumber numberWithInteger:indexTitle], elementTitle,
			[NSNumber numberWithInteger:indexDescription], elementDescription,
			[NSNumber numberWithInteger:indexComuName], elementComuName,
			[NSNumber numberWithInteger:indexComuID], elementComuID,
			[NSNumber numberWithInteger:indexThumbnail], elementThumbnail, 
			[NSNumber numberWithInteger:indexNickname], elementNickname, nil];
	
	return elementDict;
}// end - (NSDictionary *) elementDict

- (void) parseOfficialProgram
{
	OnigRegexp *titleRegex = [OnigRegexp compile:ProgramTitleRegex];
	OnigRegexp *imgRegex = [OnigRegexp compile:ThumbImageRegex];
	OnigRegexp *programRegex = [OnigRegexp compile:ProgramURLRegex];
	OnigResult *result = nil;
	
	result = [titleRegex search:embedContent];
	if (result == nil)
		@throw [NSException exceptionWithName:EmbedParseFailed reason:ProgramTitleCollectFail userInfo:[NSDictionary dictionaryWithObject:embedContent forKey:@"embedContent"]];
	programTitle = [[NSString alloc] initWithString:[result stringAt:1]];
	
	result = [imgRegex search:embedContent];
	if (result == nil)
		@throw [NSException exceptionWithName:EmbedParseFailed reason:ImageURLCollectFail userInfo:[NSDictionary dictionaryWithObject:embedContent forKey:@"embedContent"]];
	thumbnail = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[result stringAt:1]]];
	if ([thumbnail isValid] == YES)
	{
		[thumbnail setSize:NSMakeSize(thumbnailSize, thumbnailSize)];
		iconWasValid = YES;
		iconIsValid = YES;
	}
	else
	{
#if __has_feature(objc_arc) == 0
		[thumbnail release];
#endif
		thumbnail = nil;
		thumbnailURL = [[NSURL alloc] initWithString:[result stringAt:1]];
	}
	
	result = [programRegex search:embedContent];
	if (result == nil)
		@throw [NSException exceptionWithName:EmbedParseFailed reason:ProgramURLCollectFail userInfo:[NSDictionary dictionaryWithObject:embedContent forKey:@"embedContent"]];
	programURL = [[NSString alloc] initWithString:[result stringAt:1]];
#if __has_feature(objc_arc) == 0
	[embedContent release];
	embedContent = nil;
#endif
}// end - (void) parseOfficialProgram

- (void) parseProgramInfo:(NSString *)liveNo
{
#if __has_feature(objc_arc) == 0
	if (embedContent != nil)	[embedContent release];
	embedContent = nil;
#endif
	BOOL success = NO;
	NSXMLParser *parser = nil;
#if __has_feature(objc_arc)
	@autoreleasepool {
#else
		NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
#endif
		elementDict = [self elementDict];
		NSString *streamQueryURL = [NSString stringWithFormat:STREAMINFOQUERY, liveNo];
		NSURL *queryURL = [NSURL URLWithString:streamQueryURL];
		NSData *response = [[NSData alloc] initWithContentsOfURL:queryURL];
		parser = [[NSXMLParser alloc] initWithData:response];
		if (parser != nil)
		{
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
			[parser setDelegate:self];
#else
			[parser setDelegate:(id)self];
#endif
			@try {
				success = [parser parse];
			}
			@catch (NSException *exception) {
				NSLog(@"Catch %@ : %@\n%@", NSStringFromSelector(_cmd), [self class], exception);
			}// end exception handling
		}// end if parser is allocated
#if __has_feature(objc_arc)
	}
#else
	[response release];
	[parser release];
	[arp drain];
#endif
	if (success != YES)
		@throw [NSException exceptionWithName:StreamInforFetchFaild reason:UserProgXMLParseFail userInfo:nil];
}// end - (BOOL) parseProgramInfo:(NSString *)urlString

- (void) parseOwnerNickname:(NSString *)owner
{
#if __has_feature(objc_arc)
	@autoreleasepool {
#else
		NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
#endif
		elementDict = [self elementDict];
		NSError *err;
		NSString *nicknameQueryURL = [NSString stringWithFormat:NICKNAMEQUERY, owner];
		NSURL *queryURL = [NSURL URLWithString:nicknameQueryURL];
		NSString *nicknameXML = [NSString stringWithContentsOfURL:queryURL encoding:NSUTF8StringEncoding error:&err];
		OnigRegexp *nicknameRegex = [OnigRegexp compile:NicknameRegex];
		OnigResult *nicknameResult = [nicknameRegex search:nicknameXML];
		if (nicknameResult != nil)
			broadcastOwnerName = [[NSString alloc] initWithString:[nicknameResult stringAt:1]];
		else
			broadcastOwnerName = [[NSString alloc] initWithString:owner];
			// end if
#if __has_feature(objc_arc)
	}
#else
	[arp drain];
#endif
}// end - (void) parseOwnerNickname:(NSString *)owner

#pragma mark -
#pragma mark NSXMLParserDelegate methods
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
}// end - (void)parserDidStartDocument:(NSXMLParser *)parser

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}// end - (void)parserDidEndDocument:(NSXMLParser *)parser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:elementStreaminfo] == YES)
		if ([[attributeDict valueForKey:keyXMLStatus] isEqualToString:resultOK] == NO)
			@throw [NSException exceptionWithName:RESULTERRORNAME reason:RESULTERRORREASON userInfo:attributeDict];
		// end if result is not ok
	// end if element is status
	
	currentElement = [[elementDict valueForKey:elementName] integerValue];
	if (currentElement != 0)
		dataString = [NSMutableString string];
	// end if
}// end - (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
	NSError *err = nil;
#endif
	NSData *thumbData = nil;
	switch (currentElement) {
		case indexRequestID:
			programURL = [[NSString alloc] initWithString:[NSString stringWithFormat:PROGRAMURLFORMAT, dataString]];
			break;
		case indexTitle:
			programTitle = [[NSString alloc] initWithString:dataString];
			break;
		case indexDescription:
			programDescription = [[NSString alloc] initWithString:dataString];
			break;
		case indexComuName:
			if (communityName == nil)
				communityName = [[NSString alloc] initWithString:dataString];
			break;
		case indexComuID:
			communityID = [[NSString alloc] initWithString:dataString];
			break;
		case indexThumbnail:
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
			thumbData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dataString] options:NSDataReadingUncached error:&err];
#else
			thumbData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dataString]];
#endif
			thumbnail = [[NSImage alloc] initWithData:thumbData];
			if ([thumbnail isValid] == YES)
			{
				[thumbnail setSize:NSMakeSize(thumbnailSize, thumbnailSize)];
				iconWasValid = YES;
				iconIsValid = YES;
			}
			else
			{	// retry fetch image
#if __has_feature(objc_arc) == 0
				[thumbnail release];
#endif
				thumbnail = nil;
				thumbnailURL = [[NSURL alloc] initWithString:dataString];
				
			}
			break;
		case indexNickname:
			broadcastOwnerName = [[NSString alloc] initWithString:dataString];
			break;
		default:
			break;
	}
}// end - (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	[dataString appendString:string];
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
/*
 - (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)entityName systemID:(NSString *)systemID
 {
 return nil;
 }// end - (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)entityName systemID:(NSString *)systemID
 */
@end
