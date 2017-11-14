//
//  ViewController.m
//  CouchbaseLite_NoSQL
//
//  Created by Liangk on 2017/11/14.
//  Copyright © 2017年 liang. All rights reserved.
//

#import "ViewController.h"
#import "DatabaseSetupUtil.h"
#import "UserDataDBModel.h"

@interface ViewController () {
    UserDataDBModel * _model;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self addUserData];
    
    [self saveDate];
    
    NSArray* updateDatas = [UserDataDBModel getModelsByStatus:@0];
}

//1.增加数据
- (void)addUserData {
    _model = [[UserDataDBModel alloc] init];
    _model.resident = @"张三";
    _model.mobile = @"123456789111";
    _model.idno = @"546456456575675";
    _model.note = @"假设是资料";
    _model.status = @0;
    _model.crtime = [self getCurrentUTCTime];
}


- (void)saveDate {
    if(![UserDataDBModel createDocument:_model]) {
        //失败
    }
    else {
        //成功
        NSArray* updateDatas = [UserDataDBModel getModelsByStatus:@0];
        for (UserDataDBModel* model in updateDatas) {
            NSLog(@"文档唯一性id: %@",model._id);
            NSPredicate* where = [NSPredicate predicateWithFormat:@"collection == %@ && _id=%@ ",UserDataPackageCollectionName,model._id];
            [UserDataDBModel updateDocument:where newModel:model];
        }
    }
}

- (NSString*)getCurrentUTCTime {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
