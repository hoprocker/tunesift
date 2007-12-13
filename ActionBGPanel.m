//
//  ActionBGPanel.m
//  TuneSift
//
//  Created by Malcolm McFarland on 4/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ActionBGPanel.h"


@implementation ActionBGPanel

-(ActionBGPanel*) init {/**/
	NSSize			sFrame = [[NSScreen mainScreen] frame].size;
	int				left = (sFrame.width - 211) / 2;
	NSRect			bounds = NSMakeRect(left,140, 211, 206);
	
    self = [super initWithContentRect:bounds
//					styleMask:NSTitledWindowMask | NSUtilityWindowMask | NSTexturedBackgroundWindowMask | kNSNonactivatingPanelMask
					styleMask:NSNonactivatingPanelMask | NSBorderlessWindowMask
					backing:NSBackingStoreBuffered
					defer:FALSE];
					
	[self setBackgroundColor:[NSColor clearColor]];
	[self setAlphaValue:.9];
	[self setHidesOnDeactivate:FALSE];
	[self setFloatingPanel:TRUE];

	[self setOpaque:FALSE];
	
	return self;
}


-(void) initializeView {
	bgView = [[ActionDisplayBGView alloc] init];
	
	[self setContentView:bgView];
	[self setHasShadow:FALSE];
	[self setLevel:NSPopUpMenuWindowLevel];
	
	[bgView retain];
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

@end
