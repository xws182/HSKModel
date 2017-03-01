//
//  NSObject+HSKModel.h
//
//  Created by zhouqiao on 2016/12/19.
//  Copyright © 2016年 ZQ. All rights reserved.
//

#import "NSObject+HSKModel.h"
#import "HSKClass.h"

@implementation NSObject (HSKModel)

+ (instancetype)hsk_modelWithObject:(id)object{
    NSDictionary *dictionary = [self dictionaryWithObject:object];
    if(!dictionary) return nil;
    HSKClass *cls = [HSKClass classInfoWithClass:self];
    return [self modelClass:cls dictionary:dictionary];
}

+ (instancetype)hsk_modelWithResource:(NSString *)name ofType:(NSString *)ext{
    NSDictionary *dictionary = [self dictionaryWithResource:name ofType:ext];
    return [self hsk_modelWithObject:dictionary];
}

+ (NSMutableArray *)hsk_modelArrayWithObject:(id)object{
    NSArray *array = [self arrayWithObject:object];
    if(!array) return nil;
    NSMutableArray *models = [NSMutableArray array];
    for (id value in array) {
        if([value isKindOfClass:[NSDictionary class]]){
            NSObject *model = [self hsk_modelWithObject:value];
            if(model) [models addObject:model];
        }
    }
    return models;
}

+ (NSMutableArray *)hsk_modelArrayWithResource:(NSString *)name ofType:(NSString *)ext{
    NSDictionary *dictionary = [self dictionaryWithResource:name ofType:ext];
    return [self hsk_modelArrayWithObject:dictionary];
}

- (NSMutableDictionary *)hsk_keyValues{
    HSKClass *cls = [HSKClass classInfoWithClass:self.class];
    return [self dictionaryForModelClass:cls];
}

+ (NSDictionary *)dictionaryWithResource:(NSString *)name ofType:(NSString *)ext{
    NSDictionary *dictionary = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:ext];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if(data) dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return dictionary;
}

+ (NSArray *)arrayWithObject:(id)object{
    if(!object) return nil;
    NSArray *array = nil;
    NSData *jsonData = nil;
    if ([object isKindOfClass:[NSArray class]]) {
        array = object;
    } else if ([object isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)object dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([object isKindOfClass:[NSData class]]) {
        jsonData = object;
    }
    if (jsonData) {
        array = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![array isKindOfClass:[NSArray class]]) array = nil;
    }
    return array;
}

+ (NSDictionary *)dictionaryWithObject:(id)object{
    if (!object) return nil;
    NSDictionary *dictionary = nil;
    NSData *jsonData = nil;
    if ([object isKindOfClass:[NSDictionary class]]) {
        dictionary = object;
    } else if ([object isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)object dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([object isKindOfClass:[NSData class]]) {
        jsonData = object;
    }
    if (jsonData) {
        dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dictionary isKindOfClass:[NSDictionary class]]) dictionary = nil;
    }
    return dictionary;
}

- (NSArray *)arrayForModelArray:(NSArray *)array{
    NSMutableArray *mArray = [NSMutableArray array];
    for(id obj in array){
        if([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]]) {
            [mArray addObject:obj];
        }else if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *array = [self arrayForModelArray:obj];
            if(array) [mArray addObject:array];
        }else if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = [self dictionaryForModelDictionary:obj];
            if(dict) [mArray addObject:dict];
        }else{
            NSDictionary *dict = [obj hsk_keyValues];
            if(dict) [mArray addObject:dict];
        }
    }
    return mArray;
}

- (NSDictionary *)dictionaryForModelDictionary:(NSDictionary *)dictionary{
    NSMutableDictionary *mDictionary= [NSMutableDictionary dictionary];
    for(id obj in dictionary){
        id value = dictionary[obj];
        if([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
            mDictionary[obj] = value;
        }else if ([value isKindOfClass:[NSArray class]]) {
            NSArray *array = [self arrayForModelArray:value];
            if(array) mDictionary[obj] = array;
        }else if ([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = [self dictionaryForModelDictionary:value];
            if(dict) mDictionary[obj] = dict;
        }else{
            NSDictionary *dict = [value hsk_keyValues];
            if(dict) mDictionary[obj] = dict;
        }
    }
    return mDictionary;
}

- (NSMutableDictionary *)dictionaryForModelClass:(HSKClass *)modelClass{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *replacedValues = modelClass.exportModelCustomPropertyMapper.allKeys;
    for (NSString *key in modelClass.propertys) {
        NSString *replacedKey = key;
        HSKProperty *property = modelClass.propertys[key];
        if(!property) continue;
        if([replacedValues containsObject:key]){
            replacedKey = modelClass.exportModelCustomPropertyMapper[key];
        }
        switch (property.dataType) {
            case HSKDataTypeBool:{
                NSNumber *num = @(((bool (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                if(num) dictionary[replacedKey] = [num boolValue] ? @"1" : @"0";
            }
                break;
            case HSKDataTypeFloat:{
                NSNumber *num = @(((float (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                if(num) dictionary[replacedKey] = num;
            }
                break;
            case HSKDataTypeDouble:{
                NSNumber *num = @(((double (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                if(num) dictionary[replacedKey] = num;
            }
                break;
            case HSKDataTypeChar:{
                NSNumber *num = @(((char (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                if(num) dictionary[replacedKey] = num;
            }
                break;
            case HSKDataTypeShort:{
                NSNumber *num = @(((short (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                if(num) dictionary[replacedKey] = num;
            }
                break;
            case HSKDataTypeInt:{
                NSNumber *num = @(((int (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                if(num) dictionary[replacedKey] = num;
            }
                break;
            case HSKDataTypeLongLong:{
                NSNumber *num = @(((long long (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                if(num) dictionary[replacedKey] = num;
            }
                break;
            case HSKDataTypeUnsignedChar:{
                NSNumber *num = @(((unsigned char (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                if(num) dictionary[replacedKey] = num;
            }
                break;
            case HSKDataTypeUnsignedShort:{
                NSNumber *num = @(((unsigned short (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                if(num) dictionary[replacedKey] = num;
            }
                break;
            case HSKDataTypeUnsignedInt:{
                NSNumber *num = @(((unsigned int (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                if(num) dictionary[replacedKey] = num;
            }
                break;
            case HSKDataTypeUnsignedLongLong:{
                NSNumber *num = @(((unsigned long long (*)(id, SEL))(void *) objc_msgSend)(self, property.getter));
                if(num) dictionary[replacedKey] = num;
            }
                break;
            case HSKDataTypeNSNumber:{
                NSNumber *num = ((NSNumber * (*)(id, SEL))(void *) objc_msgSend)(self, property.getter);
                if(num) dictionary[replacedKey] = num;
            }
                break;
            case HSKDataTypeNSString:
            case HSKDataTypeNSMutableString:{
                NSString *str = ((NSString * (*)(id, SEL))(void *) objc_msgSend)(self, property.getter);
                if(str.length) dictionary[replacedKey] = str;
            }
                break;
            case HSKDataTypeNSDictionary:
            case HSKDataTypeNSMutableDictionary:{
                NSDictionary *dict = ((NSDictionary * (*)(id, SEL))(void *) objc_msgSend)(self, property.getter);
                NSDictionary *mDict = [self dictionaryForModelDictionary:dict];
                if(mDict.count) dictionary[replacedKey] = mDict;
            }
                break;
            case HSKDataTypeNSArray:
            case HSKDataTypeNSMutableArray:{
                NSArray *array = ((NSArray * (*)(id, SEL))(void *) objc_msgSend)(self, property.getter);
                NSArray *mArray = [self arrayForModelArray:array];
                if(mArray.count) dictionary[replacedKey] = mArray;
            }
                break;
            case HSKDataTypeCustomObject:{
                NSObject *object = ((NSObject * (*)(id, SEL))(void *) objc_msgSend)(self, property.getter);
                NSDictionary *dict = [object hsk_keyValues];
                if(dict.count) dictionary[replacedKey] = dict;
            }
                break;
            default:break;
        }
    }
    return dictionary;
}

+ (NSObject *)modelClass:(HSKClass *)modelClass dictionary:(NSDictionary *)dictionary{
    NSObject *objc = [modelClass.cls new];
    NSArray *replacedKeys = modelClass.loadModelCustomPropertyMapper.allKeys;
    for (NSString *key in dictionary) {
        NSString *propertyKey = key;
        if([replacedKeys containsObject:propertyKey]){
            propertyKey = modelClass.loadModelCustomPropertyMapper[propertyKey];
        }
        HSKProperty *property = modelClass.propertys[propertyKey];
        if(!property) continue;
        id value = dictionary[key];
        switch (property.dataType) {
            case HSKDataTypeBool:
                ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)objc, property.setter, [value boolValue] ? YES : NO);
                break;
            case HSKDataTypeFloat:
                ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)objc, property.setter, [value isKindOfClass:[NSNumber class]] ? [value floatValue] : 0);
                break;
            case HSKDataTypeDouble:
                ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)objc, property.setter, [value isKindOfClass:[NSNumber class]] ? [value doubleValue] : 0);
                break;
            case HSKDataTypeChar:
                ((void (*)(id, SEL, int8_t))(void *) objc_msgSend)((id)objc, property.setter, [value isKindOfClass:[NSNumber class]] ? [value charValue] : 0);
                break;
            case HSKDataTypeShort:
                ((void (*)(id, SEL, int16_t))(void *) objc_msgSend)((id)objc, property.setter, [value isKindOfClass:[NSNumber class]] ? [value shortValue] : 0);
                break;
            case HSKDataTypeInt:
                ((void (*)(id, SEL, int32_t))(void *) objc_msgSend)((id)objc, property.setter, [value isKindOfClass:[NSNumber class]] ? [value intValue] : 0);
                break;
            case HSKDataTypeLongLong:
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)objc, property.setter, [value isKindOfClass:[NSNumber class]] ? [value longLongValue] : 0);
                break;
            case HSKDataTypeUnsignedChar:
                ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)objc, property.setter, [value isKindOfClass:[NSNumber class]] ? [value unsignedCharValue] : 0);
                break;
            case HSKDataTypeUnsignedShort:
                ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)objc, property.setter, [value isKindOfClass:[NSNumber class]] ? [value unsignedShortValue] : 0);
                break;
            case HSKDataTypeUnsignedInt:
                ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)objc, property.setter, [value isKindOfClass:[NSNumber class]] ? [value unsignedIntValue] : 0);
                break;
            case HSKDataTypeUnsignedLongLong:
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)objc, property.setter, [value isKindOfClass:[NSNumber class]] ? [value unsignedLongLongValue] : 0);
                break;
            case HSKDataTypeNSNumber:
                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)objc, property.setter, [value isKindOfClass:[NSNumber class]] ? value : nil);
                break;
            case HSKDataTypeCustomObject:
                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)objc, property.setter, [property.propertyClass hsk_modelWithObject:value]);
                break;
            case HSKDataTypeNSString:
            case HSKDataTypeNSMutableString:{
                if([value isKindOfClass:[NSString class]]){
                    NSString *str = (NSString *)value;
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)objc, property.setter, property.dataType == HSKDataTypeNSMutableString ? str.mutableCopy : str);
                }else if ([value isKindOfClass:[NSNumber class]]){
                    NSString *str = [NSString stringWithFormat:@"%@",value];
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)objc, property.setter, property.dataType == HSKDataTypeNSMutableString ? str.mutableCopy : str);
                }
            }
                break;
            case HSKDataTypeNSDictionary:
            case HSKDataTypeNSMutableDictionary:
                if([value isKindOfClass:[NSDictionary class]]){
                    NSDictionary *dictionary = (NSDictionary *)value;
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)objc, property.setter, property.dataType == HSKDataTypeNSMutableDictionary ? dictionary.mutableCopy : dictionary);
                }
                break;
            case HSKDataTypeNSArray:
            case HSKDataTypeNSMutableArray:
                if([value isKindOfClass:[NSArray class]]){
                    if([modelClass.modelClassInArray.allKeys containsObject:property.propertyName] && modelClass.modelClassInArray[property.propertyName]){
                        Class cls = modelClass.modelClassInArray[property.propertyName];
                        NSMutableArray *models = [NSMutableArray array];
                        for(id obj in (NSArray *)value){
                            NSObject *model = [cls hsk_modelWithObject:obj];
                            if(model) [models addObject:model];
                        }
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)objc, property.setter, property.dataType == HSKDataTypeNSMutableArray ? models : models.copy);
                    }
                    else{
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)objc, property.setter, nil);
                    }
                }
                break;
            default:break;
        }
    }
    if([modelClass.cls respondsToSelector:@selector(hsk_objectTransformModelDidFinish)]){
        [modelClass.cls hsk_objectTransformModelDidFinish];
    }
    return objc;
}

@end

