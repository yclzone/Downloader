//
//  MultiThreadDownloader.m
//  02.23-Downloader
//
//  Created by Chenglin Yu on 2/23/15.
//  Copyright (c) 2015 yclzone. All rights reserved.
//

#import "MultiThreadDownloader.h"
#import "Downloader.h"
#define kMaxDownloaders 10


@interface MultiThreadDownloader ()
/** currentLength */
@property (assign, nonatomic) long long currentLength;
/** totalLength */
@property (assign, nonatomic) long long totalLength;
/** connection */
@property (strong, nonatomic) NSURLConnection *connection;
/** fileHandle */
//@property (strong, nonatomic) NSFileHandle *fileHandle;

/** downloaders */
@property (strong, nonatomic) NSMutableArray *downloaders;
/** double */
@property (strong, nonatomic) NSDate *date;

@end

@implementation MultiThreadDownloader

// 发送 HEAD 请求，获取头文件信息
- (void)getContentSize {
  NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.sourceURL]];
  requestM.HTTPMethod = @"HEAD";
  NSURLResponse *response;
  [NSURLConnection sendSynchronousRequest:requestM returningResponse:&response error:nil];
  self.totalLength = response.expectedContentLength;
}

- (NSMutableArray *)downloaders {
  if (!_downloaders) {
    _downloaders = [NSMutableArray arrayWithCapacity:kMaxDownloaders];
    
    // 每个下载器需要下载的大小
    long long downloadLength = 0;
    [self getContentSize];
    if (0 == self.totalLength % kMaxDownloaders) {
      downloadLength = self.totalLength / kMaxDownloaders;
    } else {
      downloadLength = self.totalLength / kMaxDownloaders + 1;
    }
    
    for (int i = 0; i<kMaxDownloaders; i++) {
      Downloader *downloader = [[Downloader alloc] init];
      downloader.sourceURL = self.sourceURL;
      downloader.destinationPath = self.destinationPath;
      downloader.range = NSMakeRange(i * downloadLength, downloadLength);
      downloader.progressHandle = ^ (long long length) {
        self.currentLength += length;
        double progress = (double)self.currentLength / self.totalLength;
        if (self.progressHandle) {
          self.progressHandle(progress);
          NSLog(@"%f", progress);
        }
      };
      
      downloader.completeHandle = ^(BOOL finished) {
        static int count = 0;
        if (finished) {
          count++;
        }
        NSLog(@"%d段(共%d段)下载完成", count, kMaxDownloaders);
        if (self.completeHandle && count == kMaxDownloaders) {
          NSLog(@"文件大小：%.2fMB, 耗时：%.2f秒", (double)self.totalLength/1024/1024, [[NSDate date] timeIntervalSinceDate:self.date]);
          self.completeHandle();
        }
      };
      
      [_downloaders addObject:downloader];
    }
    
    // 先生成一个相同大小的空文件
    [[NSFileManager defaultManager] createFileAtPath:self.destinationPath contents:nil attributes:nil];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.destinationPath];
    [fileHandle truncateFileAtOffset:self.totalLength];
    [fileHandle closeFile];
  }
  return _downloaders;
}

- (void)start {
  if (!self.date) {
    self.date = [NSDate date];
  }
  self.downloading = YES;
  [self.downloaders makeObjectsPerformSelector:@selector(start)];
}

- (void)pause {
  self.downloading = NO;
  [self.downloaders makeObjectsPerformSelector:@selector(pause)];
}
@end
