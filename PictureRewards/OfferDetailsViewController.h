//
//  OfferDetailsViewController.h
//  PictureRewards
//
//  Created by Yisheng Jiang on 6/14/13.
//  Copyright (c) 2013 ragnus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Offer.h"

@interface OfferDetailsViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) Offer *offer;
@property int points,uid,bonusUpper;
@property (nonatomic,strong) NSString *bonusCode;
@end
