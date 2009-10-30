//
//  SongSearchBox.m
//  TuneSift
//
//  Created by Malcolm McFarland on Mon Nov 01 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "SongSearchPanel.h"

const int	kNSNonactivatingPanelMask = 1 << 7;	// specify a panel that does not activate owning application

const int   kNameMenuItem = 0;
const int	kLibraryMenu = 1;
const int   kArtistMenuItem = 2;
const int   kAlbumMenuItem = 3;
const int   kPlaylistsMenuItem = 5;

@implementation SongSearchPanel

-(SongSearchPanel*) initWithController:(id)cont boundary:(NSRect)bounds{/**/
	NSSize			sFrame = [[NSScreen mainScreen] frame].size;
	
    self = [super initWithContentRect:bounds
//					styleMask:NSTitledWindowMask | NSUtilityWindowMask | NSTexturedBackgroundWindowMask | kNSNonactivatingPanelMask
					styleMask:NSNonactivatingPanelMask
					backing:NSBackingStoreBuffered
					defer:FALSE];
	
	TuneSiftController = cont;
	
//	[super init];
//	[self setBackgroundColor:[NSColor colorWithDeviceRed:0.0 green:0.05 blue:0.0 alpha:1]];
//	[self setBackgroundColor:[NSColor colorWithDeviceRed:0.9 green:0.5 blue:0 alpha:1.0]];
//	[self setBackgroundColor:[NSColor colorWithDeviceRed:0.10 green:0.15 blue:0.05 alpha:1]];
	[self setBackgroundColor:[NSColor clearColor]];
	[self setLevel:NSStatusWindowLevel];
	[self setAlphaValue:.9];
	[self setHidesOnDeactivate:FALSE];
//	[self setWorksWhenModal:TRUE];// :malcolm:20041115 // :malcolm:20041115 
	[self setFloatingPanel:TRUE];
//	[self setShowsResizeIndicator:FALSE];

	[self setOpaque:FALSE];
/*	
	[self initPanelView];
	[self initPromptText];
	[self initCurrentSong];
	[self initSongChooser];
	[self initPopupMenu];
	[self setupPlaylistsMenu];*/

	searchStr = [NSMutableString stringWithCapacity:100];
	
	[searchStr retain];
	return self;
}
/*
-(void) awakeFromNib {
}*/


-(BOOL) canBecomeKeyWindow {
	return TRUE;
}

-(BOOL) becomesKeyOnlyIfNeeded {
	return FALSE;
}

-(BOOL) needsPanelToBecomeKey {
	return FALSE;
}

-(BOOL) acceptsFirstResponder {
	return TRUE;
}

	
/* Initialize a custom view for the interior of the window */
-(void) initPanelView {
	panelView = [[SearchPanelView alloc] initWithFrame:[self frame]];
	[self setContentView:panelView];
	[self initPromptText];
	[self initCurrentSong];
	[self initCurrentVitals];
	[self initSongChooser];
	[self initPopupMenu];
	[self setupPlaylistsMenu];

	[self setHasShadow:FALSE];
	
	[panelView retain];
}

/* Initialize the custom "choose a song" textfield */
-(void) initPromptText {
	NSRect			mainFrame = [[self contentView] frame];
	NSPoint			origin = mainFrame.origin;
	NSSize			dim = mainFrame.size;
	NSRect			framerect = NSMakeRect(20, 0, 380, 55);
	
//	printf("x,y,w,h: %f %f %f %f\n", origin.x, origin.y, dim.width, dim.height);
	prompt = [[NSTextField allocWithZone:[self zone]] initWithFrame:framerect];
	[prompt setFont:[NSFont fontWithName:@"Arial" size:15]];
	[prompt setStringValue:@"Please type part of a song, artist, or album name:"];
	[prompt setHidden:FALSE];
	[prompt setDrawsBackground:FALSE];
	[prompt setEditable:FALSE];
	[prompt setSelectable:FALSE];
	[prompt setBezeled:FALSE];
	[prompt setTextColor:[NSColor colorWithDeviceRed:.4 green:.4 blue:.7 alpha:1]];
//	[[prompt cell] sizeToFit];
//	[prompt setBackgroundColor:[NSColor colorWithDeviceRed:1 green:0 blue:0 alpha:1]];
	[[self contentView] addSubview:prompt];
	
	[prompt retain];
}

/* Setup and display the combo box that filters out song titles. */
-(void) initSongChooser {
	NSRect			framerect = NSMakeRect(20, kSearchPanelSearchFieldBottomIndent, kSearchPanelWidth-40, 20);
	
	songs = [[NSTextField alloc] initWithFrame:framerect];
//	[self setContentView:songs];
	
//	songsCell = [[NSTextFieldCell alloc] initTextCell:@""];
	
//	[songs setCell:songsCell];
//	[songsCell setDrawsBackground:TRUE];
	
//	[songs setFont:[NSFont fontWithName:@"Lucida Grande" size:11]];
	[songs setEditable:FALSE];
	[songs setEnabled:FALSE];
	[songs setSelectable:FALSE];
	[songs setTextColor:[NSColor colorWithDeviceRed:0.95 green:1 blue:0.95 alpha:1]];
	[songs setBackgroundColor:[NSColor colorWithDeviceRed:0.5 green:0.1 blue:0.0 alpha:1]];
//	[songs setAlphaValue:0.1];
	[songs setBordered:TRUE];		
//	[songs setDrawsBackground:TRUE];
//	[songs setTextColor:redColor];
//	[[songs cell] setPlaceholderString:@"Type part of a song name here"];
//	[songs setStringValue:@"This is my only line."];
	if(![songs becomeFirstResponder])
		fprintf(stderr, "SongSearchPanel::initSongChooser : couldn't become first responder.\n");
	[[self contentView] addSubview:songs];
//	[[songs cell] drawWithFrame:framerect inView:[self contentView]];
	
	[songs retain];
}
	
-(void) initPopupMenu {
	NSRect			framerect = NSMakeRect(kSearchPanelWidth-50, kSearchPanelHeight-30, 20, 20);
	NSString*		urlHolder;
	NSImage*		arrowimage;
#ifdef _MAIN_DEBUG_
	printf("initializing initPopupMenu\n");
#endif

	appmenu = [[NSPopUpButton alloc] initWithFrame:framerect pullsDown:TRUE];
	[appmenu setMenu:[TuneSiftController getAppMenu]];
	[appmenu setTitle:@""];
	[[appmenu cell] setBezelStyle:NSShadowlessSquareBezelStyle];
	[[appmenu cell] setTransparent:TRUE];
	
	appmenuview = [[NSImageView alloc] initWithFrame:framerect];

	if(urlHolder = [[NSBundle bundleForClass:[self class]] pathForResource:@"menuarrow-1" ofType:@"gif"]) {
		if(!(arrowimage = [[NSImage alloc] initWithContentsOfFile:urlHolder])) {
			printf("no image!\n");
			NSLog(@"urlHolder: %@", urlHolder);
		} else {
			[appmenuview setImage:arrowimage];
			[arrowimage retain];
		}
	} else
		fprintf(stderr, "songsearchpanel::initPopupMenu : couldn't get image\n");
		
	[[self contentView] addSubview:appmenuview];
	[[self contentView] addSubview:appmenu];
	
	[appmenu retain];
	[appmenuview retain];
}

-(void) setupPlaylistsMenu {
	NSString*		asStr, *objstr;
	NSAppleEventDescriptor* AED;
	NSAppleScript*  as;
	NSDictionary*   returnDict;
	NSArray*		playlists;
	NSEnumerator*   playlistEnum;
	NSMenu*			playlistMenu;
	int				i;

	printf("here!\n");
	returnDict = [NSDictionary dictionary];
	asStr = @"tell application \"iTunes\" to get name of every user playlist whose smart is false\n";
	as = [[NSAppleScript alloc] initWithSource:asStr];
	AED = [as executeAndReturnError:&returnDict];

	printf("there\n");
	if([returnDict count] > 0) {
		NSLog([returnDict description]);
		return;
	} /*else {
		if([AED data])//playlists = (NSArray*)[[AED data] bytes];
			NSLog(@"%i     %@", [AED numberOfItems], [[AED descriptorAtIndex:1] stringValue]);
//		NSLog(@"%i %s %@ %@\n", [AED numberOfItems], [[AED data] bytes], [AED stringValue], (NSString*)[[AED data] description]);
	}*/
	printf("everywhere!\n");

	if(!(playlistMenu = [[appmenu itemAtIndex:kPlaylistsMenuItem] submenu])) {
#ifdef _MAIN_DEBUG_
		NSLog([[appmenu itemAtIndex:kPlaylistsMenuItem] title]);
		printf("NO PLAYLISTMENU!!!!!\n");
#endif
	}
	
	for(i = 0; i < [AED numberOfItems]; i++) {
		printf("here two!\n");
		[[playlistMenu insertItemWithTitle:[[AED descriptorAtIndex:(i+1)] stringValue] action:@selector(songToPlaylist:) keyEquivalent:@"" atIndex:i] retain];
	}
}


-(void) setupLibraryMenu:(NSDictionary*)entirelibrary {
	NSMenu			*popupmenu, *artistmenu, *albummenu;
	NSEnumerator*	dataenum, *albumenum, *albumkeys, *artistkeys;
	NSArray*		newitem, *newalbum;
	NSString*		albumtitle, *nextartist;
	int				i, numofitems;
	
	popupmenu =  [[appmenu itemAtIndex:kLibraryMenu] submenu];
#ifdef _MENU_DEBUG_
	NSLog(@"data passed: %@", [data description]);
	NSLog(@"number of menu items:%i", [popupmenu numberOfItems]);
#endif
	numofitems = [popupmenu numberOfItems];
	for(i = 0; i < numofitems; i++) {
#ifdef _MENU_DEBUG_
		NSLog(@"removing from artists menu: %@", [[popupmenu itemAtIndex:0] title]);
#endif
		[popupmenu removeItemAtIndex:0];
	}
	
	if(!entirelibrary) return;
	
//	albumenum = [data objectEnumerator];
	artistkeys = [[[entirelibrary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectEnumerator];
//	printf("1\n");
	while(nextartist = (NSString*)[artistkeys nextObject]) {
		artistmenu = [[NSMenu allocWithZone:[self zone]] initWithTitle:@""];
		[artistmenu retain];
	
//	printf("artist\n");
		[popupmenu addItemWithTitle:(NSString*)nextartist action:nil keyEquivalent:@""];
		[popupmenu setSubmenu:artistmenu forItem:[popupmenu itemWithTitle:nextartist]];
		
		albumkeys = [[[[entirelibrary objectForKey:nextartist] allKeys]sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectEnumerator];

	#ifdef _MENU_DEBUG_
		NSLog(@"number of menu items:%i", [popupmenu numberOfItems]);
	#endif
		while(albumtitle = (NSString*)[albumkeys nextObject]) {
//	printf("album\n");
			dataenum = [[[entirelibrary objectForKey:nextartist] objectForKey:albumtitle] objectEnumerator];
			
			albummenu = [[NSMenu allocWithZone:[self zone]] initWithTitle:@""];
			[albummenu retain];
			
			[artistmenu addItemWithTitle:(NSString*)albumtitle action:nil keyEquivalent:@""];
			[artistmenu setSubmenu:albummenu forItem:[artistmenu itemWithTitle:albumtitle]];
			
			while(newitem = (NSArray*)[dataenum nextObject]) {
		#ifdef _MENU_DEBUG_
				NSLog(@"adding to artists menu: %@", [newitem objectAtIndex:0]);
		#endif
//	printf("song\n");
				[albummenu addItemWithTitle:[newitem objectAtIndex:0] action:@selector(playSong:) keyEquivalent:@""];
				[[albummenu itemWithTitle:[newitem objectAtIndex:0]] setTag:[[newitem objectAtIndex:1] intValue]];
			}
		}
	}
	
	printf("total number of items: %i\n", [popupmenu numberOfItems]);
}

-(void) initCurrentSong {
	NSRect			framerect = NSMakeRect(30, kSearchPanelHeight-28, kSearchPanelWidth-10, 18);

	currentsong = [[NSTextField allocWithZone:[self zone]] initWithFrame:framerect];
	[currentsong setFont:[NSFont fontWithName:@"Geneva" size:13]];
//	[currentsong setStringValue:@"Playing: "];
	[currentsong setHidden:FALSE];
	[currentsong setDrawsBackground:FALSE];
	[currentsong setEditable:FALSE];
	[currentsong setSelectable:FALSE];
	[currentsong setBezeled:FALSE];
	[currentsong setTextColor:[NSColor colorWithDeviceRed:.9 green:0.9 blue:0.7 alpha:1]];
//	[[prompt cell] sizeToFit];
//	[prompt setBackgroundColor:[NSColor colorWithDeviceRed:1 green:0 blue:0 alpha:1]];
	[[self contentView] addSubview:currentsong];
	
	[currentsong retain];
}

-(void) initCurrentVitals {
	NSRect			framerect = NSMakeRect(30, kSearchPanelHeight-57, kSearchPanelWidth-10, 30);

	currentvitals = [[NSTextField allocWithZone:[self zone]] initWithFrame:framerect];
	[currentvitals setFont:[NSFont fontWithName:@"Geneva" size:12]];
//	[currentsong setStringValue:@"Playing: "];
	[currentvitals setHidden:FALSE];
	[currentvitals setDrawsBackground:FALSE];
	[currentvitals setEditable:FALSE];
	[currentvitals setSelectable:FALSE];
	[currentvitals setBezeled:FALSE];
	[currentvitals setTextColor:[NSColor colorWithDeviceRed:1 green:0.8 blue:0.8 alpha:1]];
//	[[prompt cell] sizeToFit];
//	[prompt setBackgroundColor:[NSColor colorWithDeviceRed:1 green:0 blue:0 alpha:1]];
	[[self contentView] addSubview:currentvitals];
	
	[currentvitals retain];
}


-(void) setCurrentSong:(NSString*) newtitle {
	[currentsong setStringValue:[NSString stringWithFormat:@"%@", newtitle]];
}

-(void) setCurrentAlbum:(NSString*) newalbum {
	[[appmenu itemAtIndex:kAlbumMenuItem] setTitle:newalbum];
}

-(void) setCurrentArtist:(NSString*) newartist {
	[[appmenu itemAtIndex:kArtistMenuItem] setTitle:newartist];

}

-(void) setCurrentVitals:(NSString*)cursong artist:(NSString*)curartist album:(NSString*)curalbum {
	[currentsong setStringValue:[NSString stringWithFormat:@"%@", cursong]];
	[currentvitals setStringValue:[NSString stringWithFormat:@"%@\n%@", curartist, curalbum]];
}

-(void) songToPlaylist:(id)sender {
	NSMenuItem*		menusend = (NSMenuItem*)sender;
	
	[TuneSiftController addCurrentSongToPlaylist:[menusend title]];
}

-(void)keyDown:(NSEvent*) theEvent {
	if([theEvent keyCode] == kUpArrow) {
		[TuneSiftController moveUpOneSong];
		return;
	} else if([theEvent keyCode] == kDownArrow) {
		[TuneSiftController moveDownOneSong];
		return;
	}
}

-(void)keyUp:(NSEvent*) theEvent {
//	NSLog([theEvent characters]);
#ifdef _MAIN_DEBUG_
	printf("eventcode: %i\n", [theEvent keyCode]);
#endif
/*	if(![self isKeyWindow])
		[self makeKeyAndOrderFront:nil];*/
	
	if([theEvent keyCode] == kESCKey) {
		searchStr = [NSMutableString stringWithCapacity:100];
		[searchStr retain];
		[TuneSiftController resetResultsSource];
		[TuneSiftController hideEverything];
		[songs setStringValue:searchStr];
		return;
	} else if([theEvent keyCode] == kReturnKey) {
		[TuneSiftController playSongRemotely];
		searchStr = [NSMutableString stringWithCapacity:100];
		[searchStr retain];
		[songs setStringValue:searchStr];
		return;
	} else if(([theEvent keyCode] == kBackspaceKey) && ([searchStr length] > 0)) {
		[searchStr deleteCharactersInRange:NSMakeRange([searchStr length]-1, 1)];
		[TuneSiftController resetResultsSource];
	} else if ([theEvent keyCode] == kBackspaceKey) return;
	else if (!isprint([[theEvent charactersIgnoringModifiers] cString][0])) return;
	else
		[searchStr appendString:[[theEvent charactersIgnoringModifiers] uppercaseString]];
	
	[songs setStringValue:searchStr];
	[TuneSiftController changeResultsSource:[searchStr cString]];
}

-(void) wipeSlate {
	[self orderOut:nil];
	[songs setStringValue:@""];
	[searchStr deleteCharactersInRange:NSMakeRange(0, [searchStr length])];
}

/*
 * Called when the notification window is displayed (TuneSiftInterface::printNotification).
 */
-(void) updateArtistsMenu:(NSDictionary*) data {
	NSMenu			*popupmenu, *albummenu;
	NSEnumerator*	dataenum, *albumenum, *albumkeys;
	NSArray*		newitem, *newalbum;
	NSString*		albumtitle;
	int				i, numofitems;
	
	popupmenu =  [[appmenu itemAtIndex:kArtistMenuItem] submenu];
#ifdef _MENU_DEBUG_
	NSLog(@"data passed: %@", [data description]);
	NSLog(@"number of menu items:%i", [popupmenu numberOfItems]);
#endif
	numofitems = [popupmenu numberOfItems];
	for(i = 0; i < numofitems; i++) {
#ifdef _MENU_DEBUG_
		NSLog(@"removing from artists menu: %@", [[popupmenu itemAtIndex:0] title]);
#endif
		[popupmenu removeItemAtIndex:0];
	}
	
	if(!data) return;
	
//	albumenum = [data objectEnumerator];
	albumkeys = [[[data allKeys]sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectEnumerator];
#ifdef _MENU_DEBUG_
	NSLog(@"number of menu items:%i", [popupmenu numberOfItems]);
#endif
	while(albumtitle = (NSArray*)[albumkeys nextObject]) {
		dataenum = [[data objectForKey:albumtitle] objectEnumerator];
		
		albummenu = [[NSMenu allocWithZone:[self zone]] initWithTitle:@""];
		[albummenu retain];
		
		[popupmenu addItemWithTitle:(NSString*)albumtitle action:nil keyEquivalent:@""];
		[popupmenu setSubmenu:albummenu forItem:[popupmenu itemWithTitle:albumtitle]];
		
		while(newitem = (NSArray*)[dataenum nextObject]) {
	#ifdef _MENU_DEBUG_
			NSLog(@"adding to artists menu: %@", [newitem objectAtIndex:0]);
	#endif
			[albummenu addItemWithTitle:[newitem objectAtIndex:0] action:@selector(playSong:) keyEquivalent:@""];
			[[albummenu itemWithTitle:[newitem objectAtIndex:0]] setTag:[[newitem objectAtIndex:1] intValue]];
		}
	}
}

-(void) updateAlbumMenu:(NSArray*) data {	
	NSMenu			*albummenu;
	NSEnumerator*	dataenum;
	NSArray*		newitem;
	int			i, numofitems;
	
	albummenu = [[appmenu itemAtIndex:kAlbumMenuItem] submenu];
#ifdef _MENU_DEBUG_
	NSLog(@"data passed: %@", [data description]);
	NSLog(@"number of menu items:%i", [albummenu numberOfItems]);
#endif
	
	numofitems = [albummenu numberOfItems];
	for(i = 0; i< numofitems; i++) {
#ifdef _MENU_DEBUG_
		NSLog(@"removing from artists menu: %@", [[albummenu itemAtIndex:0] title]);
#endif
		[albummenu removeItemAtIndex:0];
	}
	
	if(!data) return;
	
	dataenum = [data objectEnumerator];
	
#ifdef _MENU_DEBUG_
	NSLog(@"number of menu items:%i", [albummenu numberOfItems]);
#endif
	
	while(newitem = (NSArray*)[dataenum nextObject]) {
#ifdef _MENU_DEBUG_
		NSLog(@"adding to artists menu: %@", [newitem objectAtIndex:0]);
#endif
 		[albummenu addItemWithTitle:[newitem objectAtIndex:0] action:@selector(playSong:) keyEquivalent:@""];
		[[albummenu itemWithTitle:[newitem objectAtIndex:0]] setTag:[[newitem objectAtIndex:1] intValue]];
	}
}


-(void) playSong:(id)sender {
//	NSLog([sender description]);
	NSMenuItem*		sendermi;
	
	sendermi = (NSMenuItem*)sender;
	
	[TuneSiftController playSongRemotely:[sendermi tag]];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
   NSPoint currentLocation;
   NSPoint newOrigin;
   NSRect  screenFrame = [[NSScreen mainScreen] frame];
   NSRect  windowFrame = [self frame];
   
   //grab the current global mouse location; we could just as easily get the mouse location 
   //in the same way as we do in -mouseDown:
    currentLocation = [self convertBaseToScreen:[self mouseLocationOutsideOfEventStream]];
    newOrigin.x = currentLocation.x - initialLocation.x;
    newOrigin.y = currentLocation.y - initialLocation.y;
    
    // Don't let window get dragged up under the menu bar
    if( (newOrigin.y+windowFrame.size.height) > (screenFrame.origin.y+screenFrame.size.height) ){
	newOrigin.y=screenFrame.origin.y + (screenFrame.size.height-windowFrame.size.height);
    }
    
    //go ahead and move the window to the new location
    [self setFrameOrigin:newOrigin];
//	[self setViewsNeedDisplay:TRUE];
}

- (void)mouseDown:(NSEvent *)theEvent
{    
    NSRect  windowFrame = [self frame];

    //grab the mouse location in global coordinates
   initialLocation = [self convertBaseToScreen:[theEvent locationInWindow]];
   initialLocation.x -= windowFrame.origin.x;
   initialLocation.y -= windowFrame.origin.y;
}


-(void)setupToSearch {
//	[self makeKeyAndOrderFront:nil];
//	[self setViewsNeedDisplay:TRUE];
	if(![self makeFirstResponder:songs])
		fprintf(stderr, "SongSearchPanel::initSongChooser : couldn't become first responder.\n");
//	[songs selectText:self];
#ifdef _MAIN_DEBUG_
	printf("yay!\n");
#endif
}
@end
