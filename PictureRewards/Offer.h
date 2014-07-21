//
//  Offer.h
//  PictureRewards
//
//  Created by Yisheng Jiang on 6/23/13.
//  Copyright (c) 2013 ragnus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Offer : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *storeId;

@property (nonatomic, strong) NSString *points;
@property (nonatomic, strong) NSString *refId;
@property (nonatomic, strong) NSString *hint;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) NSString *cmd;
@property (nonatomic, strong) UIImage *icon;
@property int canUpload;

-(id)initFromNSDictionary:(NSDictionary *)dict;
@end
