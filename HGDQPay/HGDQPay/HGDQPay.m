//
//  HGDQPay.m
//  HGDQPay
//
//  Created by zhuming on 16/4/8.
//  Copyright © 2016年 zhuming. All rights reserved.
//

#import "HGDQPay.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>

#define ALIPAY_PARTNER     @"2088801142678498"
#define ALIPAY_SELLER      @"lisa@newv.com.cn"
#define ALIPAY_PRIVATEKEY    @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAKADO4HcskWfaWCSLSdCqPMWymC2m3paALX6jVjpz/eIFajO/hbOec1IZB8yLImClKTyke9kGy2IwVSt1QNugxx/u6lUEoE6LeO2LKR37YnopdgKxXVITX5Ymn0yJdI3WWFiqfcFXzAHq3D5Il9zfTVRyOTHfRTC05EML7F1hV/1AgMBAAECgYBeUKlxqQk3OngdYOvWeVcmOae+C8RnAMfse6t23hIkAAVsQ93GyZtHocTKEoPn5Z0CAKx+I05Vr4btB61H4YrLga89mbXjP+YoYejNRVoZBjEpkf7NgMh7ScQIhx3hHk2IuCO6syz/cR5zNWpK47gMSWtS3/xoWjX9aicKcsTNgQJBANQd3qZZeo1XTi4qugp8AAvCwsy4IGM1LztahKIll+XMTLHxF6e5WTEQTuRe6fQzfbP7emNX3aAwqLRhgez+hmECQQDBHdOGsuqGQkes1VO9C9zEOegjEgv+Dzxq3Wj8AeVzO4idUJ2Gl6IV4EWflev9kZGX6CXFjJ3RngM6dsoejpoVAkEAj36Rc7mOhXVtZx/ycUtHgK1FuNZK2rJM/HsUxNhntMaLj8kIdqeVpfJhXG61GEWJISvbtL7pKAgi6LwZ9+iLoQJAWO5HTqxt284B+9FxcolX7PVNtXjGFQUnKX80rXiiFWLBEtDg+e4yMijJZyg/ONIkXfQGEOckdjdx/SZfBZtd0QJAPL0+YBO5Bvbb4/VRIeoww+4pAd46f9Ews0a0gYjOrTL+tNomvVet92HgJJQIEIoLbqh4NTDJDFgC8rmh7UBeSg=="


// 银联支付 获取测试流水号的地址
#define kURL_TN_Normal     @"http://101.231.204.84:8091/sim/getacptn"
#define kURL_TN_Configure  @"http://101.231.204.84:8091/sim/app.jsp?user=123456789"

// 微信支付
#define WXPARTNER_ID     @"1900000109"
#define WXPARTNER_KEY    @"8934e7d15453e97507ef794cf7b0519d"
#define WXAPPI_ID        @"wxd930ea5d5a258f4f"
#define WXAPP_SECRET     @"db426a9829e4b49a0dcac7b4162da6b6"
#define WXAPP_KEY        @"L8LrMqqeGRxST5reouB0K66CaYAWpqhAVsq7ggKkxHCOastWksvuX1uvmvQclxaHoYd3ElNBrNO2DHnnzgfVG9Qs473M3DTOZug5er46FhuGofumV8H2FVR9qkjSlC5K"


@interface HGDQPay ()

/**
 *  支付宝支付的订单
 */
@property (nonatomic,strong)Product *product;
/**
 *  银联支付的回调block
 */
@property (nonatomic,copy)UpPayCallBack upPayCallBackBlock;

/**
 *  微信支付的回调block
 */
@property (nonatomic,copy)WXpayCallBack wxPayCallBackBlock;
/**
 *  网络请求的数据流
 */
@property (nonatomic,strong)NSMutableData *responseData;

@property (nonatomic,assign)enum WXScene scene;
@property (nonatomic,copy)NSString *Token;
@property (nonatomic,assign)long token_time;

@end

@implementation HGDQPay

/**
 *  支付单例
 *
 *  @return return value description
 */
+ (HGDQPay *)shareHGDQPay{
    static HGDQPay *hgdqPay = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        hgdqPay = [[self alloc] init];
    });
    return hgdqPay;
}
#pragma mark - 支付宝支付
/**
 *  支付宝支付
 *
 *  @param product             产品数据模型
 *  @param alipayCallBackBlock 支付回调
 */
+ (void)HGDQPayWithAlipay:(Product *)product AlipayCallBack:(AlipayCallBack  )alipayCallBackBlock{
    HGDQPay *hgdqPay = [[HGDQPay alloc] init];
    hgdqPay.product = product;
    
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = ALIPAY_PARTNER;
    NSString *seller = ALIPAY_SELLER;
    NSString *privateKey = ALIPAY_PRIVATEKEY;
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = hgdqPay.product.orderId; //订单ID（由商家自行制定）
    order.productName = hgdqPay.product.subject; //商品标题
    order.productDescription = hgdqPay.product.body; //商品描述
    order.amount = [NSString stringWithFormat:@"%.2f",hgdqPay.product.price]; //商品价格
    order.notifyURL =  @"http://www.xxx.com"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"HGDQPay";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSString *resultStatusStr = [NSString stringWithFormat:@"%@",resultDic[@"resultStatus"]];
            int resultStatus = resultStatusStr.intValue;
            HGDQPayStatus payStatus;
            switch (resultStatus) {
                case 9000:
                    payStatus = AlipayStatusSuccess;
                    break;
                case 8000:
                    payStatus = AlipayStatusDoing;
                    break;
                case 4000:
                    payStatus = AlipayStatusFail;
                    break;
                case 6001:
                    payStatus = AlipayStatusCancel;
                    break;
                case 6002:
                    payStatus = AlipayStatusNetError;
                    break;
                default: payStatus = 2016;
                    break;
            }
            alipayCallBackBlock(payStatus,resultDic);
        }];
    }
}

/**
 *  生成随机的订单号
 *
 *  @return 订单号
 */
+ (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    NSLog(@"订单号 = %@",resultStr);
    return resultStr;
}
/**
 *  生成随机的订单信息
 *
 *  @return 订单对象
 */
+ (Product *)getProductData{
    Product *product = [[Product alloc] init];
    product.subject = @"HGDQ支付宝支付";
    product.body = @"HGDQ支付宝支付2016.04.18";
    product.orderId = [self generateTradeNO];
    product.price = 0.01f;
    return product;
}

#pragma mark - 银联支付
/*
 招商银行借记卡：6226090000000048
 手机号：18100000000
 密码：111101
 短信验证码：123456（先点获取验证码之后再输入）
 证件类型：01身份证
 证件号：510265790128303
 姓名：张三
 
 华夏银行贷记卡：6226388000000095
 手机号：18100000000
 CVN2：248
 有效期：1219
 短信验证码：123456（先点获取验证码之后再输入）
 证件类型：01身份证
 证件号：510265790128303
 姓名：张三
 */

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

/**
 *  发送获取银联流水号的请求
 *
 *  @param url 请求地址
 */
- (void)startNetWithURL:(NSURL *)url
{
    NSURLRequest * urlRequest=[NSURLRequest requestWithURL:url];
    NSURLConnection* urlConn = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    [urlConn start];
}

#pragma mark - connection

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse*)response
{
    NSHTTPURLResponse* rsp = (NSHTTPURLResponse*)response;
    NSInteger code = [rsp statusCode];
    if (code != 200)
    {
        NSLog(@"网络错误");
        [connection cancel];
    }else{
        self.responseData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString* tn = [[NSMutableString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    if (tn != nil && tn.length > 0)
    {
        
        NSLog(@"tn=%@",tn);
        // 发起银联支付
        [[UPPaymentControl defaultControl] startPay:tn fromScheme:@"HGDQPay" mode:@"01" viewController:self.viewController];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"网络错误 = %@",error);
}

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
#pragma mark - 微信支付
/**
 *  微信支付
 *
 *  @param wxPayCallBackBlock 支付回调
 */
+ (void)HGDQPAyWithWXPayCallBack:(WXpayCallBack)wxPayCallBackBlock{
    HGDQPay *hg = [HGDQPay shareHGDQPay];
    hg.scene = WXSceneSession;
    hg.token_time = 0;
    [hg wxpay];
    hg.wxPayCallBackBlock = ^(HGDQPayStatus payStatus){
        wxPayCallBackBlock(payStatus);
    };

}

//微信支付
- (void)wxpay
{
    //商户号
    NSString *PARTNER_ID    = WXPARTNER_ID;
    //商户密钥
    NSString *PARTNER_KEY   = WXPARTNER_KEY;
    //APPID
    NSString *APPI_ID       = WXAPPI_ID;
    //appsecret
    NSString *APP_SECRET	= WXAPP_SECRET;
    //支付密钥
    NSString *APP_KEY       = WXAPP_KEY;
    
    //支付结果回调页面
    NSString *NOTIFY_URL    = @"http://localhost/pay/wx/notify_url.asp";
    //订单标题
    NSString *ORDER_NAME    = @"iOS客户端签名支付 测试";
    //订单金额,单位（分）
    NSString *ORDER_PRICE   = @"1";
    
    //创建支付签名对象
    payRequsestHandler *req = [payRequsestHandler alloc];
    //初始化支付签名对象
    [req init:APPI_ID app_secret:APP_SECRET partner_key:PARTNER_KEY app_key:APP_KEY];
    
    //判断Token过期时间，10分钟内不重复获取,测试帐号多个使用，可能造成其他地方获取后不能用，需要即时获取
    time_t  now;
    time(&now);
    //if ( (now - token_time) > 0 )//非测试帐号调试请启用该条件判断
    {
        //获取Token
        self.Token                   = [req GetToken];
        //设置Token有效期为10分钟
        self.token_time              = now + 600;
        //日志输出
        NSLog(@"获取Token： %@\n",[req getDebugifo]);
    }
    if (self.Token != nil){
        //================================
        //预付单参数订单设置
        //================================
        NSMutableDictionary *packageParams = [NSMutableDictionary dictionary];
        [packageParams setObject: @"WX" forKey:@"bank_type"];
        [packageParams setObject: ORDER_NAME forKey:@"body"];
        [packageParams setObject: @"1" forKey:@"fee_type"];
        [packageParams setObject: @"UTF-8" forKey:@"input_charset"];
        [packageParams setObject: NOTIFY_URL forKey:@"notify_url"];
        [packageParams setObject: [NSString stringWithFormat:@"%ld",time(0)]        forKey:@"out_trade_no"];
        [packageParams setObject: PARTNER_ID forKey:@"partner"];
        [packageParams setObject: @"196.168.1.1" forKey:@"spbill_create_ip"];
        [packageParams setObject: ORDER_PRICE forKey:@"total_fee"];
        
        NSString    *package, *time_stamp, *nonce_str, *traceid;
        //获取package包
        package		= [req genPackage:packageParams];
        
        //输出debug info
        NSString *debug     = [req getDebugifo];
        NSLog(@"gen package: %@\n",package);
        NSLog(@"生成package: %@\n",debug);
        
        //设置支付参数
        time_stamp  = [NSString stringWithFormat:@"%ld", now];
        nonce_str	= [TenpayUtil md5:time_stamp];
        traceid		= @"mytestid_001";
        NSMutableDictionary *prePayParams = [NSMutableDictionary dictionary];
        [prePayParams setObject: APPI_ID forKey:@"appid"];
        [prePayParams setObject: APP_KEY forKey:@"appkey"];
        [prePayParams setObject: nonce_str forKey:@"noncestr"];
        [prePayParams setObject: package forKey:@"package"];
        [prePayParams setObject: time_stamp forKey:@"timestamp"];
        [prePayParams setObject: traceid forKey:@"traceid"];
        
        //生成支付签名
        NSString    *sign;
        sign		= [req createSHA1Sign:prePayParams];
        //增加非参与签名的额外参数
        [prePayParams setObject: @"sha1" forKey:@"sign_method"];
        [prePayParams setObject: sign forKey:@"app_signature"];
        
        //获取prepayId
        NSString *prePayid;
        prePayid            = [req sendPrepay:prePayParams];
        //输出debug info
        debug               = [req getDebugifo];
        NSLog(@"提交预付单： %@\n",debug);
        
        if ( prePayid != nil) {
            //重新按提交格式组包，微信客户端5.0.3以前版本只支持package=Sign=***格式，须考虑升级后支持携带package具体参数的情况
            //package       = [NSString stringWithFormat:@"Sign=%@",package];
            package         = @"Sign=WXPay";
            //签名参数列表
            NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
            [signParams setObject: APPI_ID forKey:@"appid"];
            [signParams setObject: APP_KEY forKey:@"appkey"];
            [signParams setObject: nonce_str forKey:@"noncestr"];
            [signParams setObject: package forKey:@"package"];
            [signParams setObject: PARTNER_ID forKey:@"partnerid"];
            [signParams setObject: time_stamp forKey:@"timestamp"];
            [signParams setObject: prePayid forKey:@"prepayid"];
            
            //生成签名
            sign		= [req createSHA1Sign:signParams];
            
            //输出debug info
            debug     = [req getDebugifo];
            NSLog(@"调起支付签名： %@\n",debug);
            
            //调起微信支付
            PayReq* req = [[PayReq alloc] init];
            req.openID      = APPI_ID;
            req.partnerId   = PARTNER_ID;
            req.prepayId    = prePayid;
            req.nonceStr    = nonce_str;
            req.timeStamp   = now;
            req.package     = package;
            req.sign        = sign;
            [WXApi safeSendReq:req];
        }else{
            /*long errcode = [req getLasterrCode];
             if ( errcode == 40001 )
             {//Token实效，重新获取
             Token                   = [req GetToken];
             token_time              = now + 600;
             NSLog(@"获取Token： %@\n",[req getDebugifo]);
             };*/
            NSLog(@"获取prepayid失败\n");
            [self alert:@"提示信息" msg:debug];
        }
    }else{
        NSLog(@"获取Token失败\n");
        [self alert:@"提示信息" msg:@"获取Token失败"];
    }
    
}
/**
 *  微信支付成功回调
 *
 *  @param resp resp description
 */
- (void)onResp:(BaseResp *)resp {
    HGDQPayStatus payStatus;
    switch (resp.errCode) {
        case WXSuccess:
            payStatus = WXPayStatusSuccess;
            break;
        case WXErrCodeCommon:
            payStatus = WXPayStatusErrCodeCommon;
            break;
        case WXErrCodeUserCancel:
            payStatus = WXPayStatusErrCodeUserCancel;
            break;
        case WXErrCodeSentFail:
            payStatus = WXPayStatusErrCodeSentFail;
            break;
        case WXErrCodeAuthDeny:
            payStatus = WXPayStatusErrCodeAuthDeny;
            break;
        case WXErrCodeUnsupport:
            payStatus = WXPayStatusErrCodeUnsupport;
            break;
        default:
            payStatus = 2016;
            break;
    }
    [HGDQPay shareHGDQPay].wxPayCallBackBlock(payStatus);
}

#pragma mark - setCallBackURL
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


//客户端提示信息
- (void)alert:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alter show];
}




@end
