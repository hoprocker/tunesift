//
//  TuneSiftInterface.m
//  TuneSift
//
//  Created by Malcolm McFarland on Thu Oct 28 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "TuneSiftInterface.h"

#define kAllOptions 0x03
#define kActionBGAlpha	.6
#define kActionIconAlpha 1
#define kActionBGAlphaInterval .0375
#define kActionIconAlphaInterval .0625

#define kActionFadeIncrement	.05
#define kActionInitialDelay		1

const UInt32 kLockUIElementHotKey	    = 98; // F7 will be the key to hit, in combo with Cmd
const int kLockUIElementModifierKey = cmdKey;

const UInt32 kHotKeyCode	= 100;  // F8
const int kHotKeyModifiers  = 0;	// w/ no modifiers

const UInt32 kF1KeyCode	= 122;  // F1
const UInt32 kF2KeyCode	= 120;  // F2
const UInt32 kF3KeyCode	= 99;  // F3
const UInt32 kF4KeyCode = 118;  // F4
const UInt32 kESCKeyCode	= 53;

pascal OSStatus HandleHotKey(EventHandlerCallRef nextHandler,EventRef theEvent, void *userData);

SongSearchPanel*		gSearchPanelBridge;
TuneSiftInterface*		gSelfBridge;

@implementation TuneSiftInterface

-(void) awakeFromNib {
	NSSize			sFrame = [[NSScreen mainScreen] frame].size;
	
	[self setupApplescripts];
	[self setupGlobalHotKeys];
	
	[self setupResultsPanel];
	
	oldSong = @"";
	[oldSong retain];
	
	[headsUpPanel setFloatingPanel:TRUE];
	[headsUpPanel setLevel:NSPopUpMenuWindowLevel];
	[headsUpPanel setHidesOnDeactivate:FALSE];
	[headsUpPanel setLevel:NSStatusWindowLevel];
	[headsUpPanel setBackgroundColor:[NSColor colorWithDeviceRed:0.05 green:0.1 blue:0.05	alpha:1.0]];
	[headsUpPanel setAlphaValue:kMaxAlpha];
	
	searchpanelbounds = NSMakeRect((sFrame.width-kSearchPanelWidth)/2, sFrame.height-[NSMenuView menuBarHeight]-kSearchPanelHeight, kSearchPanelWidth, kSearchPanelHeight);
	searchPanel = (SongSearchPanel*)[[SongSearchPanel alloc] initWithController:(id)self boundary:searchpanelbounds];
	if(!searchPanel) fprintf(stderr, "No searchPanel!!\n");
//	[searchPanel orderOut:self];
//	[searchPanel display];
//	[searchPanel makeKeyAndOrderFront:nil];

	/* this is super hacked; we need to first init the panel, *then* initialize the controls 
	 * because we're making this whole thing programmatically (stupid!).
	 */
	[searchPanel initPanelView];
	[searchPanel setHasShadow:FALSE];
//	[searchPanel invalidateShadow];
//	[searchpanel initControls];
//	[searchPanel setViewsNeedDisplay:TRUE];
	
	[searchPanel retain];
	[searchPanel setupLibraryMenu:[resDataSource entireLibrary]];
	
	gSearchPanelBridge = searchPanel;
	
//	[songSearchPanel orderFront:self];
	
	[nameField setFont:[NSFont fontWithName:@"Courier" size:32]];
	[artistField setFont:[NSFont fontWithName:@"Courier" size:14]];
	[albumField setFont:[NSFont fontWithName:@"Courier" size:14]];
	[lengthField setFont:[NSFont fontWithName:@"Courier" size:20]];

	/* Get the image icons into memory */
	shuffleOnIcon = [NSImage imageNamed:@"shuffleOn"];
	shuffleOffIcon = [NSImage imageNamed:@"shuffleOff"];
/*	NSImage*		playIcon;
	NSImage*		pauseIcon;
	NSImage*		forwardTrackIcon;
	NSImage*		backTrackIcon;*/
	
	[self setupTimers];
	
	[self setNameString];

	[self testAndShowWelcome];
	
//	[self testITunesOpen];
	
	[searchResultsPanel setFrameOrigin:NSMakePoint(
		(sFrame.width - [searchResultsPanel frame].size.width)/2, [searchPanel frame].origin.y-kSearchResultsHeight-16)];
	[searchResultsPanel setFloatingPanel:TRUE];
	[searchResultsPanel setHidesOnDeactivate:FALSE];
	[searchResultsPanel setLevel:NSStatusWindowLevel];
//	[searchResultsPanel setWorksWhenModal:TRUE];
	
	actionbgpanel = [[ActionBGPanel alloc] init];
	[actionbgpanel initializeView];
	[actionbgpanel retain];
	
	actioniconpanel = [[ActionDisplayIconPanel alloc] init];
	[actioniconpanel initializeView];
	[actioniconpanel retain];
	
//	startingTime = [NSDate date];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needToHide:) name:@"NSWindowDidResignKeyNotification" object:nil];
	[self updateShuffleMenu];
	gSelfBridge = self;
	
	[self setupStatusbarItems];
//	printf("\n*************** 1 ***************\n\n");
}

-(IBAction) showHelpText:(id) sender {
	NSAlert*	tempAlert = [[NSAlert alloc] init];
	
#ifdef _MAIN_DEBUG_
	printf("Showing help panel\n");
#endif
	[tempAlert setAlertStyle:NSInformationalAlertStyle];
	[tempAlert setHelpAnchor:nil];
	[tempAlert setShowsHelp:FALSE];
	[tempAlert setMessageText:[NSString stringWithFormat:@"TuneSift\nv0.4"]];
	[tempAlert addButtonWithTitle:@"Ok"];
	[tempAlert setInformativeText:@"©2005 Malcolm McFarland\n\nCommand keys:\n\tF1: previous track\n\tF2: play/pause track\n\tF3: next track\n\tF4: toggle shuffle on/off\n\tF8: show song listing - type part of a \n\t\tsong/artist/album name, navigate\n\t\twith up/down arrows, return key\n\t\tto play\n\nwebsite: http://www.csua.berkeley.edu/~malcolm/.\nfeedback: ltlbigman@gmail.com\n\n"];
	
	[NSApp activateIgnoringOtherApps:TRUE];
	
	[searchPanel setLevel:NSFloatingWindowLevel];
	[tempAlert runModal];
	[searchPanel setLevel:NSStatusWindowLevel];
}

-(void) testAndShowWelcome {
	NSAlert*	tempAlert = [[NSAlert alloc] init];
	NSString*   pathstr = [[NSString stringWithString:@"~/Library/Preferences/com.shrugsoft.TuneSift"] stringByExpandingTildeInPath];
	FILE*		prefsfile;
	char		*outstr, *datestr;
	
	if(prefsfile = fopen([pathstr UTF8String], "r")) {
		fclose(prefsfile);
		return;
	}
	
#ifdef _MAIN_DEBUG_
	printf("Showing welcome...\n");
#endif
	[tempAlert setAlertStyle:NSInformationalAlertStyle];
	[tempAlert setHelpAnchor:nil];
	[tempAlert setShowsHelp:FALSE];
	[tempAlert setMessageText:@"Welcome!"];
	[tempAlert addButtonWithTitle:@"Continue"];
	[tempAlert setInformativeText:@"Welcome to development build v0.4 of TuneSift!  TuneSift provides a way of accessing your iTunes library remotely, without needing to bring iTunes to the front.\n\nCommand keys:\n\tF1: previous track\n\tF2: play/pause\n\tF3: next track\n\tF4: toggle shuffle on/off\n\tF8: show song listing - type part of a \n\t\tsong/artist/album name, use the\n\t\tup/down arrow keys to navigate, and\n\t\tpress return to play the song!\n\nRemember, this is a development copy, so not everything will necessarily work as expected (or at all).  Feedback is openly welcomed at ltlbigman@gmail.com.  Remember to check back at http://www.csua.berkeley.edu/~malcolm/ regularly for updates!\n\nThis information can be found under \"About TuneSift\" in the \"V\" menu near the righthand side of the menubar (or from the command panel).\n"];
	
	[searchPanel setLevel:NSFloatingWindowLevel];
	[tempAlert runModal];
	[searchPanel setLevel:NSStatusWindowLevel];
	
	if(prefsfile = fopen([pathstr UTF8String], "w")) {
		datestr =[[[NSDate date] description] UTF8String];
		outstr = (char*)malloc((10+strlen(datestr))*sizeof(char*));
		sprintf(outstr, "created %s\n", datestr);
		fprintf(prefsfile, outstr);
		fclose(prefsfile);
		free(outstr);
	}
}

/* 
 * Create and the compile (but don't execute) the various Applescripts
 * that we are going to use throughout the execution of the program
 */
-(void) setupApplescripts {
	NSString*		preString = @"tell application \"Finder\"\nif number of (every process whose name is \"iTunes\") > 0 then\n";
	NSString*		postString = @"end if\nend tell\n";
	NSString*		IDStr = [NSString stringWithFormat:@"%@%@%@", preString, @"tell application \"iTunes\" to get database ID of current track\n", postString];;
	NSString*		nameStr = [NSString stringWithFormat:@"%@%@%@", preString, @"tell application \"iTunes\" to get name of current track\n", postString];
	NSString*		artistStr = [NSString stringWithFormat:@"%@%@%@", preString, @"tell application \"iTunes\" to get artist of current track\n", postString];
	NSString*		albumStr = [NSString stringWithFormat:@"%@%@%@", preString, @"tell application \"iTunes\" to get album of current track\n", postString];
	NSString*		lengthStr = [NSString stringWithFormat:@"%@%@%@", preString, @"tell application \"iTunes\" to get time of current track\n", postString];
//	NSString*		testForItunesStr = @"tell application \"Finder\" to get number of (every process whose name is \"iTunes\")\n";
	NSDictionary*   resultDict;

//	testForITunesAS = [[NSAppleScript alloc] initWithSource:testForItunesStr];
	pollSongID = [[NSAppleScript alloc] initWithSource:IDStr];
	pollSongName = [[NSAppleScript alloc] initWithSource:nameStr];
	pollSongArtist = [[NSAppleScript alloc] initWithSource:artistStr];
	pollSongAlbum = [[NSAppleScript alloc] initWithSource:albumStr];
	pollSongLength = [[NSAppleScript alloc] initWithSource:lengthStr];
	
	if(!pollSongID) {
		//printf("Couldn't establish contact with iTunes!\n\n");
		exit(-1);
	}
	
	if(!([pollSongID compileAndReturnError:&resultDict] &&
		 [pollSongName compileAndReturnError:&resultDict] &&
		 [pollSongArtist compileAndReturnError:&resultDict] &&
		 [pollSongAlbum compileAndReturnError:&resultDict] &&
		 [pollSongLength compileAndReturnError:&resultDict])) {
//		 [testForITunesAS compileAndReturnError:&resultDict])) {
		fprintf(stderr, "Couldn't compile polling script.\n\n");
		exit(-1);
	}
}

/* 
 * Add the various command icons to the status bar on the righthand side of the screen
 *
 * Right now, these are back (<-), play/pause (> ||), next (->), and the menu (V).
 */
-(void) setupStatusbarItems {
	NSStatusItem*   item1, *item2, *item3, *appItem;
	
	appItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
/*	item3 = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	item2 = [[NSStatusBar systemStatusBar] statusItemWithLength:40];
	item1 = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];*/

	[appItem setMenu:(NSMenu*)appMenu];
	[appItem setHighlightMode:TRUE];
	[appItem setTitle:@"v"];
	
/*	[item1 setTitle:@"<-"];
	[item1 setHighlightMode:TRUE];
	[item1 setTarget:self];
	[item1 setAction:sel_registerName("backTrack:")];
	
	[item2 setTitle:@"> ||"];
	[item2 setHighlightMode:TRUE];
	[item2 setTarget:self];
	[item2 setAction:sel_registerName("playPause:")];
	
	[item3 setTitle:@"->"];
	[item3 setTarget:self];
	[item3 setHighlightMode:TRUE];
	[item3 setAction:sel_registerName("forwardTrack:")];
	
	[item1 retain];
	[item2 retain];
	[item3 retain];*/
	[appItem retain];
}

/*
 * Establish our polling timer, tempTimer here, which checks periodically
 * to see if the song has changed (and, if so, adjust our readout), and the
 * timer that will eventually control how longthe readout panel stays visible.
 */
-(void) setupTimers {
	NSTimer*		tempTimer;
	
	tempTimer = [NSTimer scheduledTimerWithTimeInterval:kPollInterval
					target:self selector:sel_registerName("checkForNewSong:")
					userInfo:nil
					repeats:TRUE];
	
	headsUpTimer = [NSTimer scheduledTimerWithTimeInterval:.5
					target:self selector:sel_registerName("hideHeadsUpDisplay:")
					userInfo:nil
					repeats:FALSE];
	
//	[NSDate dateWithTimeIntervalSinceNow:(kMaxAlpha*.1/kAlphaIncrement)]
//	[headsUpTimer retain];
}

/*
 * Initialize the panel that will eventually show the results when the user starts typing in
 * the search panel.
 */
-(void) setupResultsPanel {
	NSSize			sFrame = [[NSScreen mainScreen] frame].size;
	char**			songsFromSource;
	int				topedge = sFrame.height-[NSMenuView menuBarHeight]-kSearchPanelHeight-[searchResultsPanel frame].size.height-kSmallTitlebarHeight;
	NSPoint			bottomleft = NSMakePoint(0, topedge);
	NSFont*			useFont;
	int				rowheight;
	
	useFont = [NSFont fontWithName:@"Lucida Grande" size:12];
	rowheight = [useFont ascender] - [useFont descender] + 1;
	
	[searchResultsPanel orderOut:nil];
	[searchResultsPanel setHidesOnDeactivate:TRUE];

	[searchResultsPanel setHasShadow:TRUE];

	[searchResultsView customizeSelfWithController:self];
	[searchResultsView setBackgroundColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
	[searchResultsView setGridStyleMask:NSTableViewSolidVerticalGridLineMask | NSTableViewSolidHorizontalGridLineMask];
	[searchResultsView setRowHeight:rowheight];

	
	resDataSource = [[SearchResultsSource alloc] initWithTableView:searchResultsView];
	[searchResultsView setDataSource:resDataSource];
	
	songsFromSource = (char**)[resDataSource songs];

#ifdef _MAIN_DEBUG_
/*	printf("sample:  %s   %s\n", (char*)[(NSString*)songsFromSource[1] cString],
						(char*)[(NSString*)songsFromSource[4] cString]);*/
#endif
	
	[searchResultsPanel setFrameOrigin: bottomleft];
	
	[searchResultsPanel setTitle:[NSString stringWithFormat:@"%i results", [resDataSource updateSongsWithString:""]]];
	
	[resDataSource retain];
}

/* 
 * Install the global hotkey combination that brings up the search dialog.
 * As of now, this key is immutable, but modification will eventually be an
 * "extra" feature (as it should be in all good software!).
 *
 * ADDED 11/04/04 : Now can back/playpause/next with F1/F2/F3.
 */
-(void) setupGlobalHotKeys {
	EventTypeSpec   whichTypes;
	EventHandlerUPP defHandler;
	EventHotKeyID  f1Ref, f2Ref, f3Ref, f4Ref;
	
	OSStatus		err;
	
	hotKeyID.signature = kSearchPanelActiveCode;
	hotKeyID.id = 1;
	
	f1Ref.signature = 'itns';
	f1Ref.id = 1;
	f2Ref.signature = 'itns';
	f2Ref.id = 2;
	f3Ref.signature = 'itns';
	f3Ref.id = 3;
	f4Ref.signature = 'itns';
	f4Ref.id = 4;
	

	defHandler = NewEventHandlerUPP(HandleHotKey);
	if(!defHandler)
		fprintf(stderr, "Didn't register UPP\n");
	
	whichTypes.eventClass = kEventClassKeyboard;
	whichTypes.eventKind = kEventHotKeyReleased;
	
	err = InstallApplicationEventHandler(defHandler,1,&whichTypes,searchPanel,NULL);
	if(err != noErr)
		fprintf(stderr, "COULDN'T INSTALL APP EVENT HANDLER: %ld\n", (long)err);
	
	err = RegisterEventHotKey(kHotKeyCode, kHotKeyModifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyPtr);

	// Now for the direct keyboard control
	err = RegisterEventHotKey(kF1KeyCode, kHotKeyModifiers, f1Ref, GetApplicationEventTarget(), 0, &hotKeyPtr);
	err = RegisterEventHotKey(kF2KeyCode, kHotKeyModifiers, f2Ref, GetApplicationEventTarget(), 0, &hotKeyPtr);
	err = RegisterEventHotKey(kF3KeyCode, kHotKeyModifiers, f3Ref, GetApplicationEventTarget(), 0, &hotKeyPtr);
	err = RegisterEventHotKey(kF4KeyCode, kHotKeyModifiers, f4Ref, GetApplicationEventTarget(), 0, &hotKeyPtr);
	
	if(err != noErr)
		fprintf(stderr, "ERROR REGISTERING THE HOTKEY: %ld\n", (long)err);
	
	//InstallWindowEventHandler(window, NewEventHandlerUPP(HandleHotKey), 1, &whichTypes, NULL, NULL);
}

-(void) hideHeadsUpDisplay: (id) sender {
	alphaTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
					target:self selector:sel_registerName("fadeMore:")
					userInfo:nil
					repeats:TRUE];
//	[headsUpTimer release];
	headsUpTimer = nil;

}

-(void) fadeMore: (id) sender {
	if ([headsUpPanel alphaValue] <= 0) {
		[alphaTimer invalidate];
//		[alphaTimer release];
		alphaTimer = nil;
		[headsUpPanel orderOut:self];
	} else {
		printf("fading headsuppanel\n");
		[headsUpPanel setAlphaValue:([headsUpPanel alphaValue]-kAlphaIncrement)];
	}
}

-(void) cancelFade {
	if(alphaTimer) {
		[alphaTimer invalidate];
//		[alphaTimer release];
		alphaTimer = nil;
//		[headsUpPanel setAlphaValue:kMaxAlpha];
	}
}


-(void) showHeadsUp {
	printf("*** 1 ***\n");
	[headsUpPanel setAlphaValue:kMaxAlpha];
	printf("*** 2 ***\n");
	[headsUpPanel orderFront:self];
	printf("*** 3 ***\n");
}


-(void) displayStatusIcon {
	printf("Testing for actionPanelTimer\n");
/*	if(!statusFading) {
		[actionPanelTimer invalidate];
	}*/
	
//	printf("Main loop\n");
	if(!statusFading) {
		printf("check for active timer\n");
		if(actionPanelTimer != NULL) {
			printf("actionPanelTimer !=NULL\n");
			if([actionPanelTimer isValid]) {
				printf("actionPanelTimer isValid\n");
				[actionPanelTimer invalidate];
			}
		}
		
		printf("resetting everything\n");
//		startingTime = [NSDate dateWithTimeIntervalSinceNow:2];
			
		[actionbgpanel setAlphaValue:kActionBGAlpha];
		[actioniconpanel setAlphaValue:kActionIconAlpha];
	
/*		if(shuffleIsOn)
			[actioniconpanel setIcon:@"shuffleOnIcon"];
		else [actioniconpanel setIcon:@"shuffleOffIcon"]; */
	
		[actionbgpanel orderFront:self];
		[actioniconpanel orderFront:self];
		
		actionPanelTimer = [NSTimer scheduledTimerWithTimeInterval:kActionInitialDelay
					target:self selector:sel_registerName("displayStatusIcon")
					userInfo:[headsUpTimer userInfo]
					repeats:FALSE];
		statusFading = TRUE;
	} else {	
//		printf("fading: %f\n", [actionbgpanel alphaValue]);
		[actionbgpanel setAlphaValue:[actionbgpanel alphaValue] - kActionBGAlphaInterval];
		[actioniconpanel setAlphaValue:[actioniconpanel alphaValue] - kActionIconAlphaInterval];
		actionPanelTimer = [NSTimer scheduledTimerWithTimeInterval:kActionFadeIncrement
					target:self selector:sel_registerName("displayStatusIcon")
					userInfo:[headsUpTimer userInfo]
					repeats:FALSE];
	}
		
	if([actioniconpanel alphaValue] <= 0) {
		printf("removing panel\n");
		[actioniconpanel orderOut:self];
		[actionbgpanel orderOut:self];
		if((actionPanelTimer != NULL) && [actionPanelTimer isValid]) { printf("invalidating timer\n"); [actionPanelTimer invalidate]; actionPanelTimer = NULL; printf("done\n");}
		statusFading = FALSE;
	}
}


-(void) checkForNewSong:(id) notification {
	NSAppleEventDescriptor	*AED;
	NSDictionary*			returnDict;

	returnDict = [NSDictionary dictionary];
	
	AED = [pollSongID executeAndReturnError:&returnDict];
	
	if ([returnDict count] > 0 &&
			([returnDict objectForKey:@"NSAppleScriptErrorNumber"] != [[NSNumber numberWithInt:-1728] stringValue])) {
		//printf("error!\n");
#ifdef _MAIN_DEBUG_
		NSLog([returnDict description]);
#endif
		[searchPanel setCurrentSong:@""];
		[searchPanel setCurrentAlbum:@""];
		[searchPanel setCurrentArtist:@""];
		[searchPanel updateArtistsMenu:NULL];
		[searchPanel updateAlbumMenu:NULL];
	} else if (AED && ![oldSong isEqualTo:[AED stringValue]]) {	
		[searchPanel setCurrentSong:@""];
		[searchPanel setCurrentAlbum:@""];
		[searchPanel setCurrentArtist:@""];
		[self printNotification:[AED stringValue]];
		printf("*** NEW SONG ***\n");
	}
}


-(void) printNotification:(NSString*)songid {
	NSAppleEventDescriptor* AED;
	NSDictionary*   returnDict;
	NSString*		artistname, *cursong, *curartist, *curalbum;
	
	cursong = @"";
	curartist = @"";
	curalbum = @"";
	
	if(headsUpTimer && [headsUpTimer isValid]) {
		[headsUpTimer invalidate];
		//[headsUpTimer release];
	}
			
	if(alphaTimer)
		[self cancelFade];				
	
	headsUpTimer = nil;

	oldSong = songid;
	[oldSong retain];
	
	AED = [pollSongName executeAndReturnError:&returnDict];	
	
	if(AED) {
		[nameField setStringValue:(NSString*) [AED stringValue]];
		/* change menu notification item */
		cursong = [AED stringValue];
	}
	
	artistname = @"";
	
	AED = [pollSongArtist executeAndReturnError:&returnDict];
	if(AED) {
		/* update artists menu */
		if([[AED stringValue] length] <= 0)
			[searchPanel updateArtistsMenu:NULL];
		else [searchPanel updateArtistsMenu:[resDataSource songsForArtist:(NSString*)[AED stringValue]]];
		[artistField setStringValue:(NSString*) [AED stringValue]];
		/* change menu notification item */
		[artistMenuItem setTitle:[AED stringValue]];
//				[searchPanel setCurrentArtist:[AED stringValue]];
		artistname = (NSString*)[AED stringValue];
		curartist = artistname;
	} else [searchPanel updateArtistsMenu:NULL];
	
	AED = [pollSongAlbum executeAndReturnError:&returnDict];
	if(AED) {
		if([[AED stringValue] length] <= 0)
			[searchPanel updateAlbumMenu:NULL];
		else if(artistname)
			[searchPanel updateAlbumMenu:[resDataSource songsForAlbum:(NSString*)[AED stringValue] artist:(NSString*)artistname]];
		else
			[searchPanel updateAlbumMenu:[resDataSource songsForAlbum:(NSString*)[AED stringValue] artist:@""]];
		[albumField setStringValue:(NSString*) [AED stringValue]];
		/* change menu notification item */
		[albumMenuItem setTitle:[AED stringValue]];
		//[searchPanel setCurrentAlbum:[AED stringValue]];
		curalbum = [AED stringValue];
	} else {
		[searchPanel updateAlbumMenu:NULL];
	}
			
	AED = [pollSongLength executeAndReturnError:&returnDict];
	if(AED)
		[lengthField setStringValue:(NSString*) [AED stringValue]];

	[searchPanel setCurrentVitals:cursong artist:curartist album:curalbum];
	
	printf("*** SHOWING HEADSUP ***\n");
	[self showHeadsUp];
	
	headsUpTimer = [NSTimer scheduledTimerWithTimeInterval:4
					target:self selector:sel_registerName("hideHeadsUpDisplay:")
					userInfo:[headsUpTimer userInfo]
					repeats:FALSE];

	[searchPanel setCurrentVitals:cursong artist:curartist album:curalbum];
}

-(BOOL) testITunesOpen {
	NSDictionary*	nullDict;
	NSAppleEventDescriptor*		ASret;

//	ASret = [testForITunesAS executeAndReturnError:&nullDict];
	
//	NSLog([ASret stringValue]);
	
	return true;
}


-(IBAction) backTrack: (id) sender {
	NSString*		preString = @"tell application \"Finder\"\nif number of (every process whose name is \"iTunes\") > 0 then\n";
	NSString*		postString = @"end if\nend tell\n";
	NSString*		scriptStr = [NSString stringWithFormat:@"%@%@%@", preString, @"tell application \"iTunes\" to back track\n", postString];
	NSAppleScript*  sendScript;
	NSDictionary*  returnDict;
	
	if(![self testITunesOpen]) return;
	
	returnDict = [NSDictionary dictionary];
	sendScript = [[NSAppleScript alloc] initWithSource:scriptStr];
	
	[sendScript executeAndReturnError:&returnDict];

	statusFading = FALSE;	/* send us into the initial loop in displayShuffleIcon: */
	
	[actioniconpanel setState:kBackTrack];

	[self displayStatusIcon];
}


-(IBAction) forwardTrack: (id) sender {
	NSString*		preString = @"tell application \"Finder\"\nif number of (every process whose name is \"iTunes\") > 0 then\n";
	NSString*		postString = @"end if\nend tell\n";
	NSString*		scriptStr = [NSString stringWithFormat:@"%@%@%@", preString, @"tell application \"iTunes\" to next track\n", postString];
	NSAppleScript*  sendScript;
	NSDictionary*  returnDict;
	
//1											if(![self testITunesOpen]) return;

	returnDict = [NSDictionary dictionary];
	sendScript = [[NSAppleScript alloc] initWithSource:scriptStr];
	
	[sendScript executeAndReturnError:&returnDict];
	
	statusFading = FALSE;	/* send us into the initial loop in displayShuffleIcon: */
	
	[actioniconpanel setState:kNextTrack];

	[self displayStatusIcon];
}

-(IBAction) playPause: (id) sender {
	NSString*		preString = @"tell application \"Finder\"\nif number of (every process whose name is \"iTunes\") > 0 then\n";
	NSString*		postString = @"end if\nend tell\n";
	NSString*		scriptStr = [NSString stringWithFormat:@"%@%@%@", preString, @"tell application \"iTunes\" to playpause\n", postString];
	NSString*		queryStr = [NSString stringWithFormat:@"%@%@%@", preString, @"tell application \"iTunes\"\nget player state\nend tell\n", postString];
	NSAppleScript*  sendScript;
	NSAppleEventDescriptor* AED;
	NSDictionary*  returnDict;
		
	if(![self testITunesOpen]) return;
	
	returnDict = [NSDictionary dictionary];
	sendScript = [[NSAppleScript alloc] initWithSource:scriptStr];
	
	[sendScript executeAndReturnError:&returnDict];
	
	sendScript = [[NSAppleScript alloc] initWithSource:queryStr];
	
	AED = [sendScript executeAndReturnError:&returnDict];
	
	printf("playpause state: %s\n", [[[AED stringValue] substringFromIndex:[[AED stringValue] length]] cString]);
	
	statusFading = FALSE;
	if([[[AED stringValue] substringFromIndex:([[AED stringValue] length] -1)] compare:@"P"] == 0) {
		[actioniconpanel setState:kPlayTrack];
	} else {
		[actioniconpanel setState:kPauseTrack];
	}

	[self displayStatusIcon];
		
#ifdef _MAIN_DEBUG_
	if([returnDict count] > 0) {
		NSLog([returnDict description]);
	}
#endif
		
	[self setNameString];
}

-(IBAction) toggleShuffle: (id) sender {
	NSString*		preString = @"tell application \"Finder\"\nif number of (every process whose name is \"iTunes\") > 0 then\n";
	NSString*		postString = @"end if\nend tell\n";
	NSString*		scriptStr = [NSString stringWithFormat:@"%@%@%@", preString, @"tell application \"iTunes\"\nif shuffle of current playlist is true then\nset shuffle of current playlist to false\nelse\nset shuffle of current playlist to true\nend if\nend tell\n", postString];
	NSString*		testShuffleStr = [NSString stringWithFormat:@"%@%@%@", preString, @"tell application \"iTunes\"\nget shuffle of current playlist\nend tell\n", postString];
	NSAppleScript*	shuffleScript;
	NSAppleEventDescriptor*	AED;
	NSDictionary*	returnDict;
	int				shuffleIsOn;


	shuffleScript = [[NSAppleScript alloc] initWithSource:testShuffleStr];
	AED = [shuffleScript executeAndReturnError:&returnDict];
	
//	printf("%i  ||%s\n||\n\n", [AED numberOfItems], [[AED stringValue] cString]);

//	[shuffleMenuItem setTitle:@"testingtestingtesting"];
	printf("AED: %s\n", [[AED stringValue] cString]);
	
	if([[AED stringValue] compare:@"true"] == 0) {
		printf("shuffleIsOff\n");
		shuffleIsOn = kShuffleOff;
	} else {
		printf("shuffleIsOn\n");
		shuffleIsOn = kShuffleOn;
	}
	
	returnDict = [NSDictionary dictionary];
	shuffleScript = [[NSAppleScript alloc] initWithSource:scriptStr];
	
	[shuffleScript executeAndReturnError:&returnDict];
	
	statusFading = FALSE;	/* send us into the initial loop in displayShuffleIcon: */
	
	[actioniconpanel setState:shuffleIsOn];

	[self displayStatusIcon];

#ifdef _MAIN_DEBUG_
	if([returnDict count] > 0) {
		NSLog([returnDict description]);
	}
#endif

	[self updateShuffleMenu];
}


-(void) updateShuffleMenu {	
	NSString*		preString = @"tell application \"Finder\"\nif number of (every process whose name is \"iTunes\") > 0 then\n";
	NSString*		postString = @"end if\nend tell\n";
	NSString*		scriptStr = [NSString stringWithFormat:@"%@%@%@", preString, @"tell application \"iTunes\"\nget shuffle of current playlist\nend tell\n", postString];
	NSAppleScript*	shuffleScript;
	NSAppleEventDescriptor*	AED;
	NSDictionary*	returnDict;
	
	shuffleScript = [[NSAppleScript alloc] initWithSource:scriptStr];
	AED = [shuffleScript executeAndReturnError:&returnDict];
	
//	printf("%i  ||%s\n||\n\n", [AED numberOfItems], [[AED stringValue] cString]);

//	[shuffleMenuItem setTitle:@"testingtestingtesting"];
	if([[AED stringValue] compare:@"true"] == 0)
		[shuffleMenuItem setTitle:@"Turn Shuffle Off"];
	else [shuffleMenuItem setTitle:@"Turn Shuffle On"];
}


-(void) setNameString {
	NSAppleEventDescriptor* AED;
	NSDictionary*  returnDict;
	
	returnDict = [NSDictionary dictionary];
//	sendScript = [[NSAppleScript alloc] initWithSource:scriptStr];
	
	AED = [pollSongName executeAndReturnError:&returnDict];
	
	if ([returnDict count] > 0) {
		//printf("error!\n");
#ifdef _MAIN_DEBUG_
		NSLog([returnDict description]);
#endif
	} else if (AED) {
		[nameField setStringValue:(NSString*) [AED stringValue]];
//		NSLog([AED stringValue]);
//		//printf("num: %i\n", [AED numberOfItems]);
	}
}


-(void) dealloc {
	UnregisterEventHotKey(hotKeyPtr);
}

/*
 * This handles updating the search results pane when new text is entered.  It is
 * meant to be called from the search panel's keyUp: method.
 */
 
-(void) changeResultsSource:(const char*) newText {
#ifdef _MAIN_DEBUG_
	printf("characters: %s\n", newText);
#endif
	int		totNum= 0;
	totNum = [resDataSource updateSongsWithString:newText];
	[searchResultsView reloadData];

	if([searchResultsView selectedRow] < 0)
		[self moveUpOneSong];
	
	[searchResultsPanel setTitle:[NSString stringWithFormat:@"%i results", totNum]];
	
/*	if(![searchPanel isKeyWindow])
		[searchPanel makeKeyAndOrderFront:nil];
	if(![searchResultsPanel isMainWindow])
		[searchResultsPanel orderFront:nil];*/
	
#ifdef _MAIN_DEBUG_
	printf("BOING!\n");
#endif
}

-(void) resetResultsSource {
	[resDataSource resetSongChest];
}

-(void) moveUpOneSong {
	int newrow = 0;
	if([searchResultsView selectedRow] > 1) newrow = ([searchResultsView selectedRow] - 1);
	[searchResultsView selectRowIndexes:[NSIndexSet indexSetWithIndex:newrow] byExtendingSelection:FALSE];
	[searchResultsView scrollRowToVisible:newrow];
}

-(void) moveDownOneSong {
	int newrow = [searchResultsView numberOfRows] - 1;
	if([searchResultsView selectedRow] < newrow) newrow = ([searchResultsView selectedRow] + 1);
	[searchResultsView selectRowIndexes:[NSIndexSet indexSetWithIndex:newrow] byExtendingSelection:FALSE];
	[searchResultsView scrollRowToVisible:newrow];
}

-(void) playSongRemotely {
	int				dbid;
	NSString*		playStr;
	NSAppleScript*  playAS;
	NSDictionary*   errDict;
	
	[self hideEverything];
	
	if([searchResultsView selectedRow] >= 0)
		dbid = [resDataSource DBIDForRowIndex:[searchResultsView selectedRow]];
	else return;
	
#ifdef _MAIN_DEBUG_
	printf("gonna play that song, play that song, play that song...\n");
#endif

	playStr = [NSString stringWithFormat:@"tell application \"iTunes\" to play the first item of (every track of playlist \"Library\" whose database ID is %i)", dbid];
	errDict = [NSDictionary dictionary];
	playAS = [[NSAppleScript alloc] initWithSource:playStr];
	
#ifdef _MAIN_DEBUG_
	printf("TuneSiftInterface::playSongRemotely:\n\tdbid: %i\n\tplayStr: %s\n", dbid, [playStr cString]);
#endif

	[playAS executeAndReturnError:&errDict];
	
	if([errDict count] > 0)
		NSLog([errDict description]);

	[self resetResultsSource];

#ifdef _MAIN_DEBUG_
	printf("played that song, that song, that song...\n");
#endif
}

-(void) playSongRemotely:(int) dbid {
	NSString*		playStr;
	NSAppleScript*  playAS;
	NSDictionary*   errDict;
	
	[self hideEverything];
	
#ifdef _MAIN_DEBUG_
	printf("gonna play that song, play that song, play that song...\n");
#endif

	playStr = [NSString stringWithFormat:@"tell application \"iTunes\" to play the first item of (every track of playlist \"Library\" whose database ID is %i)", dbid];
	errDict = [NSDictionary dictionary];
	playAS = [[NSAppleScript alloc] initWithSource:playStr];
	
#ifdef _MAIN_DEBUG_
	printf("TuneSiftInterface::playSongRemotely:\n\tdbid: %i\n\tplayStr: %s\n", dbid, [playStr cString]);
#endif

	[playAS executeAndReturnError:&errDict];
	
	if([errDict count] > 0)
		NSLog([errDict description]);

	[self resetResultsSource];

#ifdef _MAIN_DEBUG_
	printf("played that song, that song, that song...\n");
#endif
}

-(void) setupToSearch {
	int		totNum= 0;
	totNum = [resDataSource updateSongsWithString:""];
	
	[searchResultsPanel setTitle:[NSString stringWithFormat:@"%i results", totNum]];
	
	[searchPanel setupToSearch];
	[resDataSource resetSongChest];
	[searchResultsView reloadData];
	
//	[NSApp activateIgnoringOtherApps:FALSE];
	//[NSApp runModalForWindow:searchPanel];
	[self showEverything];
}

-(void) showEverything {
//	[searchPanel orderFront:nil];
//	[searchPanel makeKeyWindow];
	[searchPanel makeKeyAndOrderFront:self];
	[searchResultsPanel orderFront:self];
//	[searchPanel setViewsNeedDisplay:TRUE];
}

-(void) hideEverything {
//	[NSApp abortModal];
	[searchResultsPanel orderOut:nil];
/*	[searchResultsView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:FALSE];
	[searchResultsView scrollRowToVisible:0];*/
	[searchPanel wipeSlate];
}

-(void) needToHide:(NSNotification*) obj {
	printf("got notification, hiding everything\n");
	[self hideEverything];
	printf("hidden (theoretically)\n");
}

-(id) getAppMenu {
	return appMenu;
}

-(void) addCurrentSongToPlaylist:(NSString*)playlistName {
	NSString*  asstring;
	NSAppleScript* as;
	NSAppleEventDescriptor* AED;
	NSDictionary* returnDict;
	
	asstring = [NSString stringWithFormat:@"tell application \"iTunes\" to add (get location of current track) to playlist \"%@\"", playlistName];
	returnDict = [NSDictionary dictionary];
	as = [[NSAppleScript alloc] initWithSource:asstring];
	AED = [as executeAndReturnError:&returnDict];
	
#ifdef _MAIN_DEBUG_
	if([returnDict count] > 0) NSLog([returnDict description]);
#endif
}

@end


pascal OSStatus HandleHotKey(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData) {
	EventHotKeyID		theID;
	
#ifdef _MAIN_DEBUG_
	printf("got hotkey event\n");
#endif
	GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(EventHotKeyID), NULL, &theID);
	if(theID.signature == 'itns') {
		switch(theID.id) {
			case 1:
				[gSelfBridge backTrack:NULL];
				break;
				
			case 2:
				[gSelfBridge playPause:NULL];
				break;
			
			case 3:
				[gSelfBridge forwardTrack:NULL];
				break;
			
			case 4:
				[gSelfBridge toggleShuffle:NULL];
				break;
			
			default:
				break;
		}
	} else {
		[gSelfBridge setupToSearch];
	}
	
	return 0;
}