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

- (void) taskDidRecieveData:(NSData*) theData fromTask:(MFTask*)task;
- (void) taskDidRecieveErrorData:(NSData*) theData fromTask:(MFTask*)task;
- (void) taskDidTerminate:(MFTask*) theTask;
- (void) taskDidLaunch:(MFTask*) theTask;

@end
