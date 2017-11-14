//
//  DBModelIDMap.h
//  CouchbaseLite_NoSQL
//
//  Created by Liangk on 2017/11/14.
//  Copyright © 2017年 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBModelBase.h"

/**
 *  id映射实体，主要是documentid与具体业务实体id之间的映射关系
 */
@interface DBModelIDMap : DBModelBase

@property(strong,nonatomic) NSString* docmentId;  //文档id
@property(strong,nonatomic) NSString* modelId;  //具体业务实体id

@end
