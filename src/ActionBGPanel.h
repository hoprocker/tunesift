//
//  ActionBGPanel.h
//  TuneSift
//
//  Created by Malcolm McFarland on 4/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ActionDisplayBGView.h"


@interface ActionBGPanel : NSPanel {
	ActionDisplayBGView*	bgView;
}

-(void) initializeView;

@end
