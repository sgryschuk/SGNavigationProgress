//
//  ViewController.m
//  NavigationProgress
//
//  Created by Shawn Gryschuk on 2013-09-19.
//  Copyright (c) 2013 Shawn Gryschuk. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(nonatomic, weak) NSBlockOperation *currentProgress;
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
	[self.currentProgress cancel];
	[self.navigationController performSelector:@selector(finishSGProgress) withObject:nil afterDelay:0.1];
}

- (IBAction)cancelPressed:(id)sender
{
    [self.currentProgress cancel];
    [self.navigationController cancelSGProgress];
}

- (IBAction)startPercentagePressed:(id)sender
{
    __weak typeof(self)weakSelf = self;
    [self simulateProgressWithAction:^(float percentage) {
        [weakSelf.navigationController setSGProgressPercentage:percentage];
    }];
}

- (IBAction)startMaskWithPercentagePressed:(id)sender
{
    __weak typeof(self)weakSelf = self;
    [self simulateProgressWithAction:^(float percentage) {
        [weakSelf.navigationController setSGProgressMaskWithPercentage:percentage];
    }];
}

- (IBAction)startPercentageTitlePressed:(id)sender
{
    __weak typeof(self)weakSelf = self;
    [self simulateProgressWithAction:^(float percentage) {
        [weakSelf.navigationController setSGProgressPercentage:percentage andTitle:@"Sending..."];
    }];
}

- (IBAction)startMaskTitleWithPercentagePressed:(id)sender
{
    __weak typeof(self)weakSelf = self;
    [self simulateProgressWithAction:^(float percentage) {
        [weakSelf.navigationController setSGProgressMaskWithPercentage:percentage andTitle:@"Sending..."];
    }];
}

- (void)simulateProgressWithAction:(void (^)(float percentage))displayProgress
{
    [self.currentProgress cancel];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *operation = [[NSBlockOperation alloc] init];

    __weak NSBlockOperation *weakOp = operation;
    [operation addExecutionBlock:^{
        float percentage = 0;

        while (![weakOp isCancelled])
        {
            NSLog(@"%f", percentage);
            [NSThread sleepForTimeInterval:0.1];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                displayProgress(percentage);
            }];

            if (percentage >= 100)
            {
                return;
            }
            percentage += (arc4random() % 3);
        }
    }];
    [queue addOperation:operation];

    self.currentProgress = operation;
}

@end
