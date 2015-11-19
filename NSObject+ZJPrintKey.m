//
//  NSObject+ZJPrintKey.m
//  123123
//
//  Created by MACMINI on 15/11/17.
//  Copyright (c) 2015年 LZJ. All rights reserved.
//

#import "NSObject+ZJPrintKey.h"
#import <objc/runtime.h>
@implementation NSObject (ZJPrintKey)
// 定义一个关联的key
static char replaceDictionaryKey;
- (void)zj_dictionaryToLogUrlStr:(NSString *)urlStr andKey:(NSString *)key andKeyReplaceDictionary:(NSDictionary *)dict {
    if (!urlStr || urlStr.length == 0 || !key) {
        return;
    }
    objc_setAssociatedObject(self, &replaceDictionaryKey, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    NSLog(@"Loading......");
    // 异步获取数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:urlStr]];
        NSLog(@"Loaded");
        NSDictionary *temDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        [self findTheValue:key andDict:temDict];
    });
}
- (void)findTheValue:(NSString *)str andDict:(NSDictionary *)dict {
    NSArray *ak = dict.allKeys;
    for (NSString *keyName in ak) {
        if ([keyName isEqualToString:str]) {
            // 如果找到了相应的key，递归就可以结束了
            id tem = dict[keyName];
            // 获取关联值
            NSDictionary *temDict = objc_getAssociatedObject(self, &replaceDictionaryKey);
            if ([tem isKindOfClass:[NSDictionary class]]) {
                [self handleDict:tem andKeyreplaces:temDict];
            }
            else if ([tem isKindOfClass:[NSArray class]]) {
                if ([tem count] >= 1) {
                    [self handleDict:tem[0] andKeyreplaces:temDict];
                }
            }
            else {
                NSLog(@"Format is not correct");
            }
            objc_setAssociatedObject(self, &replaceDictionaryKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            return;
        }
        else {
            id tem = dict[keyName];
            if ([tem isKindOfClass:[NSDictionary class]]) {
                // 递归，遍历下一层，如果是字典的话
                [self findTheValue:str andDict:tem];
            }
            else if ([tem isKindOfClass:[NSArray class]]) {
                // 如果是数组，只取第0个数据，并且传值递归
                if ([tem count] >= 1) {
                    [self findTheValue:str andDict:tem[0]];
                }
            }
            else {
                // 其他
            }
        }
    }
    NSLog(@"not found");
}
- (void)handleDict:(NSDictionary *)dict andKeyreplaces:(NSDictionary *)kDict {
    NSMutableString *mustr = [NSMutableString new];
    
    __block NSDictionary *temDict = kDict;
    // 确定相应值里面的元素，有哪些属性
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        // 三元运算，先确定要替换值是否存在于请求返回的数据，然后确定temDict不为nil
        NSString *temKey = temDict ? (temDict[key] ? temDict[key] : key) : key;
        if ([obj isKindOfClass:[NSNumber class]]) {
            [mustr appendString:[NSString stringWithFormat:@"@property (strong, nonatomic) NSNumber *%@;\n", temKey]];
        }
        else if ([obj isKindOfClass:[NSArray class]]) {
            [mustr appendString:[NSString stringWithFormat:@"@property (strong, nonatomic) NSArray *%@;\n", temKey]];
        }
        else {
            [mustr appendString:[NSString stringWithFormat:@"@property (copy, nonatomic) NSString *%@;\n", temKey]];
        }
    }];
    
    NSLog(@"\n/**********ZJPrintKey***********/\n%@/**********ZJPrintKey***********/\n", mustr);
}
@end
