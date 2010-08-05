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
#import "Argument.h"

@implementation MFTaskAppDelegate

@synthesize window,taskPathField,outputView,startButton,stopButton,currentTask,taskDelegate;

- (id) init {
	if ( self=[super init]){
		arguments=[NSMutableArray array];
		
	}
	return self;
}

- (void) dealloc {

	[arguments release];
	[super dealloc];
}

- (void) insertObject:(Argument*) arg inArgumentsAtIndex:(NSInteger) index {
	[arguments insertObject:arg atIndex:index];
}

- (void) removeObjectFromArgumentsAtIndex:(NSInteger) index {
	[arguments removeObjectAtIndex:index];
}

- (NSArray*) arguments {
	return arguments;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 

	
	[self setTaskDelegate:[[MFTaskDelegate new] autorelease]];
	[taskDelegate setOutputView:outputView];
	
	NSArray *argvals = [NSArray arrayWithObjects:@"/",@"-name",@"*.xml",nil];
	for(NSString* val in argvals){
		Argument *argObject = [[Argument new] autorelease];
		[argObject setValue:val];
		[argsArrayController addObject:argObject];
	}
	
	[taskPathField setStringValue:@"/usr/bin/find"];

}

-(IBAction) start:(id) sender {
	NSString *path = [taskPathField stringValue];
	
	MFTask *taskObject = [[MFTask new] autorelease];
	
	[self setCurrentTask:taskObject];
	[currentTask setLaunchPath:path];
	
	[currentTask setDelegate:taskDelegate];
	
	
	[currentTask setCurrentDirectoryPath:NSHomeDirectory()];
	
	
	NSDictionary *environmentDict = [[NSProcessInfo processInfo] environment];
	[currentTask setEnvironment:environmentDict];
	
	
		// Set arguments
	NSArray *args = [argsArrayController arrangedObjects];
	NSMutableArray *argVals = [NSMutableArray array];
	
	for(Argument *arg in args){
		[argVals addObject:[arg value]];
	}
	
		 NSLog(@"Task arguments %@",argVals);
		 
	[currentTask setArguments:argVals];
	
	
	
	[currentTask launch];

	
}

-(IBAction) stop:(id) sender {

	[currentTask terminate];	
	
}

- (IBAction) clear:(id) sender {
	NSMutableAttributedString *outputStore = [outputView textStorage];
	
	[outputStore deleteCharactersInRange:NSMakeRange(0, [outputStore length])];
}



@end
