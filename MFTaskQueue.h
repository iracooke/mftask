//
//  MFTaskQueue.h
//  MFTask
//
//  Created by Ira Cooke on 10/05/10.
//  Copyright 2010 Mudflat Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MFTask;

/*! @abstract A simple queue for MFTasks

 MFTaskQueue is designed to fill a similar role to NSOperationQueue, except that it operates on MFTask objects rather than on NSOperations. The reason for this is that it can be tricky wrapping an NSTask in an NSOperation. MFTaskQueue only provides a very simple subset of the functionality of NSOperationQueue. In particular it supports only a simple fifo ordering of task execution.
 
 Note that we use the terminology of tasks here when referring to task methods like terminate, launch etc. But we use the terminology of an OperationQueue where referring to queuing functionality.
 */
@interface MFTaskQueue : NSObject {
	NSMutableArray *tasks;
	NSInteger maxConcurrentTaskCount;
	

	// Internal variables for keeping track of the timing of starting tasks. Sometimes tasks need to be staggered.
	BOOL waitingForTimer;
	NSTimeInterval staggerSeconds;

	BOOL waitsForTaskCompletion;
	
}

/*! @abstract Whether to wait for tasks to completely clean up (YES), or to simply terminate them ignore any further data they might generate (NO). The default is NO
 */
@property (nonatomic,assign) BOOL waitsForTaskCompletion;

/*! 
 @abstract The number of seconds to wait between launching concurrent tasks.  
 This can be useful for interacting with certain servers, where for example multiple login attempts in succession would be seen as an attack. The default value is 5.0 seconds.
 */
@property (nonatomic,assign) NSTimeInterval staggerSeconds;

/*! 
 @abstract The maximum number of simultaneous tasks to run 
 */
@property (nonatomic,assign) NSInteger maxConcurrentTaskCount;

/*! 
 @abstract Sends a terminate message to all tasks 
 */
- (void) terminateAllTasks;

/*! 
 @abstract Adds a task to the queue, launching it immediately if possible 
 @param task The MFTask object to add to the queue.
 */
- (void) addTask:(MFTask*) task;

/*! 
 @abstract The number of remaining tasks 
 @result The number of tasks that are currently running or which have not yet been launched 
 */
- (NSInteger) remainingTasks;

@end
