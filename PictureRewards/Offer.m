//
//  Offer.m
//  PictureRewards
//
//  Created by Yisheng Jiang on 6/23/13.
//  Copyright (c) 2013 ragnus. All rights reserved.
//

#import "Offer.h"

@implementation Offer

-(id)initFromNSDictionary:(NSDictionary *)dict{
    if(self=[super init]){
		
		
        self.name=dict[@"Name"];
        self.points=dict[@"Amount"];
        if([dict objectForKey:@"RedirectURL"]){
            self.url=dict[@"RedirectURL"];
        }
        self.canUpload=[[dict objectForKey:@"canUpload"] intValue];
        self.hint=[dict objectForKey:@"hint"];
        self.storeId=[dict objectForKey:@"StoreID"];
        self.refId=[dict objectForKey:@"refId"];
        self.type=[dict objectForKey:@"OfferType"];
        self.action=[dict objectForKey:@"Action"];
        self.category=[dict objectForKey:@"category"];
        self.imageUrl=[dict objectForKey:@"IconURL"];
		if(dict[@"cmd"]) self.cmd=dict[@"cmd"];
		
		self.imageUrl=[dict objectForKey:@"IconURL"];

        if([self.imageUrl isEqualToString:@"localt"]){
            self.icon=[UIImage imageNamed:self.category];
            if(!self.icon){
                self.icon=[UIImage imageNamed:@"camera"];
            }
        }
    }
    return self;
}

@end
