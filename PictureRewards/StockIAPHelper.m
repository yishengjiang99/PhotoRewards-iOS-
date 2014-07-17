//
//  StockIAPHelper.m
//  stockalerts
//
//  Created by Yisheng Jiang on 4/28/13.
//  Copyright (c) 2013 ragnus. All rights reserved.
//

#import "StockIAPHelper.h"

@implementation StockIAPHelper
@synthesize products;

+ (StockIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static StockIAPHelper * sharedInstance;

    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.ragnus.slide.20stars",
                                      @"com.ragnus.slide.10stars",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

+ (SKProduct *) get20Star
{
    StockIAPHelper *helper = [self sharedInstance];
    for(SKProduct *p in helper.products){
        if([p.productIdentifier isEqualToString:@"com.ragnus.slide.20stars"]){
            return p;
        }
    }
    return nil;
}

@end
