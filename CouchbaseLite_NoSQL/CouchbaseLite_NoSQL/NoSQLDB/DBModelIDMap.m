//
//  DBModelIDMap.m
//  CouchbaseLite_NoSQL
//
//  Created by Liangk on 2017/11/14.
//  Copyright © 2017年 liang. All rights reserved.
//

#import "DBModelIDMap.h"

@implementation DBModelIDMap

//实体转词典
- (NSDictionary*)toDictionary {
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if(self._id) {
        dic[@"_id"] = self._id;
    }
    if(self.collection) {
        dic[@"collection"] = self.collection;
    }
    if(self.docmentId) {
        dic[@"docmentId"] = self.docmentId;
    }
    if(self.modelId) {
        dic[@"modelId"] = self.modelId;
    }
    if (self.extendFields) {
        for (NSString* key in self.extendFields.allKeys) {
            id value = self.extendFields[key];
            if (value) {
                dic[key] = value;
            }
        }
    }
    return dic;
}

//文档转实体
+ (DBModelIDMap*)fromDictionary:(NSDictionary*)dictionary {
    DBModelIDMap* ret = [[DBModelIDMap alloc] init];
    
    for (NSString* key in dictionary.allKeys) {
        if ([key isEqualToString:@"_id"] ||
            [key isEqualToString:@"_rev"] ||
            [key isEqualToString:@"collection"] ||
            [key isEqualToString:@"docmentId"] ||
            [key isEqualToString:@"modelId"]) {
            
            [ret setValue:dictionary[key] forKey:key];
        }
        else {
            //动态字段
            if (ret.extendFields == nil) {
                ret.extendFields = [NSMutableDictionary dictionary];
            }
            ret.extendFields[key]= dictionary[key];
        }
    }
    
    return ret;
}


@end
