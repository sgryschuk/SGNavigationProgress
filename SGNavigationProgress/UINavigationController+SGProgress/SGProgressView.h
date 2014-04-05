//
//  SGProgressView.h
//  SGNavigationProgress
//
//  Created by Ben on 19/03/2014.
//  Copyright (c) 2014 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGProgressView : UIView

/**
 *  The current progress shown by the receiver.
 *  The progress value ranges from 0 to 1. The default value is 0.
 */
@property (nonatomic, assign) float progress;

@end
