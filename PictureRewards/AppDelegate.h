//
//  AppDelegate.h
//  PictureRewards
//
//  Created by Yisheng Jiang on 6/13/13.
//  Copyright (c) 2013 ragnus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OfferViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "StoreViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain) NSDictionary *config;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) OfferViewController *offerController;
@property (strong, nonatomic) StoreViewController *store;

@property (strong, nonatomic) FBSession *fbsession;
@property (strong, nonatomic) NSDictionary *fbuser;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (BOOL)getWritePermissions:(BOOL)allowLoginUI;
@property BOOL shouldReloadOffers;

extern NSString *const FBSessionStateChangedNotification;
extern NSString *const FBSessionWriterStateChangedNotification;
-(NSDictionary *)getFbUser;

@property (strong,nonatomic) NSString *extu;
@end
