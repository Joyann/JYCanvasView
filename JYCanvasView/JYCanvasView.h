//
//  JYCanvasView.h
//  JYCanvasView
//
//  Created by joyann on 15/10/26.
//  Copyright © 2015年 Joyann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JYCanvasView : UIView

@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, strong) UIColor *strokeColor;

@property (nonatomic, strong) UIImage *image;

- (void)clearScreen;
- (void)undo;

@end
