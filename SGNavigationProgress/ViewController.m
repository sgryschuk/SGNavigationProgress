//
//  ViewController.m
//  NavigationProgress
//
//  Created by Shawn Gryschuk on 2013-09-19.
//  Copyright (c) 2013 Shawn Gryschuk. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(nonatomic, getter = isCanceled) BOOL canceled;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = @"Title of the bar";
}

- (IBAction)startPressed:(id)sender
{
	[self.navigationController showSGProgressWithDuration:4];
}

- (IBAction)startPressedWithMaskPressed:(id)sender
{
	[self.navigationController showSGProgressWithMaskAndDuration:4 andTitle:@"Sending..."];
}

- (IBAction)startWithTitlePressed:(id)sender
{
	[self.navigationController showSGProgressWithDuration:4 andTintColor:self.navigationController.navigationBar.tintColor andTitle:@"Sending..." ];
}

- (IBAction)finishPressed:(id)sender
{
	[self.navigationController finishSGProgress];
}

- (IBAction)cancelPressed:(id)sender
{
    self.canceled = YES;
    [self.navigationController cancelSGProgress];
}

- (IBAction)startPercentagePressed:(id)sender
{
    self.canceled = NO;
	[self performSelectorInBackground:@selector(runPercentageLoop) withObject:nil];
}

- (IBAction)startMaskWithPercentagePressed:(id)sender
{
    self.canceled = NO;
	[self performSelectorInBackground:@selector(runMaskPercentageLoop) withObject:nil];
}

- (IBAction)startPercentageTitlePressed:(id)sender
{
    self.canceled = NO;
	[self performSelectorInBackground:@selector(runTitlePercentageLoop) withObject:nil];
}

- (IBAction)startMaskTitleWithPercentagePressed:(id)sender
{
    self.canceled = NO;
	[self performSelectorInBackground:@selector(runMaskTitlePercentageLoop) withObject:nil];
}

- (void)runPercentageLoop
{
	float percentage = 0;
	
	while (percentage <= 200 && !self.canceled)
	{
		NSLog(@"%f", percentage);
		[NSThread sleepForTimeInterval:0.1];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.navigationController setSGProgressPercentage:percentage];
		});
		if(percentage >= 100.0)
		{
			return;
		}
		
		percentage = percentage + (arc4random() % 3);
	}
}

- (void)runMaskPercentageLoop
{
	float percentage = 0;
	
	while (percentage <= 200 && !self.canceled)
	{
		NSLog(@"%f", percentage);
		[NSThread sleepForTimeInterval:0.1];
		[self.navigationController setSGProgressMaskWithPercentage:percentage];
		if(percentage >= 100.0)
		{
			return;
		}
		
		percentage = percentage + (arc4random() % 3);
	}
}

- (void)runTitlePercentageLoop
{
	float percentage = 0;
	
	while (percentage <= 200 && !self.canceled)
	{
		NSLog(@"%f", percentage);
		[NSThread sleepForTimeInterval:0.1];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.navigationController setSGProgressPercentage:percentage andTitle:@"Sending..."];
		});
		if(percentage >= 100.0)
		{
			return;
		}
		
		percentage = percentage + (arc4random() % 3);
	}
}

- (void)runMaskTitlePercentageLoop
{
	float percentage = 0;
	
	while (percentage <= 200 && !self.canceled)
	{
		NSLog(@"%f", percentage);
		[NSThread sleepForTimeInterval:0.1];
		[self.navigationController setSGProgressMaskWithPercentage:percentage andTitle:@"Sending..."];
		if(percentage >= 100.0)
		{
			return;
		}
		
		percentage = percentage + (arc4random() % 3);
	}
}

@end
