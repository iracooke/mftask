//
//  MFTaskAppDelegate.h
//  MFTask
//
//  Created by Ira Cooke on 19/02/10.
//  Copyright 2010 Mudflat Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MFTask,MFTaskDelegate;

@interface MFTaskAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	IBOutlet NSTextField *taskPathField;
	IBOutlet NSTextView *outputView;
	IBOutlet NSButton *startButton;
	IBOutlet NSButton *stopButton;
		
	IBOutlet NSArrayController *argsArrayController;
	
	NSMutableArray *arguments;
	
	MFTask *currentTask;
	MFTaskDelegate *taskDelegate;
}

@property (assign) IBOutlet NSWindow *window;

@property (retain) IBOutlet NSTextField *taskPathField;
@property (retain) IBOutlet NSTextView *outputView;
@property (retain) IBOutlet NSButton *startButton;
@property (retain) IBOutlet NSButton *stopButton;

@property (retain) MFTask *currentTask;
@property (retain) MFTaskDelegate *taskDelegate;

-(IBAction) start:(id) sender;
-(IBAction) stop:(id) sender;

- (IBAction) clear:(id) sender;

@end
