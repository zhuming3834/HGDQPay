//
//  APViewController.m
//  HGDQPay
//
//  Created by zhuming on 16/4/8.
//  Copyright © 2016年 zhuming. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


/**
 *  支付宝支付
 *
 *  @param sender sender description
 */
- (IBAction)alipayBtnClick:(UIButton *)sender {
    
    [HGDQPay HGDQPayWithAlipay:[HGDQPay getProductData] AlipayCallBack:^(HGDQPayStatus payStatus,NSDictionary *resultDic) {
        switch (payStatus) {
            case AlipayStatusSuccess:
                NSLog(@"AlipayStatusSuccess");
                break;
            case AlipayStatusFail:
                NSLog(@"AlipayStatusFail");
                break;
            case AlipayStatusDoing:
                NSLog(@"AlipayStatusDoing");
                break;
            case AlipayStatusCancel:
                NSLog(@"AlipayStatusCancel");
                break;
            case AlipayStatusNetError:
                NSLog(@"AlipayStatusNetError");
                break;
            default:
                break;
        }
        NSLog(@"支付宝支付结果:resultDic = %@",resultDic);
    }];
}
/**
 *  银联支付
 *
 *  @param sender sender description
 */
- (IBAction)UpPayBtnClick:(UIButton *)sender {
    [HGDQPay HGDQWithUppay:self UpPayCallBack:^(HGDQPayStatus payStatus, NSDictionary *data) {
        switch (payStatus) {
            case UpPayStatusSuccess:
                NSLog(@"UpPayStatusSuccess");
                break;
            case UpPayStatusFail:
                NSLog(@"UpPayStatusFail");
                break;
            case UpPayStatusCancel:
                NSLog(@"UpPayStatusCancel");
                break;
            default:
                break;
        }
        NSLog(@"银联支付结果:data = %@",data);
    }];
}
/**
 *  微信支付
 *
 *  @param sender sender description
 */
- (IBAction)WXpayBtnClick:(UIButton *)sender {
    [HGDQPay HGDQPAyWithWXPayCallBack:^(HGDQPayStatus payStatus) {
        switch (payStatus) {
            case WXPayStatusSuccess:
                NSLog(@"WXPayStatusSuccess");
                break;
            case WXPayStatusErrCodeCommon:
                NSLog(@"WXPayStatusErrCodeCommon");
                break;
            case WXPayStatusErrCodeUserCancel:
                NSLog(@"WXPayStatusErrCodeUserCancel");
                break;
            case WXPayStatusErrCodeSentFail:
                NSLog(@"WXPayStatusErrCodeSentFail");
                break;
            case WXPayStatusErrCodeAuthDeny:
                NSLog(@"WXPayStatusErrCodeAuthDeny");
                break;
            case WXPayStatusErrCodeUnsupport:
                NSLog(@"WXPayStatusErrCodeUnsupport");
                break;
            default:
                break;
        }
    }];
}




@end
