//
//  SearchResultsView.m
//  TuneSift
//
//  Created by Malcolm McFarland on Tue Nov 09 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "SearchResultsView.h"


@implementation SearchResultsView

-(id) init {
	[super init];
	
	return self;
}
/*
-(id) initWithFrame:(NSRect) myframe {
}*/

-(void) customizeSelfWithController:(id <SearchResultsViewController>) cont {
	NSCell*		customCell;
	
	TuneSiftController = cont;
	
	customCell = [[NSCell alloc] initTextCell:@""];
	[customCell	setFont:[NSFont fontWithName:@"Lucida Grande" size:12]];
//	[customCell setBackgroundColor:[NSColor colorWithCalibratedRed:0.7 green:0.8 blue:0.7 alpha:1.0]];
	[customCell retain];

	songCol = [self tableColumnWithIdentifier:@"Song"];
//	[[songCol dataCell] setFont:[NSFont fontWithName:@"Courier" size:32]];
	[songCol setDataCell:[customCell copyWithZone:[self zone]]];
	[songCol setEditable:FALSE];
	[songCol setWidth:400];
	
	artistCol = [[NSTableColumn alloc] initWithIdentifier:@"artist"];
	[[artistCol headerCell] setStringValue:@"Artist"];
	[artistCol setDataCell:[customCell copyWithZone:[self zone]]];
	[self addTableColumn:artistCol];
	[artistCol setWidth:300];
	[artistCol setEditable:FALSE];
	[artistCol retain];
	
	albumCol = [[NSTableColumn alloc] initWithIdentifier:@"album"];
	[[albumCol headerCell] setStringValue:@"Album"];
	[albumCol setDataCell:[customCell copyWithZone:[self zone]]];
	[self addTableColumn:albumCol];
	[albumCol setWidth:300];
//	[albumCol sizeToFit];
	[albumCol retain];
	[albumCol setEditable:FALSE];
	
	[self setAllowsColumnResizing:NO];
	[self setAllowsColumnSelection:NO];
	[self setAllowsColumnReordering:NO];
	[self setAutoresizesAllColumnsToFit:NO];
	[self setAllowsMultipleSelection:NO];
	[self setRowHeight:[self rowHeight]-2];
	[self setGridColor:[NSColor colorWithCalibratedRed:0.7 green:0.7 blue:1.0 alpha:1.0]];

	[self setDoubleAction:@selector(bridgeToPlaySongRemotely)];
/*	if([self tableColumnWithIdentifier:@"false2"] != nil) {
		[self removeTableColumn:[self tableColumnWithIdentifier:@"false1"]];
		[self removeTableColumn:[self tableColumnWithIdentifier:@"false2"]];
	} else printf("identifiers not valid\n");*/

//	[self setGridStyleMask:NSTableViewSolidVerticalGridLineMask];	
/*	theenum = [[self tableColumns] objectEnumerator];

	while(curcol = [theenum nextObject]) {
		printf("next table column identifier: %s  with identifier: %s\n", [[curcol className] cString], [[curcol identifier] cString]);
	}*/
}

-(void) bridgeToPlaySongRemotely {
	[TuneSiftController playSongRemotely];
}

@end
