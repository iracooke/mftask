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
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:internal_task];
		
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

- (void) giveErrorDataToDelegate:(NSData*)data {
	[delegate taskDidRecieveErrorData:data];
}

#pragma mark reading from NSTask output pipe
- (void) waitForStandardOutputDataOnThread {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[readingDataLock lock];
	
	NSAssert(internal_task,@"Must have a task");
	NSFileHandle *readHandle = [[internal_task standardOutput] fileHandleForReading];
	NSAssert(readHandle!=nil,@" Task must have a standardoutput handle");
	

	NSData *readData;	
	while ( [readData = [readHandle availableData] length]){		
		[self performSelectorOnMainThread:@selector(giveDataToDelegate:) withObject:readData waitUntilDone:YES];
	}
	
	readingDataCondition++;
	[readingDataLock signal];
	[readingDataLock unlock];
	[pool release];

}

// Detaches a thread to wait for output data
- (void) waitForStandardOutputData {
	[NSThread detachNewThreadSelector:@selector(waitForStandardOutputDataOnThread)
							 toTarget:self withObject:nil];
}


#pragma mark reading from NSTask error pipe
- (void) waitForStandardErrorDataOnThread {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[readingErrorDataLock lock];
	
	NSAssert(internal_task,@"Must have a task");
	NSFileHandle *readHandle = [[internal_task standardError] fileHandleForReading];
	NSAssert(readHandle!=nil,@" Task must have a standarderror handle");
	
	
	NSData *readData;	
	while ( [readData = [readHandle availableData] length]){		
		[self performSelectorOnMainThread:@selector(giveErrorDataToDelegate:) withObject:readData waitUntilDone:YES];
	}
	
	readingErrorDataCondition++;
	[readingErrorDataLock signal];
	[readingErrorDataLock unlock];
	[pool release];
	
}

// Detaches a thread to wait for output data
- (void) waitForStandardErrorData {
	[NSThread detachNewThreadSelector:@selector(waitForStandardErrorDataOnThread)
							 toTarget:self withObject:nil];
}


- (void) respondToTaskTerminationOnThread {
	
	// Wait until all data is read from the output pipe until we proceed
	[readingDataLock lock];
	while( readingDataCondition <=0)
		[readingDataLock wait];
	
	[readingDataLock unlock];

	// Wait until all data is read from the error pipe until we proceed
	[readingErrorDataLock lock];
	while( readingErrorDataCondition <=0)
		[readingErrorDataLock wait];
	
	[readingErrorDataLock unlock];
	
	
	if ( [self delegate] )
		[(NSObject*)delegate performSelectorOnMainThread:@selector(taskDidTerminate:) withObject:self waitUntilDone:NO];
}

- (void) respondToTaskTermination:(NSNotification *)notification {
	
	
	[NSThread detachNewThreadSelector:@selector(respondToTaskTerminationOnThread) toTarget:self withObject:nil];
	
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
	[self waitForStandardErrorData];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToTaskTermination:) name:NSTaskDidTerminateNotification object:internal_task];

	[internal_task launch];
	
	return YES;
}

@end
