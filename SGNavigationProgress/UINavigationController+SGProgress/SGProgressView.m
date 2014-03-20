//
//  SGProgressView.m
//  SGNavigationProgress
//
//  Created by Ben on 19/03/2014.
//  Copyright (c) 2014 Ben. All rights reserved.
//

#import "SGProgressView.h"

@interface SGProgressView ()
@property (nonatomic, strong) UIView *progressBar;
@end

@implementation SGProgressView

- (void)setProgress:(float)progress {
	if (_progress == progress) {
		return;
	}

	_progress = (progress < 0) ? 0 :
				(progress > 1) ? 1 :
				progress;

	CGRect slice, remainder;
	CGRectDivide(self.bounds, &slice, &remainder, CGRectGetWidth(self.bounds) * _progress, CGRectMinXEdge);
	self.progressBar.frame = slice;
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		self.progressBar = [[UIView alloc] init];
		self.progressBar.backgroundColor = self.tintColor;
		[self addSubview:self.progressBar];
	}
	return self;
}

- (void)setTintColor:(UIColor *)tintColor
{
	[super setTintColor:tintColor];
	self.progressBar.backgroundColor = tintColor;
}

@end
