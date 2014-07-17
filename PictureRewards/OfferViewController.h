//
//  OfferViewController.h
//  PictureRewards
//
//  Created by Yisheng Jiang on 6/13/13.
//  Copyright (c) 2013 ragnus. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "Offer.h"
@interface OfferViewController : UIViewController
@property (nonatomic,strong) NSMutableArray *offers;
@property (nonatomic, retain) UITableView *tableView;
@property BOOL loadingMore;
@property BOOL loaded;
@property BOOL loggedInFb,showTutorial,refreshing,showLoadingScreen,hasMore;
-(void)reloadOffers:(int)index;
- (void) setLoadingScreen;
-(void)updateUI;
@end

@interface PlayerView : UIView

@property (nonatomic) AVPlayer *player;

@end
