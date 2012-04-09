//
//  NLProgramList.m
//  NicoLiveAlert
//
//  Created by Чайка on 4/4/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLProgramList.h"

@interface NLProgramList ()
- (void) checkProgram:(NSString *)progInfo;
- (void) checkConnectionActive;
@end

@implementation NLProgramList
@synthesize watchList;
@synthesize watchOfficial;

- (id) init
{
	self = [super init];
	if (self)
	{
		programListSocket = NULL;
		watchList = NULL;
		serverInfo = NULL;
		lastTime = NULL;
		aliveMonitor = NULL;
		dataBuffer = NULL;
		sendrequest = NO;
		isOfficial = NO;
	}// end if self
	return self;
}// end - (id) init

- (BOOL) startListen
{
	BOOL success = NO;
	serverInfo = [[NLMessageServerInfo alloc] init];
	if (serverInfo == NULL)
		return success;
	// end if cannot correct server information.

	programListSocket = [[SocketConnection alloc] initWithServer:[serverInfo serveName] andPort:[serverInfo port] direction:SCDirectionBoth];
	[programListSocket setStreamEventDelegate:self];
	success = [programListSocket connect];
	aliveMonitor = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(checkConnectionActive) userInfo:NULL repeats:YES];
	[aliveMonitor fire];

	return success;
}// end - (void) startListen

- (void) stopListen
{
	[aliveMonitor invalidate];
	if (programListSocket == NULL)
		return;
	// end if not connection

	[programListSocket disconnect];
}// end - (void) stopListen

#pragma mark -
#pragma mark internal
- (void) checkProgram:(NSString *)progInfo
{
	NSArray *program = [progInfo componentsSeparatedByString:dataSeparator];
	if (([program count] == 2) || ([[program objectAtIndex:offsetCommuCh] isEqualToString:liveOfficialString] == YES))
		NSLog(@"%@", progInfo);

	for (NSString *prog in program)
	{		// process official
		if (isOfficial)
		{
			NSLog(@"%@", progInfo);
			isOfficial = NO;
		}// end is Official
			// check official
		if ((watchOfficial == YES) && ([prog isEqualToString:liveOfficialString] == YES))
			isOfficial = YES;
		if ([watchList valueForKey:prog] != NULL)
			NSLog(@"%@", progInfo);
	}// end for
}// end - (void) checkProgram:(NSString *)progInfo

- (void) checkConnectionActive
{
	NSTimeInterval diff = [lastTime timeIntervalSinceNow];
	if (diff < -disconnectionInterval)
		NSLog(@"%lf", diff);
}// end - (void) checkConnectionActive

#pragma mark -
#pragma mark StreamEventDelegate
NSMutableData *dataBuffer;
- (void) streamEventHasBytesAvailable:(NSStream *)stream
{
	NSInputStream *iStream = (NSInputStream *)stream;
	uint8_t oneByte;
	NSUInteger actuallyRead = 0;
	if (dataBuffer == NULL)
		dataBuffer = [[NSMutableData alloc] init];
	// end if data buffer is cleard

	actuallyRead = [iStream read:&oneByte maxLength:1U];
	if (actuallyRead == 1)
		[dataBuffer appendBytes:&oneByte length:1];
	// end if read

		// check databyte is not terminator
	if (oneByte != '\0')
		return;

#if __has_feature(objc_arc)
	@autoreleasepool {
#else
	NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
	if (lastTime != NULL)
		[lastTime release];
#endif


		// store last data recieve time;
	lastTime = [[NSDate alloc] init];
		// databyte is terminator
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:dataBuffer];
	[parser setDelegate:self];
	[parser parse];
#if __has_feature(objc_arc)
	}
#else
	[parser release];
	[dataBuffer release];
	[arp release];
#endif
	dataBuffer = NULL;
}// end - (void) NSStreamEventHasBytesAvailable:(NSStream *)stream

BOOL sendrequest;
- (void) streamEventHasSpaceAvailable:(NSStream *)stream
{
	if ((sendrequest == NO) && ([programListSocket isOutputStream:stream] == YES))
	{
		NSInteger byteToWrite = 0;
		NSString *request = [NSString stringWithFormat:REQUESTFORMAT,[serverInfo thread]];
		byteToWrite = [(NSOutputStream *)stream write:(uint8_t *)[request UTF8String] maxLength:[request length]];
		
		if (byteToWrite == [request length])
			sendrequest = YES;
	}
}// end - (void) streamEventHasSpaceAvailable:(NSStream *)stream

- (void) streamEventErrorOccurred:(NSStream *)stream
{
	NSLog(@"streamEventErrorOccurred: : %@", stream);
}// end - (void) streamEventErrorOccurred:(NSStream *)stream

#pragma mark StreamEventDelegate (optional)
- (void) streamEventOpenCompleted:(NSStream *)stream
{
	NSLog(@"streamEventOpenCompleted: : %@", stream);
}// end - (void) streamEventOpenCompleted:(NSStream *)stream

- (void) streamEventEndEncountered:(NSStream *)stream
{
	NSLog(@"streamEventEndEncountered: : %@", stream);
}// end - (void) streamEventEndEncountered:(NSStream *)stream

- (void) streamEventNone:(NSStream *)stream
{
	NSLog(@"streamEventNone: : %@", stream);
}// end - (void) streamEventNone:(NSStream *)stream

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
}// end - (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
}// end - (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	NSString *progInfo = [NSString stringWithFormat:liveNoAppendFormat, string];
	[self checkProgram:progInfo];
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
