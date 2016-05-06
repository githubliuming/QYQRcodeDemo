//
//  ViewController.m
//  QYQRDemo
//
//  Created by 明刘 on 16/5/6.
//  Copyright © 2016年 liuming. All rights reserved.
//

#import "ViewController.h"
#import "QYScanerView.h"
#import "QYScannerViewController.h"
#import "QYQRBuilderViewController.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView * tableView;
@end

@implementation ViewController

- (NSArray * )dataSource{
    
    return @[@"生成二维码",@"扫描二维码"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"首页";
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:self.tableView];
    
    
    //    CGRect frame = self.view.bounds;
    //    QYScanerView * scanerView = [[QYScanerView alloc] initWithFrame:frame];
    //
    //    [self.view addSubview:scanerView];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [[self dataSource] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * identifier = @"cellID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [[self dataSource] objectAtIndex:indexPath.row];
    
    return cell;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            QYQRBuilderViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"QYQRBuilderViewController"];
            
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:{
        
            QYScannerViewController * vc = [[QYScannerViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
