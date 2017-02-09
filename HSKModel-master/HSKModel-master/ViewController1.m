//
//  ViewController1.m
//  HSKModel-master
//
//  Created by scott on 2016/12/20.
//  Copyright © 2016年 ZQ. All rights reserved.
//

#import "ViewController1.h"
#import "Person.h"
#import "BaseModel.h"
#import "NSObject+HSKModel.h"

@interface ViewController1 ()
@property (nonatomic) BaseModel *model;
@property (nonatomic) BaseModel *model1;
@end

@implementation ViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"字典转模型";
    self.view.backgroundColor = [UIColor whiteColor];

    NSDictionary *json = @{
                           @"desciption":@"集runtime之灵气, 吸MJExtension YYModel之精华",
                           @"id":@"8888888",
                           @"newName":@"zhouqiao",
                           @"hsk":[NSNull null],
                           @"person": @{
                                       @"name" : @"zhouqiao",
                                       @"age" : @"26",
                                       @"sex" : @"男"
                                   }
                           };
    

    

    BaseModel *model = [BaseModel hsk_modelWithObject:json];
 
    NSDictionary *dict = [model hsk_modelTransformDictionary];

    NSLog(@"model = %@",model.ID);
    NSLog(@"model = %@",model.desc);
    NSLog(@"model = %@",model.name);
    NSLog(@"model = %@",model.hsk);
    
    NSLog(@"model = %@",model.person.name);
    NSLog(@"model = %@",model.person.age);
    NSLog(@"model = %@",model.person.sex);
    
    NSLog(@"dict = %@",dict);

}

- (void)dealloc{


}


@end
