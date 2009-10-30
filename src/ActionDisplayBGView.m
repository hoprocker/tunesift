//
//  ActionDisplayBGView.m
//  TuneSift
//
//  Created by Malcolm McFarland on 3/2/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ActionDisplayBGView.h"

#define	kPanelWidth
#define kPanelHeight

@implementation ActionDisplayBGView

-(id) init {
	[super init];
	
//	bgImage = [NSImage imageNamed:@"headsupBG"];
	bgImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"headsupBG" ofType:@"tif"]];	
		
	[bgImage retain];
	
	return self;
}

-(void) drawRect:(NSRect) rect {
	[[NSColor clearColor] set];
	NSRectFill([self frame]);

	if(![bgImage isValid]) {
		bgImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"headsupBG" ofType:@"tif"]];
//		bgimage = [NSImage imageNamed:@"PanelBG2.tif"];
	}
	
	[[self window] setHasShadow:FALSE];
	if(![bgImage isValid])
		printf(" panelBG2 *still* not valid!!\n");
	else {
		[bgImage compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver];
	}
}
@end
