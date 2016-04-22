//
//  Product.h
//  HGDQPay
//
//  Created by zhuming on 16/4/8.
//  Copyright © 2016年 zhuming. All rights reserved.
//

#import <Foundation/Foundation.h>

//
//测试商品信息封装在Product中,外部商户可以根据自己商品实际情况定义
//

@interface Product : NSObject

@property (nonatomic, assign) float price;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *orderId;

@end
