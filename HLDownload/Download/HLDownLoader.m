//
//  HLDownLoader.m
//  HLDownloadDemo
//
//  Created by LHL on 18/6/21.
//  Copyright © 2018年 LHL. All rights reserved.
//

#import "HLDownLoader.h"

static NSLock *downloadLock;

@implementation HLDownLoader

-(instancetype)initWithHLM3U8List:(HLM3U8List *)list
{
    if (self = [super init])
    {
        self.playlist = list;
        self.progress = 0.0;
        self.writtenSize = 0.0;
        self.totalSize = 0.0;
        self.filePath = self.playlist.filePath;
        downloadLock = [[NSLock alloc] init];
    }
    return  self;
}

/**
 *  开始下载
 */
-(void)startDownload
{
    [self.downloadArray removeAllObjects];
    
    for(int i = 0;i< self.playlist.length;i++)
    {
        // 一个文件名
        NSString *fileName = [NSString stringWithFormat:@"%d.ts",i];
        // 根据索引获得片段info
        HLM3U8SegmentInfo *segment = [self.playlist getSegment:i];
        // 创建分段下载器
        HLSegmentDownLoader *sgDownloader = [[HLSegmentDownLoader alloc]
                                             initWithUrl:segment.locationUrl
                                             andFilePathName:self.playlist.filePath
                                             andFileName:fileName];
        sgDownloader.delegate = self;
        [sgDownloader start];
        
        [self.downloadArray addObject:sgDownloader];
    }
    self.isDownloading = YES;
}

-(void)resumeDownload
{
    for(HLSegmentDownLoader *obj in self.downloadArray)
    {
        [obj resume];
    }
    self.isDownloading = YES;
}

/**
 *  暂停下载
 */
- (void)suspendDownload
{
    [downloadLock lock];
    NSLog(@"suspendDownload");
    if(self.isDownloading && self.downloadArray != nil)
    {
        for(HLSegmentDownLoader *obj in self.downloadArray)
        {
            [obj suspend];
        }
        self.isDownloading = NO;
    }
    [downloadLock unlock];
}

/**
 *  取消下载
 */
- (void)cancelDownload{
    [downloadLock lock];
    for(HLSegmentDownLoader *obj in self.downloadArray)
    {
        [obj cancel];
    }
    
    [self.downloadArray removeAllObjects];
    [downloadLock unlock];
}


#pragma mark - SegmentHLDownloadDelegate

// 每个下载器下载完成
-(void)segmentDownloadFinished:(HLSegmentDownLoader *)request
{
    [downloadLock lock];
    
    NSLog(@"a segment Download Finished");
    [self.downloadArray removeObject:request];
    
    if([self.downloadArray count] == 0)
    {
        self.progress = 1;
        self.downloadArray = nil;
        NSLog(@"-----100%%-------all the segments downloaded. video download finished");
        // 总下载字节数有时候有误差
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloader:Progress:)])
        {
            [self.delegate downloader:self Progress:self.progress];
        }
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(downloaderFinished:)])
        {
            [self.delegate downloaderFinished:self];
        }
        
        self.progress = 0;
        self.writtenSize = 0.0;
        self.isDownloading = NO;
    }else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloader:Progress:)])
        {
            [self.delegate downloader:self Progress:self.progress];
        }
    }
    [downloadLock unlock];
}

// 进度
- (void)segmentDownload:(HLSegmentDownLoader *)request progresser:(HLSegmentProgresser *)progresser
{
    NSLog(@"totalSize %@ , writtenSize %@",@(progresser.totalSize), @(progresser.writtenSize));
    
    
    self.writtenSize += progresser.writtenSize;
    
    double progress = (self.playlist.segments.count - self.downloadArray.count+1)/(float)self.playlist.segments.count;
    self.progress = progress+(progresser.writtenSize/progresser.totalSize)/self.playlist.segments.count;
    if (self.progress > 1) {
        self.progress = 1.0;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloader:Progress:)])
    {
        [self.delegate downloader:self Progress:self.progress];
    }
}


// 下载失败
-(void)segmentDownloadFailed:(HLSegmentDownLoader *)request error:(NSError *)error progresser:(HLSegmentProgresser *)progresser
{
    NSLog(@"segmentDownloadFailed error =%@", error);
    
    self.totalWrittenSize +=  progresser.totalWritten;
    self.writtenSize = self.totalWrittenSize;
    
    if (error.code != NSURLErrorCancelled) { // 取消
//        [request start];
    }
}

#pragma mark -


-(NSString*)createLocalM3U8file
{
    
    if(self.playlist !=nil)
    {
        NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        NSString *saveTo = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.filePath];
        NSString *fullpath = [saveTo stringByAppendingPathComponent:@"index.m3u8"];
        
        NSLog(@"createLocalM3U8file:%@",fullpath);
        
        //创建文件头部
        NSString* head = @"#EXTM3U\n#EXT-X-TARGETDURATION:30\n#EXT-X-VERSION:2\n#EXT-X-DISCONTINUITY\n";
        
        //        NSString* segmentPrefix = [NSString stringWithFormat:@"http://127.0.0.1:12345/%@/",self.filePath]; // 这是localServer
        NSString* segmentPrefix = @"";
        //填充片段数据
        for(int i = 0;i< self.playlist.length;i++)
        {
            NSString* filename = [NSString stringWithFormat:@"%d.ts",i];
            HLM3U8SegmentInfo* segInfo = [self.playlist getSegment:i];
            NSString* length = [NSString stringWithFormat:@"#EXTINF:%ld,\n",(long)segInfo.duration];
            NSString* url = [segmentPrefix stringByAppendingString:filename];
            head = [NSString stringWithFormat:@"%@%@%@\n",head,length,url];
        }
        //创建尾部
        NSString* end = @"#EXT-X-ENDLIST";
        head = [head stringByAppendingString:end];
        NSMutableData *writer = [[NSMutableData alloc] init];
        [writer appendData:[head dataUsingEncoding:NSUTF8StringEncoding]];
        
        BOOL bSucc =[writer writeToFile:fullpath atomically:YES];
        if(bSucc)
        {
            NSLog(@"create m3u8file succeed; fullpath:%@, content:%@",fullpath,head);
            return  fullpath;
        }
        else
        {
            NSLog(@"create m3u8file failed");
            return  nil;
        }
    }
    return nil;
}

- (NSMutableArray *)downloadArray{
    if (!_downloadArray) {
        _downloadArray = [[NSMutableArray alloc]init];
    }
    return _downloadArray;
}

@end

