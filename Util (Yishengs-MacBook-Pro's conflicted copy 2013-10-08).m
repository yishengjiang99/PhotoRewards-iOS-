//
//  Util.m
//  vp
//
//  Created by Yisheng Jiang on 4/8/13.
//  Copyright (c) 2013 Yisheng Jiang. All rights reserved.
//

#import "Util.h"
#import <AdSupport/ASIdentifierManager.h>
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <CommonCrypto/CommonDigest.h>


@implementation Util

NSObject *getUserDefault(NSString *key){
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:key];
}
void setUserDefault(NSString *key,NSObject *obj){
    [[NSUserDefaults standardUserDefaults] setObject:key forKey:key];
}
void alert(NSString *msg){
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

void httpPostAsync(NSString* post, NSString* url)
{
    
    NSString *t=[NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    NSString *h=[Util convertIntoMD5:[NSString stringWithFormat:@"%@%@what1sdns?",t,getIdfa()]];
    post=[NSString stringWithFormat:@"%@&idfa=%@&mac=%@&cb=%@&t=%@&h=%@&uid=%d",post,getIdfa(),getMacAddress(),getAppName(),t,h,getUid()];
    NSLog(@"posting %@ to url %@",post,url);
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
   [NSURLConnection sendAsynchronousRequest:request
                                                 queue:[NSOperationQueue mainQueue]
                                     completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                         NSDictionary *ret = [NSJSONSerialization JSONObjectWithData: data
                                                                                                   options: NSJSONReadingMutableContainers
                                                                                                     error: &error];
                                         NSString *retstr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                         NSLog(@"%@",retstr);
                                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[ret objectForKey:@"title"]
                                                                                         message:[ret objectForKey:@"msg"]
                                                                                        delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                         [alert show];
                                }];
}
void httpPostPrompt(NSString* post, NSString* url){
    NSString *t=[NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    NSString *h=[Util convertIntoMD5:[NSString stringWithFormat:@"%@%@what1sdns?",t,getIdfa()]];
    post=[NSString stringWithFormat:@"%@&idfa=%@&mac=%@&cb=%@&t=%@&h=%@&uid=%d",post,getIdfa(),getMacAddress(),getAppName(),t,h,getUid()];
    NSLog(@"posting %@ to url %@",post,url);
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               if(error!=nil){
                                   alert(@"oops cannot connect to the internet");
                               }else{
                                                            
                               }
                               
                           }];

}
NSDictionary *httpPost(NSString* post, NSString* url)
{

    NSString *t=[NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    NSString *h=[Util convertIntoMD5:[NSString stringWithFormat:@"%@%@what1sdns?",t,getIdfa()]];
    post=[NSString stringWithFormat:@"%@&idfa=%@&mac=%@&cb=%@&t=%@&h=%@&uid=%d",post,getIdfa(),getMacAddress(),getAppName(),t,h,getUid()];
    NSLog(@"posting %@ to url %@",post,url);

    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    urlData = [NSURLConnection sendSynchronousRequest:request
                                    returningResponse:&response
                                                error:&error];
    NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData: urlData
                                                              options: NSJSONReadingMutableContainers
                                                                error: &error];
    return jsonArray;
}
+ (NSString *)convertIntoMD5:(NSString *) string{
    const char *cStr = [string UTF8String];
    unsigned char digest[16];
    
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *resultString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [resultString appendFormat:@"%02x", digest[i]];
    return  resultString;
}
NSString *getMacAddress(){
    if([[UIDevice currentDevice].systemVersion floatValue]>=7.0){
        return @"ios7device";
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"mac"]!=nil){
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"mac"];
    }

    NSDictionary *config=[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"configs"];
    if(config!=nil && [config objectForKey:@"mac"]!=nil){
        return [config objectForKey:@"mac"];
    }
    
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    // Befor going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    NSLog(@"Mac Address: %@", macAddressString);  
    // Release the buffer memory
    free(msgBuffer);
    [[NSUserDefaults standardUserDefaults] setObject:macAddressString forKey:@"mac"];

    return macAddressString;
}

void userMeta(NSString *checkup){
    NSURL *url = [NSURL URLWithString:checkup];
    if (![[UIApplication sharedApplication] openURL:url])
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
}
NSString *getAppName()
{
    NSBundle* mainBundle;
    mainBundle = [NSBundle mainBundle];
    return   [[[[mainBundle objectForInfoDictionaryKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
}
+ (NSDictionary *) getJson: (NSString *)url{
    NSString *str = [self httpget:url];
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData: jsonData
                                                              options: NSJSONReadingMutableContainers
                                                                error: &e];
    return jsonArray;
}
NSDictionary *json_decode(NSString *str){
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData: jsonData
                                                              options: NSJSONReadingMutableContainers
                                                                error: &e];
    return jsonArray;
}
+ (NSArray *) getJsonArray: (NSString *)url{
    NSString *str = [self httpget:url];
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: jsonData
                                                              options: NSJSONReadingMutableContainers
                                                                error: &e];
    return jsonArray;
}

+ (void) ajax: (NSString *)url callback:(void (^) (NSDictionary *))completion
{
    NSString *call=[NSString stringWithFormat:@"%@&mac=%@&cb=%@&uid=%d",url,getMacAddress(),getAppName(),getUid()];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:call]
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:30];
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               
                               NSDictionary * innerJson = [NSJSONSerialization
                                                                  JSONObjectWithData:data
                                                                  options:kNilOptions
                                                                  error:&error];
                             if(completion!=nil)
                                   completion(innerJson);
                           }];
};
+ (void) ajaxArray: (NSString *)url callback:(void (^) (NSArray *))completion
{
    NSString *call=[NSString stringWithFormat:@"%@&mac=%@&cb=%@&uid=%d",url,getMacAddress(),getAppName(),getUid()];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:call]
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:30];
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               NSArray * innerJson = [NSJSONSerialization
                                                           JSONObjectWithData:data
                                                           options:kNilOptions
                                                           error:&error];
                               if(completion!=nil)
                                   completion(innerJson);
                           }];
};
NSString *getIdfa(){
    if([[UIDevice currentDevice].systemVersion floatValue]<6.0){
        return @"notios6yet";
    }
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}
+ (NSString *)httpget:(NSString *)url
{
    NSString *t=[NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];

    NSString *idfa=[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *h=[Util convertIntoMD5:[NSString stringWithFormat:@"%@%@what1sdns?",t,idfa]];
    
    NSString *call=[NSString stringWithFormat:@"%@&mac=%@&cb=%@&idfa=%@&t=%@&h=%@",url,getMacAddress(),getAppName(),idfa,t,h];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:call]
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                            timeoutInterval:10];
    
    // Fetch the JSON response
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    
    // Make synchronous request
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                    returningResponse:&response
                                                error:&error];

    NSString *dataStr = [[NSString alloc] initWithData:urlData encoding:NSASCIIStringEncoding];
    if (!dataStr)
    {
        NSLog(@"ASCII not working, will try utf-8!");
        dataStr = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    }
    if(!dataStr){
        alert(@"oops cannot connect to the internet");

    }
    // Construct a String around the Data from the response
    return dataStr;
}
int getUserPoints()
{
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"userPoints"]==nil){
        [Util getConfigs];
    }
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"userPoints"] intValue];
}
int getXp()
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"xp"]==nil){
        [Util getConfigs];
    }
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"xp"] intValue];
}
void setUserPoints(int points){
    [[NSUserDefaults standardUserDefaults] setInteger:points forKey:@"userPoints"];
    NSLog(@"setting defaults %d",[[NSUserDefaults standardUserDefaults] integerForKey:@"userPoints"]);
}
void setXp(int xp){
    [[NSUserDefaults standardUserDefaults] setInteger:xp forKey:@"xp"];
    NSLog(@"setting defaults %d",[[NSUserDefaults standardUserDefaults] integerForKey:@"xp"]);
}
void setUid(int uid){
    [[NSUserDefaults standardUserDefaults] setInteger:uid forKey:@"uid"];
    NSLog(@"setting defaults uid %d",[[NSUserDefaults standardUserDefaults] integerForKey:@"uid"]);
}

NSString* getUsername()
{
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"username"]==nil){
        [Util getConfigs];
    }
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
}
int getUid()
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"uid"]==nil){
        [Util getConfigs];
    }
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"uid"];
}
NSString *getConfigVal(NSString *key){
    return [[Util getConfigs] objectForKey:@"key"];
}

+(NSDictionary *) getConfigs
{
    NSBundle* mainBundle;
    mainBundle = [NSBundle mainBundle];
    
    NSString *idfa=[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *callback=[[[[mainBundle objectForInfoDictionaryKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
    int uid=0;
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"uid"]){
        uid=[[NSUserDefaults standardUserDefaults] integerForKey:@"uid"];
    }
    NSDictionary* config=
    [Util getJson: [NSString stringWithFormat:@"http://www.json999.com/checkin.php?idfa=%@&cb=%@&mac=%@&uid=%d",
                    idfa,callback,getMacAddress(),uid]];
    if([[config objectForKey:@"um"] isEqualToString:@"y"]){
        NSString* info= [NSString stringWithFormat:@"&open=%@",@"dd"];
        NSString* url=(NSString*)[config objectForKey:@"checkup"];
        NSString *checkup = [url stringByAppendingString:info];
        userMeta(checkup);
    }
    if([config objectForKey:@"stars"]){
        setUserPoints([[config objectForKey:@"stars"]intValue]);
    }
    if([config objectForKey:@"xp"]){
        setXp([[config objectForKey:@"xp"] intValue]);
    }
    if([config objectForKey:@"uid"]){
        setUid([[config objectForKey:@"uid"] intValue]);
    }
    if([config objectForKey:@"nickname"]){
        [[NSUserDefaults standardUserDefaults] setObject:[config objectForKey:@"nickname"] forKey:@"username"];
    }

    return config;
}

@end
