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

#import <AVFoundation/AVFoundation.h>

@interface MYAppDelegate ()
@property (nonatomic, strong) ITLibrary *library;
@property (nonatomic, strong) NSArray *sortedLibraryItems;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
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

- (void) tableViewSelectionDidChange:(NSNotification *) notification {
	[self.window.toolbar validateVisibleItems];
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

#pragma mark -

- (IBAction) playSelectedSong:(id) sender {
	if (self.tableView.selectedRow == -1) {
		return;
	}

	ITLibMediaItem *selectedItem = self.sortedLibraryItems[self.tableView.selectedRow];
	if (selectedItem.locationType != ITLibMediaItemLocationTypeFile) {
		NSLog(@"We can only play local files! Unable to play %@ by %@ from %@", selectedItem.title, selectedItem.artist.name, selectedItem.album.title);

		return;
	}

	if ([self.audioPlayer.url isEqual:selectedItem.location]) {
		[self.audioPlayer play];
	} else {
		[self.audioPlayer stop];

		NSError *error = nil;

		self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:selectedItem.location error:&error];

		if (!self.audioPlayer) {
			NSLog(@"%@ for %@", error, selectedItem.location);
		}
	}
}
@end
