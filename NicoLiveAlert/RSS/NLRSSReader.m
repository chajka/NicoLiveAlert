//
//  NLRSSReader.m
//  NicoLiveAlert
//
//  Created by Чайка on 7/23/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLRSSReader.h"
#import "HTTPConnection.h"
#import "NicoLiveAlert.h"

@interface NLRSSReader (private)
- (NSDictionary *)makeWatchOwnerList:(NSDictionary *)list;
- (NSString *) ownerNameFromID:(NSString *)ownersID;
@end

@implementation NLRSSReader
@synthesize activePrograms;
@synthesize watchList;
@synthesize watchOfficial;
@synthesize watchChannel;

NSMutableString *stringBuffer;

- (id) init
{
	self = [super init];
	if (self) {
		repeat = YES;
		elementDict = [[NSDictionary alloc] initWithObjectsAndKeys:
			[NSNumber numberWithInteger:indexNameGUID], ElementNameGUID, 
			[NSNumber numberWithInteger:indexNameDate], ElementNameDate, 
			[NSNumber numberWithInteger:indexNameCommuNumber], ElementNameCommuNumber, 
			[NSNumber numberWithInteger:indexNameType], ElementNameType, 
			[NSNumber numberWithInteger:indexNameOwner], ElementNameOwner, nil];
/*
			[NSNumber numberWithInteger:indexNameTitle], ElementNameTitle, 
			[NSNumber numberWithInteger:indexNameDescription], ElementNameDescription, 
			[NSNumber numberWithInteger:indexNameCommuName], ElementNameCommuName, 
*/
		programNumber = nil;
		community = nil;
		ownerName = nil;
		ownerID = nil;
		startTime = nil;
		stringBuffer = nil;
		needPick = NO;
		
	}// end if

	return self;
}// - (id) init

- (void) dealloc
{
#if __has_feature(objc_arc) == 0

	[super dealloc];
#endif
}

- (void) startScnan
{
	[NSThread detachNewThreadSelector:@selector(startScnanAtThread) toTarget:self withObject:nil];
}// end - (void) startScnan

- (void) startScnanAtThread
{
	repeat = YES;
	NSUInteger page = 0;
	ownerList = [[NSDictionary alloc] initWithDictionary:[self makeWatchOwnerList:watchList]];
	while (repeat)
	{
		[NSThread sleepForTimeInterval:0.05];
#if __has_feature(objc_arc)
		@autoreleasepool {
#else
		NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
#endif
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:RSSFeedURLFormat, page++]];
		NSData *rssContents = [NSData dataWithContentsOfURL:url];
		if ([rssContents length] <= RSSNoContentLength)
			repeat = NO;
		if (rssContents == nil)
			break;
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:rssContents];
		[parser setDelegate:self];
		[parser parse];
		
#if __has_feature(objc_arc)
		parser = nil;
		}
#else
		[parser release];
		parser = nil;
		[arp drain];
#endif
	}// end while
#if __has_feature(objc_arc) == 0
	[ownerList release];
#endif
	ownerList = nil;
}// end - (void) startScnanAtThread

#pragma mark -
#pragma mark internal
- (NSDictionary *)makeWatchOwnerList:(NSDictionary *)list
{
	NSMutableDictionary *owners = [NSMutableDictionary dictionary];
	NSMutableDictionary *names = [NSMutableDictionary dictionary];
	NSRange resultRange;
	NSCharacterSet *notOwnerCharset = [NSCharacterSet characterSetWithCharactersInString:NotOwnerCharSet];
	for (NSString *item in [list allKeys])
	{
		resultRange = [item rangeOfCharacterFromSet:notOwnerCharset];
		if (resultRange.length == Zero)
		{
			NSString *ownersName = [self ownerNameFromID:item];
			[names setValue:item forKey:ownersName];
			[owners setValue:[list valueForKey:item] forKey:ownersName];
		}// end if found owner
	}// end foreach watchlist

#if __has_feature(objc_arc) == 0
	[ownerNames release];
#endif
	ownerNames = [[NSDictionary alloc] initWithDictionary:names];
	return [NSDictionary dictionaryWithDictionary:owners];
}// - (NSDictionary *)makeWatchOwnerList:(NSDictionary *)list

- (NSString *) ownerNameFromID:(NSString *)ownersID
{
	OnigRegexp *userNameRegex = [OnigRegexp compile:UserNameCorrectRegex];
	NSError *err = nil;
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:UserNameCorrectFormat, ownersID]];
	NSString *userInfo = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
	OnigResult *result = [userNameRegex search:userInfo];

	if (result != nil)
		return [NSString stringWithString:[result stringAt:1]];
	else
		return ownersID;
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods
- (void) parserDidStartDocument:(NSXMLParser *)parser
{
}// end - (void) parserDidStartDocument:(NSXMLParser *)parser

- (void) parserDidEndDocument:(NSXMLParser *)parser
{
}// end - (void) parserDidEndDocument:(NSXMLParser *)parser

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	needPick = ([[elementDict valueForKey:elementName] integerValue] == 0) ? NO : YES;
	if (needPick == YES)
		stringBuffer = [[NSMutableString alloc] init];
}// end - (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:ElementItemName] == YES)
	{		// check this item is need to notify
		BOOL notify = NO;
		BOOL needOpen = NO;
		BOOL commu = NO;
		BOOL program = NO;
		BOOL owner = NO;
		NSUInteger broadcastKind = 0;
		
		if ([broadcastType isEqualToString:ProgramTypeChannel] == YES)
		{
			broadcastKind = FoundProgramKindChannel;
			if (watchChannel == YES)
				notify = YES;
		}// end if
	
		if ([broadcastType isEqualToString:ProgramTypeOfficial] == YES)
		{
			broadcastKind = FoundProgramKindOfficial;
			if (watchOfficial == YES)
				notify = YES;
		}// end if
		
		if ([watchList valueForKey:programNumber] != nil)
		{
			program = [[watchList valueForKey:programNumber] boolValue];
			needOpen |= program;
			notify = YES;
		}// end if found program
		
		if ([watchList valueForKey:community] != nil)
		{
			commu = [[watchList valueForKey:community] boolValue];
			needOpen |= commu;
			notify = YES;
		}// end if found program
		
		if ([ownerList objectForKey:ownerName] != nil)
		{
			owner = [[ownerList valueForKey:ownerName] boolValue];
			ownerID = [ownerNames objectForKey:ownerName];
			needOpen |= owner;
			notify = YES;
		}// end if found program
		
			// append and notify program
		if (notify == YES)
		{
			NSNumber *autoOpen = [NSNumber numberWithBool:needOpen];
			switch (broadcastKind) {
				case FoundProgramKindOfficial:
					[activePrograms addOfficialProgram:programNumber withDate:startTime autoOpen:autoOpen isOfficial:YES withChannel:nil];
					break;
				case FoundProgramKindChannel:
					[activePrograms addOfficialProgram:programNumber withDate:startTime autoOpen:autoOpen isOfficial:YES withChannel:community];
					break;
				case FoundProgramKindUser:
				default:
					[activePrograms addUserProgram:programNumber withDate:startTime community:community owner:ownerID autoOpen:autoOpen isChannel:NO];
					break;
			}// end switch
		}// end if need notify

			// cleanup variables
#if __has_feature(objc_arc) == 0
		[programNumber release];
		[startTime release];
		[community release];
		[ownerName release];
		[broadcastType release];
#endif
		programNumber = nil;
		startTime = nil;
		community = nil;
		ownerName = nil;
		broadcastType = nil;
	}// end if

	if (needPick == NO)
		return;

	NSInteger element = [[elementDict valueForKey:elementName] integerValue];
	switch (element)
	{
		case indexNameGUID:		// live number
			programNumber = [[NSString alloc] initWithString:stringBuffer];
			break;
		case indexNameDate:		// start time
			startTime = [[NSDate dateWithNaturalLanguageString:stringBuffer locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]] copy];
			break;
		case indexNameCommuNumber:		// community number
			community = [[NSString alloc] initWithString:stringBuffer];
			break;
		case indexNameOwner:			// owner’s nickname
			ownerName = [[NSString alloc] initWithString:stringBuffer];
			break;
		case indexNameType:				// community or other
			broadcastType = [[NSString alloc] initWithString:stringBuffer];
		default:
			break;
	}// end switch
#if __has_feature(objc_arc) == 0
	[stringBuffer release];
#endif
	stringBuffer = nil;
}// end - (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (needPick == YES)
		[stringBuffer appendString:string];
}// end - (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string

- (void) parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue
{
}// end - (void) parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue

- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
}// end - (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError

- (void) parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError
{
}// end - (void) parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError

- (void) parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix
{
}// end - (void) parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix

- (void) parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI
{
}// end - (void) parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI

- (void) parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
}// end - (void) parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock

- (void) parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
}// end - (void) parser:(NSXMLParser *)parser foundComment:(NSString *)comment

- (void) parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model
{
}// end - (void) parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model

- (void) parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)entityName publicID:(NSString *)publicID systemID:(NSString *)systemID
{
}// end - (void) parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)entityName publicID:(NSString *)publicID systemID:(NSString *)systemID

- (void) parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{
}// end - (void) parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString

- (void) parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value
{
}// end - (void) parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value

- (void) parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{
}// end - (void) parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID

- (void) parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
{
}// end - (void) parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data

- (void) parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName
{
}// end - (void) parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName

/*
- (NSData *) parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)entityName systemID:(NSString *)systemID
{
	<#code#>
	return <#value#>;
}// end - (NSData *) parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)entityName systemID:(NSString *)systemID
*/
@end
