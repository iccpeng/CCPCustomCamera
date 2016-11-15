//
//  CCPShowPhotoViewController.m
//  CCPCustomCamera
//
//  Created by CCP on 2016/11/15.
//  Copyright © 2016年 CCP. All rights reserved.
//

#import "CCPShowPhotoViewController.h"

@interface CCPShowPhotoViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *showTableView;
@end

@implementation CCPShowPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    self.showTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44)];
    
    [self.view addSubview:self.showTableView];
    
    self.showTableView.dataSource = self;
    self.showTableView.delegate = self;
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    
    headView.backgroundColor = [UIColor blackColor];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15, 0, 50, 44)];
    [button setTitle:@"关闭" forState:UIControlStateNormal];
    
    [button setTintColor:[UIColor whiteColor]];
    
    [button addTarget:self action:@selector(clickTheBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [headView addSubview:button];
    
    [self.view addSubview:headView];
}

- (void)setImageArray:(NSArray *)imageArray {
    
    _imageArray = imageArray;
    
//    [self.showTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.imageArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        cell.imageView.image = self.imageArray[indexPath.row];
    }
    return cell;
}

- (void) clickTheBtn {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

@end
