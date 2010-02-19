//
//  MFTask_Test.m
//  MFTask
//
//  Created by Ira Cooke on 17/02/10.
//  Copyright 2010 Mudflat Software. All rights reserved.
//

#import "MFTask_Test.h"
#import "MFTask.h"
#import "MockDelegate.h"

@implementation MFTask_Test

- (void) testCreateMFTask {
	id taskObject = [[MFTask alloc] init];
	
	STAssertTrue([taskObject isKindOfClass:[MFTask class]],@"An Object of Class MFTask could not be created");
	[taskObject release];
}


- (void) testLaunchWithNoDelegate {
	MFTask *task = [[MFTask alloc] init];
	[task setDelegate:nil];
	
	STAssertFalse([task launch],@"Task should fail to launch if a nil delegate is set");
	
	[task release];	
}

- (void) testLaunchWithUnconfiguredTask {
	MFTask *task = [[MFTask alloc] init];
	id del = [MockDelegate new];
	[task setDelegate:del];
	
	STAssertThrows([task launch],@"Task should fail to launch if a launch path has not been configured");
	
	[del release];
	[task release];	
	
}


- (void) testRun {
	MFTask *task = [[MFTask alloc] init];
	MockDelegate *del = [MockDelegate new];
	[task setDelegate:del];
	[task setLaunchPath:@"/bin/echo"];
	NSArray *args = [NSArray arrayWithObject:@"Hello"];
	[task setArguments:args];
	STAssertNoThrow([task launch],@"Task should launch successfully");
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate
											  dateWithTimeIntervalSinceNow:5.0]];
	
	STAssertTrue([[del outputData] length]>0,@"Must have some output data");
	
	[del release];
	[task release];	
}





- (void) testSetArguments {
	MFTask *task = [[MFTask alloc] init];
	
	id notArgs = [[NSObject alloc] init];
	id args = [[NSArray alloc] init];
	STAssertThrows([task setArguments:notArgs],@"A non NSArray argument should throw an exception");
	STAssertNoThrow([task setArguments:args],@"An NSArray argument should not throw an exception");
	
	
	[task release];
	[notArgs release];
	[args release];
	
}


- (void) testSetCurrentDirectoryPath {
	MFTask *task = [[MFTask alloc] init];
	
	id notArgs = [[NSObject alloc] init];
	id args = @"A String";
	STAssertThrows([task setCurrentDirectoryPath:notArgs],@"A non NSString argument should throw an exception");
	STAssertNoThrow([task setCurrentDirectoryPath:args],@"An NSString argument should not throw an exception");
	
	
	[task release];
	[notArgs release];
	[args release];
	
}

- (void) testSetEnvironment {
	MFTask *task = [[MFTask alloc] init];
	
	id notArgs = [[NSObject alloc] init];
	id args = [[NSDictionary alloc] init];
	STAssertThrows([task setEnvironment:notArgs],@"A non NSDictionary argument should throw an exception");
	STAssertNoThrow([task setEnvironment:args],@"An NSDictionary argument should not throw an exception");
	
	
	[task release];
	[notArgs release];
	[args release];
}
- (void) testSetLaunchPath {
	MFTask *task = [[MFTask alloc] init];
	
	id notArgs = [[NSObject alloc] init];
	id args = @"A String";
	STAssertThrows([task setLaunchPath:notArgs],@"A non NSString argument should throw an exception");
	STAssertNoThrow([task setLaunchPath:args],@"An NSString argument should not throw an exception");
	
	
	[task release];
	[notArgs release];
	[args release];
}



@end
