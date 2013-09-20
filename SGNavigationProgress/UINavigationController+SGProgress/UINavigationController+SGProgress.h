//
//  UINavigationController+SGProgress.h
//  NavigationProgress
//
//  Created by Shawn Gryschuk on 2013-09-19.
//  Copyright (c) 2013 Shawn Gryschuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (SGProgress)

- (void)showSGProgress;
- (void)showSGProgressWithDuration:(float)duration;
- (void)finishSGProgress;
- (void)setSGProgressPercentage:(float)percentage;


@end
