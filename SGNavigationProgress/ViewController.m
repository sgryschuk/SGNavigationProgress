//
//  ViewController.m
//  NavigationProgress
//
//  Created by Shawn Gryschuk on 2013-09-19.
//  Copyright (c) 2013 Shawn Gryschuk. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

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

- (IBAction)finishPressed:(id)sender
{
	[self.navigationController finishSGProgress];
}

- (IBAction)startPercentagePressed:(id)sender
{
	[self performSelectorInBackground:@selector(runPercentageLoop) withObject:nil];
}

- (void)runPercentageLoop
{
	float percentage = 0;
	
	while (percentage <= 200)
	{
		NSLog(@"%f", percentage);
		[NSThread sleepForTimeInterval:0.1];
		[self.navigationController setSGProgressPercentage:percentage];
		if(percentage >= 100.0)
		{
			return;
		}
		
		percentage = percentage + (arc4random() % 3);
	}
}

@end
