//
//  WebImgScrollView.m
//  smarter.LoveLog
//
//  Created by 樊康鹏 on 16/1/21.
//  Copyright © 2016年 FanKing. All rights reserved.
//

#import "WebImgScrollView.h"
#import "SDWebImageManager.h"
#import "WebImageZoomScrollView.h"
#import "MBProgressHUD.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define kScreenHeight [[UIScreen mainScreen] bounds].size.height //主屏幕的高度
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width  //主屏幕的宽度
#define kScreenBounds [UIScreen mainScreen].bounds               //主屏幕bounds


@interface WebImgScrollView  ()

@end

@implementation WebImgScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
      
        [self initSubViews];
    }
    return self;
}

+ (WebImgScrollView *)showImageWithImageArr:(NSArray *)urlArr{
    
    WebImgScrollView *imgSV = [[self alloc] initWithFrame:kScreenBounds];
    
    [[UIApplication sharedApplication].keyWindow addSubview:imgSV];
    
    imgSV.imgUrl = [urlArr lastObject];
    
    NSMutableArray * arr =[NSMutableArray array];
    for (int i =0; i <urlArr.count-1; i++) {
        [arr addObject:urlArr[i]];
    }
    
    imgSV.imgUrlArr = arr;
    
    return imgSV;
}

+ (WebImgScrollView *)showImageWithImageArr:(NSArray *)urlArr index:(NSInteger)index{
    
    WebImgScrollView *imgSV = [[self alloc] initWithFrame:kScreenBounds];
    [[UIApplication sharedApplication].keyWindow addSubview:imgSV];
    imgSV.imgUrl = urlArr[index];
    imgSV.imgUrlArr = urlArr;
    
    return imgSV;
}


#pragma mark - private method
- (void)initSubViews{
    self.backgroundColor = [UIColor blackColor];
    [self addSubview:self.downLoadBtn];
    [self addSubview:self.countLabel];
    

  
}

- (void)downLoadImg{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [self showHUD:@"未获得相册权限"];
      
    }else {
        
    }
    NSInteger index = _scrollView.contentOffset.x/kScreenWidth;
    NSString *imageURL = _imgUrlArr[index];
    NSURL *url = [NSURL URLWithString:imageURL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        [self showHUD:@"已保存"];
    }];
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
   
}

- (void)showHUD:(NSString *)text {    
    MBProgressHUD *textHUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    textHUD.mode = MBProgressHUDModeText;
    textHUD.label.text = text;
    textHUD.label.textColor = [UIColor whiteColor];
    textHUD.margin = 10;
    textHUD.userInteractionEnabled = NO;
    textHUD.bezelView.color = [UIColor blackColor];
    [textHUD showAnimated:YES];
    [textHUD hideAnimated:YES afterDelay:1];
    
}

//停止滚动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int page = (int)scrollView.contentOffset.x/kScreenWidth;
    _countLabel.text =[NSString stringWithFormat:@"%d/%lu",page+1,(unsigned long)_imgUrlArr.count];
    
//    SDWebImageManager *manager = [SDWebImageManager sharedManager];
//    
//    [manager downloadImageWithURL:[NSURL URLWithString:self.imgUrlArr[page]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//        
//    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//        self.image = image;
//        
//    }];
}
#pragma mark - setter and getter
-(void)setImgUrl:(NSString *)imgUrl
{
    _imgUrl = imgUrl;
}
- (void)setImgUrlArr:(NSArray *)imgUrlArr
{
    _imgUrlArr = imgUrlArr;
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.scrollView];
   
    
    self.scrollView.contentSize =  CGSizeMake(kScreenWidth * imgUrlArr.count,  kScreenHeight - 40);
    for (int  i  = 0; i < imgUrlArr.count; i++) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * i;
        frame.origin.y = 0;
        
        WebImageZoomScrollView * imageScrollView = [[WebImageZoomScrollView alloc] initWithFrame:frame];
        imageScrollView.imgUrl= imgUrlArr[i];
        imageScrollView.RemoveView = ^{
            [self.scrollView removeFromSuperview];
            [self removeFromSuperview];
        };
                
        [self.scrollView addSubview:imageScrollView];
    }
    if (_imgUrl) {
        NSUInteger index = [_imgUrlArr indexOfObject:_imgUrl];
        [self.scrollView setContentOffset:CGPointMake(kScreenWidth* index, 0)];
        _countLabel.text =[NSString stringWithFormat:@"%lu/%lu",(unsigned long)index+1,(unsigned long)_imgUrlArr.count];
    }
    
  
    
}


- (UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate =self;
        _scrollView.pagingEnabled = YES;
        _scrollView.userInteractionEnabled = YES;
        _scrollView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 40);
    }
    return _scrollView;
}




- (UIButton *)downLoadBtn{
    if (_downLoadBtn == nil) {
        _downLoadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downLoadBtn addTarget:self action:@selector(downLoadImg) forControlEvents:UIControlEventTouchUpInside];
        [_downLoadBtn setImage:[UIImage imageNamed:@"News_Picture_Save"] forState:UIControlStateNormal];
        _downLoadBtn.frame = CGRectMake(kScreenWidth-50, kScreenHeight-40, 40, 40);
        [_downLoadBtn sizeToFit];
    }
    return _downLoadBtn;
}
-(UILabel *)countLabel
{
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, kScreenHeight-40, 60, 30)];
        _countLabel . textColor = [UIColor whiteColor];
        _countLabel.font = [UIFont systemFontOfSize:15];
        
    }
    return _countLabel;
}

@end
