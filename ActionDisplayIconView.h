//
//  ActionDisplayIconView.h
//  TuneSift
//
//  Created by Malcolm McFarland on 4/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ActionDisplayIconView : NSView {
	BOOL		off;
	NSImage*	iconImage, *shuffleOnImage, *shuffleOffImage, *forwardImage, *backImage, *playImage, *pauseImage;
}

-(void) setState:(int)state;
@end
