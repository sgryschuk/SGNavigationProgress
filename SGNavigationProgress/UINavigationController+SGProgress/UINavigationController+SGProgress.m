//
//  UINavigationController+SGProgress.m
//  NavigationProgress
//
//  Created by Shawn Gryschuk on 2013-09-19.
//  Copyright (c) 2013 Shawn Gryschuk. All rights reserved.
//

#import "UINavigationController+SGProgress.h"

NSInteger const SGProgresstagId = 2221222323;

@implementation UINavigationController (SGProgress)

- (UIView *)setupSGProgressSubview
{
	float height = 1;
	float y = self.navigationBar.frame.size.height - height;
	
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
		progressView = [[UIView alloc] initWithFrame:CGRectMake(0, y, 0, height)];
		progressView.tag = SGProgresstagId;
		progressView.backgroundColor = self.navigationBar.tintColor;
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

- (void)showSGProgress
{
	[self showSGProgressWithDuration:3];
}

- (void)showSGProgressWithDuration:(float)duration
{
	UIView *progressView = [self setupSGProgressSubview];
	
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
		}];
	}];
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

- (void)setSGProgressPercentage:(float)percentage
{
	if (percentage > 100.0)
	{
		percentage = 100.0;
	}
	else if(percentage < 0)
	{
		percentage = 0;
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		
		UIView *progressView = [self setupSGProgressSubview];
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
				}];
			}
		}];
	});
}

@end
