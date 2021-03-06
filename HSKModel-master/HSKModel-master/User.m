//
//  User.m
//  HSKModel-master
//
//  Created by scott on 2016/12/20.
//  Copyright © 2016年 ZQ. All rights reserved.
//

#import "User.h"

@implementation User

+ (NSDictionary *)hsk_modelClassInArray{
    return @{
             @"persons" : [Person class]
             };
}

+ (NSDictionary *)hsk_loadModelCustomPropertyMapper{
    return @{
             @"id" : @"ID",
             @"desciption":  @"desc",
             @"newName" : @"name"
             };
}

+ (NSDictionary *)hsk_exportModelCustomPropertyMapper{
    return @{
             @"ID" : @"id",
             @"desc":  @"desciption",
             @"name" : @"newName"
             };
}

+ (void)hsk_objectTransformModelDidFinish{
    
    NSLog(@"转换完毕");
}


@end
