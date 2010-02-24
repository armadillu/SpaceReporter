#import "Controller.h"

@implementation Controller

int counter=0;

- (id)init{
	
	timer = [NSTimer scheduledTimerWithTimeInterval:15.00f target:self selector:@selector(refresh) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer: timer forMode:NSEventTrackingRunLoopMode];
	
	return self;
}


-(void)awakeFromNib{
	
	[[NSGraphicsContext currentContext] setImageInterpolation: NSImageInterpolationHigh];

	NSShadow * sha=[ [NSShadow alloc] init];
	NSSize shOffset = { width: 0.0, height: 0.0};
	[sha setShadowOffset: shOffset];
	[sha setShadowColor:[NSColor grayColor]];
	[sha setShadowBlurRadius: 2];

	NSArray * objs = [NSArray  arrayWithObjects: 
						[ [NSFontManager sharedFontManager] fontWithFamily:@"Lucida Grande" traits:nil	weight:5 size:9],
						sha,
						[NSColor blackColor],
						nil
						];


	NSArray * keys = [NSArray  arrayWithObjects: (id)NSFontAttributeName, (id)NSShadowAttributeName, (id)NSForegroundColorAttributeName, nil ];

	if ([keys count] != [objs count] ){
		NSLog(@"quit! Missing Lucida Grande typeface!?");
		exit(0);
	}

	textAttributes = [[NSDictionary dictionaryWithObjects:objs forKeys: keys ] retain];

	_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    [_statusItem setHighlightMode:YES];
    [_statusItem setEnabled:YES];
    [_statusItem setMenu:menu];
	[_statusItem setTarget:self];
	[self refresh];
}


-(NSImage*)createPieForPercentage:(float)ratio andPath:(NSString*) name andColor: (NSColor*) color textAttributes:(NSDictionary*) attr{

	NSString * realName = [[NSFileManager defaultManager] displayNameAtPath: name];
	NSSize nameSize = [realName sizeWithAttributes: attr];
	
	NSImage * im = [ [NSImage alloc] initWithSize: NSMakeSize( MENU_HW + NAME_OFFSET + nameSize.width + TRAILING_OFFSET, MENU_HW ) ];
	[im lockFocus];	

	NSBezierPath * p2 = [NSBezierPath bezierPath];
	[p2 appendBezierPathWithArcWithCenter:NSMakePoint(IMG_HEIGHT*0.5f, IMG_HEIGHT*0.5f) 
								   radius: IMG_HEIGHT * 0.5f 
							   startAngle: 90 - 360.0f * ratio
								 endAngle: 90 
	];
	
	[p2 lineToPoint:NSMakePoint(IMG_HEIGHT * 0.5f , IMG_HEIGHT * 0.5f )];
	[p2 closePath];
	
	[color set];
	[p2 fill];
	
	[realName drawAtPoint: NSMakePoint( MENU_HW + NAME_OFFSET, TEXT_V_OFFSET) withAttributes:attr];
	
	[im unlockFocus];

	return im;
}



- (NSImage*) createIconImage{
	
	NSArray * volumesS = [[NSWorkspace sharedWorkspace] mountedLocalVolumePaths];
	NSMutableArray * volumes = [NSMutableArray arrayWithArray: volumesS ];

	int i;
	NSString* old = [volumes objectAtIndex:0];
	
	for (i=1; i< [volumes count]; i++){
		if ( [[volumes objectAtIndex:i] isEqualToString:old] ){
			[volumes removeObjectAtIndex:i];
			i--;
		}
		old = [volumes objectAtIndex:i];
	}
	
	NSMutableArray * images = [NSMutableArray arrayWithCapacity:5];
	
	NSAffineTransform * t =[NSAffineTransform transform];
	[t translateXBy:0 yBy:1];
	[t set];
	
	for (i=0; i< [volumes count]; i++){
	
		NSDictionary * info = [[NSFileManager defaultManager] fileSystemAttributesAtPath: [volumes objectAtIndex:i]];	
	
		unsigned long long free = [[info objectForKey:@"NSFileSystemFreeSize"] unsignedLongLongValue];
		unsigned long long total = [[info objectForKey:@"NSFileSystemSize"] unsignedLongLongValue];
		
		float ratio = (long double)(total - free) / (long double)total;
		
		NSColor* pieColor;
		
		if (ratio < 0.75f)
			pieColor = [NSColor grayColor];
		else{
			float fullness = (ratio - 0.75f) * 4.0f; // this makes fullness into  [0 .. 1]
			pieColor = [NSColor colorWithDeviceRed: 0.5f + 0.4f * fullness  green:0.5f - 0.4f * fullness blue: 0.5f - 0.4f * fullness alpha:1];
		}
		
		//NSLog(@">>%@ - %f (free:%llu / total:%llu)",[volumes objectAtIndex:i], ratio , free, total );
		NSImage * pie = [self createPieForPercentage: ratio andPath: [volumes objectAtIndex:i] 
											andColor: pieColor
									  textAttributes:textAttributes ];
		[images addObject: pie ];
		
	}
	
	NSSize total;
	for (i=0; i< [images count]; i++){
		total.width += ( [[images objectAtIndex:i] size].width);
	}
	
	NSImage * im = [ [NSImage alloc] initWithSize:NSMakeSize( total.width, MENU_HW ) ];
	[im lockFocus];	

	NSSize offsets;
	offsets.width = 3;
	for (i=0; i< [images count]; i++){
		NSImage * curImg = [images objectAtIndex:i];
		[curImg compositeToPoint: NSMakePoint(offsets.width, PIE_V_OFFSET) operation: NSCompositeSourceOver];
		[curImg release];
		offsets.width += [curImg size].width;
	}
	
	[im unlockFocus];
	
	return im;	
}


- (void) refresh{
	
	NSImage* i = [self createIconImage];
	[_statusItem setImage:i];
	[i release];
}


- (IBAction)do:(id)sender{
	
	switch ([sender tag]) {
 	case 0: //about
		[aboutWin makeKeyAndOrderFront:self];
		[aboutWin setLevel:NSNormalWindowLevel + 1];
		break;

	case 1: //quit
		[NSApp terminate:self];
		break;

 	case 666: //donate
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.paypal.com/xclick/business=oriol@uri.cat&item_name=SpaceReporter&no_note=1&tax=0&currency_code=EUR"]];
		break;
		
	default:
		break;
	}
}

@end