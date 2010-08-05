//
//  MFTaskQueueTestCases.m
//  MFTask
//
//  Created by Ira Cooke on 5/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MFTaskQueueTestCases.h"
#import "MFTaskQueue.h"

@implementation MFTaskQueueTestCases

- (void) setUp {
	taskQueue = [MFTaskQueue new];
	STAssertTrue([taskQueue isKindOfClass:[MFTaskQueue class]],@"MFTask Queue not instantiated correctly");
	
}

- (void) tearDown {		
	[taskQueue release];
}

	// TODO: Write tests for MFTaskQueue

- (void) testLaunchesTasksInFIFOOrder {

}


- (void) testSafelyTerminatesMultipleTasks {
	
}

- (void) testSafelyInvalidatesMultipleTasks {
	
}

- (void) testLaunchesConcurrentTasksWithCorrectStaggerTime {
	
}



@end
