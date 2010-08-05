//
//  MockDelegate.m
//  MFTask
//
//  Created by Ira Cooke on 17/02/10.
//  Copyright 2010 Mudflat Software. All rights reserved.
//

#import "MockDelegate.h"


@implementation MockDelegate
@synthesize outputData;

- (void) taskDidRecieveData:(NSData*) theData fromTask:(MFTask*) task {
	[outputData appendData:theData];
}

- (void) taskDidTerminate:(MFTask*) theTask {
	
}

- (void) taskDidRecieveErrorData:(NSData*) theData fromTask:(MFTask*)task {
	
}

- (void) taskDidRecieveInvalidate:(MFTask*) theTask {
	
}

- (void) taskDidLaunch:(MFTask*) theTask {
	
}

@end
