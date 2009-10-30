//
//  TuneSiftInterface.h
//  TuneSift
//
//  Created by Malcolm McFarland on Thu Oct 28 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Carbon/Carbon.h>

#import "SongSearchPanel.h"
#import "SearchResultsView.h"
#import "SearchResultsSource.h"
#import "ActionBGPanel.h"
#import "ActionDisplayIconPanel.h"
//#define _SONG_RETRIEVE_TEST_

//@class SearchResultsView

@interface TuneSiftInterface : NSObject <SearchResultsController,SearchResultsViewController> {
	id				nameField;
	id				artistField;
	id				albumField;
	id				lengthField;
	
	id				headsUpPanel;
	id				appMenu;
	
	id				keyChoiceField;
	
	id				nameMenuItem;
	id				artistMenuItem;
	id				albumMenuItem;
	id				playlistsMenuItem;
	id				shuffleMenuItem;
	
//	BOOL			shuffleIsOn;
	BOOL			statusFading;
	
	SongSearchPanel*	searchPanel;
//	PanelBG*	searchPanelBG;
	
	NSRect			searchpanelbounds;
	
	EventHotKeyID   hotKeyID;
	EventHotKeyRef  hotKeyPtr;
	
	id				searchResultsPanel;
	id				searchResultsView;
	
	SearchResultsSource*	resDataSource;
	
	NSString*		oldSong;
	
	NSTimer*		headsUpTimer;
	NSTimer*		alphaTimer;
	NSTimer*		actionPanelTimer;
	
	NSDate*			startingTime;
	
	ActionBGPanel*	actionbgpanel;
	ActionDisplayIconPanel*		actioniconpanel;
	
	/* Heads up translucent panel images */
	NSImage*		shuffleOnIcon;
	NSImage*		shuffleOffIcon;
	NSImage*		playIcon;
	NSImage*		pauseIcon;
	NSImage*		forwardTrackIcon;
	NSImage*		backTrackIcon;
	
	NSAppleScript*	testForITunesAS;
	NSAppleScript*  pollSongID;
	NSAppleScript*  pollSongName;
	NSAppleScript*  pollSongArtist;
	NSAppleScript*  pollSongAlbum;
	NSAppleScript*  pollSongLength;
}

-(void) setupApplescripts;
-(void) setupStatusbarItems;
-(void) setupTimers;
-(void) setupResultsPanel;

-(void) setupGlobalHotKeys;

-(IBAction) backTrack: (id) sender;
-(IBAction) forwardTrack: (id) sender;
-(IBAction) playPause: (id) sender;
-(IBAction) toggleShuffle: (id) sender;
-(IBAction) showHelpText:(id) sender;

-(void) setNameString;
-(void) checkForNewSong:(id) notification;
-(void) printNotification: (NSString*) songid;
-(void) hideHeadsUpDisplay: (id) sender;
-(void) fadeMore: (id) sender;
-(void) showHeadsUp;

-(void) updateShuffleMenu;

-(BOOL) testITunesOpen;

-(void) testAndShowWelcome;

-(void) setupToSearch;
-(void) showEverything;
-(void) hideEverything;

-(void) displayStatusIcon;

-(void) needToHide:(NSNotification*) obj;


#ifdef _SONG_RETRIEVE_TEST_
-(int) indexSongs;
#endif

@end
