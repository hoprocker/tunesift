//
//  SearchPanelView.m
//  TuneSift
//
//  Created by Malcolm McFarland on Fri Nov 05 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "SearchPanelView.h"


@implementation SearchPanelView

-(id) init {
	[super init];
	
//	bgimage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"PanelBG1" ofType:@"jpg"]];
	bgimage = [NSImage imageNamed:@"PanelBG2"];
	
//	[self setHasShadow:FALSE];
//	[self setNeedsDisplay:TRUE];
	
	[bgimage retain];
	
	return self;
}

-(void) drawRect:(NSRect) rect {
	[[NSColor clearColor] set];
	NSRectFill([self frame]);

	if(![bgimage isValid]) {
		bgimage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"PanelBG2" ofType:@"tif"]];
//		bgimage = [NSImage imageNamed:@"PanelBG2.tif"];
	}
	
	[[self window] setHasShadow:FALSE];
	if(![bgimage isValid])
		printf(" panelBG2 *still* not valid!!\n");
	else {
		[bgimage compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver];
	}
}
/*
-(void)mouseDown:(NSEvent*) theEvent { 
//#ifdef _MAIN_DEBUG_
	printf("mouseDown\n");
//#endif
	return;
}

-(void)mouseDragged:(NSEvent*) te { 
//#ifdef _MAIN_DEBUG_
	printf("mouseDragged\n");
//#endif
	return;
}*/
@end
