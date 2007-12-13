//
//  PanelBG.m
//  mTunes
//
//  Created by Malcolm McFarland on 2/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "PanelBG.h"


@implementation PanelBG

-(PanelBG*) initWithController:(id)cont boundary:(NSRect)bounds {
//	NSSize			sFrame = [[NSScreen mainScreen] frame].size;
	
    self = [super initWithContentRect:bounds
//					styleMask:NSTitledWindowMask | NSUtilityWindowMask | NSTexturedBackgroundWindowMask | kNSNonactivatingPanelMask
					styleMask:NSBorderlessWindowMask
					backing:NSBackingStoreBuffered
					defer:FALSE];
	
//	mTunesController = cont;
	
//	[super init];
//	[self setBackgroundColor:[NSColor colorWithDeviceRed:0.0 green:0.05 blue:0.0 alpha:1]];
//	[self setBackgroundColor:[NSColor colorWithDeviceRed:0.9 green:0.5 blue:0 alpha:1.0]];
//	[self setBackgroundColor:[NSColor colorWithDeviceRed:0.10 green:0.15 blue:0.05 alpha:1]];
//	[self setBackgroundColor:[NSColor clearColor]];
	[self setLevel:NSStatusWindowLevel];
//	[self setBezeled:TRUE];
	[self setAlphaValue:0.6];
	[self setHidesOnDeactivate:TRUE];
	[self setBackgroundColor:[NSColor blackColor]];
//	[self setWorksWhenModal:TRUE];// :malcolm:20041115 // :malcolm:20041115 
//	[self setFloatingPanel:FALSE];
//	[self setShowsResizeIndicator:FALSE];
	[self setHasShadow:FALSE];
	[self setOpaque:FALSE];
	
	return self;
}



-(BOOL) canBecomeKeyWindow {
	return FALSE;
}

-(BOOL) acceptsFirstResponder {
	return FALSE;
}

-(void) mouseDown:(NSEvent*) te {
//	[mTunesController showEverything];
}
@end

