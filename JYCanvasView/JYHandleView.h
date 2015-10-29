//
//  JYHandleView.h
//  JYCanvasView
//
//  Created by joyann on 15/10/27.
//  Copyright © 2015年 Joyann. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JYHandleView;
@protocol JYHandleViewDelegate <NSObject>

- (void)handleView: (JYHandleView *)handleView didFinishedWithImage: (UIImage *)image;

@end

@interface JYHandleView : UIView
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) id<JYHandleViewDelegate> delegate;
@end
