//
//  UINavigationController+SGProgress.m
//  NavigationProgress
//
//  Created by Shawn Gryschuk on 2013-09-19.
//  Copyright (c) 2013 Shawn Gryschuk. All rights reserved.
//

#import "UINavigationController+SGProgress.h"
#import "SGProgressView.h"

NSInteger const SGProgressMasktagId = 221222322;
NSInteger const SGProgressMiniMasktagId = 221222321;
CGFloat const SGProgressBarHeight = 2.5;

@implementation UINavigationController (SGProgress)

- (CGRect)getSGMaskFrame
{
	float navBarHeight = self.navigationBar.frame.size.height;
	float navBarY = self.navigationBar.frame.origin.y;

	float width = self.view.frame.size.width;
	float height = self.view.frame.size.height - navBarHeight - navBarY;
	float x = 0;
	float y = navBarHeight + navBarY;

	return CGRectMake(x, y, width, height);
}

- (CGRect)getSGMiniMaskFrame
{
	float width = self.navigationBar.frame.size.width;
	float height = self.navigationBar.frame.size.height + self.navigationBar.frame.origin.y - SGProgressBarHeight;

	return CGRectMake(0, 0, width, height);
}

- (UIColor *)getSGMaskColor
{
	return [UIColor colorWithWhite:0 alpha:0.4];
}

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
		_progressView.tintColor = self.navigationBar.tintColor; // Default tintColor
		[self.navigationBar addSubview:_progressView];
	}

	return _progressView;
}

- (void)setupSGProgressMask
{
	UIView *mask;
	UIView *miniMask;
	for (UIView *subview in [self.view subviews])
	{
		if (subview.tag == SGProgressMasktagId)
		{
			mask = subview;
		}

		if (subview.tag == SGProgressMiniMasktagId)
		{
			miniMask = subview;
		}
	}

	if(!mask)
	{
		mask = [[UIView alloc] initWithFrame:[self getSGMaskFrame]];
		mask.tag = SGProgressMasktagId;
		mask.backgroundColor = [self getSGMaskColor];
		mask.alpha = 0;

		miniMask = [[UIView alloc] initWithFrame:[self getSGMiniMaskFrame]];
		miniMask.tag = SGProgressMiniMasktagId;
		miniMask.backgroundColor = [self getSGMaskColor];
		miniMask.alpha = 0;

		[self.view addSubview:mask];
		[self.view addSubview:miniMask];
		[UIView animateWithDuration:0.2 animations:^{
			mask.alpha = 1;
			miniMask.alpha = 1;
		}];
	}
	else
	{
		mask.frame = [self getSGMaskFrame];
		miniMask.frame = [self getSGMiniMaskFrame];
	}
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

- (void)setTintModeAndSetupMask
{
	self.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
	[self setupSGProgressMask];
}

#pragma mark user functions

- (void)showSGProgress
{
	[self showSGProgressWithDuration:3];
}

- (void)showSGProgressWithDuration:(float)duration
{
	[self showSGProgressWithDuration:duration andTintColor:self.navigationBar.tintColor];
}

- (void)showSGProgressWithDuration:(float)duration andTintColor:(UIColor *)tintColor andTitle:(NSString *)title
{
	[self changeSGProgressWithTitle:title];
	[self showSGProgressWithDuration:duration andTintColor:tintColor];
}

- (void)showSGProgressWithDuration:(float)duration andTintColor:(UIColor *)tintColor
{
	SGProgressView *progressView = [self progressView];
	progressView.tintColor = tintColor;

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

- (void)showSGProgressWithMaskAndDuration:(float)duration andTitle:(NSString *) title
{
	[self changeSGProgressWithTitle:title];
	[self showSGProgressWithMaskAndDuration:duration];

}

- (void)showSGProgressWithMaskAndDuration:(float)duration
{
	UIColor *tintColor = self.navigationBar.tintColor;
	self.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
	[self setupSGProgressMask];
	[self showSGProgressWithDuration:duration andTintColor:tintColor];

}

- (void)finishSGProgress
{
	SGProgressView *progressView = [self progressView];

	if(progressView)
	{
		[UIView animateWithDuration:0.1 animations:^{
			CGRect progressFrame = progressView.frame;
			progressFrame.size.width = progressFrame.size.width + 1;
			progressView.frame = progressFrame;
		}];
	}
}

- (void)cancelSGProgress {
	SGProgressView *progressView = [self progressView];

	if(progressView)
	{
		[UIView animateWithDuration:0.5 animations:^{
			progressView.alpha = 0;
		} completion:^(BOOL finished) {
			[progressView removeFromSuperview];
			[self removeSGMask];
			[self resetTitle];
		}];
	}
}

- (void)setSGProgressMaskWithPercentage:(float)percentage
{
	UIColor *tintColor = self.navigationBar.tintColor;

	if([NSThread isMainThread])
	{
		[self setTintModeAndSetupMask];
	}
	else
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[self setTintModeAndSetupMask];
		});
	}

	[self setSGProgressPercentage:percentage andTintColor:tintColor];
}

- (void)setSGProgressMaskWithPercentage:(float)percentage andTitle:(NSString *)title
{
	[self changeSGProgressWithTitle:title];
	[self setSGProgressMaskWithPercentage:percentage];
}

- (void)setSGProgressPercentage:(float)percentage
{
	[self setSGProgressPercentage:percentage andTintColor:self.navigationBar.tintColor];
}

- (void)setSGProgressPercentage:(float)percentage andTitle:(NSString *)title
{
	[self changeSGProgressWithTitle:title];
	[self setSGProgressPercentage:percentage andTintColor:self.navigationBar.tintColor];
}

- (void)setSGProgressPercentage:(float)percentage andTintColor:(UIColor *)tintColor
{
	SGProgressView *progressView = [self progressView];
	progressView.tintColor = tintColor;

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

@end
