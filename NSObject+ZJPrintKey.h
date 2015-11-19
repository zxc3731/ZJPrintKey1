//
//  NSObject+ZJPrintKey.h
//  123123
//
//  Created by MACMINI on 15/11/17.
//  Copyright (c) 2015年 LZJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ZJPrintKey)
/**
 *  打印模型类的所有属性
 *
 *  @param urlStr 请求URL
 *  @param key    要获取的值的key
 *  @param dict   要替换名字的属性，可以为nil
 */
- (void)zj_dictionaryToLogUrlStr:(NSString *)urlStr andKey:(NSString *)key andKeyReplaceDictionary:(NSDictionary *)dict;
@end
