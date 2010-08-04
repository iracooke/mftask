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
@synthesize delegate,tag,hasLaunched,isFinished;

/*
- (void) reportStatus {
	if ([internal_task isRunning]){
		DLog(@"Internal task %@ is running ",[self tag]);
	} else {
		DLog(@"Task %@ not running",[self tag]);
	}
}*/

- (id) init {
	if ( self=[super init]){
		internal_task=[[NSTask alloc] init];
		tag=nil;
		delegate=nil;
		isFinished=NO;
//		[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(reportStatus) userInfo:nil repeats:YES];
	}
	return self;
}

- (void) dealloc {
//	DLog(@"Deallocing task %@",[self tag]);
	[internal_task release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:internal_task];

	DLog(@"Deallocing mftask %@ %@",[self tag],[self observationInfo]);
	
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
	if ( [internal_task isRunning] ){
		// This lets the task go about its normal means of termination
		[internal_task terminate];
	} else {
		// This would occur only if the task was unable to run, if it has terminated already. or it never started. 
		
		// Only if the task was never started to we need to cleanup manually. 
		
		// This must occur on the next runloop which is why we call it like this
		if ( ![self hasLaunched] )
			[self performSelector:@selector(performTaskDidTerminate) withObject:nil afterDelay:0];
	}
}

- (BOOL) isRunning {
	return	[internal_task isRunning];
}



- (void) giveDataToDelegate:(NSData*) data {
//	DLog(@"Giving data to delegate");
	[delegate taskDidRecieveData:data fromTask:self];
//	DLog(@"Finished giving data to delegate");
}

- (void) giveErrorDataToDelegate:(NSData*)data {
//	DLog(@"Giving error data to delegate");
	[delegate taskDidRecieveErrorData:data fromTask:self];
//	DLog(@"Finished giving error data to delegate");
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

// This method should notify the delegate of termination via the taskDidTerminate delegate method. It also notifies an MFTaskQueue of this by setting its isFinished property to YES.
- (void) performTaskDidTerminate {

	if ( !_hasPerformedTerminate ) {
		_hasPerformedTerminate=YES;


	
		[self setIsFinished:YES];
		if ( [self delegate]!=nil )
			[(NSObject<MFTaskDelegateProtocol>*)delegate taskDidTerminate:self];	
	} else {
		// This shouldn't be a problem
//		NSLog(@"Attempted to perform terminate more than once on an MFTask");
	}
}


- (void) respondToTaskTerminationOnThread {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//	DLog(@"Task %@ responding to termination on thread",[self tag]);

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
	
	[self performSelectorOnMainThread:@selector(performTaskDidTerminate) withObject:nil waitUntilDone:NO];

	[pool release];
}

- (void) respondToTaskTermination:(NSNotification *)notification {
//	DLog(@"Task %@ recieved terminate notification",[self tag]);
	
	[NSThread detachNewThreadSelector:@selector(respondToTaskTerminationOnThread) toTarget:self withObject:nil];
	
}



- (BOOL) launch {
		
	if ( !delegate ){
		[NSException raise:NSGenericException format:@"Attempt to launch MFTask wihout a delegate"];
		return NO;
	}		
	
	

	
	if ( _hasPerformedTerminate )
		return NO;

	if ( [self hasLaunched] )
		[NSException raise:NSGenericException format:@"Attempt to relaunch an MFTask"]; 
	
	if ( _hasPerformedTerminate )
		[NSException raise:NSGenericException format:@"Attempt relaunch an MFTask that was terminated"]; 
	
	
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
	[self setHasLaunched:YES];
	DLog(@"Task %@ launched",[self tag]);
	
	if ( delegate)
		[delegate taskDidLaunch:self];
	
	return YES;
}

@end
