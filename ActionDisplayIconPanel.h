//
//  ActionDisplayIconPanel.h
//  TuneSift
//
//  Created by Malcolm McFarland on 3/2/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ActionDisplayIconView.h"

@interface ActionDisplayIconPanel : NSPanel {
	ActionDisplayIconView*		innerView;
}

-(void) initializeView;
-(void) setState:(int)state;
@end
