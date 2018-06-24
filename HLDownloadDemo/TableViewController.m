//
//  TableViewController.m
//  HLDownloadDemo
//
//  Created by LiHongli on 2018/6/22.
//  Copyright © 2018年 HL. All rights reserved.
//

#import "TableViewController.h"
#import <HLDownload/HLDownload.h>
#import "TableViewCell.h"

@interface TableViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[TableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    
    /*
     1.http://163.com-www-letv.com/20180604/1403_6de54f23/index.m3u8
     2.http://163.com-www-letv.com/20180604/1402_1834f64c/index.m3u8
     3.http://163.com-www-letv.com/20180604/1400_105254be/index.m3u8
     4.http://163.com-www-letv.com/20180604/1401_2c942586/index.m3u8
     */
    [[HLDownloaderCenter shareInstanced] addDownloadWithM3u8URL:[NSURL URLWithString:@"http://163.com-www-letv.com/20180604/1403_6de54f23/index.m3u8"] completeBlock:^(HLDownLoader *downloader){
        [self reloadTableData];
    }];
    
    [[HLDownloaderCenter shareInstanced] addDownloadWithM3u8URL:[NSURL URLWithString:@"http://163.com-www-letv.com/20180604/1402_1834f64c/index.m3u8"] completeBlock:^(HLDownLoader *downloader){
        [self reloadTableData];
    }];
    [[HLDownloaderCenter shareInstanced] addDownloadWithM3u8URL:[NSURL URLWithString:@"http://163.com-www-letv.com/20180604/1400_105254be/index.m3u8"] completeBlock:^(HLDownLoader *downloader){
        [self reloadTableData];
    }];
    [[HLDownloaderCenter shareInstanced] addDownloadWithM3u8URL:[NSURL URLWithString:@"http://163.com-www-letv.com/20180604/1401_2c942586/index.m3u8"] completeBlock:^(HLDownLoader *downloader){
        [self reloadTableData];
    }];
}

- (void)reloadTableData{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArray = [HLDownloaderCenter shareInstanced].downloadsArray;
        [self.tableView reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (TableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    if (indexPath.row < self.dataArray.count) {
        cell.object = self.dataArray[indexPath.row];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
