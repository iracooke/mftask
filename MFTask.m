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


- (id) init {
	if ( self=[super init]){
		internal_task=[[NSTask alloc] init];
		tag=nil;
		delegate=nil;
		isFinished=NO;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToTaskTermination:) name:NSTaskDidTerminateNotification object:internal_task];

	}
	return self;
}

- (void) dealloc {
	[internal_task release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:internal_task];

	[super dealloc];
}

- (void) setDelegate:(NSObject <MFTaskDelegateProtocol>*) delegateObject {
	if ( [delegateObject conformsToProtocol:@protocol(MFTaskDelegateProtocol)] ){
		delegate=delegateObject;
	} else {
		[NSException raise:NSGenericException format:@"**Exception: MFTask cannot set delegate as the supplied object does not conform to the MFTaskDelegateProtocol"];
	}

}

	// This must be done outside of the terminate and invalidate methods because otherwise we would trigger for isFinished in MFTaskQueue while an array of MFTasks is enumerated
- (void) performSetFinishedYES {
	[self setIsFinished:YES];
}

	// This lets the task go about its normal means of termination. If the task was never launched then this simply sets the isFinished property to yes
- (void) terminate {
	_hasBeenSentTerminate=YES;

	if ( [internal_task isRunning] ){

		[internal_task terminate];
	} else {
			// If we get here it means the task was;
			// 1. Never launched ... nothing to do. We set isFinished to YES
			// 2. Waiting for task termination ... nothing to do.
			// 3. Already dead but not yet deallocated ... nothing to do.
		if ( ![self hasLaunched] )
				//			[self performSelector:@selector(performSetFinishedYES) withObject:nil afterDelay:0.0];
			[self setIsFinished:YES];
	}
}

- (void) invalidate {
	if ( !_hasBeenSentTerminate && [internal_task isRunning]){
		[internal_task terminate];
		
	}
	_hasBeenSentTerminate=YES;
	[self setIsFinished:YES];	
		// Now we abandon the task. So that the caller and the delegate can ignore it from now on
	[delegate taskDidRecieveInvalidate:self];
	delegate=nil;
		//	[self performSelector:@selector(performSetFinishedYES) withObject:nil afterDelay:0.0];

}

- (BOOL) isRunning {
	return	[internal_task isRunning];
}



- (void) giveDataToDelegate:(NSData*) data {
	
	[delegate taskDidRecieveData:data fromTask:self];

}

- (void) giveErrorDataToDelegate:(NSData*)data {

	[delegate taskDidRecieveErrorData:data fromTask:self];

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
// This method should only ever be called by the task itself after it recieves an NSTaskDidTerminate notification and has finished reading all data.
- (void) performTaskDidTerminate {

	NSAssert(!_hasPerformedTerminate,@"Attempt to terminate a task more than once");
	
	_hasPerformedTerminate=YES;
	
	[self setIsFinished:YES];
	if ( [self delegate]!=nil ){ // The delegate might be nil if this task was abandoned
		[(NSObject<MFTaskDelegateProtocol>*)delegate taskDidTerminate:self];	
			// From this point the delegate we set the delegate to nil for safety sake
			// TODO: Set delegate to nil for safety but shouldn't need to. so leaving non-nil for debugging
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
	[NSThread detachNewThreadSelector:@selector(respondToTaskTerminationOnThread) toTarget:self withObject:nil];
	
}



- (BOOL) launch {
	
	if ( _hasPerformedTerminate )
		return NO;
	
	if ( _hasBeenSentTerminate )
		return NO;
		
	if ( !delegate ){
		[NSException raise:NSGenericException format:@"**Exception: Attempt to launch MFTask wihout a delegate %@ %d",[self tag],[self isFinished]];
		return NO;
	}		
	
	if ( [self hasLaunched] ){
		[NSException raise:NSGenericException format:@"**Exception: Attempt to relaunch an MFTask"]; 
		return NO;
	}
	
	// Setup the pipes on the task
	NSPipe *outputPipe = [NSPipe pipe];
	NSPipe *errorPipe = [NSPipe pipe];
	[internal_task setStandardOutput:outputPipe];
	[internal_task setStandardError:errorPipe];
	
	// Launch a thread to wait for data from the NSTask pipe object
	[self waitForStandardOutputData]; 
	[self waitForStandardErrorData];
	

	
	[internal_task launch];
	[self setHasLaunched:YES];
	
	if ( delegate)
		[delegate taskDidLaunch:self];
	
	return YES;
}



	//! Sets the arguments of the underlying NSTask
- (void) setArguments:(NSArray*) arguments {
	[internal_task setArguments:arguments];
}

- (NSArray *)arguments {
	return [internal_task arguments];
}





	//! Sets the Current Directory Path on the underlying task
- (void)setCurrentDirectoryPath:(NSString *)path {
	[internal_task setCurrentDirectoryPath:path];
}

- (NSString*) currentDirectoryPath {
	return [internal_task currentDirectoryPath];
}


	//! Sets the Environment for the underlying NSTask
- (void)setEnvironment:(NSDictionary *)environmentDictionary {
	[internal_task setEnvironment:environmentDictionary];
}

- (NSDictionary*) environment {
	return [internal_task environment];
}


	//! Sets the Launch path to the executable used by the underlying NSTask
- (void)setLaunchPath:(NSString *)path {
	[internal_task setLaunchPath:path];
}
- (NSString*) launchPath {
	return [internal_task launchPath];
}


	//! Sets the standard input pipe used by NSTask
- (void) setStandardInput:(NSPipe*) inputPipe {
	[internal_task setStandardInput:inputPipe];
}

- (id)standardInput {
	return [internal_task standardInput];
}

- (id)standardOutput {
	return [internal_task standardOutput];
}

- (id) standardError {
	return [internal_task standardError];
}

- (int)processIdentifier {
	return [internal_task processIdentifier];
}

- (int)terminationStatus {
	return [internal_task terminationStatus];
}



@end
