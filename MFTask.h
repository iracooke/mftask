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
	NSObject <MFTaskDelegateProtocol>* delegate;
	NSTask *internal_task;

	// These are used to form a conditional lock allowing us to wait until all data is read before signalling competion to the delegate
	NSInteger readingDataCondition;
	NSCondition *readingDataLock;
	
	NSInteger readingErrorDataCondition;
	NSCondition *readingErrorDataLock;
	
	NSString *tag;
	
	BOOL isFinished;
	
	BOOL _hasPerformedTerminate;
	BOOL _hasBeenSentTerminate;
	
	BOOL hasLaunched;
	
}

/*!
 @abstract A Tag that can be used to identify an MFTask
 */
@property (retain) NSString * tag;

/*! 
 @abstract A delegate object that conforms to the MFTaskDelegateProtocol 
*/
@property (assign) NSObject <MFTaskDelegateProtocol>* delegate;

/*!
 @abstract A flag indicating whether this MFTask has finished execution.
 @discussion This flag will be set to YES under the following conditions. 
 
 1. After the internal NSTask sends it NSTaskDidTerminateNotification and then after all output and error data has been read\n
 2. If the MFTask is terminated via a call to terminate or invalidate without ever having been launched. \n
 3. Invalidate is called on the task \n
 
 A task that is finished can be safely released.
 
 A task whose isFinished flag has been set to YES will be removed from an MFTaskQueue it belongs to.
 
 */
@property (assign) BOOL isFinished;

/*! 
 @abstract A flag indicating whether the task has launched. Set to true when launch is called. 
 */
@property (assign) BOOL hasLaunched;


/*!
@abstract Terminates the task
 If the task is running sends a message to the underlying NSTask telling it to terminate. After this method is called there may be some delay before isFinished is set to YES and the delegate selector taskDidTerminate is called. If the task has not yet been launched this method will set its isFinished flag to yes immediately.
 */
- (void) terminate;

/*! @abstract Invalidates the task, terminates it and then ensures that no further messages will be sent to its delegate, except for a taskDidRecieveInvalidate. 
 After calling this method the isFinished property is set to yes. 
 If this method is used to terminate a task the delegate will not recieve a taskDidTerminate message.
 */
- (void) invalidate;

/*! 
 @abstract Attempts to Launch the Task. Returns NO if it fails 
 @discussion An exception is thrown if this method is called on a task that has already launched, or a task that has no delegate. A task that has been terminated or invalidated will return NO.
 @result YES if launch was successful. Otherwise NO.
 */
- (BOOL) launch;


#pragma mark Cover methods for NSTask

//! Sets the arguments of the underlying NSTask. See the corresponding method of NSTask
- (void) setArguments:(NSArray*) arguments;

//! Arguments of the underlying NSTask. See the corresponding method of NSTask
- (NSArray *)arguments;

//! Sets the Current Directory Path on the underlying task. See the corresponding method of NSTask
- (void)setCurrentDirectoryPath:(NSString *)path;

//! Current directory path of the underlying task. See the corresponding method of NSTask
- (NSString*) currentDirectoryPath;

//! Sets the Environment for the underlying NSTask. See the corresponding method of NSTask
- (void)setEnvironment:(NSDictionary *)environmentDictionary;

//! The environment dictionary of the underlying nstask. See the corresponding method of NSTask
- (NSDictionary*) environment;

//! Sets the Launch path to the executable. See the corresponding method of NSTask
- (void)setLaunchPath:(NSString *)path;

//! The launch path of the task. See the corresponding method of NSTask
- (NSString*) launchPath;


//! Sets the standard input pipe. See the corresponding method of NSTask
- (void) setStandardInput:(NSPipe*) inputPipe;

//! The standard input file of the underlying NSTask. See the corresponding method of NSTask
- (id)standardInput;

//! The standard output file of the underlying NSTask. See the corresponding method of NSTask
- (id)standardOutput;

//! The standard error file of the underlying NSTask. See the corresponding method of NSTask
- (id) standardError;

//! The underlying task's process identifier. See the corresponding method of NSTask
- (int)processIdentifier;

//! The termination status of the underlying task. See the corresponding method of NSTask
- (int)terminationStatus;

/*! @abstract Whether the underlying task is running. See the corresponding method of NSTask */
- (BOOL) isRunning;

@end
