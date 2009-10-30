//
//  SearchResultsSource.m
//  TuneSift
//
//  Created by Malcolm McFarland on Tue Nov 09 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

/* playing a track by database id via itunes:
tell application "iTunes"
	play the first item of (every track of playlist "Library" whose database ID is THE_ID)
end tell
*/

#import "SearchResultsSource.h"


int			gTotalNumberOfSongs;
int			gInfoArrayLengths;

char		**songs, **artists, **albums;
//NSArray*	songs, *artists, *albums;

@implementation SearchResultsSource

-(id) initWithTableView:(NSTableView*) theview {
	int i = 0;
	
	[super init];
	
	tView = theview;
	gTotalNumberOfSongs = 0;
	gInfoArrayLengths = 1;
	songChest = [[StringBox allocWithZone:[self zone]] init];
	[songChest retain];
	
	songCol = [tView tableColumnWithIdentifier:@"song"];
	if(!songCol) { fprintf(stderr, "no songCol in SearchResultsSource::init\n"); return nil; }

	artistCol = [tView tableColumnWithIdentifier:@"artist"];
	if(!artistCol) { fprintf(stderr, "no artistCol in SearchResultsSource::init\n"); return nil; }
	
	albumCol = [tView tableColumnWithIdentifier:@"album"];
	if(!albumCol) { fprintf(stderr, "no albumCol in SearchResultsSource::init\n"); return nil; }
	
	songs = (char**)malloc(sizeof(char*));
	artists = (char**)malloc(sizeof(char*));
	albums = (char**)malloc(sizeof(char*));

/*	songs = (char**)malloc(kSongNumberCap*sizeof(char*));
	artists = (char**)malloc(kSongNumberCap*sizeof(char*));
	albums = (char**)malloc(kSongNumberCap*sizeof(char*));
	
	gInfoArrayLengths = kSongNumberCap;*/
		
/*	songs = [[NSArray alloc] init];
	artists = [[NSArray alloc] init];
	albums = [[NSArray alloc] init];
	
	[songs retain];
	[artists retain];
	[albums retain];*/
	
	[self readPlaylistInfoFromFile];
/*	[songCol retain];
	[artistCol retain];
	[albumCol retain];*/
	
	
//	NSLog([songChest description]);
	return self;
}
	

/*
 * Going track by track until there ain't no more, read the song, artist, and album for tracks
 * 0 through whatever, then place them each in their own array of NSData* objects.  We use
 * NSData* because there seem to be some descrepencies between the object management system and
 * the ANSI C memory management underbelly when dealing with raw arrays of bytes.  So, instead,
 * we use raw arrays of NSData pointers.  Same thing, more robust, acknowledged on both sides.
 */
-(void) readPlaylistInfo {
/*	NSString*		fetchString;
	NSDictionary*   resultDict = NULL;
	NSAppleScript*  fetchAS;
	NSAppleEventDescriptor* fetchAED;
	char*			concatStr;
	NSData*			songData, *artistData, *albumData;
	int				concatStrSize = 0;
	
	while((gTotalNumberOfSongs < kSongNumberCap)) {
		fetchString = [NSString stringWithFormat:@"tell application \"iTunes\" to get name of track %i of current playlist", gTotalNumberOfSongs+1];
		fetchAS = [[NSAppleScript alloc] initWithSource:fetchString];
		if(!(fetchAED = [fetchAS executeAndReturnError:&resultDict])) {
			fprintf(stderr, "SearchResultsSource::readPlaylistInfo : executeAndReturnError failed on name fetch\n");
			NSLog([resultDict description]);
			return;
		}
		
		if(gTotalNumberOfSongs >= gInfoArrayLengths) {
			if(!(songs = (char**)realloc(songs, sizeof(NSData*)*(gInfoArrayLengths+50)))) {
				fprintf(stderr, "SearchResultsSource::readPlaylistInfo : songs failed to realloc\n");
				return;
			 } else if(!(artists = (char**)realloc(artists, sizeof(NSData*)*(gInfoArrayLengths+50)))) {
				fprintf(stderr, "SearchResultsSource::readPlaylistInfo : artists failed to realloc\n");
				return;
			} else if(!(albums = (char**)realloc(albums, sizeof(NSData*)*(gInfoArrayLengths+50)))) {
				fprintf(stderr, "SearchResultsSource::readPlaylistInfo : albums failed to realloc\n");
				return;
			} else gInfoArrayLengths += 50;
		}
		
		songData = [NSData dataWithBytes:[[fetchAED stringValue] UTF8String] length:strlen([[fetchAED stringValue] cString])];
		[songData retain];
		songs[gTotalNumberOfSongs] = (void*)songData;
		
#ifdef _SOURCE_DEBUG_
		printf("song %i: %s\n", gTotalNumberOfSongs, songs[gTotalNumberOfSongs]);
#endif
		concatStrSize += [[fetchAED stringValue] length] + 1;
		
		fetchString = [NSString stringWithFormat:@"tell application \"iTunes\" to get artist of track %i of current playlist", gTotalNumberOfSongs+1];
		fetchAS = [[NSAppleScript alloc] initWithSource:fetchString];
		if(!(fetchAED = [fetchAS executeAndReturnError:&resultDict])) {
			fprintf(stderr, "SearchResultsSource::readPlaylistInfo : executeAndReturnError failed on artist fetch\n");
			NSLog([resultDict description]);
			return;
		}
		
		artistData = [NSData dataWithBytes:[[fetchAED stringValue] UTF8String] length:strlen([[fetchAED stringValue] cString])];
		[artistData retain];
		artists[gTotalNumberOfSongs] = (void*)artistData;
#ifdef _SOURCE_DEBUG_
		printf("artist %i: %s\n", gTotalNumberOfSongs, artists[gTotalNumberOfSongs]);
#endif
		concatStrSize += ([[fetchAED stringValue] length] + 1);
		
		fetchString = [NSString stringWithFormat:@"tell application \"iTunes\" to get album of track %i of current playlist", gTotalNumberOfSongs+1];
		fetchAS = [[NSAppleScript alloc] initWithSource:fetchString];
		if(!(fetchAED = [fetchAS executeAndReturnError:&resultDict])) {
			fprintf(stderr, "SearchResultsSource::readPlaylistInfo : executeAndReturnError failed on albums fetch\n");
			NSLog([resultDict description]);
			return;
		}
		
		albumData = [NSData dataWithBytes:[[fetchAED stringValue] UTF8String] length:strlen([[fetchAED stringValue] cString])];
		[albumData retain];
		albums[gTotalNumberOfSongs] = (void*)albumData;
#ifdef _SOURCE_DEBUG_
		printf("album %i: %s\n", gTotalNumberOfSongs, albums[gTotalNumberOfSongs]);
#endif
		concatStrSize += ([[fetchAED stringValue] length] + 1);
		
		concatStr = malloc(sizeof(char)*concatStrSize);
		sprintf(concatStr, "%s\t%s\t%s\n", (char*)[(NSData*)songs[gTotalNumberOfSongs] bytes],
				(char*)[(NSData*)artists[gTotalNumberOfSongs] bytes],
				(char*)[(NSData*)albums[gTotalNumberOfSongs] bytes]);
		
		[songChest addString:concatStr length:concatStrSize dbID:0];
//		free(concatStr);

		gTotalNumberOfSongs++;
	}*/
	
//	NSLog([songChest description]);
}


/*
 * A more refined version of the above function, this one read all of the track informations out
 * of ~/Music/iTunes/iTunes Music Library.xml, parses it, and extracts the song/album/artist information
 * and places it where appropriate.
 */
-(void) readPlaylistInfoFromFile {
	NSString*		filepath = [[NSString stringWithString:@"~/Music/iTunes/iTunes Music Library.xml"] stringByExpandingTildeInPath];
	NSDictionary*   itunesDict = [NSDictionary dictionaryWithContentsOfFile:filepath];
	NSDictionary*   songsDict = [itunesDict objectForKey:@"Tracks"];
	NSDictionary*   eachTrack;
	NSArray*		sortedSongs, *artistsname, *artistssong, *artistsdbid, *albumarray;
	NSMutableDictionary* artistprotodict = [NSMutableDictionary dictionaryWithCapacity:[songsDict count]+1];
	NSMutableDictionary* albumprotodict;
	NSSortDescriptor* albumSort, *trackSort;
	NSEnumerator*   songsEnum;// = [songsDict objectEnumerator];
	NSString*		songData, *artistData, *albumData, *artistskey, *albumkey;
	char*			concatStr, *even_more_temp_str;
	int				concatStrLength, i;
	
	
	albumSort = [[[NSSortDescriptor alloc] initWithKey:@"Album" ascending:YES] autorelease];
	trackSort = [[[NSSortDescriptor alloc] initWithKey:@"Track Number" ascending:YES] autorelease];
	sortedSongs = [[songsDict allValues] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:albumSort, trackSort, nil]];
	
//	artistsdict = [NSDictionary dictionary];
/*	artistsname = [NSArray array];
	artistssong = [NSArray array];
	artistsdbid = [NSArray array];*/

	songsEnum = [sortedSongs objectEnumerator];

	while((eachTrack = [songsEnum nextObject]) && (gTotalNumberOfSongs < kSongNumberCap)) {
		concatStrLength = 0;
#ifdef _SOURCE_DEBUG_
			printf("readPlaylistInfoFromFile: ### SONG NUMBER %i ###\n", gTotalNumberOfSongs);
#endif		
		if(gTotalNumberOfSongs >= gInfoArrayLengths) {
#ifdef _SOURCE_DEBUG_
			printf("readPlaylistInfoFromFile: expanding the arrays\n");
#endif
		if(!(songs = (char**)realloc(songs, sizeof(NSData*)*(gInfoArrayLengths+50)))) {
				fprintf(stderr, "SearchResultsSource::readPlaylistInfo : songs failed to realloc\n");
				return;
			 } else if(!(artists = (char**)realloc(artists, sizeof(NSData*)*(gInfoArrayLengths+50)))) {
				fprintf(stderr, "SearchResultsSource::readPlaylistInfo : artists failed to realloc\n");
				return;
			} else if(!(albums = (char**)realloc(albums, sizeof(NSData*)*(gInfoArrayLengths+50)))) {
				fprintf(stderr, "SearchResultsSource::readPlaylistInfo : albums failed to realloc\n");
				return;
			} else gInfoArrayLengths += 50;
		}
		
		if([eachTrack objectForKey:@"Name"] == nil)
			songData = [[NSString allocWithZone:[self zone]] initWithString:@""];
		else songData = (NSString*)[[eachTrack objectForKey:@"Name"] copyWithZone:[self zone]];
		[songData retain];
//		songs = [songs arrayByAddingObject:songData];
		songs[gTotalNumberOfSongs] = (void*)songData;
		concatStrLength += [songData length] + 1;

#ifdef _SOURCE_DEBUG_
		NSLog(@"SONG: %@", (NSString*)songs[gTotalNumberOfSongs]);
#endif
		
		if([eachTrack objectForKey:@"Artist"] == nil)
			artistData = [[NSString allocWithZone:[self zone]] initWithString:@""];
		else artistData = (NSString*)[[eachTrack objectForKey:@"Artist"] copyWithZone:[self zone]];
		[artistData retain];
//		artists = [artists arrayByAddingObject:artistData];
		artists[gTotalNumberOfSongs] = (void*)artistData;
		concatStrLength += [artistData length] + 1;
		
#ifdef _SOURCE_DEBUG_
		NSLog(@"ARTIST: %@", (NSString*)artists[gTotalNumberOfSongs]);
#endif
		
		if([eachTrack objectForKey:@"Album"] == nil)
			albumData = [[NSString allocWithZone:[self zone]] initWithString:@""];
		else albumData = (NSString*)[[eachTrack objectForKey:@"Album"] copyWithZone:[self zone]];
		[albumData retain];
//		albums = [albums arrayByAddingObject:albumData];
		albums[gTotalNumberOfSongs] = (void*)albumData;
		concatStrLength += [albumData length] + 1;
	
#ifdef _SOURCE_DEBUG_
		NSLog(@"ALBUM: %@", (NSString*)albums[gTotalNumberOfSongs]);
#endif

#ifdef _SOURCE_DEBUG_
		NSLog(@"DB ID: %i", [[eachTrack objectForKey:@"Track ID"] intValue]);
#endif

		filepath = [NSString stringWithFormat:@"%@\t%@\t%@\n", (NSString*)songs[gTotalNumberOfSongs],
				(NSString*)artists[gTotalNumberOfSongs],
				(NSString*)albums[gTotalNumberOfSongs]];
#ifdef _SOURCE_DEBUG_
		NSLog(@"filepath: %s", [filepath UTF8String]);
#endif
		even_more_temp_str = (char*)[filepath UTF8String];
		concatStr = (char*)malloc(strlen(even_more_temp_str)*sizeof(char));
		i = 0;
		while(i < strlen(even_more_temp_str))
			concatStr[i++] = even_more_temp_str[i];

		[songChest addString:concatStr length:concatStrLength dbID:(int)[[eachTrack objectForKey:@"Track ID"] intValue]];
		
		artistskey = (NSString*)[NSString stringWithString:artists[gTotalNumberOfSongs]];
		albumkey = (NSString*)[NSString stringWithString:albums[gTotalNumberOfSongs]];
#ifdef _SOURCE_DEBUG_
		NSLog(@"%@...", artistskey);
		NSLog(@"%@...", albumkey);
#endif	
		if([artistprotodict objectForKey:artistskey] == nil) {/* No artist could be found... */
			albumprotodict = [NSMutableDictionary dictionaryWithCapacity:1];
#ifdef _SOURCE_DEBUG_
				printf("new artist\n");
#endif
/*			albumarray = [NSArray arrayWithObject:[NSArray arrayWithObjects:[NSString stringWithString:songs[gTotalNumberOfSongs]], [eachTrack objectForKey:@"Track ID"], nil]];
			[albumprotodict setValue:albumarray forKey:albumkey];*/
			[artistprotodict setValue:albumprotodict forKey:artistskey];
		}
		
		if([[artistprotodict objectForKey:artistskey] objectForKey:albumkey] != nil) {
#ifdef _SOURCE_DEBUG_
			printf("old album\n");
#endif
			albumarray = [[[artistprotodict objectForKey:artistskey] objectForKey:albumkey]
								arrayByAddingObject:[NSArray arrayWithObjects:[NSString stringWithString:songs[gTotalNumberOfSongs]], [eachTrack objectForKey:@"Track ID"], nil]];
			[[artistprotodict objectForKey:artistskey] setValue:albumarray forKey:albumkey];
		} else { /* No structure could be found for this album */
#ifdef _SOURCE_DEBUG_
			printf("new album\n");
#endif
			albumarray = [NSArray arrayWithObject:[NSArray arrayWithObjects:[NSString stringWithString:songs[gTotalNumberOfSongs]], [eachTrack objectForKey:@"Track ID"], nil]];
			[[artistprotodict objectForKey:artistskey] setValue:albumarray forKey:albumkey];
		}
		
#ifdef _SOURCE_DEBUG_
		printf("done\n");
#endif
		gTotalNumberOfSongs++;
	}
	
	songData = NULL;
	artistData = NULL;
	albumData = NULL;
	
	artistdict = [NSDictionary dictionaryWithDictionary:artistprotodict];
	[artistdict retain];
/*	[itunesDict release];
	[songsDict release]; */
}

	
-(int)numberOfRowsInTableView:(NSTableView *)aTableView{
#ifdef _SOURCE_DEBUG_
	NSLog(@"numberOfRowsInTableView: %i", [songChest getNumOfStrings]);
#endif
	return [songChest getNumOfStrings];
}

-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex{
	NSString*		retData;
	int			mappedIndex;

#ifdef _SOURCE_DEBUG_
	printf("made it to objectValueForTableColumn\n");
#endif

	if((rowIndex >= [songChest getNumOfStrings]) || (rowIndex < 0))
		return NULL;
	
	mappedIndex = [songChest mapSubsetToFull:rowIndex];
	
	if(aTableColumn == songCol)
		retData = (NSString*)songs[mappedIndex];
	else if (aTableColumn == artistCol)
		retData = (NSString*)artists[mappedIndex];
	else if (aTableColumn == albumCol)
		retData = (NSString*)albums[mappedIndex];

#ifdef _SOURCE_DEBUG_
	printf("SearchResultsSource::objectValueForTableColumn : rowIndex: %i  value: %s\n", rowIndex, (char*)[retData cString]);
#endif

//	[retData retain];
	
//	return([NSString stringWithCString:(char*)[retData bytes]]);
	return retData;
}

-(void*) songs {
#ifdef _SOURCE_DEBUG_
	printf("returning songs\n");
#endif
	return songs;
}

-(int) DBIDForRowIndex:(int) index {
#ifdef _SOURCE_DEBUG_
	printf("DBIDForRowIndex\n");
	printf("DBID for index %i is %i\n", index, [songChest mapSubsetToDBID:index]);
#endif
	return [songChest mapSubsetToDBID:index];
}

-(NSDictionary*) songsForArtist:(NSString*) artistname {
#ifdef _MENU_DEBUG_
	NSLog(@"SearchResultsSource::songsForArtist : %@", artistname);
#endif
	return (NSDictionary*)[artistdict valueForKey:artistname];
}


-(NSArray*) songsForAlbum:(NSString*) albumname artist:(NSString*) artistname {
	return (NSArray*)[[artistdict valueForKey:artistname] valueForKey:albumname];
}

-(NSDictionary*) entireLibrary {
	return artistdict;
}


-(void) testOut {
	int i;
	NSString*		curPtr;
	
	printf("TEST BEGIN\n");
	for(i=0; i < gTotalNumberOfSongs; i++) {
		curPtr = (NSString*)songs[i];
		printf("%s", (char*)[curPtr cString]);
	}
	printf("\nTEST END\n");
}

-(void) resetSongChest {
#ifdef _SOURCE_DEBUG_
	printf("Resetting song chest\n");
#endif
	[songChest resetSubsetMapper];
}

-(int) updateSongsWithString:(const char*) str {
#ifdef _SOURCE_DEBUG_
	printf("updateSongsWithString\n");
#endif
	return [songChest matchesForSubstring:str];
}

-(void) dealloc {
	int i;
	
#ifdef _SOURCE_DEBUG_
	printf("SearchREsultsSource:dealloc\n");
#endif
	for (i = 0; i < gTotalNumberOfSongs; i++) {
		free(songs[i]);
		free(albums[i]);
		free(artists[i]);
	}
	
	free(songs);
	free(albums);
	free(artists);
}
@end
