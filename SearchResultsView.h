//
//  SearchResultsView.h
//  TuneSift
//
//  Created by Malcolm McFarland on Tue Nov 09 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@protocol SearchResultsViewController
-(void) playSongRemotely;
@end

@interface SearchResultsView : NSTableView {
	NSTableColumn   *songCol, *artistCol, *albumCol;
	id <SearchResultsViewController>	TuneSiftController;
}

-(void) customizeSelfWithController:(id <SearchResultsViewController>) cont;
-(void) bridgeToPlaySongRemotely;

@end
