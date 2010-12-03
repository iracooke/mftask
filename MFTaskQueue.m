//
//  MFTaskQueue.m
//  DropSync
//
//  Created by Ira Cooke on 10/05/10.
//  Copyright 2010 Mudflat Software. All rights reserved.
//

#import "MFTaskQueue.h"
#import "MFTask.h"

static NSString *const MFTaskQueueKVOObservingContext=@"MFTaskQueueKVOObservingContext";

@implementation MFTaskQueue
@synthesize maxConcurrentTaskCount,staggerSeconds,waitsForTaskCompletion;

- (id) init {
	if ( self = [super init]){
		tasks=[NSMutableArray new];
		maxConcurrentTaskCount=1;
		staggerSeconds=5.0;
		waitingForTimer=NO;
		return self;
	} else {
		return nil;
	}
}

- (void) dealloc {

	for(MFTask *task in tasks){	
		if ( [task hasLaunched] )
			[task removeObserver:self forKeyPath:@"isFinished"];
	}
	[tasks release];
	

	[super dealloc];
	
}



//! Send all tasks a terminate message
- (void) terminateAllTasks {
	for(MFTask *task in tasks){		
		if ( [self waitsForTaskCompletion] ){
			[task terminate];
		} else {
			[task invalidate];
		}
	}
	staggerSeconds=0; // Set this so that we cancel things quickly
}

//! Number of running tasks
- (NSInteger) numRunning {
	NSInteger num=0;
	for(MFTask *task in tasks){
		if ( [task isRunning] ){
			num++;
		}
	}
	return num;
}

//! The number of unfinished tasks. (ie still running or not yet launched) in the queue
- (NSInteger) remainingTasks {
	NSInteger num=0;
	for(MFTask *task in tasks){
		if ( ![task isFinished] ){
			num++;
		} 
	}
	return num;
}

//! If possible launch the next task in the queue. Respects a stagger timer and a maximum for concurrent tasks. 
- (void) launchTasksIfNeeded {
	waitingForTimer=NO;
	NSInteger maxNumToLaunch=[self maxConcurrentTaskCount]-[self numRunning];
	
	for(MFTask *task in tasks){
		
		if ( ![task hasLaunched] && (maxNumToLaunch>0) ){

			[task addObserver:self forKeyPath:@"isFinished" options:0 context:MFTaskQueueKVOObservingContext];
			BOOL taskLaunched = [task launch];

			if ( !taskLaunched ){
				// If we failed to launch then KVO needs removing here because isFinished will never be observed to change
				[task removeObserver:self forKeyPath:@"isFinished"];
			}
			
			maxNumToLaunch--;
			if ( maxNumToLaunch > 0 ){
					//				DLog(@"Launching timer");
					// We still need to start more but we need to wait a bit or ssh will lock us out
				[NSTimer scheduledTimerWithTimeInterval:staggerSeconds target:self selector:@selector(launchTasksIfNeeded) userInfo:nil repeats:NO];
				waitingForTimer=YES;
				return;
			}
		}
	}
	
}

//! Add a task to the queue. Tasks will be launched in the order they are added. If possible this method will immediately launch the task.
- (void) addTask:(MFTask*) task {
	[tasks addObject:task];
	if ( !waitingForTimer ){
		[self launchTasksIfNeeded];
	}
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change 
					  context:(void *)context {
    if ( (context==MFTaskQueueKVOObservingContext) && [keyPath isEqualToString:@"isFinished"] ) {
		
		// If the task isFinished then we should remove it from the queue and launch another if possible
		if ( [object isFinished] ){
			
			// Only if the task was launched will we have registered 
			[object removeObserver:self forKeyPath:@"isFinished"];
			
			// Remove the task from the queue 
			//			[tasks removeObject:object];	
			[tasks performSelector:@selector(removeObject:) withObject:object afterDelay:0.0];
			
			if ( !waitingForTimer ){
				
				[self performSelector:@selector(launchTasksIfNeeded) withObject:nil afterDelay:0.0];
				
					//				[self launchTasksIfNeeded];
				
			} else {
			//	DLog(@"Waiting for timer");
			}
		} else {
			// Should never get here
			
		}
    } else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

@end
