//
//  Sidebar.m
//  GitHub
//
//  Created by Евгений Богомолов on 05.11.14.
//  Copyright (c) 2014 Евгений Богомолов. All rights reserved.
//

#import "Sidebar.h"

@implementation Sidebar

@synthesize width = _width;
@synthesize animationDuration = _animationDuration;
@synthesize contentUsers;

- (instancetype)init
{
    if (self = [super init]) {
        _width = 150;
        _animationDuration = 0.25f;
        contentUsers = [NSMutableArray array];
//        _tintColor = [UIColor colorWithWhite:0.2 alpha:0.73];
//        _itemBackgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.25];
        
//        [_images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
//            RNCalloutItemView *view = [[RNCalloutItemView alloc] init];
//            view.itemIndex = idx;
//            view.clipsToBounds = YES;
//            view.imageView.image = image;
//            [_contentView addSubview:view];
//            
//            [_itemViews addObject:view];
//            
//            if (_borderColors && _selectedIndices && [_selectedIndices containsIndex:idx]) {
//                UIColor *color = _borderColors[idx];
//                view.layer.borderColor = color.CGColor;
//            }
//            else {
//                view.layer.borderColor = [UIColor clearColor].CGColor;
//            }
//        }];
    }
    return self;

}


- (void)showAnimated:(BOOL)animated {
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (controller.presentedViewController != nil) {
        controller = controller.presentedViewController;
    }
    [self showInViewController:controller animated:animated];
}

- (void)show {
    [self showAnimated:YES];
}


- (void)showInViewController:(UIViewController *)controller animated:(BOOL)animated {
//    if (rn_frostedMenu != nil) {
//        [rn_frostedMenu dismissAnimated:NO];
//    }
    
//    if ([self.delegate respondsToSelector:@selector(sidebar:willShowOnScreenAnimated:)]) {
//        [self.delegate sidebar:self willShowOnScreenAnimated:animated];
//    }
    
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImageJPEGRepresentation(image, 0.75);
    image = [UIImage imageWithData:imageData];
    
    UIImage *blurImage = image;
//    blurImage = [blurImage applyBlurWithRadius:5 tintColor:self.view.tintColor saturationDeltaFactor:1.8 maskImage:nil];
    
//    [self rn_addToParentViewController:controller callingAppearanceMethods:YES];
    self.view.frame = controller.view.bounds;
    
    CGFloat parentWidth = self.view.bounds.size.width;
    
    CGRect contentFrame = self.view.bounds;
//    contentFrame.origin.x = _showFromRight ? parentWidth : -_width;
    contentFrame.size.width = _width;
    self.view.frame = contentFrame;
    
//    [self layoutItems];
    
    CGRect blurFrame = CGRectMake(0, 0, 0, self.view.bounds.size.height);
    
    self.blurView = [[UIImageView alloc] initWithImage:blurImage];
    self.blurView.frame = blurFrame;
    self.blurView.contentMode = UIViewContentModeTopRight;
    self.blurView.clipsToBounds = YES;
    [self.view insertSubview:self.blurView belowSubview:self.view];
    
    contentFrame.origin.x = parentWidth - _width;
    blurFrame.origin.x = contentFrame.origin.x;
    blurFrame.size.width = _width;
    
    void (^animations)() = ^{
        self.view.frame = contentFrame;
        self.blurView.frame = blurFrame;
    };
    void (^completion)(BOOL) = ^(BOOL finished) {
//        if (finished && [self.delegate respondsToSelector:@selector(sidebar:didShowOnScreenAnimated:)]) {
//            [self.delegate sidebar:self didShowOnScreenAnimated:animated];
//        }
    };
    
    if (animated) {
        [UIView animateWithDuration:self.animationDuration
                              delay:0
                            options:kNilOptions
                         animations:animations
                         completion:completion];
    }
    else{
        animations();
        completion(YES);
    }
    
    CGFloat initDelay = 0.1f;
    SEL sdkSpringSelector = NSSelectorFromString(@"animateWithDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:");
    BOOL sdkHasSpringAnimation = [UIView respondsToSelector:sdkSpringSelector];
    
//    [self.itemViews enumerateObjectsUsingBlock:^(RNCalloutItemView *view, NSUInteger idx, BOOL *stop) {
//        view.layer.transform = CATransform3DMakeScale(0.3, 0.3, 1);
//        view.alpha = 0;
//        view.originalBackgroundColor = self.itemBackgroundColor;
//        view.layer.borderWidth = self.borderWidth;
//        
//        if (sdkHasSpringAnimation) {
//            [self animateSpringWithView:view idx:idx initDelay:initDelay];
//        }
//        else {
//            [self animateFauxBounceWithView:view idx:idx initDelay:initDelay];
//        }
//    }];
}
@end
