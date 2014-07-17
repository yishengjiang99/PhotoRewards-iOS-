//
//  Util.h
//  vp
//
//  Created by Yisheng Jiang on 4/8/13.
//  Copyright (c) 2013 Yisheng Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^HttpRetBlock)(NSDictionary *jsonResponse);

@interface Util : NSObject
+ (NSString *) httpget: (NSString *)url;
+ (NSDictionary *) getJson: (NSString *)url;
+ (NSArray *) getJsonArray: (NSString *)url;
+ (void) ajaxArray: (NSString *)url callback:(void (^) (NSArray *))completion;
+ (void) ajax: (NSString *)url callback:(void (^) (NSDictionary *))completion;
+ (NSDictionary *) getConfigs;
void userMeta(NSString *m);
NSObject *getUserDefault(NSString *key);
void setUserDefault(NSString *key,NSObject *obj);
void alert(NSString *msg);
NSString *getMacAddress();
NSString *getIdfa();
NSInteger getUserPoints();
void setUid(int uid);
int getUid();
void httpPostShowPopup(NSString *post, NSString *url,HttpRetBlock callback);
void httpPostAsync(NSString* post, NSString* url);
int getXp();
NSString *getUsername();
NSString *getAppName();
NSDictionary *json_decode(NSString *str);

NSDictionary *httpPost(NSString* post, NSString* url);
NSString *getConfigVal(NSString *key);
NSString *urlencode(NSString *input);
NSString *json_encode(NSDictionary *dictionary);
@end
