//
//  CCPShowPhotoVC.m
//  CCPCustomCamera
//
//  Created by CCP on 2016/11/15.
//  Copyright © 2016年 CCP. All rights reserved.
//

#import "CCPShowPhotoVC.h"
//间距
#define CCP_Margin 0.5
//每排显示的个数
#define CCP_count 3
//屏幕宽度
#define CCPScreenW  [UIScreen mainScreen].bounds.size.width

@interface CCPShowPhotoVC ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *showCollectionView;

@end

@implementation CCPShowPhotoVC

- (UICollectionView *)showCollectionView {
    
    if (_showCollectionView==nil) {
        
        // 流水布局
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = CCP_Margin;
        flowLayout.minimumInteritemSpacing = CCP_Margin;
        flowLayout.itemSize = CGSizeMake((CCPScreenW - (CCP_count -1) * CCP_Margin) / 3,(CCPScreenW - (CCP_count -1) * CCP_Margin) / 3);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
       _showCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,44, self.view.frame.size.width, self.view.frame.size.height - 44) collectionViewLayout:flowLayout];
    }
    
    return _showCollectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeUI];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 0;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
    
}



#pragma mark -UI布局
- (void) makeUI {
    self.view.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.showCollectionView];
    self.showCollectionView.delegate = self;
    self.showCollectionView.dataSource = self;
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    headView.backgroundColor = [UIColor blackColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15, 0, 50, 44)];
    [button setTitle:@"关闭" forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(clickTheBtn) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:button];
    [self.view addSubview:headView];
}

- (void) clickTheBtn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
