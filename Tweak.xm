#import "substrate.h"

static BOOL snagNext = NO;
static BOOL snagBlock = NO;
static BOOL snagAll = NO;
static BOOL logOnSnag = YES;
static UIView* snaggedView = nil;

static void log(NSString* string)
{
	printf("%s", [string UTF8String]);
}

static void logln(NSString* string)
{
	log([NSString stringWithFormat:@"%@\n", string]);
}

static NSString* viewSettings()
{
	return [NSString stringWithFormat:@"[cyc]   snag next touch (snext) = %@;   snag and block touch (sblock) = %@;   snag all touches (sall) = %@;   log to console on snag (slogging) = %@;", (snagNext?@"YES":@"NO"), (snagBlock?@"YES":@"NO"), (snagAll?@"YES":@"NO"), (logOnSnag?@"YES":@"NO")];
}

typedef BOOL(^CYCViewSearchCriterionValidator)(UIView *view, NSObject *criterion);

@interface SpringBoard
-(void)relaunchSpringBoard;
@end

@interface cyc : NSObject
+(NSArray *)subviewsOfView:(UIView *)view exactClassName:(NSString *)className;
+(NSArray *)subviewsOfView:(UIView *)view withCriterion:(NSObject *)criterion matchingCriterionValidator:(CYCViewSearchCriterionValidator)validator;
+(UIViewController*)viewControllerForView:(UIView*)view;
+(id)ivarNamed:(NSString*)varName withinObject:(id)object;
+(id)ivarNamed:(NSString*)varName withinObject:(id)object dataType:(NSString*)typeName;
+(id)displayPreferences;
+(id)snagNextTouch;
+(id)snagAndBlockTouch;
+(id)snagAllTouches;
+(id)logOnSnag;
+(UIView*)snaggedView;
+(UIViewController*)snaggedViewController;
+(id)printSnagLog;
+(id)viewToFlash:(UIView*)view;
+(id)flashSnaggedView;
+(id)respring;
@end

@interface cyc (Shorthand)
+(UIViewController*)vcforv:(UIView*)view;
+(id)ivar:(NSString*)varName obj:(id)object;
+(id)ivar:(NSString*)varName obj:(id)object type:(NSString*)typeName;
+(id)prefs;
+(id)snext;
+(id)sblock;
+(id)sall;
+(id)slogging;
+(UIView*)v;
+(UIViewController*)vc;
+(id)vlog;
+(id)vtoflash:(UIView*)view;
+(id)vflash;
@end

@implementation cyc

/*+(NSArray *)subviewsOfView:(UIView *)view withClassName:(NSString *)className {
	NSMutableArray *matchingSubviews = [NSMutableArray array];
	
	if ([NSStringFromClass([view class]) isEqualToString:className]) {
		[matchingSubviews addObject:view];
	}
	
	for (UIView *eachSubview in view.subviews) {
		[matchingSubviews addObjectsFromArray:[cyc subviewsOfView:eachSubview withClassName:className]];
	}
	
	return [matchingSubviews copy];
}*/

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

+(UIViewController*)viewControllerForView:(UIView*)view
{
	id nextResponder = [view nextResponder];
	if ([nextResponder isKindOfClass:[UIViewController class]]) {
		return nextResponder;
	} else if ([nextResponder isKindOfClass:[UIView class]]) {
		return [cyc viewControllerForView:nextResponder];
	} else {
		return nil;
	}
}

+(id)ivarNamed:(NSString*)varName withinObject:(id)object
{
	return MSHookIvar<id>(object, [varName UTF8String]);
}
+(id)ivarNamed:(NSString*)varName withinObject:(id)object dataType:(NSString*)dataType
{
	if(NSClassFromString(dataType) != nil)	return MSHookIvar<id>(object, [varName UTF8String]);
	if([dataType isEqualToString:@"BOOL"])	return [NSNumber numberWithBool:MSHookIvar<BOOL>(object, [varName UTF8String])];
	if([dataType isEqualToString:@"int"])	return [NSNumber numberWithInt:MSHookIvar<int>(object, [varName UTF8String])];
	if([dataType isEqualToString:@"double"])	return [NSNumber numberWithDouble:MSHookIvar<double>(object, [varName UTF8String])];
	if([dataType isEqualToString:@"float"])	return [NSNumber numberWithFloat:MSHookIvar<float>(object, [varName UTF8String])];
	if([dataType isEqualToString:@"char"])	return [NSNumber numberWithChar:MSHookIvar<char>(object, [varName UTF8String])];
	if([dataType isEqualToString:@"unsigned char"])	return [NSNumber numberWithUnsignedChar:MSHookIvar<unsigned char>(object, [varName UTF8String])];
	return NULL;
}

+(id)displayPreferences
{
	return viewSettings();
}

+(id)snagNextTouch
{
	snagNext = !snagNext;
	return viewSettings();
}

+(id)snagAndBlockTouch
{
	snagBlock = !snagBlock;
	return viewSettings();
}

+(id)snagAllTouches
{
	snagAll = !snagAll;
	return viewSettings();
}

+(id)logOnSnag
{
	logOnSnag = !logOnSnag;
	return viewSettings();
}
+(UIView*)snaggedView
{
	return snaggedView;
}
+(UIViewController*)snaggedViewController
{
	return [cyc viewControllerForView:snaggedView];
}
+(id)printSnagLog
{
	logln(@"\n\n\t[cyc] Snag Log");
	if(snaggedView != nil)
	{
		log(@"\tSnagged view controller:\t");
		UIViewController* vc = [cyc snaggedViewController];
		if(vc != nil)
		{
			logln(NSStringFromClass([vc class]));
		}
		else
			logln(@"(nil)");
		log(@"\tSnagged view:\t\t\t");
		logln(NSStringFromClass([snaggedView class]));
		log(@"\tSnagged view's parent:\t\t");
		if([snaggedView superview] != nil)
			logln(NSStringFromClass([snaggedView class]));
		else
			logln(@"(nil)");
		
		log(@"\tSnagged view's children:\t\t");
		if([snaggedView subviews] > 0)
		{
			
			for(UIView* eachView in [snaggedView subviews])
			{
				log(NSStringFromClass([eachView class]));
				log(@" ");
			}
		}
		else
			logln(@"(nil)");
		
		logln(@"\n\n");
	}
	else
	{
		log(@"\tNo views have been snagged. Run cyc.snext and tap something!");
	}
	return @"[cyc] logged to console";
}
+(id)viewToFlash:(UIView*)view
{
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

+(id)respring {
	[(SpringBoard *)[UIApplication sharedApplication] relaunchSpringBoard];
	return @"respringing. you'll have to relaunch cycript";
}

@end

@implementation cyc (Shorthand)
//+(NSArray*)vsearch:(NSString*)className {return [cyc viewsWithClassName:className];}
+(UIViewController*)vcforv:(UIView*)view {return [cyc viewControllerForView:view];}
+(id)ivar:(NSString*)varName obj:(id)object {return [cyc ivarNamed:varName withinObject:object];}
+(id)ivar:(NSString*)varName obj:(id)object type:(NSString*)typeName {return [cyc ivarNamed:varName withinObject:object dataType:typeName];}
+(id)prefs {return [cyc displayPreferences];}
+(id)snext {return [cyc snagNextTouch];}
+(id)sblock {return [cyc snagAndBlockTouch];}
+(id)sall {return [cyc snagAllTouches];}
+(id)slogging {return [cyc logOnSnag];}
+(UIView*)v {return [cyc snaggedView];}
+(UIViewController*)vc {return [cyc snaggedViewController];}
+(id)vlog {return [cyc printSnagLog];}
+(id)vtoflash:(UIView*)view {return [cyc viewToFlash:view];}
+(id)vflash {return [cyc flashSnaggedView];}
@end

%hook UITouch
-(void)setView:(id)view
{
	if(!snagBlock)
		%orig;
	if(snagBlock || snagNext || snagAll)
	{
		snagNext = NO;
		snagBlock = NO;
		if(view != nil)
		{
			snaggedView = view;
			if(logOnSnag)
			{
				[cyc printSnagLog];
			}
		}
	}
}
%end