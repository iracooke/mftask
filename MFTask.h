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

/*!
 @abstract Encapsulates an NSTask providing easy capture of output via its delegate
 @discussion Provides an API for NSTask objects that is more similar to NSURLConnection. All output from the task can easily be captured via the delegate methods defined in MFTaskDelegateProtocol. MFTask objects accept a tag so that a delegate can recognise output from multiple tasks. Although a standard input pipe can be set, the standard output and standard input are managed internally.
 */
@interface MFTask : NSObject {
	id <MFTaskDelegateProtocol> delegate;
	NSTask *internal_task;

	// These are used to form a conditional lock allowing us to wait until all data is read before signalling competion to the delegate
	NSInteger readingDataCondition;
	NSCondition *readingDataLock;
	
	NSInteger readingErrorDataCondition;
	NSCondition *readingErrorDataLock;
	
	NSString *tag;
	
	BOOL isFinished;
	BOOL _hasPerformedTerminate;
	BOOL hasLaunched;
	
}

/*!
 @abstract A Tag that can be used to identify an MFTask
 */
@property (retain) NSString * tag;

/*! 
 @abstract A delegate object that conforms to the MFTaskDelegateProtocol 
*/
@property (assign) id <MFTaskDelegateProtocol> delegate;

/*!
 @abstract A flag indicating whether this MFTask has finished execution.
 @discussion This flag will be set to YES under the following conditions. 
 
 1. After the internal NSTask sends it NSTaskDidTerminateNotification and then after all output and error data has been read\n
 2. If the MFTask is terminated via a call to terminate without ever having been launched.
 
 */
@property (assign) BOOL isFinished;

/*! 
 @abstract A flag indicating whether the task has launched. Set to true when launch is called. 
 */
@property (assign) BOOL hasLaunched;


/*!
@abstract Terminates the task
 If called on a task that has not been launched, this method will ensure that the isFinished flag is set, which invalidates the task for further use.
 */
- (void) terminate;

/*! @abstract Whether the underlying task is running. See the corresponding method of NSTask */
- (BOOL) isRunning;


/*! 
 @abstract Attempts to Launch the Task. Returns NO if it fails 
 @discussion An exception is thrown if this method is called on a task that has already launched, or a task that has been terminated.
 @result YES if launch was successful. Otherwise no.
 */
- (BOOL) launch;

//! Sets the arguments of the underlying NSTask. See the corresponding method of NSTask
- (void) setArguments:(NSArray*) arguments;

//! Sets the Current Directory Path on the underlying task. See the corresponding method of NSTask
- (void)setCurrentDirectoryPath:(NSString *)path;

//! Sets the Environment for the underlying NSTask. See the corresponding method of NSTask
- (void)setEnvironment:(NSDictionary *)environmentDictionary;

//! Sets the Launch path to the executable. See the corresponding method of NSTask
- (void)setLaunchPath:(NSString *)path;

//! Sets the standard input pipe. See the corresponding method of NSTask
- (void) setStandardInput:(NSPipe*) inputPipe;


@end
