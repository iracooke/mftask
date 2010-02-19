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

- (void) taskDidRecieveData:(NSData*) theData {
	[outputData appendData:theData];
}

- (void) taskDidTerminate:(MFTask*) theTask {
	
}

@end
