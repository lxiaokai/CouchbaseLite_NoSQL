//
//  UserDataDBModel.h
//  CouchbaseLite_NoSQL
//
//  Created by Liangk on 2017/11/14.
//  Copyright © 2017年 liang. All rights reserved.
//

#import "DBModelBase.h"

#define UserDataPackageCollectionName @"UserDataPackage"

/**
 用户资料model实体
 作用: 主要是存储一些用户信息
 */
@interface UserDataDBModel : DBModelBase

/*-----可以定义字典或者数组类型,demo不做举例------*/
@property (nonatomic,strong) NSString* resident;     //居民姓名
@property (nonatomic,strong) NSString* mobile;      //居民手机号码
@property (nonatomic,strong) NSString* idno;        //居民身份证号码
@property (nonatomic,strong) NSNumber* status;       //状态:1、未上传，2、已上传
@property (nonatomic,strong) NSString* note;      //备注
@property (nonatomic,strong) NSString* crtime;  //创建时间



//根据实体id获取包数据
+ (UserDataDBModel*)getModelByPackageID:(NSString*)reportId;

//根据上上传状态值获取包数据(根据时间排序)
+ (NSArray*)getModelsByStatus:(NSNumber*)status;

//获取所有包数据(根据时间排序)
+ (NSArray*)getAllModels;

@end
