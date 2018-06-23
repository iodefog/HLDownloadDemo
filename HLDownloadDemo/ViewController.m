//
//  ViewController.m
//  HLDownloadDemo
//
//  Created by LHL on 2018/6/21.
//  Copyright © 2018 HL. All rights reserved.
//

#import "ViewController.h"
#import <HLDownload/HLDownload.h>
#import <AVFoundation/AVFoundation.h>
#import "HTTPServer.h"
#import "HLDownloaderCenter.h"

@interface ViewController ()<HLDownloadDelegate, HLSegmentDownloadDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, strong) HLM3U8Praser *HLM3U8Praser;
@property (nonatomic, strong) HLDownLoader *downloader;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic, strong) HTTPServer *server;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSLog(@"沙盒---path----%@",path);

    self.HLM3U8Praser = [[HLM3U8Praser alloc] init];

}


- (IBAction)downloadClicked:(id)sender {
/*  1.http://163.com-www-letv.com/20180604/1403_6de54f23/index.m3u8
    2.http://163.com-www-letv.com/20180604/1402_1834f64c/index.m3u8
    3.http://163.com-www-letv.com/20180604/1400_105254be/index.m3u8
    4.http://163.com-www-letv.com/20180604/1401_2c942586/index.m3u8
*/
    [self.HLM3U8Praser praseM3u8Url:[NSURL URLWithString:@"http://163.com-www-letv.com/20180604/1401_2c942586/index.m3u8"] praserBlock:^(NSURL *m3u8URL, HLM3U8List *segmentList) {
        // 视频文件父目录
//        segmentList.filePath = m3u8URL.absoluteString.md5Hash;
        // 一个下载器
        self.downloader = [[HLDownLoader alloc]initWithHLM3U8List:segmentList];
        self.downloader.delegate = self;
        [self.downloader startDownload];
    }];
}

- (IBAction)pauseClicked:(id)sender {
    if (self.downloader) {
        [self.downloader suspendDownload];
    }
}

- (IBAction)resumeClicked:(id)sender {
    [self.downloader resumeDownload];
}

- (IBAction)playClicked:(id)sender {
    [self play];
}

- (void)play{
    NSString *localM3u8 = self.downloader.localM3U8;
    NSLog(@"LocalM3U8file %@", localM3u8) ;
    if (localM3u8) {
        
        if(!self.server){
            self.server = [[HTTPServer alloc] init];
            [self.server setType:@"_http.tcp"];
            [self.server setPort:12345];
            
            //设置服务器根路径
            [self.server setDocumentRoot:localM3u8.stringByDeletingLastPathComponent];
        }
        
        if(![self.server isRunning]){
            NSError *error = nil;
            [self.server start:&error];
            
            NSLog(@"xxx %@",error);
            NSLog(@"yyy %@",self.server.documentRoot);
        }
        
        
        
//        NSURL *m3u8 = [NSURL URLWithString:@"http://163.com-www-letv.com/20180604/1403_6de54f23/1000k/hls/index.m3u8"];
        NSURL *m3u8 = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:12345/index.m3u8"]];

        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:m3u8];
        AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        playerLayer.frame = self.contentView.bounds;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.contentView.layer addSublayer:playerLayer];
            [player play];
        });

    }
}

#pragma mark - HLDownloadDelegate
-(void)downloader:(HLDownLoader *)request Progress:(double)progess
{
    NSString *str = [NSString stringWithFormat:@"%0.1f%%",progess*100];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.label.text = str;
    });
}

-(void)downloaderFinished:(HLDownLoader *)download
{
    [self play];
}


@end
