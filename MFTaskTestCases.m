//
//  MFTask_Test.m
//  MFTask
//
//  Created by Ira Cooke on 17/02/10.
//  Copyright 2010 Mudflat Software. All rights reserved.
//

#import "MFTaskTestCases.h"
#import "MFTask.h"
#import "MFTaskDelegateProtocol.h"
#import <OCMock/OCMock.h>

@implementation MFTaskTestCases

- (void) setUp {
	taskObject = [[MFTask alloc] init];
	STAssertTrue([taskObject isKindOfClass:[MFTask class]],@"An Object of Class MFTask could not be created");
		//	NSLog(@"Setting up");
}

- (void) tearDown {
		//	NSLog(@"Tearing down %@",[taskObject tag]);

	STAssertTrue([taskObject isFinished],@"Not finished with this task object");

		// Try to fix things if the task Object wasn't properly killed
	if ( ![taskObject isFinished] ){
			//		NSLog(@"Taking evasive action .. a rogue task is on the loose");

		[taskObject invalidate]; // This will lead to an OCMock error in cases where invalidate was not expected
			// Wait for a bit

		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3]];
	}
	
	[taskObject release];
}


#pragma mark Helper Methods
	// Prepares the global task with basic settings. No delegate is set
- (void) prepareTaskWithCommand:(NSString*) command args:(NSArray *)extraArgs {	
	[taskObject setCurrentDirectoryPath:NSHomeDirectory()];
	[taskObject setLaunchPath:command];	
	if ( !extraArgs ){
		[taskObject setArguments:[NSArray array]];	
	} else {
		[taskObject setArguments:extraArgs];	
	}
	
	[taskObject setStandardInput:[NSFileHandle fileHandleWithNullDevice]];
	
}

- (void) runUntilTimeout:(NSTimeInterval) timeout {
	NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:timeout]; 
	while ((![taskObject isFinished]) && ([runUntil timeIntervalSinceNow] > 0))  {
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.1]];
			//		NSLog(@"Waiting for tests %f , %@",[runUntil timeIntervalSinceNow],([taskObject isFinished]) ? @"YES" : @"NO");
	}
	
}

- (id) mockDelegateExpectingTerminationAndData {
	id mock = [OCMockObject mockForProtocol:@protocol(MFTaskDelegateProtocol)];	
	
	[[mock expect] taskDidLaunch:taskObject];	
	[[mock expect] taskDidRecieveData:[OCMArg any] fromTask:taskObject];
	[[mock expect] taskDidTerminate:taskObject];
	
	
	return mock;
	
}

- (id) mockDelegateExpectingInvalidationAndData {
	
	id mock = [OCMockObject mockForProtocol:@protocol(MFTaskDelegateProtocol)];	
	
	[[mock expect] taskDidLaunch:taskObject];	
	[[mock expect] taskDidRecieveData:[OCMArg any] fromTask:taskObject];
	[[mock expect] taskDidRecieveInvalidate:taskObject];
	
	
	return mock;
		
}


- (id) launchWithMockExpectingTerminationAndData {
	id mock = [self mockDelegateExpectingTerminationAndData];
	
	[taskObject setDelegate:mock];
	[taskObject launch];
	return mock;
	
}

- (id) launchWithMockDelegateExpectingInvalidationAndNoData {
	id mock = [OCMockObject mockForProtocol:@protocol(MFTaskDelegateProtocol)];	
	
	[[mock expect] taskDidLaunch:taskObject];
	[[mock expect] taskDidRecieveInvalidate:taskObject];
	
	[taskObject setDelegate:mock];
	[taskObject launch];
	return mock;	
}



#pragma mark Tests for the launch method

- (void) testLaunchWithNoDelegateThrowsException {
	STAssertThrows([taskObject launch],@"Task should throw an exception if launched without a delegate");
	[taskObject setIsFinished:YES];
}



- (void) testTaskPWDInvokesDelegateMethodsAndTerminatesQuickly {
	[taskObject setTag:@"testTaskPWDInvokesDelegateMethodsAndTerminatesQuickly"];
	[self prepareTaskWithCommand:@"/bin/pwd" args:nil];
	id mock = [self launchWithMockExpectingTerminationAndData];
	
	[self runUntilTimeout:2];
	
	STAssertTrue([taskObject isFinished],@"Task timed out");
	[mock verify];
	
	
}

- (void) testLaunchFailsOnTerminatedTask {
	[taskObject setTag:@"testLaunchFailsOnTerminatedTask"];
	
	[self prepareTaskWithCommand:@"/bin/pwd" args:nil];

	id mock = [self launchWithMockExpectingTerminationAndData];
	
		// Run the task to completion
	[self runUntilTimeout:10];
	STAssertTrue([taskObject isFinished],@"Task timed out");
	STAssertFalse([taskObject launch],@"Finished task was able to launch");
	[mock verify];
	
}

- (void) testLaunchFailsOnInvalidatedTask {
	[taskObject setTag:@"testLaunchFailsOnInvalidatedTask"];
	
	[self prepareTaskWithCommand:@"/bin/pwd" args:nil];
	
	id mock = [self launchWithMockDelegateExpectingInvalidationAndNoData];
	
	[taskObject invalidate];
	STAssertFalse([taskObject launch],@"Invalidated task was able to launch");
	[mock verify];	
}

- (void) taskDidRecieveErrorData:(NSData*) data fromTask:(MFTask*) theTask {
	NSLog(@"Calling replacement method %@",[[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease]);
}


- (void) testInvalidateWorksOnLongRunningTask {
	[taskObject setTag:@"testInvalidateWorksOnLongRunningTask"];
	[self prepareTaskWithCommand:@"/usr/bin/find" args:[NSArray arrayWithObjects:@"/",@"-name",@"*.xml",nil]];
	
		// A nice mock is needed in this case because we can't be sure about whether we'll get any error data
	id mock = [OCMockObject niceMockForProtocol:@protocol(MFTaskDelegateProtocol)];	
	
	[[mock expect] taskDidLaunch:taskObject];	
	[[mock expect] taskDidRecieveData:[OCMArg any] fromTask:taskObject];
	[[mock expect] taskDidRecieveInvalidate:taskObject];
	
	[taskObject setDelegate:mock];

	[taskObject launch];
	
		// Run for 1 second and verify we are still running
	[self runUntilTimeout:1];
	
	STAssertTrue([taskObject isRunning],@"Test command exited prematurely");
	
	[taskObject invalidate];
	
		// Task should be finished instantly
	[self runUntilTimeout:0.1];
	
	STAssertTrue([taskObject isFinished],@"Task not finished after 10 secs");

	[mock verify];
		//	NSLog(@"Reached end of %@",[taskObject tag]);
	
}


- (void) testTerminateWorksOnLongRunningTask {
	[taskObject setTag:@"testInvalidateWorksOnLongRunningTask"];
	[self prepareTaskWithCommand:@"/usr/bin/find" args:[NSArray arrayWithObjects:@"/",@"-name",@"*.xml",nil]];
	
		// A nice mock is needed in this case because we can't be sure about whether we'll get any error data
	id mock = [OCMockObject niceMockForProtocol:@protocol(MFTaskDelegateProtocol)];	
	
	[[mock expect] taskDidLaunch:taskObject];	
	[[mock expect] taskDidRecieveData:[OCMArg any] fromTask:taskObject];
	[[mock expect] taskDidTerminate:taskObject];
	
	[taskObject setDelegate:mock];
	
	[taskObject launch];
	
		// Run for 1 second and verify we are still running
	[self runUntilTimeout:1];
	
	STAssertTrue([taskObject isRunning],@"Test command exited prematurely");
	
	[taskObject terminate];
	
		// The task may take some time to finish. Give it 10 seconds but be aware it might sometimes (rarely) take longer. 
	[self runUntilTimeout:10];
	
	STAssertTrue([taskObject isFinished],@"Task not finished after timeout");
	STAssertFalse([taskObject isRunning],@"Finished task still running after timeout");
	
	[mock verify];
 
 }



@end
