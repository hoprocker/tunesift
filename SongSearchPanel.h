//
//  SongSearchBox.h
//  TuneSift
//
//  Created by Malcolm McFarland on Mon Nov 01 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "SearchPanelView.h"

@protocol SearchResultsController 
-(void) changeResultsSource:(const char*) newText;
-(void) resetResultsSource;
-(void) moveUpOneSong;
-(void) moveDownOneSong;
-(void) playSongRemotely;
-(void) playSongRemotely:(int) songid;
-(void) hideEverything;
-(id) getAppMenu;
-(void) addCurrentSongToPlaylist:(NSString*)playlistName;
@end

@interface SongSearchPanel : NSPanel {
	NSTextField*		prompt;
	NSTextField*		songs;
	NSTextField*		currentsong;
	NSTextField*		currentvitals;
	NSPopUpButton*		appmenu;
	NSImageView*		appmenuview;
	
	NSTextFieldCell*	songsCell;
	
	SearchPanelView*	panelView;
	
	NSMutableString*	searchStr;
	
	NSPoint				initialLocation;
	
	id <SearchResultsController>	TuneSiftController;
}

-(SongSearchPanel*) initWithController:(id) cont boundary:(NSRect)bounds;

-(void) initPanelView;
-(void) initPromptText;
-(void) initSongChooser;
-(void) initCurrentSong;
-(void) initCurrentVitals;
-(void) initPopupMenu;
-(void) setupPlaylistsMenu;
-(void) setupLibraryMenu:(NSDictionary*)entirelibrary;
-(void) playSong:(id)sender;
-(void) setupToSearch;
-(void) wipeSlate;
-(void) updateArtistsMenu:(NSDictionary*) data;
-(void) updateAlbumMenu:(NSArray*) data;
-(void) setCurrentSong:(NSString*) newtitle;
-(void) setCurrentArtist:(NSString*) newartist;
-(void) setCurrentAlbum:(NSString*) newalbum;
-(void) setCurrentVitals:(NSString*)cursong artist:(NSString*)curartist album:(NSString*)curalbum;
-(void) songToPlaylist:(id)sender;
@end
