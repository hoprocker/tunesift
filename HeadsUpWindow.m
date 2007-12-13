//
//  HeadsUpWindow.m
//  TuneSift
//
//  Created by Malcolm McFarland on Mon Nov 01 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "HeadsUpWindow.h"


@implementation HeadsUpWindow

-(id) init {
//	printf ("AAAAAAAAA\n");
	[super initWithContentRect:NSMakeRect(-7, -1, 1056, 128) styleMask:NSBorderlessWindowMask | NSNonactivatingPanelMask
					backing:NSBackingStoreBuffered defer:FALSE];
	
	[self setIgnoresMouseEvents:TRUE];
	
	return self;
}



-(BOOL) canBecomeKeyWindow {
	return TRUE;
}

-(BOOL) becomesKeyOnlyIfNeeded {
	return FALSE;
}

-(BOOL) needsPanelToBecomeKey {
	return TRUE;
}

-(BOOL) acceptsFirstResponder {
	return TRUE;
}

-(void) mouseDown: (NSEvent*) theEvent {
	[self orderOut:self];
}

-(void) mouseDragged: (NSEvent*) theEvent {
	[self orderOut:self];
}
@end
