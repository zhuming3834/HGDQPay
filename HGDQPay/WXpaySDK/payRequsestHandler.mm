
#import <Foundation/Foundation.h>
#import "payRequsestHandler.h"
#import "TenpayUtil.h"
/*
 服务器请求操作处理
 */
@implementation payRequsestHandler

//初始化函数
-(BOOL) init:(NSString *)app_id app_secret:(NSString *)app_secret partner_key:(NSString *)partner_key app_key:(NSString *)app_key;
{
    //初始构造函数
    tokenUrl    = @"https://api.weixin.qq.com/cgi-bin/token";
    gateUrl     = @"https://api.weixin.qq.com/pay/genprepay";
    notifyUrl	= @"https://gw.tenpay.com/gateway/simpleverifynotifyid.xml";
    if (debugInfo == nil){
        debugInfo   = [NSMutableString string];
    }
    appid       = [NSString stringWithString:app_id];
    appsecret   = [NSString stringWithString:app_secret];
    partnerkey  = [NSString stringWithString:partner_key];
    appkey      = [NSString stringWithString:app_key];
    token_time  = 0;
    [debugInfo setString:@""];
    return YES;
}
//设置商户密钥
-(void) setKey:(NSString *)key
{
    partnerkey  = [NSString stringWithString:key];
}
//获取debug信息
-(NSString*) getDebugifo
{
    NSString    *res = [NSString stringWithString:debugInfo];
    [debugInfo setString:@""];
    return res;
}
//获取最后服务返回错误代码
-(long) getLasterrCode
{
    return last_errcode;
}
//获取TOKEN，一天最多获取200次，需要所有用户共享值
-(NSString *) GetToken
{
    NSString        *url;
    NSDictionary    *resParams;
    url         = [NSString stringWithFormat:@"%@?grant_type=client_credential&appid=%@&secret=%@", tokenUrl, appid, appsecret];
    //发送http请求
    resParams   = [TenpayUtil httpSendJson:url method:@"GET" data:@""];
    
    //判断返回，获取access_token参数
    Token       = [resParams objectForKey:@"access_token"];
    if ( Token == nil ){
        last_errcode = [[resParams objectForKey:@"retcode"] integerValue];
        token_time  = 0;
    }
    
    //输出Debug Info
    [debugInfo appendFormat:@"Get Token url:%@\n", url];
    [debugInfo appendFormat:@"Get Token json:%@\n", [TenpayUtil toJson:resParams]];
    
    return Token;
}

//创建package签名
-(NSString*) createMd5Sign:(NSMutableDictionary*)dict
{
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (   ![[dict objectForKey:categoryId] isEqualToString:@""]
            && ![[dict objectForKey:categoryId] isEqualToString:@"sign"]
            && ![[dict objectForKey:categoryId] isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
        
    }
    //添加key字段
    [contentString appendFormat:@"key=%@", partnerkey];
    //得到MD5 sign签名
    NSString *md5Sign =[TenpayUtil md5:contentString];
    
    //输出Debug Info
    [debugInfo appendFormat:@"MD5签名字符串：\n%@\n",contentString];

    return md5Sign;
}

//获取package带参数的签名包
-(NSString *)genPackage:(NSMutableDictionary*)packageParams
{
    NSString *sign;
    NSMutableString *reqPars=[NSMutableString string];
    //生成签名
    sign        = [self createMd5Sign:packageParams];

    NSStringEncoding enc = NSUTF8StringEncoding;
    //生成urlendcode的package
    NSArray *keys = [packageParams allKeys];
    for (NSString *categoryId in keys) {
        [reqPars appendFormat:@"%@=%@&", categoryId, [[packageParams objectForKey:categoryId] stringByAddingPercentEscapesUsingEncoding:enc]];
    }
    [reqPars appendFormat:@"sign=%@", sign];
    
    return [NSString stringWithString:reqPars];
}
//创建签名SHA1
-(NSString *)createSHA1Sign:(NSMutableDictionary *)signParams
{
    NSMutableString *signString=[NSMutableString string];
    //按字母顺序排序
    NSArray *keys = [signParams allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if ( [signString length] > 0) {
            [signString appendString:@"&"];
        }
        [signString appendFormat:@"%@=%@", categoryId, [signParams objectForKey:categoryId]];
        
    }
    //得到sha1 sign签名
    NSString *sign =[TenpayUtil sha1:signString];
    
    //输出Debug Info
    [debugInfo appendFormat:@"SHA1签名字符串：\n%@\n",signString];

    return sign;
}
//提交预支付
-(NSString *)sendPrepay:(NSMutableDictionary *)prePayParams
{
    NSString *prepayid = nil;
    //获取提交支付json
    NSString *json      = [TenpayUtil toJson:prePayParams];
    NSString *url       = [NSString stringWithFormat:@"%@?access_token=%@", gateUrl, Token];
    //发送请求post json数据
    NSDictionary *resParams = [TenpayUtil httpSendJson:url method:@"POST" data:json];
    //判断返回
    long retcode   = [[resParams objectForKey:@"errcode"] longValue];
    if ( retcode == 0) {//返回成功
        prepayid    = [resParams objectForKey:@"prepayid"];
    }
    last_errcode = retcode;

    //输出Debug Info
    [debugInfo appendFormat:@"send prePay url:%@\n", url];
    [debugInfo appendFormat:@"send prePay body json:%@\n", json];
    NSError *error = nil;
    //ios5.0 自带的NSJSONSerialization序列化
    //记录返回的json
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resParams options:NSJSONWritingPrettyPrinted error:&error];
    [debugInfo appendFormat:@"send prePay res json:%@\n", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];

    return prepayid;
}

@end