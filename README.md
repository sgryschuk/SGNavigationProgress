# SGNavigationProgress

A category for showing a Safari-like progress view on a UINavigationBar
![SGNavigationProgress](https://raw.github.com/sgryschuk/SGNavigationProgress/master/ScreenShot.png)
![SGNavigationProgress With Mask](https://raw.github.com/sgryschuk/SGNavigationProgress/master/ScreenShotMask.png)

## Installation

Cocoapods: `pod 'SGNavigationProgress'`

Manual: add UINavigationController+SGProgress.h and UINavigationController+SGProgress.m to your project and import the .h file

## Usage

### set duration
`[self.self.navigationController showSGProgress];	//defaults to 3 seconds`
`[self.navigationController showSGProgressWithDuration:3];  //uses the navbar tint color`
`[self.navigationController showSGProgressWithDuration:3 andTintColor:[UIColor blueColor];`
`[self.navigationController showSGProgressWithDuration:3 andTintColor:[UIColor blueColor] andTitle:@"Sending..."];`
`[self.navigationController showSGProgressWithMaskAndDuration:3];`
`[self.navigationController showSGProgressWithMaskAndDuration:3 andTitle:@"Sending..."];`

`[self.navigationController finishSGProgress]; //finish animation early`

### custom percentage

`- (void)setSGProgressPercentage:(float)percentage;`
`- (void)setSGProgressPercentage:(float)percentage andTitle:(NSString *)title;`
`- (void)setSGProgressPercentage:(float)percentage andTintColor:(UIColor *)tintColor;`
`- (void)setSGProgressMaskWithPercentage:(float)percentage;`
`- (void)setSGProgressMaskWithPercentage:(float)percentage andTitle:(NSString *)title;`

`[SVHTTPRequest POST:URL parameters:@{} progress:^(float progress) {[self.navigationController setSGProgressPercentage:progress * 100];} completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {}];`



## License

MIT License
