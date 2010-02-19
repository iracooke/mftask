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

- (void) taskDidRecieveData:(NSData*) theData {
	NSString *stringRep = [[NSString alloc] initWithData:theData encoding:NSASCIIStringEncoding];
	NSLog(@"%@\n",stringRep);
	
	NSMutableAttributedString *outputStore = [outputView textStorage];
	
	[outputStore appendAttributedString:[[NSAttributedString alloc] initWithString:stringRep]];
	
}

- (void) taskDidTerminate:(MFTask*) theTask {
	
}


@end
