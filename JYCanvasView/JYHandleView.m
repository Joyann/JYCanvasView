//
//  JYHandleView.m
//  JYCanvasView
//
//  Created by joyann on 15/10/27.
//  Copyright © 2015年 Joyann. All rights reserved.
//

#import "JYHandleView.h"

@interface JYHandleView () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, weak) UIImageView *imageView;
@end

@implementation JYHandleView

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    [self addImageViewWithImage:image];
}

#pragma mark - Add Image View

- (void)addImageViewWithImage: (UIImage *)image
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.image = image;
    imageView.userInteractionEnabled = YES;
    [self addSubview:imageView];
    self.imageView = imageView;
    // 给imageView添加手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [imageView addGestureRecognizer:pan];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    [imageView addGestureRecognizer:pinch];
    
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    rotation.delegate = self;
    [imageView addGestureRecognizer:rotation];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.delegate = self;
    [imageView addGestureRecognizer:longPress];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Handle Long Press

- (void)handleLongPress: (UILongPressGestureRecognizer *)longPress
{
    
    [UIView animateWithDuration:0.5 animations:^{
        self.imageView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.imageView.alpha = 1.0;
        } completion:^(BOOL finished) {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            [self.layer renderInContext:context];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            if ([self.delegate respondsToSelector:@selector(handleView:didFinishedWithImage:)]) {
                [self.delegate handleView:self didFinishedWithImage: image];
            }
            
            [self removeFromSuperview];
        }];
    }];
}

#pragma mark - Handle Pan

- (void)handlePan: (UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:self.imageView];
    self.imageView.transform = CGAffineTransformTranslate(pan.view.transform, point.x, point.y);
    [pan setTranslation:CGPointZero inView:self.imageView];
}

#pragma mark - Handle Pinch

- (void)handlePinch: (UIPinchGestureRecognizer *)pinch
{
    CGFloat scale = pinch.scale;
    self.imageView.transform = CGAffineTransformScale(pinch.view.transform, scale, scale);
    [pinch setScale:1.0];
}

#pragma mark - Handle Rotation

- (void)handleRotation: (UIRotationGestureRecognizer *)rotation
{
    CGFloat angle = rotation.rotation;
    self.imageView.transform = CGAffineTransformRotate(rotation.view.transform, angle);
    [rotation setRotation:0.0];
}



@end
