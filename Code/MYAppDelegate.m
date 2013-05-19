//
//  MYAppDelegate.m
//  Melody
//
//  Created by Zach Drayer on 5/19/13.
//

#import "MYAppDelegate.h"

#import <iTunesLibrary/ITLibrary.h>
#import <iTunesLibrary/ITLibMediaItem.h>
#import <iTunesLibrary/ITLibArtist.h>
#import <iTunesLibrary/ITLibAlbum.h>

@interface MYAppDelegate ()
@property (nonatomic, strong) ITLibrary *library;
@property (nonatomic, strong) NSArray *sortedLibraryItems;
@end

@implementation MYAppDelegate
- (void) applicationDidFinishLaunching:(NSNotification *) notification {
	NSError *error = nil;
	self.library = [ITLibrary libraryWithAPIVersion:@"1.0" error:&error];

	if (!self.library) {
		NSLog(@"error: %@", error);
	}

	[self tableView:self.tableView didClickTableColumn:nil];
	[self.tableView reloadData];
}

#pragma mark -

- (NSInteger) numberOfRowsInTableView:(NSTableView *) tableView {
	return self.library.allMediaItems.count;
}

- (id) tableView:(NSTableView *) tableView objectValueForTableColumn:(NSTableColumn *) tableColumn row:(NSInteger) row {
	ITLibMediaItem *item = self.sortedLibraryItems[row];

	if ([tableColumn.identifier isEqualToString:@"name"]) {
		return item.title;
	}

	if ([tableColumn.identifier isEqualToString:@"artist"]) {
		return item.artist.name;
	}

	if ([tableColumn.identifier isEqualToString:@"album"]) {
		return item.album.title;
	}

	return nil;
}

- (void) tableView:(NSTableView *) tableView didClickTableColumn:(NSTableColumn *) tableColumn {
	if ([tableColumn.identifier isEqualToString:@"name"]) {
		self.sortedLibraryItems = [self.library.allMediaItems sortedArrayUsingComparator:^(id one, id two) {
			return [[one title] compare:[two title]];
		}];
	} else if (!tableColumn || [tableColumn.identifier isEqualToString:@"artist"]) {
		self.sortedLibraryItems = [self.library.allMediaItems sortedArrayUsingComparator:^(id one, id two) {
			return [[[one artist] name] compare:[[two artist] name]];
		}];
	} else if ([tableColumn.identifier isEqualToString:@"album"]) {
		self.sortedLibraryItems = [self.library.allMediaItems sortedArrayUsingComparator:^(id one, id two) {
			return [[[one album] title] compare:[[two album] title]];
		}];
	}

	[tableView reloadData];
	[tableView deselectColumn:[tableView columnWithIdentifier:tableColumn.identifier]];
}
@end
