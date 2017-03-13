//
//  CCPShowPhotoVC.m
//  CCPCustomCamera
//
//  Created by CCP on 2016/11/15.
//  Copyright © 2016年 CCP. All rights reserved.
//

#import "CCPShowPhotoVC.h"
#import "CCPShowPhotoCollectionViewCell.h"
#import "UIView+XLExtension.h"
#import "XLPhotoBrowser.h"
#import "CCPPhotoAlbumViewController.h"
//间距
#define CCP_Margin 3.0f
//每排显示的个数
#define CCP_count 3
//屏幕宽度
#define CCPScreenW  [UIScreen mainScreen].bounds.size.width

@interface CCPShowPhotoVC ()<UICollectionViewDelegate,UICollectionViewDataSource,XLPhotoBrowserDelegate, XLPhotoBrowserDatasource>

@property (nonatomic,strong) UICollectionView *showCollectionView;
//选中的图片数组
@property (nonatomic,strong) NSMutableArray *selectedImageArray;
//占位数组
@property (nonatomic,strong) NSMutableArray *dataImageArray;
//预览按钮
@property (nonatomic,weak) UIButton *previewBtn;
@end

@implementation CCPShowPhotoVC

- (UICollectionView *)showCollectionView {
    if (_showCollectionView==nil) {
        // 流水布局
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = CCP_Margin;
        flowLayout.minimumInteritemSpacing = CCP_Margin;
        CGFloat w = (CCPScreenW - (CCP_count -1) * CCP_Margin) / CCP_count;
        flowLayout.itemSize = CGSizeMake(w,w);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _showCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,55, self.view.frame.size.width, self.view.frame.size.height - 55) collectionViewLayout:flowLayout];
        _showCollectionView.backgroundColor = [UIColor whiteColor];
        [_showCollectionView registerClass:[CCPShowPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"CollectionCell"];
    }
    return _showCollectionView;
}

- (NSMutableArray *)dataImageArray {
    if (_dataImageArray == nil) {
        _dataImageArray = [NSMutableArray array];
        if (self.isIOS8) {
            for (int i = 0; i < self.imageArray.count; i ++) {
                [_dataImageArray addObject:@""];
            }
        } else {
            for (int i = 0; i < self.fetchResult.count; i ++) {
                [_dataImageArray addObject:@""];
            }
        }
    }
    return _dataImageArray;
}
- (NSMutableArray *)selectedImageArray {
    if (_selectedImageArray == nil) {
        _selectedImageArray = [NSMutableArray array];
    }
    return _selectedImageArray;
}

- (void)setImageArray:(NSMutableArray *)imageArray {
    _imageArray = imageArray;
}
- (void)setFetchResult:(PHFetchResult *)fetchResult {
    _fetchResult = fetchResult;
    __weak typeof(self) weakSelf = self;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // resizeMode 与 deliveryMode 参数介绍:
    // http://kayosite.com/ios-development-and-detail-of-photo-framework-part-two.html
    options.resizeMode = PHImageRequestOptionsResizeModeNone;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    for (int i = 0; i < fetchResult.count; i ++) {
        PHAsset * asset = weakSelf.fetchResult[i];
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(125, 125) contentMode:PHImageContentModeDefault options:options  resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
         {
             //将获取到的图片放入数组
             [weakSelf.imageArray addObject:result];
             //主线程中更新UI
             dispatch_async(dispatch_get_main_queue(), ^{
                 [weakSelf.showCollectionView reloadData];
             });
         }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    [self makeUI];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    CCPShowPhotoCollectionViewCell * collectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
            /*
            也可以选择这样为cell赋值,设置options 为 nil 即可显示相对清晰的图片
            PHAsset * asset = self.fetchResult[indexPath.row];
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(125, 125) contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
             {
                 collectionCell.showImage = result;
             }];
            */
    if (self.imageArray.count > 0) {
        
        collectionCell.showImage = weakSelf.imageArray[indexPath.row];
        //解决cell重用问题
        NSString *stringTest = [NSString stringWithFormat:@"%@",self.dataImageArray[indexPath.row]];
        if ( stringTest.length > 0) {
            collectionCell.selectBtn.selected = YES;
            [ collectionCell.selectBtn setImage:[UIImage imageNamed:@"xuanzhong"] forState:UIControlStateNormal];
        } else {
            collectionCell.selectBtn.selected = NO;
            [ collectionCell.selectBtn setImage:[UIImage imageNamed:@"weiXuanZhong"] forState:UIControlStateNormal];
        }
        //按钮点击事件的处理
        collectionCell.selectedBtnBlock = ^(UIButton *btn) {
            CCPShowPhotoCollectionViewCell *buttonCell = (CCPShowPhotoCollectionViewCell *)[[btn superview] superview];
            NSUInteger row = [[weakSelf.showCollectionView indexPathForCell:buttonCell] row];
            [weakSelf.dataImageArray replaceObjectAtIndex:row withObject:weakSelf.imageArray[row]];
            [weakSelf.selectedImageArray removeAllObjects];
            for (id obj in weakSelf.dataImageArray) {
                if (![obj isEqual: @""]) {
                    UIImage *objImage = (UIImage *)obj;
                    [weakSelf.selectedImageArray addObject:objImage];
                }
                if (weakSelf.selectedImageArray.count == 0) {
                    weakSelf.previewBtn.enabled = NO;
                } else {
                    weakSelf.previewBtn.enabled = YES;
                }
            }
        };
        collectionCell.unselectedBtnBlock = ^(UIButton *btn) {
            CCPShowPhotoCollectionViewCell *buttonCell = (CCPShowPhotoCollectionViewCell *)[[btn superview] superview];
            NSUInteger row = [[weakSelf.showCollectionView indexPathForCell:buttonCell] row];
            [weakSelf.dataImageArray replaceObjectAtIndex:row withObject:@""];
            
            [weakSelf.selectedImageArray removeAllObjects];
            
            for (id obj in weakSelf.dataImageArray) {
                if (![obj isEqual: @""]) {
                    UIImage *objImage = (UIImage *)obj;
                    [weakSelf.selectedImageArray addObject:objImage];
                }
                if (weakSelf.selectedImageArray.count == 0) {
                    weakSelf.previewBtn.enabled = NO;
                } else {
                    weakSelf.previewBtn.enabled = YES;
                }
            }
        };
    }
        return collectionCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithImages:self.imageArray currentImageIndex:indexPath.row];
    browser.browserStyle = XLPhotoBrowserStylePageControl;
}

#pragma mark -UI布局
- (void) makeUI {
    [self.view addSubview:self.showCollectionView];
    NSMutableArray *imageArray = [NSMutableArray array];
    self.imageArray = imageArray;
    self.showCollectionView.delegate = self;
    self.showCollectionView.dataSource = self;
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 55)];
    headView.backgroundColor = [UIColor orangeColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15, 0, 60, 55)];
    [button setTitle:@"关闭" forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(clickTheBtn) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:button];
    UIButton *previewBtn = [[UIButton alloc] initWithFrame:CGRectMake(CCPScreenW - 65, 0, 60, 55)];
    [previewBtn setTitle:@"预览" forState:UIControlStateNormal];
    [previewBtn setTintColor:[UIColor whiteColor]];
    previewBtn.enabled = NO;
    [previewBtn addTarget:self action:@selector(clickThepreviewBtn) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:previewBtn];
    self.previewBtn = previewBtn;
    [self.view addSubview:headView];
}

- (void) clickThepreviewBtn {
    
    // 快速创建并进入浏览模式
    // [XLPhotoBrowser showPhotoBrowserWithImages:self.selectedImageArray currentImageIndex:self.selectedImageArray.count - 1];
    XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithImages:self.selectedImageArray currentImageIndex:0];
    browser.browserStyle = XLPhotoBrowserStyleIndexLabel;
    // 设置长按手势弹出的地步ActionSheet数据,不实现此方法则没有长按手势
    [browser setActionSheetWithTitle:nil delegate:self cancelButtonTitle:@"取消" deleteButtonTitle:nil otherButtonTitles:@"保存图片",nil];
    
}
//图片浏览器的代理方法
- (void)photoBrowser:(XLPhotoBrowser *)browser clickActionSheetIndex:(NSInteger)actionSheetindex currentImageIndex:(NSInteger)currentImageIndex
{
    switch (actionSheetindex) {
        case 0: // 保存
        {
            NSLog(@"点击了actionSheet索引是:%zd , 当前展示的图片索引是:%zd",actionSheetindex,currentImageIndex);
            [browser saveCurrentShowImage];
        }
            break;
        default:
        {
            NSLog(@"点击了actionSheet索引是:%zd , 当前展示的图片索引是:%zd",actionSheetindex,currentImageIndex);
        }
            break;
    }
}


#pragma mark -系统版本判断
- (BOOL) iOSIsbefore_iOS8 {
    return [[[UIDevice currentDevice] systemVersion] floatValue] <= 8.0 ?1:0;
}
- (void) clickTheBtn {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
