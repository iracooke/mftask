//
//  MFTask.m
//  MFTask
//
//  Created by Ira Cooke on 17/02/10.
//  Copyright 2010 Mudflat Software. All rights reserved.
//

#import "MFTask.h"
#import "MFTaskDelegateProtocol.h"

@implementation MFTask
@synthesize delegate;

- (id) init {
	if ( self=[super init]){
		internal_task=[[NSTask alloc] init];
	}
	return self;
}

- (void) dealloc {
	[internal_task release];
	[super dealloc];
}

//! Sets the arguments of the underlying NSTask
- (void) setArguments:(NSArray*) arguments {
	[internal_task setArguments:arguments];
}


//! Sets the Current Directory Path on the underlying task
- (void)setCurrentDirectoryPath:(NSString *)path {
	[internal_task setCurrentDirectoryPath:path];
}

//! Sets the Environment for the underlying NSTask
- (void)setEnvironment:(NSDictionary *)environmentDictionary {
	[internal_task setEnvironment:environmentDictionary];
}

//! Sets the Launch path to the executable used by the underlying NSTask
- (void)setLaunchPath:(NSString *)path {
	[internal_task setLaunchPath:path];
}

//! Sets the standard input pipe used by NSTask
- (void) setStandardInput:(NSPipe*) inputPipe {
	[internal_task setStandardInput:inputPipe];
}


- (void) terminate {
	[internal_task terminate];
}

- (BOOL) isRunning {
	return	[internal_task isRunning];
}



- (void) giveDataToDelegate:(NSData*) data {
	[delegate taskDidRecieveData:data];
}

#pragma mark reading from NSTask output pipe
- (void) waitForStandardOutputDataOnThread {
	
	NSAssert(internal_task,@"Must have a task");
	NSFileHandle *readHandle = [[internal_task standardOutput] fileHandleForReading];
	NSAssert(readHandle!=nil,@" Task must have a standardoutput handle");
	

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSData *readData;	
	while ( [readData = [readHandle availableData] length]){		
		[self performSelectorOnMainThread:@selector(giveDataToDelegate:) withObject:readData waitUntilDone:YES];
	}
	
	[pool release];
}

// Detaches a thread to wait for output data
- (void) waitForStandardOutputData {
	[NSThread detachNewThreadSelector:@selector(waitForStandardOutputDataOnThread)
							 toTarget:self withObject:nil];
}


- (BOOL) launch {
	if ( !delegate )
		return NO;
	
	// Setup the pipes on the task
	NSPipe *outputPipe = [NSPipe pipe];
	NSPipe *errorPipe = [NSPipe pipe];
	[internal_task setStandardOutput:outputPipe];
	[internal_task setStandardError:errorPipe];
	
	// Launch a thread to wait for data from the NSTask pipe object
	[self waitForStandardOutputData]; 
	
	
	[internal_task launch];
	
	return YES;
}

@end
