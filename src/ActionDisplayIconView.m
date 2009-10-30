//
//  ActionDisplayIconView.m
//  TuneSift
//
//  Created by Malcolm McFarland on 4/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ActionDisplayIconView.h"

@implementation ActionDisplayIconView

-(id) init {
	[super init];
	
	off= FALSE;
	
//	iconImage = [NSImage imageNamed:@"headsupBG"];
	shuffleOnImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"headsupShuffleOn" ofType:@"tif"]];
	shuffleOffImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"headsupShuffleOff" ofType:@"tif"]];
	forwardImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"forwardicon" ofType:@"tif"]];
	backImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"backicon" ofType:@"tif"]];
	playImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"playicon" ofType:@"tif"]];
	pauseImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"pauseicon" ofType:@"tif"]];
	
	iconImage = shuffleOnImage;
	
	[shuffleOnImage retain];
	[shuffleOffImage retain];
	
	return self;
}

-(void) setState:(int)state {
	switch(state) {
		case kShuffleOn:
	//		printf("setting image to \"on\"\n");
			iconImage = shuffleOnImage;
			break;
		
		case kNextTrack:
			iconImage = forwardImage;
			break;
		
		case kBackTrack:
			iconImage = backImage;
			break;

		case kPlayTrack:
			iconImage = playImage;
			break;
		
		case kPauseTrack:
			iconImage = pauseImage;
			break;
			
		case kShuffleOff:
		default:
	//		printf("setting image to \"off\"\n");
			iconImage = shuffleOffImage;
			break;
	}
	
	[self setNeedsDisplay:TRUE];
}

-(void) drawRect:(NSRect) rect {
	[[NSColor clearColor] set];
	NSRectFill([self frame]);

	if(![iconImage isValid]) {
		printf("iconImage isn't valid!\n");
		return;
//		iconImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"headsupBG" ofType:@"tif"]];
//		iconImage = [NSImage imageNamed:@"PanelBG2.tif"];
	}
	
	[[self window] setHasShadow:FALSE];
	if(![iconImage isValid])
		printf(" panelBG2 *still* not valid!!\n");
	else {
		[iconImage compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver];
	}
}
@end
