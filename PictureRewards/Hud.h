//
//  Hud.h
//  PictureRewards
//
//  Created by Yisheng Jiang on 6/23/13.
//  Copyright (c) 2013 ragnus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Hud :NSObject
+(Hud *) getK: (UIViewController *)viewController;
+(void) update;
@property (strong, nonatomic) UIBarButtonItem *btn;
@property (strong, nonatomic) UIViewController* controller;
@property (strong, nonatomic) NSString* label;

@end
