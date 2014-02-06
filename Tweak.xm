#import "UIImage+ImageEffects.h"
#import "substrate.h"

#define LOG_PANEL_HEIGHT 120

// view snagging properties
static UIView* snaggedView = nil;
static BOOL snagBlock = NO;
static BOOL snagNext = NO;

// log view
static UIWindow *logWindow;
static UIView *logContainer;
static UIView *logBackground;
static UILabel *logLabel;

typedef BOOL(^CYCViewSearchCriterionValidator)(UIView *view, NSObject *criterion);

@interface SpringBoard
-(void)relaunchSpringBoard;
@end

@interface cyc : NSObject
// scraping for views
+(NSArray *)subviewsOfView:(UIView *)view kindOfClassForName:(NSString *)classToTest;
+(NSArray *)subviewsOfView:(UIView *)view exactClassName:(NSString *)className;
+(NSArray *)subviewsOfView:(UIView *)view withCriterion:(NSObject *)criterion matchingCriterionValidator:(CYCViewSearchCriterionValidator)validator;
+(UIViewController*)viewControllerForView:(UIView*)view;
+(id)ivarNamed:(NSString*)varName withinObject:(id)object;
+(id)ivarNamed:(NSString*)varName withinObject:(id)object dataType:(NSString*)typeName;
+(id)snagNextTouch;
+(UIView*)snaggedView;
+(UIViewController*)snaggedViewController;
+(id)viewToFlash:(UIView*)view;
+(id)flashSnaggedView;
+(id)blurrySnapshot;
+(id)respring;
@end

@implementation cyc

+(NSArray *)subviewsOfView:(UIView *)view kindOfClassForName:(NSString *)classToTest {
	CYCViewSearchCriterionValidator validator = ^(UIView *view, NSObject *classToTest) {
		Class theClass = NSClassFromString((NSString *)classToTest);
		if ([view isKindOfClass:theClass]) {
			return YES;
		} else {
			return NO;
		}
	};

	return [cyc subviewsOfView:view withCriterion:classToTest matchingCriterionValidator:validator];
}

+(NSArray *)subviewsOfView:(UIView *)view exactClassName:(NSString *)className {
	CYCViewSearchCriterionValidator validator = ^(UIView *view, NSObject *className) {
		if ([NSStringFromClass([view class]) isEqualToString:(NSString *)className]) {
			return YES;
		} else {
			return NO;
		}
	};
	
	return [cyc subviewsOfView:view withCriterion:className matchingCriterionValidator:validator];
}

+(NSArray *)subviewsOfView:(UIView *)view inheritsClassName:(NSString *)className {
	CYCViewSearchCriterionValidator validator = ^(UIView *view, NSObject *className) {
		id classFromString = NSClassFromString((NSString *)className);
		if (classFromString != nil && [[view class] isKindOfClass:classFromString]) {
			return YES;
		} else {
			return NO;
		}
	};

	return [cyc subviewsOfView:view withCriterion:className matchingCriterionValidator:validator];
}

+(NSArray *)subviewsOfView:(UIView *)view withCriterion:(NSObject *)criterion matchingCriterionValidator:(CYCViewSearchCriterionValidator)validator {
	NSMutableArray *matchingSubviews = [NSMutableArray array];

	if (validator(view, criterion)) {
		[matchingSubviews addObject:view];
	}

	for (UIView *eachSubview in view.subviews) {
		[matchingSubviews addObjectsFromArray:[cyc subviewsOfView:eachSubview withCriterion:criterion matchingCriterionValidator:validator]];
	}

	return [matchingSubviews copy];
}

+(UIViewController*)viewControllerForView:(UIView*)view {
	id nextResponder = [view nextResponder];
	if ([nextResponder isKindOfClass:[UIViewController class]]) {
		return nextResponder;
	} else if ([nextResponder isKindOfClass:[UIView class]]) {
		return [cyc viewControllerForView:nextResponder];
	} else {
		return nil;
	}
}

+(id)ivarNamed:(NSString*)varName withinObject:(id)object {
	return MSHookIvar<id>(object, [varName UTF8String]);
}

+(id)ivarNamed:(NSString*)varName withinObject:(id)object dataType:(NSString*)dataType {
	if(NSClassFromString(dataType) != nil)	return MSHookIvar<id>(object, [varName UTF8String]);
	if([dataType isEqualToString:@"BOOL"])	return [NSNumber numberWithBool:MSHookIvar<BOOL>(object, [varName UTF8String])];
	if([dataType isEqualToString:@"int"])	return [NSNumber numberWithInt:MSHookIvar<int>(object, [varName UTF8String])];
	if([dataType isEqualToString:@"double"])	return [NSNumber numberWithDouble:MSHookIvar<double>(object, [varName UTF8String])];
	if([dataType isEqualToString:@"float"])	return [NSNumber numberWithFloat:MSHookIvar<float>(object, [varName UTF8String])];
	if([dataType isEqualToString:@"char"])	return [NSNumber numberWithChar:MSHookIvar<char>(object, [varName UTF8String])];
	if([dataType isEqualToString:@"unsigned char"])	return [NSNumber numberWithUnsignedChar:MSHookIvar<unsigned char>(object, [varName UTF8String])];
	return NULL;
}

+(id)snagNextTouch {
	snagBlock = !snagBlock;
	snagNext = !snagNext;
	return @"next touch will be eaten; access view that was tapped with [cyc snaggedView]";
}

+(UIView*)snaggedView {
	return snaggedView;
}

+(UIViewController*)snaggedViewController {
	return [cyc viewControllerForView:snaggedView];
}

+(id)viewToFlash:(UIView*)view {
	UIView* flash = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
	flash.backgroundColor = [UIColor yellowColor];
	flash.alpha = 0.0;
	[view addSubview:flash];
	[UIView animateWithDuration:0.3 delay: 0.0 options: UIViewAnimationOptionCurveEaseOut animations:^{
		 flash.alpha = 1.0;
	} completion:^(BOOL finished){
		[UIView animateWithDuration:0.3 delay: 0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
			flash.alpha = 0.0;
		} completion:^(BOOL finished){
			[UIView animateWithDuration:0.3 delay: 0.0 options: UIViewAnimationOptionCurveEaseOut animations:^{
				 flash.alpha = 1.0;
			} completion:^(BOOL finished){
				[UIView animateWithDuration:0.3 delay: 0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
					flash.alpha = 0.0;
				} completion:^(BOOL finished){
					[UIView animateWithDuration:0.3 delay: 0.0 options: UIViewAnimationOptionCurveEaseOut animations:^{
						 flash.alpha = 1.0;
					} completion:^(BOOL finished){
						[UIView animateWithDuration:0.3 delay: 0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
							flash.alpha = 0.0;
						} completion:^(BOOL finished){
							[flash removeFromSuperview];
						}];
					}];
				}];
			}];
		}];
	}];
	return [NSString stringWithFormat:@"[cyc] flashing %@ at ((%f,%f),(%f,%f))", NSStringFromClass([view class]), view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height];
}

+(id)flashSnaggedView
{
	if(snaggedView != nil)
		return [cyc viewToFlash:snaggedView];
	else
		return @"No snagged view";
}

+(id)blurrySnapshot {
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	UIGraphicsBeginImageContextWithOptions(keyWindow.bounds.size, NO, keyWindow.screen.scale);
	[keyWindow drawViewHierarchyInRect:keyWindow.frame afterScreenUpdates:NO];
	UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
	UIImage *blurredSnapshotImage = [snapshotImage applyLightEffect];
	UIGraphicsEndImageContext();
	
	return blurredSnapshotImage;
}

+(id)respring {
	[cyc postLog:@"Respringing..."];
	double delayInSeconds = 0.5;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[(SpringBoard *)[UIApplication sharedApplication] relaunchSpringBoard];
	});
	return @"respringing. you'll have to relaunch cycript";
}

static cyc *dumbInstance = [[cyc alloc] init];

+(id)postLog:(NSString *)log {
	[cyc cancelPreviousPerformRequestsWithTarget:dumbInstance];
	[cyc showLog];
	logLabel.text = log;
	logLabel.textAlignment = NSTextAlignmentCenter;
	[dumbInstance performSelector:@selector(hideLog) withObject:nil afterDelay:5];
	return log;
}

+(id)showLog {
	if (logWindow == nil) {
		logWindow = [[UIWindow alloc] initWithFrame:[[UIApplication sharedApplication] keyWindow].frame];
		logWindow.backgroundColor = [UIColor clearColor];
		logWindow.windowLevel = 27000;
		logWindow.hidden = NO;
		logWindow.userInteractionEnabled = NO;
		
		CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
		CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
		logContainer = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight, screenWidth, LOG_PANEL_HEIGHT)];
		logContainer.userInteractionEnabled = NO;
		
		logBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, LOG_PANEL_HEIGHT)];
		logBackground.backgroundColor = [UIColor blackColor];
		logBackground.alpha = 0.7;
		logBackground.userInteractionEnabled = NO;
		
		logLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, screenWidth - 10, LOG_PANEL_HEIGHT - 10)];
		logLabel.textColor = [UIColor whiteColor];
		logLabel.numberOfLines = 0;
		logLabel.font = [UIFont systemFontOfSize:14];
		logLabel.textAlignment = NSTextAlignmentCenter;
		logLabel.userInteractionEnabled = NO;
		
		[logContainer addSubview:logBackground];
		[logContainer addSubview:logLabel];
		[logWindow addSubview:logContainer];
	}
	[UIView animateWithDuration:0.3 animations:^{
		logContainer.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - LOG_PANEL_HEIGHT, [UIScreen mainScreen].bounds.size.width, LOG_PANEL_HEIGHT);
	}];
	
	return @"showing log panel";
}

-(id)hideLog {
	[UIView animateWithDuration:0.3 animations:^{
		logContainer.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, LOG_PANEL_HEIGHT);
	}];
	
	return @"showing log panel";
}

+(id)logPanel {
	return logContainer;
}

+(id)hooked {
	return @"not hooked";
}

@end

%hook cyc
+(id)hooked {
	return @"hooked";
}
%end

@interface SBApplication
-(id)displayName;
@end

%hook SBApplication
-(void)willActivate {
	NSString *log = [NSString stringWithFormat:@"SBApplication -(void)willActivate\n[self displayName] = \"%@\"", [self displayName]];
	[cyc postLog:log];
	%orig;
}

-(void)didSuspend {
	NSString *log = [NSString stringWithFormat:@"SBApplication -(void)didSuspend\n\n[self displayName] = \"%@\"", [self displayName]];
	[cyc postLog:log];
	%orig;
}

-(void)didExitWithInfo:(id)info type:(int)type {
	NSString *log = [NSString stringWithFormat:@"SBApplication -(void)didExitWithInfo:%@ type:%i\n\n[self displayName] = \"%@\"", info, type, [self displayName]];
	[cyc postLog:log];
	%orig;
}

-(void)didLaunch:(id)launch {
	NSString *log = [NSString stringWithFormat:@"SBApplication -(void)didLaunch\n\n[self displayName] = \"%@\"", [self displayName]];
	[cyc postLog:log];
	%orig;
}

-(void)didBeginLaunch:(id)launch {
	NSString *log = [NSString stringWithFormat:@"SBApplication -(void)didBeginLaunch\n\n[self displayName] = \"%@\"", [self displayName]];
	[cyc postLog:log];
	%orig;
}
%end

%hook UITouch
-(void)setView:(id)view
{
	if(!snagBlock)
		%orig;
	if(snagBlock || snagNext)
	{
		snagNext = NO;
		snagBlock = NO;
		if(view != nil)
		{
			snaggedView = view;
		}
	}
}
%end

