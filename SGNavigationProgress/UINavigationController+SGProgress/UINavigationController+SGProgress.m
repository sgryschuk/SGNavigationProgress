//
//  UINavigationController+SGProgress.m
//  NavigationProgress
//
//  Created by Shawn Gryschuk on 2013-09-19.
//  Copyright (c) 2013 Shawn Gryschuk. All rights reserved.
//

#import "UINavigationController+SGProgress.h"
#import "SGProgressView.h"

#define SGMaskColor [UIColor colorWithWhite:0 alpha:0.4]

NSInteger const SGProgressMasktagId = 221222322;
NSInteger const SGProgressMiniMasktagId = 221222321;
CGFloat const SGProgressBarHeight = 2.5;

@implementation UINavigationController (SGProgress)

- (SGProgressView *)progressView
{
	SGProgressView *_progressView;
	for (UIView *subview in [self.navigationBar subviews])
	{
		if ([subview isKindOfClass:[SGProgressView class]])
		{
			_progressView = (SGProgressView *)subview;
		}
	}

	if (!_progressView)
	{
		CGRect slice, remainder;
		CGRectDivide(self.navigationBar.bounds, &slice, &remainder, SGProgressBarHeight, CGRectMaxYEdge);
		_progressView = [[SGProgressView alloc] initWithFrame:slice];
		_progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		[self.navigationBar addSubview:_progressView];
	}

	return _progressView;
}

- (UIView *)topMask
{
	UIView *topMask;
	for (UIView *subview in [self.view subviews])
	{
		if (subview.tag == SGProgressMiniMasktagId)
		{
			topMask = subview;
		}
	}
	return topMask;
}

- (UIView *)bottomMask
{
	UIView *bottomMask;
	for (UIView *subview in [self.view subviews])
	{
		if (subview.tag == SGProgressMasktagId)
		{
			bottomMask = subview;
		}
	}
	return bottomMask;
}

- (BOOL)hasSGProgressMask
{
	for (UIView *subview in [self.view subviews])
	{
		if (subview.tag == SGProgressMiniMasktagId || subview.tag == SGProgressMasktagId)
		{
			return YES;
		}
	}
	return NO;
}

- (void)setupSGProgressMask
{
	self.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;

	UIView *topMask = [self topMask];
	UIView *bottomMask = [self bottomMask];

	if (!topMask)
	{
		topMask = [[UIView alloc] init];
		topMask.tag = SGProgressMiniMasktagId;
		topMask.backgroundColor = SGMaskColor;
		topMask.alpha = 0;
		[self.view addSubview:topMask];
	}

	if (!bottomMask)
	{
		bottomMask = [[UIView alloc] init];
		bottomMask.tag = SGProgressMasktagId;
		bottomMask.backgroundColor = SGMaskColor;
		bottomMask.alpha = 0;
		[self.view addSubview:bottomMask];
	}

	[self updateSGProgressMaskFrame];

	[UIView animateWithDuration:0.3 animations:^{
		topMask.alpha = 1;
		bottomMask.alpha = 1;
	}];
}

- (void)updateSGProgressMaskFrame
{
	CGFloat width = CGRectGetWidth(self.view.bounds);
	CGFloat height = CGRectGetMaxY(self.navigationBar.frame) - CGRectGetHeight([[self progressView] frame]);
	[[self topMask] setFrame:CGRectMake(0, 0, width, height)];

	CGRect slice, remainder;
	CGRectDivide(self.view.bounds, &slice, &remainder, CGRectGetMaxY(self.navigationBar.frame) + 0.5, CGRectMinYEdge);
	[[self bottomMask] setFrame:remainder];
}

- (void)removeSGMask
{
	for (UIView *subview in [self.view subviews])
	{
		if (subview.tag == SGProgressMasktagId || subview.tag == SGProgressMiniMasktagId)
		{
			[UIView animateWithDuration:0.3 animations:^{
				subview.alpha = 0;
			} completion:^(BOOL finished) {
				[subview removeFromSuperview];
				self.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
			}];
		}
	}
}

- (void)resetTitle
{
	BOOL titleChanged = [[[NSUserDefaults standardUserDefaults] objectForKey:kSGProgressTitleChanged] boolValue];

	if(titleChanged)
	{
		NSString *oldTitle = [[NSUserDefaults standardUserDefaults] objectForKey:kSGProgressOldTitle];
		//add animation
		self.visibleViewController.navigationItem.title = oldTitle;
	}

	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kSGProgressTitleChanged];
	[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kSGProgressOldTitle];
	[[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)changeSGProgressWithTitle:(NSString *)title
{
	BOOL titleAlreadyChanged = [[[NSUserDefaults standardUserDefaults] objectForKey:kSGProgressTitleChanged] boolValue];
	if(!titleAlreadyChanged)
	{
		NSString *oldTitle = self.visibleViewController.navigationItem.title;
		[[NSUserDefaults standardUserDefaults] setObject:oldTitle forKey:kSGProgressOldTitle];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kSGProgressTitleChanged];
		[[NSUserDefaults standardUserDefaults] synchronize];

		//add animation
		self.visibleViewController.navigationItem.title = title;
	}
}

#pragma mark - UIViewController

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if ([self hasSGProgressMask])
	{
		__weak typeof(self)weakSelf = self;
		__block NSTimeInterval timeInterval = 0;
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			while (timeInterval <= duration) {
				[NSThread sleepForTimeInterval:0.1];
				timeInterval += 0.1;
				dispatch_async(dispatch_get_main_queue(), ^{
					[weakSelf updateSGProgressMaskFrame];
				});
			}
		});
	}
}

#pragma mark user functions

- (void)showSGProgress
{
	[self showSGProgressWithDuration:3];
}

- (void)showSGProgressWithDuration:(float)duration
{
	SGProgressView *progressView = [self progressView];

	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		progressView.progress = 1;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.5 animations:^{
			progressView.alpha = 0;
		} completion:^(BOOL finished) {
			[progressView removeFromSuperview];
			[self removeSGMask];
			[self resetTitle];
		}];
	}];
}

- (void)showSGProgressWithDuration:(float)duration andTintColor:(UIColor *)tintColor
{
	[[self progressView] setTintColor:tintColor];
	[self showSGProgressWithDuration:duration];
}

- (void)showSGProgressWithDuration:(float)duration andTintColor:(UIColor *)tintColor andTitle:(NSString *)title
{
	[self changeSGProgressWithTitle:title];
	[self showSGProgressWithDuration:duration andTintColor:tintColor];
}

- (void)showSGProgressWithMaskAndDuration:(float)duration
{
	[self setupSGProgressMask];
	[self showSGProgressWithDuration:duration];
}

- (void)showSGProgressWithMaskAndDuration:(float)duration andTitle:(NSString *) title
{
	[self changeSGProgressWithTitle:title];
	[self showSGProgressWithMaskAndDuration:duration];
}

- (void)finishSGProgress
{
	SGProgressView *progressView = [self progressView];
	[UIView animateWithDuration:0.1 animations:^{
		progressView.progress = 1;
	}];
}

- (void)cancelSGProgress
{
	SGProgressView *progressView = [self progressView];
	[UIView animateWithDuration:0.5 animations:^{
		progressView.alpha = 0;
	} completion:^(BOOL finished) {
		[progressView removeFromSuperview];
		[self removeSGMask];
		[self resetTitle];
	}];
}

- (void)setSGProgressPercentage:(float)percentage
{
	SGProgressView *progressView = [self progressView];

	[UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
		progressView.progress = percentage / 100.f;

	} completion:^(BOOL finished) {
		if (percentage >= 100)
		{
			[UIView animateWithDuration:0.5 animations:^{
				progressView.alpha = 0;
			} completion:^(BOOL finished) {
				[progressView removeFromSuperview];
				[self removeSGMask];
				[self resetTitle];
			}];
		}
	}];
}

- (void)setSGProgressPercentage:(float)percentage andTitle:(NSString *)title
{
	[self changeSGProgressWithTitle:title];
	[self setSGProgressPercentage:percentage];
}

- (void)setSGProgressPercentage:(float)percentage andTintColor:(UIColor *)tintColor
{
	[[self progressView] setTintColor:tintColor];
	[self setSGProgressPercentage:percentage];
}

- (void)setSGProgressPercentage:(float)percentage andTintColor:(UIColor *)tintColor andTitle:(NSString *)title
{
	[self changeSGProgressWithTitle:title];
	[[self progressView] setTintColor:tintColor];
	[self setSGProgressPercentage:percentage];
}


- (void)setSGProgressMaskWithPercentage:(float)percentage
{
	[self setSGProgressPercentage:percentage];
	[self setupSGProgressMask];
}

- (void)setSGProgressMaskWithPercentage:(float)percentage andTitle:(NSString *)title
{
	[self changeSGProgressWithTitle:title];
	[self setSGProgressMaskWithPercentage:percentage];
}

@end
