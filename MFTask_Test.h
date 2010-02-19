//
//  MFTask_Test.h
//  MFTask
//
//  Created by Ira Cooke on 17/02/10.
//  Copyright 2010 Mudflat Software. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@interface MFTask_Test : SenTestCase {

}

- (void) testCreateMFTask;
- (void) testLaunchWithNoDelegate;
- (void) testLaunchWithUnconfiguredTask;
- (void) testRun;


- (void) testSetArguments;
- (void) testSetCurrentDirectoryPath;
- (void) testSetEnvironment;
- (void) testSetLaunchPath;

@end
