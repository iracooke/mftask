//
//  MockDelegate.h
//  MFTask
//
//  Created by Ira Cooke on 17/02/10.
//  Copyright 2010 Mudflat Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MFTaskDelegateProtocol.h"

@interface MockDelegate : NSObject <MFTaskDelegateProtocol>  {
	NSMutableData *outputData;
	
}

@property (retain) NSMutableData* outputData;

@end
