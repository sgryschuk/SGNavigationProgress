//
//  ViewController.h
//  NavigationProgress
//
//  Created by Shawn Gryschuk on 2013-09-19.
//  Copyright (c) 2013 Shawn Gryschuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationController+SGProgress.h"

@interface ViewController : UIViewController

- (IBAction)finishPressed:(id)sender;
- (IBAction)startPressed:(id)sender;
- (IBAction)startPressedWithMaskPressed:(id)sender;

- (IBAction)startPercentagePressed:(id)sender;
- (IBAction)startMaskWithPercentagePressed:(id)sender;

- (void)runPercentageLoop;
- (void)runMaskPercentageLoop;

@end
