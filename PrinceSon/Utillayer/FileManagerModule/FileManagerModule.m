//
//  FileManagerModule.m
//  PrinceSon
//
//  Created by wangmingquan on 2/6/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import "FileManagerModule.h"

@implementation FileManagerModule

+ (NSString *)getDocumentFileWithName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, name];
    return filePath;
}

+ (NSString *)getLibraryFileWithName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", libraryDirectory, name];
    return filePath;
}

+ (NSString *)getCacheFileWithName:(NSString *)name
{
    NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cacPath objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", cachePath, name];
    return filePath;
}

+ (NSString *)getTmpFileWithName:(NSString *)name
{
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", tmpDirectory, name];
    return filePath;
}

+ (BOOL)isFileExist:(NSString *)filePath
{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:filePath]) {
        return YES;
    }
    return NO;
}

@end
