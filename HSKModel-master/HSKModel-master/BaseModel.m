//
//  BaseModel.m
//  HSKModel-master
//
//  Created by scott on 2016/12/20.
//  Copyright © 2016年 ZQ. All rights reserved.
//

#import "BaseModel.h"
#import "NSObject+HSKModel.h"
#import "Person.h"

@implementation BaseModel


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


//+ (void)hsk_objectTransformModelDidFinish{
//
//    NSLog(@"转换完毕");
//}

@end
