//
//  SearchResultsSource.h
//  TuneSift
//
//  Created by Malcolm McFarland on Tue Nov 09 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <stdlib.h>
#import <stdio.h>
#import "StringBox.h"


@interface SearchResultsSource : NSObject {

	NSTableView*			tView;

	NSTableColumn			*songCol, *artistCol, *albumCol;
	
	StringBox*				songChest;
	
	NSDictionary			*artistdict;
}

-(id) initWithTableView:(NSTableView*) theview;
-(void) readPlaylistInfo;
-(void) readPlaylistInfoFromFile;

-(int)numberOfRowsInTableView:(NSTableView *)aTableView;
-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;

-(NSDictionary*) songsForArtist:(NSString*) artistname;
-(NSArray*) songsForAlbum:(NSString*)albumname artist:(NSString*)artistname;
-(NSDictionary*) entireLibrary;
-(int) DBIDForRowIndex:(int) index;
-(void) resetSongChest;
-(int) updateSongsWithString:(const char*) str;

-(void*) songs;
-(void) testOut;
@end
