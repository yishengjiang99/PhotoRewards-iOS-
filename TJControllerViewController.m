//
//  TJControllerViewController.m
//  PictureRewards
//
//  Created by Yisheng Jiang on 7/16/14.
//  Copyright (c) 2014 ragnus. All rights reserved.
//

#import "TJControllerViewController.h"

@interface TJControllerViewController ()<TJCViewDelegate,SPOfferWallViewControllerDelegate>{
	OfferwallType _type;
}
@end

@implementation TJControllerViewController
-(id)initWithType:(OfferwallType)type{
	if(self=[super init]){
		_type=type;
	}
	return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	if(_type==TapjoyWalll){

	}
	else if(_type==SponsorPayWalll){
		[Tapjoy showOffersWithViewController:self];
	}

	/* Your Security Token as NSString or nil */;
    // Do any additional setup after loading the view.
}
- (void) offerWallViewController:(SPOfferWallViewController *)offerWallVC isFinishedWithStatus:(int)status {
	
    // we could know if status determines a network error by comparing it with the
    // SPONSORPAY_ERR_NETWORK constant defined in SPOfferWallViewController.h
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppearWithType:(int)viewType{
	NSLog(@"Offerwall is about to be shown");
	//Mute the Audio (Pseudocode)
}
// This method is called right after the offerwall has appeared.
- (void)viewDidAppearWithType:(int)viewType{
	NSLog(@"Offerwall has been shown");
}
// This method is called right before the offerwall has ended.
- (void)viewWillDisappearWithType:(int)viewType {
	NSLog(@"Offerwall is about to go away");
}
// This method is called right after the offerwall has closed.
- (void)viewDidDisappearWithType:(int)viewType{
	NSLog(@"Offerwall has closed");
	// Get updated balance after the video view is closed.
	[Tapjoy getTapPoints];
	//Unmute the Audio (Pseudocode)
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
