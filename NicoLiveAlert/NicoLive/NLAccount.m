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

@implementation NLAccount
@synthesize mailaddr;
@synthesize password;
@synthesize nickname;
@synthesize userid;
@synthesize ticket;
@synthesize channels;
@synthesize accountMenu;
@synthesize keychainItem;

	// internal use variables (when initialize only)
NSDictionary	*elements;
NSMutableString	*stringBuffer;
NSUInteger		currentElement;
NSNumber		*notAutoOpen;

#pragma mark construct / destruct
- (id) initWithKeychainAccount:(KCSInternetUser *)keychainAccount
{
	self = [super init];
	if (self)
	{
		keychainItem = keychainAccount;
#if __has_feature(objc_arc) == 0
		[keychainItem retain];
#endif
		mailaddr = [keychainItem account];
		password = [keychainItem password];
		nickname = nil;
		userid = nil;
		channels = nil;
		ticket = nil;
			// initialize connection internal variables
		ticket = nil;
			// initialize internal variable
		elements = [self generateElementDict]; 
#if __has_feature(objc_arc) == 0
		[elements retain];
#endif
		stringBuffer = nil;
		currentElement = 0;
		notAutoOpen = [NSNumber numberWithBool:NO];
		if ([self getLoginTicket] != YES)
		{
#if __has_feature(objc_arc) == 0
			[self dealloc];
#endif
			return nil;
		}// end if getAccountInfo is failed
		if ([self getAccountInfo] != YES)
		{
#if __has_feature(objc_arc) == 0
			[self dealloc];
#endif
			return nil;
		}// end if get Account info was failed
			// cleanup initialize only variables
		[self cleanupInternalVariables];
		[self makeMenuItem];
	}// end if

	return self;
}// - (id) initWithKeychainItem:(KCSInternetUser *)keychainItem

- (id) initWithAccount:(NSString *)account andPassword:(NSString *)pass
{
	self = [super init];
	if (self)
	{		// initialize user information member variables
		keychainItem = nil;
		mailaddr = [account copy];
		password = [pass copy];
		nickname = nil;
		userid = nil;
		channels = nil;
			// initialize connection internal variables
		ticket = nil;
			// initialize internal variable
		elements = [self generateElementDict]; 
#if __has_feature(objc_arc) == 0
		[elements retain];
#endif
		stringBuffer = nil;
		currentElement = 0;
		notAutoOpen = [NSNumber numberWithBool:NO];
		if ([self getLoginTicket] != YES)
		{
#if __has_feature(objc_arc) == 0
			[self dealloc];
#endif
			return nil;
		}// end if getAccountInfo is failed
		if ([self getAccountInfo] != YES)
		{
#if __has_feature(objc_arc) == 0
			[self dealloc];
#endif
			return nil;
		}// end if get Account info was failed
			// cleanup initialize only variables
		[self cleanupInternalVariables];
		[self makeMenuItem];
	}// end if self
	return self;
}// end - (id) initWithAccount:(NSString *)account andPassword:(NSString *)pass

- (id) initOfflineAccount:(NSString *)account andPassword:(NSString *)pass isNickname:(NSString *)nick
{
	self = [super init];
	if (self)
	{
		mailaddr = [account copy];
		password = [pass copy];
		nickname = [nick copy];
		userid = nil;
		channels = nil;
		ticket = nil;
		channels = nil;
		keychainItem = nil;
		[self makeMenuItem];
	}// end if self 
	return self;
}

- (void) dealloc
{
#if __has_feature(objc_arc) == 0
		// cleanup user information variables.
	if (mailaddr != nil)		[mailaddr release];
	if (password != nil)		[password release];
	if (nickname != nil)		[nickname release];
	if (userid != nil)			[userid release];
		// cleanup connection information variables.
	if (ticket != nil)			[ticket release];
	if (channels != nil)		[channels release];
	if (stringBuffer != nil)	[stringBuffer release];
		// cleanup menu item
	if (accountMenu != nil)	[accountMenu release];
		//
	if (keychainItem != nil)	[keychainItem release];

	[super dealloc];
#endif
}// end - (void) dealloc

#pragma mark -
#pragma mark accessor
- (void) makeMenuItem
{
	NSImage *onStateImg = [NSImage imageNamed:@"NLOnState"];
	NSImage *offStateImg = [NSImage imageNamed:@"NLOffStateRed"];
	NSImage *mixedStateImg = [NSImage imageNamed:@"NLMixedState"];
	accountMenu = [[NSMenuItem alloc] initWithTitle:nickname action:@selector(toggleUserState:) keyEquivalent:EMPTYSTRING];
	[accountMenu setOnStateImage:onStateImg];
	[accountMenu setOffStateImage:offStateImg];
	[accountMenu setMixedStateImage:mixedStateImg];
	[accountMenu setRepresentedObject:self];
}// end - (void) makeMenuItem

- (BOOL) changePasswordTo:(NSString *)pass
{
	OSStatus result = -1;
	result = [keychainItem changePasswordTo:pass];

	return (result == noErr) ? YES : NO;
}// end 

- (BOOL) updateAccountInfo
{
	BOOL success = NO;

		// save last values
	NSString			*savedNickname =	nickname;	nickname = nil;
	NSNumber			*savedUserid =		userid;		userid = nil;
	NSString			*savedTicket =		ticket;		ticket = nil;
	NSMutableDictionary *savedChannels =	channels;	channels = nil;
	success = [self getLoginTicket];
	if (success == YES)
		success = [self getAccountInfo];

	if (success == YES)
	{		// cleanup saved values
#if __has_feature(objc_arc) == 0
		if (savedNickname != nil)	[savedNickname release];
		if (savedUserid != nil)	[savedUserid release];
		if (savedTicket != nil)	[savedTicket release];
		if (savedChannels != nil)	[savedChannels release];
#endif
		savedNickname = nil;
		savedUserid = nil;
		savedTicket = nil;
		savedChannels = nil;
	}
	else
	{		// restore saved values
			// cleanup garbage
#if __has_feature(objc_arc) == 0
		if (nickname != nil)	[nickname release];
		if (userid != nil)		[userid release];
		if (ticket != nil)		[ticket release];
		if (channels != nil)	[channels release];
#endif
		nickname = savedNickname;
		userid = savedUserid;
		ticket = savedTicket;
		channels = savedChannels;
	}// end if success or not

	return success;
}// end - (void) updateAccountInfo

#pragma mark -
#pragma mark internal
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
	if (ticket != nil)
	{
		[ticket autorelease];
		ticket = nil;
	}// end cleanup ticket
	
		// clanup elements
	if (elements != nil)
	{		// cleanup elements
		[elements release];
		elements = nil;
	}// end cleanup elements
	
		// cleanup stringBuffer
	if (stringBuffer != nil)
	{
		[stringBuffer release];
		stringBuffer = nil;
	}// end cleanup stringBuffer
#endif
}// end - (void) cleanupInternalVariables

#pragma mark -
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
	NSError *err = nil;
	NSData *response = [loginServer dataByPost:&err];
#if __has_feature(objc_arc) == 0
	[loginServer release];
	loginServer = nil;
#endif
	if ([err code] == noErr)
	{		// start parse for get ticket.
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:response];
		if (parser != nil)
		{
			[parser setDelegate:(id)self];
			@try {
				success = [parser parse];
			}
			@catch (NSException *exception) {
				NSLog(@"Catch %@ : %@\n%@", NSStringFromSelector(_cmd), [self class], exception);
			}// end parse get ticket
#if __has_feature(objc_arc) == 0
			[parser release];
			parser = nil;
#endif
		} // end if not parser allocated.
	}// end if login success
#if __has_feature(objc_arc)
	}
#else
	[arp drain];
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
	NSXMLParser *parser = nil;
		// fetch userdata
	NSURLResponse *resp = nil;
	NSString *userInfoQueryString = [NSString stringWithFormat:ALERTQUERY, ticket];
	NSURL *userInfoQuery = [NSURL URLWithString:userInfoQueryString];
	NSData *response = [HTTPConnection HTTPData:userInfoQuery response:&resp];
	if (response != nil)
	{	// start parse for get user's information from getalertstatus.
		parser = [[NSXMLParser alloc] initWithData:response];
#if __has_feature(objc_arc) == 0
		[parser autorelease];
#endif
		if (parser != nil)
		{
			[parser setDelegate:(id)self];
			@try {
				success = [parser parse];
			}
			@catch (NSException *exception) {
				NSLog(@"Catch %@ : %@\n%@", NSStringFromSelector(_cmd), [self class], exception);
			}// end parse get ticket
		} // end if not parser allocated.
	} // end if no response
#if __has_feature(objc_arc)
	}
#else
	[arp drain];
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
		if (stringBuffer != nil)
		{
			[stringBuffer autorelease];
			stringBuffer = nil;
		}// end if release old string buffer
#endif
		stringBuffer = [[NSMutableString alloc] init];
	}// end if known and required element

}// end - (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	NSString *channel = nil;
	switch ([[elements valueForKey:elementName] integerValue])
	{
		case indexTicket:
			ticket = [[NSString alloc] initWithString:stringBuffer];
			break;
		case indexUserID:
			userid = [[NSNumber alloc] initWithUnsignedInteger:[stringBuffer integerValue]];
			break;
		case indexUserName:
			nickname = [[NSString alloc] initWithString:stringBuffer];
			break;
		case indexCommunity:
			channel = [NSString stringWithString:stringBuffer];
			[channels setValue:notAutoOpen forKey:channel];
			break;
		default:
			break;
	}// end switch

#if __has_feature(objc_arc) == 0
	if (stringBuffer != nil)
	{
		[stringBuffer autorelease];
		stringBuffer = nil;
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
	return nil;
}// end - (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)entityName systemID:(NSString *)systemID
@end
