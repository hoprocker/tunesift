//
//  PanelBG.h
//  mTunes
//
//  Created by Malcolm McFarland on 2/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PanelBGController
-(void) showEverything;
@end

@interface PanelBG : NSPanel {	
	id <PanelBGController>	mTunesController;
}

-(PanelBG*) initWithController:(id)cont boundary:(NSRect)bounds;

@end
