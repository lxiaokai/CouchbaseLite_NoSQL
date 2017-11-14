//
//  UserDataDBModel.m
//  CouchbaseLite_NoSQL
//
//  Created by Liangk on 2017/11/14.
//  Copyright © 2017年 liang. All rights reserved.
//

#import "UserDataDBModel.h"

@implementation UserDataDBModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        //文档所属的记录集
        self.collection = UserDataPackageCollectionName;
    }
    return self;
}

- (id)mutableCopy {
    UserDataDBModel* model = [[UserDataDBModel alloc] init];
    //这三个是必须的字段
    model._id = [self._id mutableCopy];
    model._rev = [self._rev mutableCopy];
    model.collection = [self.collection mutableCopy];
    
    model.resident = [self.resident mutableCopy];
    model.mobile = [self.mobile mutableCopy];
    model.idno= [self.idno mutableCopy];
    model.status = self.status;
    model.note = [self.note mutableCopy];
    model.crtime = [self.crtime mutableCopy];
    
    return model;
}

//实体转词典
- (NSDictionary*)toDictionary {
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    //固有字段
    if(self._id) {
        dic[@"_id"] = self._id;
    }
    
    if(self._rev) {
        dic[@"_rev"] = self._rev;
    }
    
    if(self.collection) {
        dic[@"collection"] = UserDataPackageCollectionName;
    }

    if(self.resident) {
        dic[@"resident"] = self.resident;
    }
    
    if(self.mobile) {
        dic[@"mobile"] = self.mobile;
    }
    
    if(self.idno) {
        dic[@"idno"] = self.idno;
    }

    if(self.note) {
        dic[@"note"] = self.note;
    }
    
    if(self.status) {
        dic[@"status"] = self.status;
    }
    if(self.crtime) {
        dic[@"crtime"] = self.crtime;
    }
    
    //动态字段
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

//词典转实体
+ (UserDataDBModel*)fromDictionary:(NSDictionary*)dictionary {
    UserDataDBModel* ret = [[UserDataDBModel alloc] init];
    
    for (NSString* key in dictionary.allKeys) {
        if ([key isEqualToString:@"_id"] ||
            [key isEqualToString:@"_rev"] ||
            [key isEqualToString:@"collection"] ||
            [key isEqualToString:@"resident"] ||
            [key isEqualToString:@"mobile"] ||
            [key isEqualToString:@"idno"] ||
            [key isEqualToString:@"status"] ||
            [key isEqualToString:@"note"] ||
            [key isEqualToString:@"crtime"]) {
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


#pragma mark -- 扩展方法

//根据体检报告id获取体检报告
+ (UserDataDBModel*)getModelByPackageID:(NSString*)reportId {
    UserDataDBModel* model = nil;
    NSPredicate* where = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"collection == '%@' AND _id =='%@'",UserDataPackageCollectionName,reportId]];
    NSArray* modelArray = [UserDataDBModel getDocumentWithSelect:nil where:where orderBy:nil];
    if (modelArray != nil && modelArray.count != 0) {
        model = modelArray[0];
    }
    return model;
}

//根据状态值获取体检报告
+ (NSArray*)getModelsByStatus:(NSNumber*)status {
    NSPredicate* where = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"collection == '%@' AND status ==%@",UserDataPackageCollectionName,status]];
    //时间排序
    return [UserDataDBModel getDocumentWithSelect:nil where:where orderBy:@[@"-crtime"]];
}

//获取所有体检报告
+ (NSArray*)getAllModels {
    NSPredicate* where = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"collection == '%@'",UserDataPackageCollectionName]];
    return [UserDataDBModel getDocumentWithSelect:nil where:where orderBy:@[@"-crtime"]];
}


@end
