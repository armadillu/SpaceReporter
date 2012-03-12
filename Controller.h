/* Controller */

#import <Cocoa/Cocoa.h>

#import "constants.h"


@interface Controller : NSObject
{
    IBOutlet id menu;
	IBOutlet id aboutWin;
	
	NSStatusItem*	_statusItem;
	NSTimer *		timer;
	NSDictionary *	textAttributes;
	
}


- (IBAction)do:(id)sender;
- (IBAction)updateNow:(id)sender;

@end
