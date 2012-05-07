//
//  IOMArrayControllerWithDragAndDrop.m
//  NicoLiveAlert
//
//  Created by Чайка on 4/25/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "IOMArrayControllerWithDragAndDrop.h"

@implementation IOMArrayControllerWithDragAndDrop
#pragma mark construct

- (id) init {
	self = [super init];
	if (self) {
	}
	return self;
}// end - (id) init

#pragma mark callback
- (void) animationEffectDidEnd:(void *)contextInfo
{
#ifdef TRACECALL
	NSLog(@"animationEffectDidEnd: : WatchListArrayController");
#endif
	NSPasteboard *pb = [NSPasteboard pasteboardWithName:NSDragPboard];
	NSArray *pbItems = [pb pasteboardItems];
	if ([pbItems count] == 1)
	{
		NSData *data = [[pbItems lastObject] dataForType:WatchListPasteboardType];
		NSIndexSet *indexes = [NSUnarchiver unarchiveObjectWithData:data];
			//		NSArray *watchLists = [[self arrangedObjects] objectsAtIndexes:indexes];
		[self removeObjectsAtArrangedObjectIndexes:indexes];
	}
}// end - (void) animationEffectDidEnd:(void *)contextInfo

#pragma mark -
#pragma mark NSTableViewDataSource
- (BOOL) tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
#ifdef TRACECALL
	NSLog(@"tableView:acceptDrop:row:dorpOperation: : WatchListArrayController");
#endif
	NSPasteboard *pb = [info draggingPasteboard];
	NSArray *pbItems = [pb pasteboardItems];
	if ([pbItems count] == 1)
	{
		NSData *data = [[pbItems lastObject] dataForType:WatchListPasteboardType];
		NSIndexSet *indexes = [NSUnarchiver unarchiveObjectWithData:data];
		NSArray *watchLists = [[self arrangedObjects] objectsAtIndexes:indexes];
		NSRange insert = NSMakeRange(row, [watchLists count]);
		[self removeObjectsAtArrangedObjectIndexes:indexes];
		[self insertObjects:watchLists atArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:insert]];
	}
	return YES;
}// end - (BOOL) tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
#ifdef TRACECALL
	NSLog(@"tableView:validateDrop:proposedRow:proposedDropOperation: : LauncherArrayController");
#endif
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
				NSString *dataString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
				NSString *ext = [dataString pathExtension];
				NSLog(@"pathExtension : %@", ext);
				if ([ext isEqualToString:@"app"] == YES)
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
}// end - (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation

- (BOOL) tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
#ifdef TRACECALL
	NSLog(@"tableView:writeRowsWithIndexes:toPasteboard: : WatchListArrayController");
#endif
	[pboard clearContents];
	NSData *pbData = [NSArchiver archivedDataWithRootObject:rowIndexes];
	[pboard setData:pbData forType:WatchListPasteboardType];
	
	return YES;
}// end - (BOOL) tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
@end
