//
//  UINavigationController+SGProgress.m
//  NavigationProgress
//
//  Created by Shawn Gryschuk on 2013-09-19.
//  Copyright (c) 2013 Shawn Gryschuk. All rights reserved.
//

#import "UINavigationController+SGProgress.h"

NSInteger const SGProgresstagId = 222122323;
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

- (UIView *)setupSGProgressSubview
{
	return [self setupSGProgressSubviewWithTintColor:self.navigationBar.tintColor];
}

- (UIView *)setupSGProgressSubviewWithTintColor:(UIColor *)tintColor
{
	float y = self.navigationBar.frame.size.height - SGProgressBarHeight;
	
	UIView *progressView;
	for (UIView *subview in [self.navigationBar subviews])
	{
		if (subview.tag == SGProgresstagId)
		{
			progressView = subview;
		}
	}
	
	if(!progressView)
	{
		progressView = [[UIView alloc] initWithFrame:CGRectMake(0, y, 0, SGProgressBarHeight)];
		progressView.tag = SGProgresstagId;
		progressView.backgroundColor = tintColor;
		[self.navigationBar addSubview:progressView];
	}
	else
	{
		CGRect progressFrame = progressView.frame;
		progressFrame.origin.y = y;
		progressView.frame = progressFrame;
	}
	
	return progressView;
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

- (void)viewUpdatesForPercentage:(float)percentage andTintColor:(UIColor *)tintColor
{
	UIView *progressView = [self setupSGProgressSubviewWithTintColor:tintColor];
	float maxWidth = self.navigationBar.frame.size.width;
	float progressWidth = maxWidth * (percentage / 100);
	
	
	[UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
		CGRect progressFrame = progressView.frame;
		progressFrame.size.width = progressWidth;
		progressView.frame = progressFrame;
		
	} completion:^(BOOL finished)
	 {
		 if(percentage >= 100.0)
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
	UIView *progressView = [self setupSGProgressSubviewWithTintColor:tintColor];
	
	float maxWidth = self.navigationBar.frame.size.width;
	
	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		CGRect progressFrame = progressView.frame;
		progressFrame.size.width = maxWidth;
		progressView.frame = progressFrame;
		
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
	UIView *progressView = [self setupSGProgressSubview];
	
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
    UIView *progressView = [self setupSGProgressSubview];

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
	if (percentage > 100.0)
	{
		percentage = 100.0;
	}
	else if(percentage < 0)
	{
		percentage = 0;
	}
	
	if([NSThread isMainThread])
	{
		[self viewUpdatesForPercentage:percentage andTintColor:tintColor];
	}
	else
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[self viewUpdatesForPercentage:percentage andTintColor:tintColor];
		});
	}
}

@end
