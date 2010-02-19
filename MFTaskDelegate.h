//
//  MFTaskDelegate.h
//  MFTask
//
//  Created by Ira Cooke on 19/02/10.
//  Copyright 2010 Mudflat Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MFTaskDelegateProtocol.h"

@interface MFTaskDelegate : NSObject <MFTaskDelegateProtocol> {

	NSTextView *outputView;
	
}

@property (retain) NSTextView *outputView;

@end
