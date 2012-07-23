//
//  NLProgram.m
//  NicoLiveAlert
//
//  Created by Чайка on 4/9/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLProgram.h"
#import "NLProgram+Drawing.h"
#import "NLProgram+Parsing.h"
#import "HTTPConnection.h"
#import "Growl/Growl.h"
#import "NicoLiveAlertCollaboration.h"

@interface NLProgram ()
	// construction support methods
- (void) clearAllMember;
- (void) setupEachMember:(NSString *)liveNo;
- (void) checkStartTime:(NSDate *)date forLive:(NSString *)liveNo;
- (NSString *) makeStartString;
- (NSDictionary *)createNotificationDict:(NSString *)liveNo kind:(NSNumber *)kind;
- (void) postPorgramStartNotification:(NSNumber *)autoOpen;
	// activity control method
- (BOOL) isBroadCasting;
- (void) createMenuItem;
- (void) clickProgram:(id)message;
- (void) clickCommunity:(id)message;
- (void) clickOwnerName:(id)message;
	// timer driven methods
- (void) checkBroadcasting:(NSTimer *)theTimer;
	// timer management methods
- (void) stopProgramStatusTimer;
- (void) stopElapsedTimer;
- (void) resetProgramStatusTimer;
- (void) resetElapsedTimer;
@end

@implementation NLProgram
@synthesize menuImage;
@synthesize programMenu;
@synthesize programNumber;
@synthesize communityID;
@synthesize broadcastOwner;
@synthesize isOfficial;
@synthesize broadCasting;
@synthesize info;
@synthesize representedObject;

NSMutableString *dataString;
NSInteger currentElement;
NSDictionary *elementDict;
NSString *embedContent;

#pragma timer constant
static const NSTimeInterval checkActivityCycle = (60.0 * 3);
static const NSTimeInterval elapseCheckCycle = (10.0);

#pragma mark construct / destruct
	// constructor for user program
- (id) initWithProgram:(NSString *)liveNo withDate:(NSDate *)date forAccount:(NLAccount *)account owner:(NSString *)owner autoOpen:(NSNumber *)autoOpen isMine:(BOOL)mine isChannel:(BOOL) isChannel
{
	self = [super init];
	if (self)
	{		// initialize member variables
		[self clearAllMember];
		isMyProgram = mine;
		iconWasValid = NO;
		iconIsValid = NO;
		@try {
			[self checkStartTime:date forLive:liveNo];
			if (isChannel == YES)
			{
				[self parseOfficialProgram];
			}
			else
			{
				broadcastOwner = [owner copy];
				[self parseOwnerNickname:broadcastOwner];
				[self parseProgramInfo:liveNo];
			}// end if program is channel or user
		}
		@catch (NSException *exception) {
			NSLog(@"Catch %@ : %@\n%@", NSStringFromSelector(_cmd), [self class], exception);
#if __has_feature(objc_arc) == 0
			[self dealloc];
#endif
			return nil;
		}
		if (account != nil)
			primaryAccount = [[account nickname] copy];
		else
			primaryAccount = [OriginalWatchList copy];
		[self setupEachMember:liveNo];
		info = [[NSDictionary alloc] initWithDictionary:[self createNotificationDict:liveNo kind:[NSNumber numberWithInteger:(isChannel ? bradcastKindChannel : bradcastKindUser)]]];
		[self postPorgramStartNotification:autoOpen];
		[elapseTimer fire];
		[programStatusTimer fire];
		@try {
			if ([startTime isEqualToDate:date] == YES)
				[self growlProgramNotify:GrowlNotifyStartUserProgram];
			else
				[self growlProgramNotify:GrowlNotifyFoundUserProgram];
		}
		@catch (NSException *exception) {
			NSLog(@"Catch %@ : %@\n%@", NSStringFromSelector(_cmd), [self class], exception);
		}
	}// end if
	return self;
}// end - (id) initWithProgram:(NSString *)liveNo withDate:(NSDate *)date forAccount:(NLAccount *)account owner:(NSString *)owner autoOpen:(NSNumber *)autoOpen isMine:(BOOL)mine isChannel:(BOOL) isChanne

	// constructor for official or channel program
- (id) initWithProgram:(NSString *)liveNo withDate:(NSDate *)date autoOpen:(NSNumber *)autoOpen isOfficial:(BOOL)official withChannel:(NSString *)ch
{
	self = [super init];
	if (self)
	{		// initialize member variables
		[self clearAllMember];
		
		isOfficial = YES;
		iconWasValid = NO;
		iconIsValid = NO;
		channelNumber = [ch copy];
NSLog(@"Channel %@", channelNumber);
		@try {
			[self checkStartTime:date forLive:liveNo];
			[self parseOfficialProgram];
		}
		@catch (NSException *exception) {
			NSLog(@"Catch %@ : %@\n%@", NSStringFromSelector(_cmd), [self class], exception);
#if __has_feature(objc_arc) == 0
			[self dealloc];
#endif
			return nil;
		}
		primaryAccount = [[NSString alloc] initWithString:OfficialTitleString];
		[self setupEachMember:liveNo];
		info = [[NSDictionary alloc] initWithDictionary:[self createNotificationDict:liveNo kind:[NSNumber numberWithInteger:(isOfficial ? bradcastKindOfficial : bradcastKindChannel)]]];
		[self postPorgramStartNotification:autoOpen];
		[elapseTimer fire];
		[programStatusTimer fire];
		if ([startTime isEqualToDate:date] == YES)
			[self growlProgramNotify:GrowlNotifyStartOfficialProgram];
		else
			[self growlProgramNotify:GrowlNotifyFoundOfficialProgram];
	}// end if
	return self;
}// end - (id) initWithOfficial:(NSString *)liveNo


- (void) dealloc
{
	if (isMyProgram == YES)
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:NLNotificationMyBroadcastEnd object:info]];

#if __has_feature(objc_arc) == 0
	if (programMenu != nil)			[programMenu release];
	if (menuImage != nil)			[menuImage release];
	if (thumbnail != nil)			[thumbnail release];
	if (ownerName != nil)			[ownerName release];
	if (background != nil)			[background release];
	if (timeMask != nil)			[timeMask release];
	if (thumbnail != nil)			[thumbnail release];
	if (stringAttributes != nil)	[stringAttributes release];
	if (programNumber != nil)		[programNumber release];
	if (programTitle != nil)		[programTitle release];
	if (programDescription != nil)	[programDescription release];
	if (communityName != nil)		[communityName release];
	if (channelNumber != nil)		[channelNumber release];
	if (primaryAccount != nil)		[primaryAccount release];
	if (communityID != nil)			[communityID release];
	if (broadcastOwner != nil)		[broadcastOwner release];
	if (broadcastOwnerName != nil)	[broadcastOwnerName release];
	if (startTime != nil)			[startTime release];
	if (startTimeString != nil)		[startTimeString release];
	if (programURL != nil)			[programURL release];
	if (info != nil)				[info release];

	if (embedContent != nil)		[embedContent release];

	[super dealloc];
#endif
}// end - (void) dealloc

#pragma mark -
#pragma mark construction support
- (void) clearAllMember
{
	programMenu = nil;
	menuImage = nil;
	thumbnail = nil;
	ownerName = nil;
	background = nil;
	timeMask = nil;
	stringAttributes = nil;
	programNumber = nil;
	programTitle = nil;
	programDescription = nil;
	communityName = nil;
	channelNumber = nil;
	primaryAccount = nil;
	communityID = nil;
	broadcastOwner = nil;
	broadcastOwnerName = nil;
	startTime = nil;
	startTimeString = nil;
	lastMintue = 0;
	localeDict = nil;
	programURL = nil;
	thumbnailURL = nil;
	programStatusTimer = nil;
	elapseTimer = nil;
	center = nil;
	isReservedProgram = NO;
	isOfficial = NO;
	broadCasting = NO;
	info = nil;

	dataString = nil;
	currentElement = 0;
	elementDict = nil;
	embedContent = nil;
}// end - (void) clearAllMember

- (void) setupEachMember:(NSString *)liveNo
{
	programNumber = [liveNo copy];
	localeDict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	center = [NSNotificationCenter defaultCenter];
	startTimeString = [[self makeStartString] copy];

	if (isOfficial == YES)
		[self drawOfficialProgram];
	else
		[self drawUserProgram];
	// end if is official or user.

	if (isMyProgram == YES)
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:NLNotificationMyBroadcastStart object:self]];
	// end if program owner is me or not.
	
	[self createMenuItem];
	[self resetElapsedTimer];
	[self resetProgramStatusTimer];
	broadCasting = YES;
}// end - (void) setupEachMember:(NSString *)liveNo

- (void) checkStartTime:(NSDate *)date forLive:(NSString *)liveNo
{
	OnigRegexp *broadcastTimeRegex = [OnigRegexp compile:ProgStartTimeRegex];
	OnigRegexp *timeSanityRegex = [OnigRegexp compile:ProgSanityRegex];
	NSURL *embedURL = [NSURL URLWithString:[NSString stringWithFormat:STREMEMBEDQUERY, liveNo]];

	NSError *err = nil;
	embedContent = [[NSString alloc] initWithContentsOfURL:embedURL encoding:NSUTF8StringEncoding error:&err];
	if (embedContent == nil)
		@throw [NSException exceptionWithName:EmbedFetchFailed reason:StringIsEmpty userInfo:nil];

	OnigResult *broadcastTime = [broadcastTimeRegex search:embedContent];
	OnigResult *sanityTime = [timeSanityRegex search:[broadcastTime stringAt:1]];

	NSString *dateString = nil;
	if (sanityTime != nil)
		dateString = [NSString stringWithFormat:TimeSanityFormatString, [sanityTime stringAt:1], [sanityTime stringAt:2], [sanityTime stringAt:3]];
	else
		dateString = [broadcastTime stringAt:1];

	NSDate *broadcastDate = [NSDate dateWithNaturalLanguageString:dateString locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
	
	NSTimeInterval diff = [broadcastDate timeIntervalSinceDate:date];
	if (abs((NSInteger)(diff / 60)) == 0)
	{
		startTime = [date copy];
		return;
	}
	else
	{
		NSTimeInterval startUnixTime = [date timeIntervalSince1970] + diff;
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
		startTime = [[NSDate alloc] initWithTimeIntervalSince1970:startUnixTime];
#else
		startTime = [NSDate dateWithTimeIntervalSince1970:startUnixTime];
		[startTime retain];
#endif
		lastMintue = ((NSInteger)([startTime timeIntervalSinceDate:date] / 60)) % 60;
		isReservedProgram = YES;

		return;
	}// endif befor program start

	startTime = [date copy];
	lastMintue = 0;
}// end - (void) checkStartTime:(NSDate *)date forLive:(NSString *)liveNo

- (NSString *) makeStartString
{
	NSString *startString = nil;
	NSUInteger minute = 0;
	if (isReservedProgram == YES)
		minute = abs([[NSDate date] timeIntervalSinceDate:startTime] / 60);
	
	if (isOfficial != YES)
	{		// user program check reserve or not
		if (isReservedProgram == YES)
		{
			NSString *calFromat = [NSString stringWithFormat:ReserveUserTimeFormat, minute];
			startString = [startTime descriptionWithCalendarFormat:calFromat timeZone:nil locale:localeDict];
		}
		else
		{
			startString = [startTime descriptionWithCalendarFormat:StartUserTimeFormat timeZone:nil locale:localeDict];
		}
	}
	else
	{		// official program it must reserved
		if (isReservedProgram == YES)
		{
			NSString *calFromat = [NSString stringWithFormat:ReserveOfficialTimeFormat, minute];
			startString = [startTime descriptionWithCalendarFormat:calFromat timeZone:nil locale:localeDict];
		}
		else
		{
			startString = [startTime descriptionWithCalendarFormat:StartOfficialTimeFormat timeZone:nil locale:localeDict];
		}
	}// end if official or user program

	return startString;
}// end - (NSString *) makeStartString

- (NSDictionary *)createNotificationDict:(NSString *)liveNo kind:(NSNumber *)kind
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setValue:[NSURL URLWithString:[NSString stringWithFormat:PROGRAMURLFORMAT, liveNo]] forKey:ProgramURL];
	[dict setValue:liveNo forKey:LiveNumber];
	[dict setValue:kind forKey:BroadCastKind];

	return [NSDictionary dictionaryWithDictionary:dict];
}// end - (NSMutableDictionary *)createNotificationDict(NSString *)liveNo kind:(NSNumber *)kind

- (void) postPorgramStartNotification:(NSNumber *)autoOpen
{
	[[NSNotificationCenter defaultCenter] postNotificationName:NLNotificationFoundProgram object:autoOpen userInfo:info];
}// end - (void) postPorgramStartNotification:(NSMutableDictionary *)info autoOpen:(NSNumber *)autoOpen

- (BOOL) isEqual:(id)object
{
	if ([object isKindOfClass:[self class]])
	{
		if ([[object programNumber] isEqualToString:programNumber] == YES)
			return YES;
		else
			return NO;
	}
	else if ([object isKindOfClass:[NSString class]])
	{
		if ([programNumber isEqualToString:object] == YES)
			return YES;
		else
			return NO;
	}
	return NO;
}// end - (BOOL) isEqual:(id)object

- (BOOL) isSame:(NLProgram *)program
{
	if (isOfficial == YES)
		return NO;

	if (([[program communityID] isEqualToString:communityID] == YES) &&
		([[program broadcastOwner] isEqualToString:broadcastOwner] == YES))
		return YES;
	else
		return NO;
}// end - (BOOL) isSame:(NLProgram *)program

#pragma mark -
#pragma mark activity control
- (void) terminate
{
	broadCasting = NO;
	[self stopElapsedTimer];
	[self stopProgramStatusTimer];
	if (isMyProgram == YES)
		[center postNotification:[NSNotification notificationWithName:NLNotificationMyBroadcastEnd object:info]];
	[center postNotification:[NSNotification notificationWithName:NLNotificationPorgramEnd object:self]];
}// end - (void) terminate

- (void) suspend
{
	[self resetElapsedTimer];
	[self resetProgramStatusTimer];
}// end - (void) suspend;

- (BOOL) resume
{
	BOOL status = YES;
	if ([self isBroadCasting] == YES)
	{
		[elapseTimer fire];
		[programStatusTimer fire];
	}
	else
	{
		[self stopElapsedTimer];
		[self stopProgramStatusTimer];
		if (isMyProgram == YES)
			[center postNotification:[NSNotification notificationWithName:NLNotificationMyBroadcastEnd object:info]];
		[center postNotification:[NSNotification notificationWithName:NLNotificationPorgramEnd object:self]];
		status = NO;
	}

	return status;
}// end - (void) resume

#pragma mark -
#pragma mark menuItem
- (void) createMenuItem
{
	programMenu = [[NSMenuItem alloc] initWithTitle:@"" action:@selector(openProgram:) keyEquivalent:@""];
	representedObject = [[NSDictionary alloc] initWithObjectsAndKeys:
						 self, keyProgram, programURL, keyLiveNumber, nil];

	NSSize imageSize = [menuImage size];
	NSRect menuItemRect = NSMakeRect(Zero, Zero, imageSize.width + MenuMargineW, imageSize.height + MenuMargineH);
	NSRect programRect = NSMakeRect(Zero, Zero, imageSize.width, imageSize.height);
	NSView *menuItem = [[NSView alloc] initWithFrame:menuItemRect];
	NLClickableImageView *programView = [[NLClickableImageView alloc] initWithFrame:programRect];
	[programView setImage:menuImage];
	[programView setAction:@selector(clickProgram:) toTarget:self];
	[programView setToolTip:programNumber];

	NSRect thumbRect = NSMakeRect(Zero, Zero, thumbnailSize, thumbnailSize);
	NLClickableImageView *thumbView = [[NLClickableImageView alloc] initWithFrame:thumbRect];
	[thumbView setImage:thumbnail];
	if (isOfficial == YES)
	{
		[thumbView setAction:@selector(clickChannel:) toTarget:self];
		if ([channelNumber isEqualToString:ExcludeChannel] == NO)
			[thumbView setRepresentedObject:channelNumber];
		else 
			[thumbView setRepresentedObject:nil];
	}
	else
	{
		[thumbView setAction:@selector(clickCommunity:) toTarget:self];
		[thumbView setRepresentedObject:communityID];
	}
	[thumbView setToolTip:communityID];
	
	if (isOfficial == NO)
	{
		NSSize ownerSize = [ownerName size];
		NSRect ownerRect = NSMakeRect(Zero, Zero, ownerSize.width, ownerSize.height);
		NLClickableImageView *ownerView = [[NLClickableImageView alloc] initWithFrame:ownerRect];
		[ownerView setImage:ownerName];
		[ownerView setAction:@selector(clickOwnerName:) toTarget:self];
		[ownerView setToolTip:broadcastOwner];
		[ownerView setRepresentedObject:broadcastOwner];
		[programView setSubviews:[NSArray arrayWithObjects:thumbView, ownerView, nil]];
		[ownerView setFrameOrigin:NSMakePoint(progOwnerOffsetX, progOwnerOffsetY)];
#if __has_feature(objc_arc) == 0
		[ownerView release];
#endif
	}
	else
	{
		[programView setSubviews:[NSArray arrayWithObject:thumbView]];
	}
	[thumbView setFrameOrigin:NSMakePoint(Zero, Zero)];
	[menuItem setSubviews:[NSArray arrayWithObject:programView]];
	[programView setFrameOrigin:NSMakePoint(menuOffsetX, Zero)];	
	
	[programMenu setView:menuItem];
	[programMenu setEnabled:YES];
	[programMenu setRepresentedObject:representedObject];
#if __has_feature(objc_arc) == 0
	[thumbView release];
	[programView release];
	[menuItem release];
#endif
}// - (void) createMenuItem

- (void) clickProgram:(id)message
{
	id app = [NSApp delegate];
	[app performSelector:@selector(openProgram:) withObject:self];
}// end - (void) clickProgram:(id)message

- (void) clickCommunity:(id)message
{
	if (([message representedObject] == nil) || ([[message representedObject] isEqualToString:@""] == YES))
		[self clickProgram:nil];
	
	NSString *urlstr = [NSString stringWithFormat:URLFormatCommunity, [message representedObject]];
	NSURL *url = [NSURL URLWithString:urlstr];
	[[NSWorkspace sharedWorkspace] openURL:url];
}// end - (void) clickCommunity:(id)message

- (void) clickChannel:(id)message
{
	if (([message representedObject] == nil) || 
		([[message representedObject] isEqualToString:@""] == YES))
	{
		[self clickProgram:nil];
		return;
	}
		
	NSString *urlstr = [NSString stringWithFormat:URLFormatChannel, [message representedObject]];
	NSURL *url = [NSURL URLWithString:urlstr];
	[[NSWorkspace sharedWorkspace] openURL:url];
}// end - (void) clickChannel:(id)message

- (void) clickOwnerName:(id)message
{
	NSString *urlstr = [NSString stringWithFormat:URLFormatUser, [message representedObject]];
	NSURL *url = [NSURL URLWithString:urlstr];
	[[NSWorkspace sharedWorkspace] openURL:url];
}// end - (void) clickOwnerName:(id)message

#pragma mark-
#pragma mark timer driven methods
- (void) checkBroadcasting:(NSTimer*)theTimer
{
	if ([self isBroadCasting] == NO)
	{	// program is done stop each timer and post notification
		broadCasting = NO;
		[self stopElapsedTimer];
		[self stopProgramStatusTimer];
		if (isMyProgram == YES)
			[center postNotification:[NSNotification notificationWithName:NLNotificationMyBroadcastEnd object:info]];
		[center postNotification:[NSNotification notificationWithName:NLNotificationPorgramEnd object:self]];
	}
}// end - (void) checkBroadcasting

- (BOOL) isBroadCasting
{
	NSString *urlStr = [NSString stringWithFormat:STREMEMBEDQUERY, programNumber];
	NSURL *url = [NSURL URLWithString:urlStr];
	NSError *err = nil;
	NSString *embed = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
	if ((err != nil) || ([embed length] == 0))
		return YES;

	OnigRegexp *liveStateRegex = [OnigRegexp compile:ProgStateRegex];
	OnigResult *result = [liveStateRegex search:embed];
	if ((result == nil) ||
		([[result stringAt:1] isEqualToString:DONESTATE] == YES) ||
		([[result stringAt:1] isEqualToString:DONETSSTATE] == YES))
		return NO;
	else
		return YES;
}// end - (BOOL) isBroadCasting:(BOOL)needPost

#pragma mark -
#pragma mark timer management methods
- (void) stopProgramStatusTimer
{		// check timer is running
	if ([programStatusTimer isValid] == YES)
		[programStatusTimer invalidate];
	programStatusTimer = nil;
}// end - (void) stopProgramStatusTimer

- (void) stopElapsedTimer
{		// check timer is running
	if ([elapseTimer isValid] == YES)
		[elapseTimer invalidate];
	elapseTimer = nil;
	
}// end - (void) stopElapsedTimer

- (void) resetProgramStatusTimer
{		// check timer is running
	if ([programStatusTimer isValid] == YES)
		[programStatusTimer invalidate];

		// setup timer object
	programStatusTimer = [NSTimer scheduledTimerWithTimeInterval:checkActivityCycle target:self selector:@selector(checkBroadcasting:) userInfo:nil repeats:YES];
}// end - (void) resetProgramStatusTimer

- (void) resetElapsedTimer
{		// check timer is running
	if ([elapseTimer isValid] == YES)
		[elapseTimer invalidate];

		// setup timer object
	elapseTimer = [NSTimer scheduledTimerWithTimeInterval:elapseCheckCycle target:self selector:@selector(updateElapse:) userInfo:nil repeats:YES];
}// end - (void) resetElapsedTimer

@end
