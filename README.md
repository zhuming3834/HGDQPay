# HGDQPay
###前言
前些时一个朋友做了一个swift版本的Demo,继承了支付宝支付/银联支付和微信支付,但是Issues他怎么不搞个OC版本.后来后来我就自己写了一个<br>
[传送门](https://github.com/Chakery/CGYPay)<br>
###Demo的界面
[首页](https://github.com/zhuming3834/HGDQPay/blob/master/桌面.png)<br>
首页是三个按钮,由上至下依次是,支付宝/银联/微信.在测试中,我们只需要点击三个按钮就可以触发相应的事件.
在项目中使用第三方支付,支付宝需要产品信息,银联需要流水号,微信需要订单信息.实际就是他们需要什么我们传什么就是了.所以我们是可以把他<br>
们封装一下的,这样我们在项目中维护起来就比较方面了.<br>
###基本思路
1.在AppDelegate我们要做的就是注册微信支付和把回调的url取到<br>
我是怎么取回调的url的<br>

```OC
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
   [HGDQPay shareHGDQPay].callBackURL = url;
    return YES;
}
```
2.使用HGDQPay类的单例,利用单例传值的方式,把url传递出去,这样我们就可以在HGDQPay类里面处理这个url.<br>
怎么区分url是支付宝的回调还是银联的回调/微信的回调了?<br>
每个url的host不一样.<br>
```OC
/**
 *  callBackURL的set方法
 *
 *  @param callBackURL 银联支付成功回调
 */
- (void)setCallBackURL:(NSURL *)callBackURL{
    NSLog(@"host = %@",callBackURL.host);
    // 支付宝  不走这个回调
    if ([callBackURL.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:callBackURL standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
        }];
    }
    // 银联
    else if([callBackURL.host isEqualToString:@"uppayresult"]){
        [self upPay:callBackURL];
    }
    // 微信
    else if ([callBackURL.host isEqualToString:@"pay"]){
        id idSelf = self;
        [WXApi handleOpenURL:callBackURL delegate:idSelf];
    }
}
```
3.接下来要做的就是把每种支付的回调使用block传递到调用支付的地方供使用.这样我我们只需要一个方法就可以,完成支付和获取支付的回调.<br>
支付宝支付:<br>
```OC
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
```
支付宝支付相对银联和微信在给block赋值的时候要简单一点.
银联支付:<br>
```OC
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
```
首先我们需要在银联支付的回调中取到支付状态的数据,接下就是给我们申明的block赋值<br>
```OC
/**
 *  银联支付
 *
 *  @param url url description
 */
- (void)upPay:(NSURL *)url{
    [[UPPaymentControl defaultControl] handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
        
        HGDQPayStatus payStatus;
        // 支付成功
        if ([code isEqualToString:@"success"]) {
            payStatus = UpPayStatusSuccess;
        }
        // 支付失败
        else if ([code isEqualToString:@"fail"]){
            payStatus = UpPayStatusFail;
        }
        // 取消等其他错误
        else {
            payStatus = UpPayStatusCancel;
        }
        
        [HGDQPay shareHGDQPay].upPayCallBackBlock(payStatus,data);
    }];
}
```
```OC
/**
 *  银联支付
 *
 *  @param vc                 控制器
 *  @param upPayCallBackBlock 支付结果回调
 */
+ (void)HGDQWithUppay:(UIViewController *)vc UpPayCallBack:(UpPayCallBack)upPayCallBackBlock{
    HGDQPay *hg = [HGDQPay shareHGDQPay];
    hg.viewController = vc;
    [hg startNetWithURL:[NSURL URLWithString:kURL_TN_Normal]];
    hg.upPayCallBackBlock = ^(HGDQPayStatus payStatus, NSDictionary *data){
        upPayCallBackBlock(payStatus,data);
    };
}
```
微信支付:<br>
微信支付在给block赋值的过程和银联基本一致,只是微信支付只返回状态码.<br>
```OC
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
```
###遇见的坑
在集成支付宝的时候是遇见坑最多的,最后的做法是直接使用支付宝的Demo,把工程重新命名后就是我的了.😄<br>
银联和微信的集成基本没什么问题.按照文档操作,百度一下就不会错.<br>
但是在测试银联支付的时候出现了这个错误8100435<br>
集成银联的当天都是没有问题的,到了第二天再去运行Demo的时候就出现了问题<br>
[8100453](https://github.com/zhuming3834/HGDQPay/blob/master/8100453.png)<br>
后来运行银联给的Demo,也是这问题,换了银联提供的测试账号也是出现这个问题,最后去银联的论坛发帖了,但是还没有回复<br>
###总结
前后利用下班后的时间集成这三类支付,难度不大.<br>
1.明确我们的目的是什么;<br>
2.三类支付之间的异同点;<br>
3.三类支付需要什么参数;<br>
4.在调用支付类的时候怎样简单、直接;<br>
5.分块区分三类支付,便于查看和维护.<br>



















