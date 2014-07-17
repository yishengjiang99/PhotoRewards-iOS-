//
//  StoreViewController.h
//  PictureRewards
//
//  Created by Yisheng Jiang on 6/18/13.
//  Copyright (c) 2013 ragnus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreViewController : UITableViewController
@property (strong,nonatomic) NSArray *inbox;
@property int unread;

-(void)loadInbox;
@end
