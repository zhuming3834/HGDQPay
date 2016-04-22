

#import <Foundation/Foundation.h>
#import "WXUtil.h"
/*
 //微信支付服务器签名支付请求请求类
 //============================================================================
 //api说明：
 -(BOOL) init:(NSString *)app_id app_secret:(NSString *)app_secret partner_key:(NSString *)partner_key app_key:(NSString *)app_key;
 //初始化函数，默认给一些参数赋值，如cmdno,date等。
 -(void) setKey:(NSString *)key;'设置商户密钥
 -(NSString *) GetToken;获取Token
 -(NSString*) createMd5Sign:(NSMutableDictionary*)dict;字典生成Md5签名
 -(NSString *) genPackage:(NSMutableDictionary*)packageParams;获取package包
 -(NSString *) createSHA1Sign:(NSMutableDictionary *)signParams;创建签名SHA1
 -(NSString *) sendPrepay:(NSMutableDictionary *);提交预支付
 -(NSString *) getDebugifo;获取debug信息
 -(long) getLasterrCode;获取最后返回的错误代码
 //============================================================================
 */
@interface payRequsestHandler : NSObject{
    //Token获取网关地址
	NSString *tokenUrl;
	//预支付网关url地址
    NSString *gateUrl;
	//查询支付通知网关URL
    NSString *notifyUrl;
	//商户参数
    NSString *appid, *partnerkey, *appsecret, *appkey;
	//Token
    NSString *Token;
    //Token alive time
    int      token_time;
    //lash_errcode;
    long     last_errcode;
	//debug信息
    NSMutableString *debugInfo;
}
//初始化函数
-(BOOL) init:(NSString *)app_id app_secret:(NSString *)app_secret partner_key:(NSString *)partner_key app_key:(NSString *)app_key;
-(NSString *) getDebugifo;
-(long) getLasterrCode;
//设置商户密钥
-(void) setKey:(NSString *)key;
//获取Token
-(NSString *) GetToken;
//创建package签名
-(NSString*) createMd5Sign:(NSMutableDictionary*)dict;
//获取package带参数的签名包
-(NSString *)genPackage:(NSMutableDictionary*)packageParams;
//创建签名SHA1
-(NSString *)createSHA1Sign:(NSMutableDictionary *)signParams;
//提交预支付
-(NSString *)sendPrepay:(NSMutableDictionary *)prePayParams;

@end