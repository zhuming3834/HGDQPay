//
//  HGDQPay.h
//  HGDQPay
//
//  Created by zhuming on 16/4/8.
//  Copyright © 2016年 zhuming. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HGDQPayStatus) {
    /**
     *  支付宝支付成功
     */
    AlipayStatusSuccess  = 9000,
    /**
     *  支付宝支付中
     */
    AlipayStatusDoing = 8000,
    /**
     *  支付宝支付失败
     */
    AlipayStatusFail = 4000,
    /**
     *  支付宝用户中途取消
     */
    AlipayStatusCancel = 6001,
    /**
     *  支付宝网络链接错误
     */
    AlipayStatusNetError = 6002,
    
    /**
     *  银联支付成功
     */
    UpPayStatusSuccess = 1,
    /**
     *  银联支付失败
     */
    UpPayStatusFail = 2,
    /**
     *  银联支付 取消
     */
    UpPayStatusCancel = 3,
    
    /**
     *  微信支付成功
     */
    WXPayStatusSuccess = 0,
    
    WXPayStatusErrCodeCommon = -1,
    
    WXPayStatusErrCodeUserCancel = -2,
    
    WXPayStatusErrCodeSentFail = -3,
    
    WXPayStatusErrCodeAuthDeny = -4,
    
    WXPayStatusErrCodeUnsupport = -5,
};

/**
 *  支付宝支付的回调
 *
 *  @param payStatus 支付结果状态
 *  @param resultDic 结果集
 */
typedef void(^AlipayCallBack)(HGDQPayStatus payStatus,NSDictionary *resultDic);
/**
 *  银联支付的block
 *
 *  @param payStatus 状态码
 *  @param data 结果集
 */
typedef void(^UpPayCallBack)(HGDQPayStatus payStatus,NSDictionary *data);
/**
 *  微信支付的回调
 *
 *  @param payStatus 支付后的状态码
 */
typedef void(^WXpayCallBack)(HGDQPayStatus payStatus);


@interface HGDQPay : NSObject
/**
 *  支付单例
 *
 *  @return return value description
 */
+ (HGDQPay *)shareHGDQPay;

/**
 *  支付宝支付
 *
 *  @param product             产品数据模型
 *  @param alipayCallBackBlock 支付回调
 */
+ (void)HGDQPayWithAlipay:(Product *)product AlipayCallBack:(AlipayCallBack)alipayCallBackBlock;

/**
 *  生成随机的订单信息
 *
 *  @return 订单对象
 */
+ (Product *)getProductData;

/**
 *  银联支付
 *
 *  @param vc                 控制器
 *  @param upPayCallBackBlock 支付结果回调
 */
+ (void)HGDQWithUppay:(UIViewController *)vc UpPayCallBack:(UpPayCallBack)upPayCallBackBlock;

/**
 *  微信支付
 *
 *  @param wxPayCallBackBlock 支付回调
 */
+ (void)HGDQPAyWithWXPayCallBack:(WXpayCallBack)wxPayCallBackBlock;


/**
 *  使用控件的控制器
 */
@property (nonatomic,strong)UIViewController *viewController;
/**
 *  银联支付成功 从AppDelegate里面回调获取的url
 */
@property (nonatomic,strong)NSURL *callBackURL;

@end








