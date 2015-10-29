//
//  ViewController.m
//  JYCanvasView
//
//  Created by joyann on 15/10/26.
//  Copyright © 2015年 Joyann. All rights reserved.
//

#import "ViewController.h"
#import "JYCanvasView.h"
#import "JYHandleView.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, JYHandleViewDelegate>

@property (nonatomic, weak) JYCanvasView *canvasView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.canvasView = (JYCanvasView *)self.view;
}

#pragma mark - Actions

- (IBAction)clearScreen:(id)sender
{
    [self.canvasView clearScreen];
}

- (IBAction)undo:(id)sender
{
    [self.canvasView undo];
}

- (IBAction)eraser:(id)sender
{
    self.canvasView.strokeColor = [UIColor whiteColor];
}

- (IBAction)openPhotoLibrary:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}


- (IBAction)savePhoto:(id)sender
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(newImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSLog(@"保存完毕");
}


- (IBAction)sliderChanged:(UISlider *)slider
{
    self.canvasView.strokeWidth = slider.value * 10;
}

- (IBAction)changeColor:(UIButton *)button
{
    UIColor *color = button.backgroundColor;
    self.canvasView.strokeColor = color;
}

#pragma mark - UIImagePickerControllerDelegate

/*
 添加JYHandleView的原因：
    最开始的做法是在相册中选择图片，此时我们可以拿到一个image，将这个image添加到一个imageView上，对这个imageView进行形变，然后将image直接画到上下文中（通过drawInRect），但是当从上下文中获得新图片的时候，发现图片被拉伸到和上下文等大，也就是说image直接被绘制到上下文中，会铺满上下文，这样之前的形变效果就没有了。
    这里采用的做法是当从相册中拿到图片时创建一个自定义UIView类即JYHandleView,在handleView中创建一个UIImageView然后将image加进去，并且给这个UIImageView添加手势进行形变。当长按的时候将整个handleView渲染到上下文中，此时得到新的图片，imageView的形变状态就会被保留。
 */

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
//    [self addImageViewWithImage: image];
    [self addHandleViewWithImage:image];

    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Add Handle View

- (void)addHandleViewWithImage: (UIImage *)image
{
    JYHandleView *handleView = [[JYHandleView alloc] initWithFrame:self.view.bounds];
    handleView.image = image;
    handleView.delegate = self;
    [self.view addSubview:handleView];
}

#pragma mark - JYHandleViewDelegate

- (void)handleView:(JYHandleView *)handleView didFinishedWithImage:(UIImage *)image
{
    self.canvasView.image = image;
}

@end
