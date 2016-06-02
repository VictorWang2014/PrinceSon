//
//  FileManagerModule.h
//  PrinceSon
//
//  Created by wangmingquan on 2/6/16.
//  Copyright © 2016年 wangmingquan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManagerModule : NSObject

/*获取Document文件路径，不管文件是否存在*/
+ (NSString *)getDocumentFileWithName:(NSString *)name;
/*获取Library文件路径，不管文件是否存在*/
+ (NSString *)getLibraryFileWithName:(NSString *)name;
/*获取Library Cache文件路径，不管文件是否存在*/
+ (NSString *)getCacheFileWithName:(NSString *)name;
/*获取Tmp文件路径，不管文件是否存在*/
+ (NSString *)getTmpFileWithName:(NSString *)name;
/*文件是否存在*/
+ (BOOL)isFileExist:(NSString *)filePath;

@end
