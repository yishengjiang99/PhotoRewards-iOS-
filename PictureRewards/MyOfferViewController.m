//
//  MyOfferViewController.m
//  PictureRewards
//
//  Created by Yisheng Jiang on 6/22/13.
//  Copyright (c) 2013 ragnus. All rights reserved.
//

#import "MyOfferViewController.h"
#import "Offer.h"

@interface MyOfferViewController ()

@end

@implementation MyOfferViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) loadLogo{
//don't do anything.. trust me. OOP is gay.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        super.loaded=YES;
    [self reloadOffers:0];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadOffers:(int)start{
    super.loadingMore=YES;
    NSDictionary *oconf=[Util getJson:[NSString stringWithFormat:@"http://json999.com/pr/myoffers.php?t=1&uid=%d",getUid()]];
    super.offers=nil;
    super.offers=[[NSMutableArray alloc] init];
    for(NSDictionary *oStr in oconf[@"my"]){
        [super.offers addObject:[[Offer alloc] initFromNSDictionary:oStr]];
    }
    [super updateUI];
    
    [super.tableView reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

{
    if(section==0){
        return @"";
    }else if (section==1){
        return @"My Listings";
    }
    else return @"";
}


@end
