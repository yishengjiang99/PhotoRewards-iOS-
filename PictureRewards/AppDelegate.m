//
//  AppDelegate.m
//  PictureRewards
//
//  Created by Yisheng Jiang on 6/13/13.
//  Copyright (c) 2013 ragnus. All rights reserved.
//

#import "AppDelegate.h"


#import "OfferViewController.h"
#import "RedeemViewController.h"
#import "StoreViewController.h"
#import "RequestViewController.h"
#import <FiksuSDK/FiksuSDK.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Hud.h"
#import <MobileAppTracker/MobileAppTracker.h>

@implementation AppDelegate
@synthesize offerController,config,fbsession,fbuser,store,extu,shouldReloadOffers;
NSString *const FBSessionStateChangedNotification =@"com.ragnus.fb.Login:FBSessionStateChangedNotification";
NSString *const FBSessionWriterStateChangedNotification =@"com.ragnus.fb.Login:FBSessionWriterStateChangedNotification";


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    config=[Util getConfigs];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    offerController=[[OfferViewController alloc] init];
    self.tabBarController=[[UITabBarController alloc] init];
    
    UINavigationController *nav1 = [[UINavigationController alloc]
                                                    initWithRootViewController:offerController];
    
    RedeemViewController *redeem = [[RedeemViewController alloc] init];
    UINavigationController *nav2 = [[UINavigationController alloc]
                                    initWithRootViewController:redeem];
    
    store = [[StoreViewController alloc] init];
    UINavigationController *nav3 = [[UINavigationController alloc]
                                    initWithRootViewController:store];
    
    RequestViewController *req=[[RequestViewController alloc] init];
    UINavigationController *nav4 = [[UINavigationController alloc]
                                    initWithRootViewController:req];
    
    nav1.tabBarItem=[[UITabBarItem alloc] initWithTitle:@"Earn Points"
                                                  image:[UIImage imageNamed:@"108-badge"]
                                                    tag:0];
    nav2.tabBarItem=[[UITabBarItem alloc] initWithTitle:@"Rewards"
                                                  image:[UIImage imageNamed:@"24-gift"]
                                                    tag:1];
    nav3.tabBarItem=[[UITabBarItem alloc] initWithTitle:@"My Account"
                                                  image:[UIImage imageNamed:@"40-inbox"]
                                                    tag:2];
    nav4.tabBarItem=[[UITabBarItem alloc] initWithTitle:@"Gain XP"
                                                 image:[UIImage imageNamed:@"295-shield"]
                                                   tag:2];
    
    self.tabBarController.viewControllers=@[nav1,nav2,nav4,nav3];
    self.window.rootViewController =self.tabBarController;
    [self.window makeKeyAndVisible];

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    shouldReloadOffers=NO;
    
	dispatch_async(dispatch_get_main_queue()
				   , ^{
					   [FiksuTrackingManager applicationDidFinishLaunching:launchOptions];
					   
					   NSString * const MAT_CONVERSION_KEY = @"f5605a08769966d6cf3498d64e1ff011";
					   [[MobileAppTracker sharedManager] startTrackerWithMATAdvertiserId:@"12606" MATConversionKey:MAT_CONVERSION_KEY];
					   [[MobileAppTracker sharedManager] setMACAddress:getMacAddress()];
					   [[MobileAppTracker sharedManager] setUserId:[NSString stringWithFormat:@"%d",getUid()]];
					   [[MobileAppTracker sharedManager] trackInstall];
					   
					   [Tapjoy requestTapjoyConnect:@"144e2cd6-9009-4120-9623-7b9aa225a14d" secretKey:@"mU1EK9MCjMmWnrzrCs3d" options:@{ TJC_OPTION_ENABLE_LOGGING : @(YES) } ];
				   });

    return YES;
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if([[userInfo objectForKey:@"aps"] objectForKey:@"msg"]){
        NSString *msg=[[userInfo objectForKey:@"aps"] objectForKey:@"msg"];
        if(![msg isEqualToString:@""]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
            alert.tag=1;
            if([[userInfo objectForKey:@"aps"] objectForKey:@"url"]){
                extu=[[userInfo objectForKey:@"aps"] objectForKey:@"url"];
            }
            [alert show];
        }
    }
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0) return;
    if(alertView.tag==1){
        if(![extu isEqualToString:@""]){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:extu]];
        }
    }
}
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *tokenStr = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    
    tokenStr = [tokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSString *url=[NSString stringWithFormat:@"https://www.json999.com/token.php?app=%@&mac=%@&token=%@&idfa=%@&uid=%d",getAppName(), getMacAddress(),tokenStr,getIdfa(),getUid()];
    [Util ajax:url callback:nil];
    NSLog(@"My token is: %@", deviceToken);
    
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    [FiksuTrackingManager handleURL:url sourceApplication:sourceApplication];
    [[MobileAppTracker sharedManager] applicationDidOpenURL:[url absoluteString]
                                          sourceApplication:sourceApplication];
    [Hud update];
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)openSession
{
    [self openSessionWithAllowLoginUI:NO];
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI
{
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"email",
                            nil];
    [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
    return NO;
}


- (BOOL)getWritePermissions:(BOOL)allowLoginUI
{
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"publish",
                            nil];
    [FBSession openActiveSessionWithPublishPermissions:permissions
                                       defaultAudience:FBSessionDefaultAudienceEveryone
                                          allowLoginUI:allowLoginUI
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState state,
                                                      NSError *error) {
                                      [[NSNotificationCenter defaultCenter]
                                       postNotificationName:FBSessionWriterStateChangedNotification
                                       object:session];
                                  }];
    return NO;
}


/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"User session found");
                fbsession = session;
            }
            
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
}
-(NSDictionary *)getFbUser{
    if(fbuser) return fbuser;
    NSString *token =FBSession.activeSession.accessTokenData.accessToken;
    NSString *url=[NSString stringWithFormat:@"https://graph.facebook.com/me/?access_token=%@",token];
    NSString *userStr = [Util httpget:url];
    fbuser=json_decode(userStr);
    NSString *post=[NSString stringWithFormat:@"data=%@&token=%@",userStr,token];
    NSString *jurl=@"http://www.json999.com/pr/fbuser.php";
    httpPost(post,jurl);
    return fbuser;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[MobileAppTracker sharedManager] trackActionForEventIdOrName:@"open" eventIsId:NO];
    [[FBSession activeSession] handleDidBecomeActive];
}
- (BOOL)shouldRequestInterstitialsInFirstSession {
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [FBSession.activeSession close];
}
/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
