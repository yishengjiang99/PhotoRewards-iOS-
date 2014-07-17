//
//  TJControllerViewController.h
//  PictureRewards
//
//  Created by Yisheng Jiang on 7/16/14.
//  Copyright (c) 2014 ragnus. All rights reserved.
//


#import <UIKit/UIKit.h>
@class TJControllerViewController;
typedef enum offerwall
{
	TapjoyWalll,
	SponsorPayWalll,
}OfferwallType;

@interface TJControllerViewController : UIViewController
-(id)initWithType:(OfferwallType)type;
@end
