//
//  ViewController.m
//  SafariReaderModel
//
//  Created by puyang on 2017/9/13.
//  Copyright © 2017年 Frank. All rights reserved.
//

#import "ViewController.h"
#import "webViewController.h"
#import "PYArticleDetailController.h"

@interface ViewController ()<UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic)  UITableView *tableView;
@property (strong, nonatomic)  NSArray * dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    
    _dataSource = @[@"http://www.pingwest.com/juicero-biggest-silicon-valley-smart-hardware-hoax/",@"noping1",@"noping",@"快讯",@"普通文章",@"黑镜"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview: self.tableView];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // NSLog(@"%@",indexPath);
    
    NSString * oName = self.dataSource[indexPath.row];
    if (indexPath.row == 0) {
        PYArticleDetailController * articleVC = [[PYArticleDetailController alloc] initWithURLString:oName];
        [self.navigationController pushViewController:articleVC animated:YES];
    }else{
        NSString * oPath = [[NSBundle mainBundle] pathForResource:oName ofType:@"txt"];
        webViewController * webC = [[webViewController alloc] init];
        webC.pathStr = oPath;
        [self.navigationController pushViewController:webC animated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"cellIDentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = _dataSource[indexPath.row];
    return cell;
}

@end
