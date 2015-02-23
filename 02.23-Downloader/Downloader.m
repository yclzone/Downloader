//
//  Downloader.m
//  02.23-Downloader
//
//  Created by Chenglin Yu on 2/23/15.
//  Copyright (c) 2015 yclzone. All rights reserved.
//

#import "Downloader.h"

@interface Downloader ()<NSURLConnectionDataDelegate>
/** currentLength */
@property (assign, nonatomic) long long currentLength;
/** connection */
@property (strong, nonatomic) NSURLConnection *connection;
/** fileHandle */
@property (strong, nonatomic) NSFileHandle *fileHandle;

@end

@implementation Downloader

- (NSFileHandle *)fileHandle {
  if (!_fileHandle) {
    _fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.destinationPath];
  }
  return _fileHandle;
}

- (void)pause {
  self.downloading = NO;
  
  // 取消连接
  [self.connection cancel];
  self.connection = nil;

}

- (void)start {
  self.downloading = YES;
  
  // 连接取消后，需要重新创建连接
  NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.sourceURL]];
  // 从当前大小的位置开始请求（设置请求头）
  long long begin = self.range.location + self.currentLength;
  long long end = self.range.location + self.range.length - 1;
  NSString *value = [NSString stringWithFormat:@"bytes=%lld-%lld", begin, end];
  [requestM setValue:value forHTTPHeaderField:@"Range"];
  self.connection = [NSURLConnection connectionWithRequest:requestM delegate:self];
}

#pragma mark -
#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  
  // 追加接收数据到文件末尾
  [self.fileHandle seekToFileOffset:self.range.location + self.currentLength];
  [self.fileHandle writeData:data];
  
  // 累加接收数据的长度
  self.currentLength += data.length;

  if (self.progressHandle) {
    self.progressHandle(data.length);
  }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//  if (self.currentLength < self.range.length) {
//    return;
//  }
  
  // 链接加载完后，关闭文件
  [self.fileHandle closeFile];
  
  if (self.completeHandle) {
    self.completeHandle(YES);
  }
  
  //
  self.currentLength = 0;
  self.connection = nil;
  self.fileHandle = nil;
  self.downloading = NO;
}
@end
