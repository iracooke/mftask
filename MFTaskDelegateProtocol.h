//
//  MFTaskDelegate.h
//  MFTask
//
//  Created by Ira Cooke on 17/02/10.
//  Copyright 2010 Mudflat Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MFTask;

@protocol MFTaskDelegateProtocol

- (void) taskDidRecieveData:(NSData*) theData;
- (void) taskDidRecieveErrorData:(NSData*) theData;
- (void) taskDidTerminate:(MFTask*) theTask;

@end
