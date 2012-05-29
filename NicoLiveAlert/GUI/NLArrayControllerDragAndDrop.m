//
//  NLArrayControllerDragAndDrop.m
//  NicoLiveAlert
//
//  Created by Чайка on 4/25/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLArrayControllerDragAndDrop.h"
#import "LinkTextFieldCell.h"
#import "NicoLiveAlertDefinitions.h"

#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
@interface NLArrayControllerDragAndDrop ()
#pragma mark watchlist
- (BOOL) watchTableAcceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation;
- (NSDragOperation) watchTableValidateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation;
- (BOOL) watchTableWriteRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard;
#pragma mark account
- (BOOL) accountTableAcceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operatio;
- (NSDragOperation) accountTableValidateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation;
- (BOOL) accountTableWriteRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard;
#pragma mark launcher
- (BOOL) launchTableAcceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operatio;
- (NSDragOperation) launchTableValidateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation;
- (BOOL) launchTableWriteRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard;
@end
#endif

@implementation NLArrayControllerDragAndDrop
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
@synthesize watchListTable;
@synthesize accountInfoTable;
@synthesize launchListTable;

- (id)init
{
	self = [super init];
	if (self)
	{
		watchListTable = nil;
		launchListTable = nil;
	}
	return self;
}// end - (id)init

- (void) dealloc
{
#if __has_feature(objc_arc) == 0
	if (watchListTable != nil)		[watchListTable release];
	if (launchListTable != nil)	[launchListTable release];

	[super dealloc];
#endif
}// end - (void) dealloc

#pragma mark callback
- (void) animationEffectDidEnd:(void *)contextInfo
{
	NSPasteboard *pb = [NSPasteboard pasteboardWithName:NSDragPboard];
	NSArray *pbItems = [pb pasteboardItems];
	NSData *pbData;
	NSDictionary *pbTableItem;
	for (NSPasteboardItem *pbItem in pbItems)
	{
		pbData = [pbItem dataForType:LauncherPasteboardType];
		if ([pbData length] != 0)
		{
			pbTableItem = [NSUnarchiver unarchiveObjectWithData:pbData];
			for (NSDictionary *tableItem in [self arrangedObjects])
			{
				if ([[tableItem objectForKey:keyLauncherAppPath] isEqualToString:[pbTableItem objectForKey:keyLauncherAppPath]] == YES)
				{
					[self removeObject:tableItem];
					break;
				}// end if
			}// end for each arrangedObjects
		}// end if pasteboard item not empty
	}// end for each pasteboard Item
	[pb clearContents];
}// end - (void) animationEffectDidEnd:(void *)contextInfo

#pragma mark -
#pragma mark TableViewDelegate
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([cell isKindOfClass:[LinkTextFieldCell class]]) {
        LinkTextFieldCell *linkCell = (LinkTextFieldCell *)cell;
			// Setup the work to be done when a link is clicked
        linkCell.linkClickedHandler = ^(NSURL *url, id sender) {
            [[NSWorkspace sharedWorkspace] openURL:url];
        };
    }// endif
}// end - (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  aTableView, KeyTableView, 
						  [NSNumber numberWithInteger:rowIndex], keyRow, nil];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:NLNotificationSelectRow object:dict]];
	return YES;
}// end - (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex

#pragma mark -
#pragma mark NSTableViewDataSource
- (BOOL) tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
	BOOL dropped = NO;

	if (aTableView == watchListTable)
		dropped = [self watchTableAcceptDrop:info row:row dropOperation:operation];
	// end if table is watchlist

	if (aTableView == accountInfoTable)
		dropped = [self accountTableAcceptDrop:info row:row dropOperation:operation];
	// end if table is watchlist
	
	if (aTableView == launchListTable)
		dropped = [self launchTableAcceptDrop:info row:row dropOperation:operation];
	// end if table is launchlist

	return dropped;
}// end - (BOOL) tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
	NSDragOperation validate = NSDragOperationNone;

	if (aTableView == watchListTable)
		validate = [self watchTableValidateDrop:info proposedRow:row proposedDropOperation:operation];
	// end if table is watchlist

	if (aTableView == accountInfoTable)
		validate = [self accountTableValidateDrop:info proposedRow:row proposedDropOperation:operation];
	// end if table is watchlist
	
	if (aTableView == launchListTable)
		validate = [self launchTableValidateDrop:info proposedRow:row proposedDropOperation:operation];
	// end if table is launchlist

	return validate;
}// end - (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation

- (BOOL) tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
	BOOL success = NO;

	if (aTableView == watchListTable)
		success = [self watchTableWriteRowsWithIndexes:rowIndexes toPasteboard:pboard];
	// end if table is watchlist

	if (aTableView == accountInfoTable)
		success = [self accountTableWriteRowsWithIndexes:rowIndexes toPasteboard:pboard];
	// end if table is watchlist
	
	if (aTableView == launchListTable)
		success = [self launchTableWriteRowsWithIndexes:rowIndexes toPasteboard:pboard];

	return success;
}// end - (BOOL) tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard

#pragma mark -
#pragma mark internal
#pragma mark -
#pragma mark watchItem
- (BOOL) watchTableAcceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
	NSPasteboard *pb = [info draggingPasteboard];
	NSArray *pbItems = [pb pasteboardItems];
	if ([pbItems count] == 1)
	{
		NSData *data = [[pbItems lastObject] dataForType:WatchListPasteboardType];
		NSIndexSet *indexes = [NSUnarchiver unarchiveObjectWithData:data];
		NSArray *watchLists = [[self arrangedObjects] objectsAtIndexes:indexes];
		NSRange insert = NSMakeRange(row, [watchLists count]);
		[self removeObjects:watchLists];
		@try {
			[self insertObjects:watchLists atArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:insert]];
		}
		@catch (NSException *exception) {
			[self addObjects:watchLists];
		}
	}
	return YES;
}// end - (BOOL) watchTableAcceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation

- (NSDragOperation) watchTableValidateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
	BOOL foudWathList = NO;
	NSPasteboard *pb = [info draggingPasteboard];
	NSArray *pbItems = [pb pasteboardItems];
	NSArray *types;
	for (NSPasteboardItem *pbItem in pbItems)
	{
		types = [pbItem types];
		for (NSString *type in types)
		{
			if ([type isEqualToString:WatchListPasteboardType] == YES)
				foudWathList = YES;
		}// end for each pasteboard item
	}// end for each pasteboard
	
	if (foudWathList)
		return NSDragOperationMove;
	else
		return NSDragOperationNone;
}// end - (NSDragOperation) watchTableValidateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation

- (BOOL) watchTableWriteRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
	[pboard clearContents];
	NSData *pbData = [NSArchiver archivedDataWithRootObject:rowIndexes];
	[pboard setData:pbData forType:WatchListPasteboardType];
	
	return YES;
}// end - (BOOL) watchTableWriteRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard

#pragma mark -
#pragma mark account item
- (BOOL) accountTableAcceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
	NSPasteboard *pb = [info draggingPasteboard];
	NSArray *pbItems = [pb pasteboardItems];
	if ([pbItems count] == 1)
	{
		NSData *data = [[pbItems lastObject] dataForType:AccountListPasteboardType];
		NSIndexSet *indexes = [NSUnarchiver unarchiveObjectWithData:data];
		NSArray *watchLists = [[self arrangedObjects] objectsAtIndexes:indexes];
		NSRange insert = NSMakeRange(row, [watchLists count]);
		[self removeObjects:watchLists];
		@try {
			[self insertObjects:watchLists atArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:insert]];
		}
		@catch (NSException *exception) {
			[self addObjects:watchLists];
		}
	}
	return YES;
}// end - (BOOL) accountTableAcceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation

- (NSDragOperation) accountTableValidateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
	BOOL foudWathList = NO;
	NSPasteboard *pb = [info draggingPasteboard];
	NSArray *pbItems = [pb pasteboardItems];
	NSArray *types;
	for (NSPasteboardItem *pbItem in pbItems)
	{
		types = [pbItem types];
		for (NSString *type in types)
		{
			if ([type isEqualToString:AccountListPasteboardType] == YES)
				foudWathList = YES;
		}// end for each pasteboard item
	}// end for each pasteboard
	
	if (foudWathList)
		return NSDragOperationMove;
	else
		return NSDragOperationNone;
}// end - (NSDragOperation) accountTableValidateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation

- (BOOL) accountTableWriteRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
	[pboard clearContents];
	NSData *pbData = [NSArchiver archivedDataWithRootObject:rowIndexes];
	[pboard setData:pbData forType:AccountListPasteboardType];
	
	return YES;
}// end - (BOOL) accountTableWriteRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard

#pragma mark -
#pragma mark lauchItem
- (BOOL) launchTableAcceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operatio
{
	BOOL dropped = NO;
	NSPasteboard *pasteboard = [info draggingPasteboard];
	NSArray *pasteboardItems = [pasteboard pasteboardItems];
	NSArray *types = nil;
	for (NSPasteboard *item in pasteboardItems)
	{
		types = [item types];
		for (NSString *type in types)
		{
			if ([type isEqualToString:LauncherPasteboardType] == YES)
			{
				NSData *data = [item dataForType:LauncherPasteboardType];
				NSDictionary *dict = [NSUnarchiver unarchiveObjectWithData:data];
				NSUInteger i = 0;
				for (NSDictionary *tmpdict in [self arrangedObjects])
				{
					if ([[tmpdict objectForKey:keyLauncherAppPath] isEqualToString:[dict objectForKey:keyLauncherAppPath]])
					{// drag move
						if (i < row)
							row --;
						[self removeObject:tmpdict];
						break;
					}// end if
					i++;
				}
				[self insertObject:dict atArrangedObjectIndex:row++];
				dropped = YES;
			}// end if
			if ([type isEqualToString:@"public.file-url"] == YES)
			{
				NSData *data = [item dataForType:@"public.file-url"];
				NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
				NSURL *fileURL = [NSURL URLWithString:dataString];
#if __has_feature(objc_arc) == 0
				[dataString release];
#endif
				NSString *fullpath = [fileURL path];
				NSFileManager *fm = [NSFileManager defaultManager];
				NSString *appname = [fm displayNameAtPath:fullpath];
				NSWorkspace *ws = [NSWorkspace sharedWorkspace];
				NSImage *icon = [ws iconForFile:[fileURL path]];
				if ([[fullpath pathExtension] isEqualToString:@"app"] == YES)
				{
					NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:icon,keyLauncherIcon, appname, keyLauncherAppName, fullpath, keyLauncherAppPath, nil];
					[self insertObject:dict atArrangedObjectIndex:row++];
					dropped = YES;
				}
			}// end if
		}// end for each pasteboard type
	}// end for each pasteborad item
	
	return dropped;
}// end - (BOOL) launchTableAcceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation

- (NSDragOperation) launchTableValidateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
	BOOL foundApplication = NO;
	NSPasteboard *pb = [info draggingPasteboard];
	NSArray *pbItems = [pb pasteboardItems];
	NSArray *types;
	for (NSPasteboardItem *pbItem in pbItems)
	{
		types = [pbItem types];
		for (NSString *type in types)
		{
			if ([type isEqualToString:@"public.file-url"] == YES)
			{
				NSData *data = [pbItem dataForType:@"public.file-url"];
				NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
				NSString *ext = [dataString pathExtension];
#if __has_feature(objc_arc) == 0
				[dataString release];
#endif
				if ([ext isEqualToString:ApplicationExtension] == YES)
					foundApplication = YES;
			}// end if
			if ([type isEqualToString:LauncherPasteboardType] == YES)
				foundApplication = YES;
		}// end for each type
	}// end for each pasteboardItem
	
	if (foundApplication)
		return NSDragOperationCopy;
	else
		return NSDragOperationNone;
}// end - (NSDragOperation) tlaunchTableValidateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation

- (BOOL) launchTableWriteRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
	[pboard clearContents];
	[pboard declareTypes:[NSArray arrayWithObject:NSFilesPromisePboardType] owner:self];
	if ([rowIndexes count] == 1)
	{// no need enumerate
		NSUInteger row = [rowIndexes firstIndex];
		NSDictionary *dict = [[self arrangedObjects] objectAtIndex:row];
		NSData *data = [NSArchiver archivedDataWithRootObject:dict];
		[pboard setData:data forType:LauncherPasteboardType];
	}
	else
	{
		NSMutableArray *pbitemArray = [NSMutableArray arrayWithCapacity:2];
		[rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
		 {
			 NSDictionary *dict = [[self arrangedObjects] objectAtIndex:idx];
			 NSData *data = [NSArchiver archivedDataWithRootObject:dict];
			 NSPasteboardItem *pbItem = [[NSPasteboardItem alloc] init];
			 [pbItem setData:data forType:LauncherPasteboardType];
			 [pbitemArray addObject:pbItem];
#if __has_feature(objc_arc) == 0
			 [pbItem release];
#endif
		 }];
		[pboard writeObjects:pbitemArray];
	}// end if
	
	return YES;
}// end - (BOOL) launchTableWriteRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
#else
- (id) init
{
	self = [super init];
	if (self)
	{
		
	}
	return self;
}// end if

- (void) dealloc
{
	[super dealloc];
}

#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([cell isKindOfClass:[LinkTextFieldCell class]]) {
        LinkTextFieldCell *linkCell = (LinkTextFieldCell *)cell;
			// Setup the work to be done when a link is clicked
        linkCell.linkClickedHandler = ^(NSURL *url, id sender) {
            [[NSWorkspace sharedWorkspace] openURL:url];
        };
    }// endif
}// end - (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
#endif

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  aTableView, KeyTableView, 
						  [NSNumber numberWithInteger:rowIndex], keyRow, nil];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:NLNotificationSelectRow object:dict]];
	return YES;
}// end - (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex

#endif
@end
