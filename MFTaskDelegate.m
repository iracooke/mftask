//
//  MFTaskDelegate.m
//  MFTask
//
//  Created by Ira Cooke on 19/02/10.
//  Copyright 2010 Mudflat Software. All rights reserved.
//

#import "MFTaskDelegate.h"


@implementation MFTaskDelegate
@synthesize outputView;

- (void) taskDidRecieveData:(NSData*) theData fromTask:(MFTask*) task {
	NSString *stringRep = [[NSString alloc] initWithData:theData encoding:NSASCIIStringEncoding];
	
	NSMutableAttributedString *outputStore = [outputView textStorage];
	
	[outputStore appendAttributedString:[[NSAttributedString alloc] initWithString:stringRep]];
	
}

- (void) taskDidTerminate:(MFTask*) theTask {
	NSMutableAttributedString *outputStore = [outputView textStorage];

	[outputStore appendAttributedString:[[NSAttributedString alloc] initWithString:@"Task terminated\n"]];
}


- (void) taskDidRecieveErrorData:(NSData*) theData fromTask:(MFTask*)task {

	[self taskDidRecieveData:theData fromTask:task];
}

- (void) taskDidRecieveInvalidate:(MFTask*) theTask {
	
}

- (void) taskDidLaunch:(MFTask*) theTask {
	NSMutableAttributedString *outputStore = [outputView textStorage];

	[outputStore appendAttributedString:[[NSAttributedString alloc] initWithString:@"Task launched\n"]];
}

@end
