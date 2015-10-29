//
//  JYCanvasView.m
//  JYCanvasView
//
//  Created by joyann on 15/10/26.
//  Copyright © 2015年 Joyann. All rights reserved.
//

#import "JYCanvasView.h"
#import "JYBezierPath.h"

@interface JYCanvasView ()
@property (nonatomic, strong) JYBezierPath *linePath;
@property (nonatomic, strong) NSMutableArray *paths;
@end

@implementation JYCanvasView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setUp];
    [self addGesture];
}

#pragma mark - Set up

- (void)setUp
{
    self.strokeWidth = 1.0;
    self.strokeColor = [UIColor blackColor];
}

#pragma mark - Setter Methods

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    [self.paths addObject:image];
    [self setNeedsDisplay];
}

#pragma mark - Getter Methods

- (NSMutableArray *)paths
{
    if (!_paths) {
        _paths = [NSMutableArray array];
    }
    return _paths;
}

#pragma mark - Add Gesture

- (void)addGesture
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:pan];
}

#pragma mark - Handle Pan

/*
 在画线的时候如果每次began都创建一条路径，那么只能保证当前画板只有一条线；
 想要画上多条线有两种做法：
 1. 第一种方法是在awakeFromNib或者其他合适的方法中就将self.linePath初始化，这样就保证当前只有一个路径，而不是每次began的时候都新建一个路径。一个路径是可以画多条线的，前提是每次都需要重新设置起始点，即moveToPoint:，而我们此时的做法是符合的，只创建一个路径，在每次began的时候给这个路径设置新的起始点就可以画多条线。
 2. 第二种方法是每次began都创建一个新路径，并设置初始点，并且将其放到一个数组中保证它不会销毁。每次重绘的时候先将数组中的路径取出来绘制然后绘制新的线，这样也能保证有多条线。
    在这里因为要有撤销操作，所以采用第二种做法.
 */

- (void)handlePan: (UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan locationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.linePath = [JYBezierPath bezierPath];
        self.linePath.color = self.strokeColor;
        self.linePath.lineWidth = self.strokeWidth;
        [self.paths addObject:self.linePath];
        [self.linePath moveToPoint:point];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [self.linePath addLineToPoint:point];
        [self setNeedsDisplay];
    }
}


#pragma mark - Draw Rect

/*
 在设置线的颜色的时候要注意：
    每次从VC传进来的color并不能在handlePan:中像设置线宽一样直接设置，因为color只能在上下文中设置，也就是只能在drawRect:方法中设置，但是如果在drawRect方法中绘制，那么每次重绘之前的线的时候都会被设置成当前的颜色。
    所以要做的就是在drawRect:中区分不同的线对应的不同的颜色。这里采用的是自定义一个UIBezierPath类，并且声明一个color属性。当VC中颜色改变就会给JYCanvasView的strokeColor赋值，每次began的时候将strokeColor赋值给自定义linePath的color属性来保存不同的线对应的颜色，然后在上下文中取出linePath的color属性来设置绘制颜色，这样就可以达到目的。
    当不同的对象对应不同的属性,而Apple提供的类又没有提供这个属性，要考虑是否需要自定义这个类，在自定义类中声明一个对应的属性以达到不同的对象保留不同属性的目的。
 */

- (void)drawRect:(CGRect)rect
{
    if (self.paths.count) {
        for (id path in self.paths) {
            if ([path isKindOfClass:[UIImage class]]) {
                UIImage *image = (UIImage *)path;
                [image drawInRect:rect];
            } else {
                [[path color] setStroke];
                [path stroke];
            }
        }
    }
}

#pragma mark - Clear Screen

- (void)clearScreen
{
    [self.paths removeAllObjects];
    [self setNeedsDisplay];
}

#pragma mark - Undo

- (void)undo
{
    [self.paths removeLastObject];
    [self setNeedsDisplay];
}



@end
