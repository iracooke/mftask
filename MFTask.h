//
//  MFTask.h
//  MFTask
//
//  Created by Ira Cooke on 17/02/10.
//  Copyright 2010 Mudflat Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MFTaskDelegateProtocol.h"

@class NSTask;

@interface MFTask : NSObject {
	id <MFTaskDelegateProtocol> delegate;
	NSTask *internal_task;
}

@property (retain) id <MFTaskDelegateProtocol> delegate;


//! Attempts to Launch the Task. Returns NO if it fails 
- (BOOL) launch;

//! Sets the arguments of the underlying NSTask
- (void) setArguments:(NSArray*) arguments;

//! Sets the Current Directory Path on the underlying task
- (void)setCurrentDirectoryPath:(NSString *)path;

//! Sets the Environment for the underlying NSTask
- (void)setEnvironment:(NSDictionary *)environmentDictionary;

//! Sets the Launch path to the executable used by the underlying NSTask
- (void)setLaunchPath:(NSString *)path;

//! Sets the standard input pipe used by NSTask
- (void) setStandardInput:(NSPipe*) inputPipe;

- (void) terminate;

- (BOOL) isRunning;

@end
