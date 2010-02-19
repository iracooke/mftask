//
//  MFTaskAppDelegate.m
//  MFTask
//
//  Created by Ira Cooke on 19/02/10.
//  Copyright 2010 Mudflat Software. All rights reserved.
//

#import "MFTaskAppDelegate.h"
#import "MFTask.h"
#import "MFTaskDelegate.h"

@implementation MFTaskAppDelegate

@synthesize window,taskPathField,outputView,startButton,stopButton,currentTask;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}

-(IBAction) start:(id) sender {
	NSString *path = [taskPathField stringValue];
	[self setCurrentTask:[[MFTask new] autorelease]];
	[currentTask setLaunchPath:path];
	
	MFTaskDelegate *taskDelegate = [[MFTaskDelegate new] autorelease];
	[taskDelegate setOutputView:outputView];
	[currentTask setDelegate:taskDelegate];
	[currentTask launch];
	
	
}

-(IBAction) stop:(id) sender {

	[currentTask terminate];	
	
}



@end
