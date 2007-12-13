//
//  SearchResultsPanel.m
//  TuneSift
//
//  Created by Malcolm McFarland on 2/27/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "SearchResultsPanel.h"


@implementation SearchResultsPanel

-(id) initWithContentRect:(NSRect)bounds styleMask:(unsigned int)styleMask
			backing:(NSBackingStoreType)backingType defer:(BOOL)flag {
			
	[super initWithContentRect:bounds
//				styleMask:NSUtilityWindowMask | NSNonactivatingPanelMask | NSTitledWindowMask
				styleMask:NSNonactivatingPanelMask | NSTitledWindowMask | NSUtilityWindowMask
				backing:backingType defer:FALSE];
/*	[self setLevel:NSPopUpMenuWindowLevel];
	[self setFloatingPanel:TRUE];
	[self setHidesOnDeactivate:FALSE];*/
	
	return self;
}

-(BOOL) canBecomeKeyWindow {
	return FALSE;
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

@end
