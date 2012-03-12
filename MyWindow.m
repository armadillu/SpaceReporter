#import "MyWindow.h"

@implementation MyWindow


- (void)makeKeyAndOrderFront:(id)sender{
	[super makeKeyAndOrderFront:sender];
	[self setLevel:NSStatusWindowLevel];
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

@end