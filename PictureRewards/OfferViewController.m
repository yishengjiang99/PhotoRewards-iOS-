//
//  OfferViewController.m
//  PictureRewards
//
//  Created by Yisheng Jiang on 6/13/13.
//  Copyright (c) 2013 ragnus. All rights reserved.
//
#import "AppDelegate.h"
#import "OfferViewController.h"
#import "OfferDetailsViewController.h"
#import "UILabel+UILabel_fonts.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "ODRefreshControl.h"
#import "PRViewController.h"
#import "IconDownloader.h"
#import "TutorialViewController.h"
#import "Aarki.h"
#import "Offer.h"
#import "TJControllerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
/************************************************/
/************* In private interface *************/
/************************************************/

@interface OfferViewController ()<UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate,UIScrollViewDelegate,UITextFieldDelegate,NSURLConnectionDelegate,SPOfferWallViewControllerDelegate>
@property (nonatomic,retain) NSMutableData *receivedData;
@property (nonatomic,retain) NSDictionary *config;
@property (nonatomic, strong) AppDelegate *delegate;
@property int points;
@property int fbbonus;
@property int invitebonus;
@property int inviteUpper;
@property int enterbonus;
@property int start;
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic,strong) UITextField *bonusField;
@property (nonatomic,weak) UIColor *bgc1;
@property (nonatomic,weak) UIColor *bgc2;
@property (nonatomic,strong) UIView *footerView;
@property (nonatomic,strong) UIView *loadingScreens;


@property (nonatomic) AVPlayer *player;
@property (nonatomic,strong) Offer *currentOffer;

@property (nonatomic) AVPlayerItem *playerItem;

@property (nonatomic, strong) IBOutlet PlayerView *playerView;

@property (nonatomic,strong) ODRefreshControl *refreshControl;

@end

@implementation OfferViewController

@synthesize loaded,refreshControl,tableView,offers,points,config,loggedInFb,fbbonus,invitebonus,delegate,inviteUpper,enterbonus,bonusField,bgc1,bgc2,loadingMore,start,footerView,receivedData,showTutorial,loadingScreens,refreshing,showLoadingScreen,hasMore;

- (id)init
{
    self = [super init];
    if (self) {
        [self loadLogo];
        fbbonus=0; invitebonus=0; inviteUpper=0;enterbonus=0;showLoadingScreen=YES;
    }
    return self;
}
-(void) loadLogo{
    UIImageView *logoView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    CGRect frame = logoView.frame;
    frame.origin.x=0.0f;
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:logoView]];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if([[UIDevice currentDevice].systemVersion floatValue]>=7.0){
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }

    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if(!self.tableView){
        self.tableView= [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.dataSource=self;
        tableView.delegate=self;
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLineEtched];
        [tableView setSeparatorColor:[UIColor grayColor]];
        
        footerView=[[UIView alloc] initWithFrame:CGRectMake(0,0,320,40)];
        footerView.backgroundColor=[UIColor whiteColor];
        UILabel *fl=[[UILabel alloc] initWithFrame:CGRectMake(40,0,280,40)];
        [fl setTextColor:[UIColor blackColor]];
        fl.text=@"   Loading...";
        UIActivityIndicatorView *loadingview=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingview.frame=CGRectMake(0,0,40,40);
        [loadingview startAnimating];
        [footerView addSubview:loadingview];
        [footerView addSubview:fl];
        refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
        [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
        [self.tableView setContentInset:(UIEdgeInsetsMake(0, 0, 0, 0))];
        self.tableView.tableFooterView=nil;
    }
    showLoadingScreen=YES;
    hasMore=YES;
    [self reloadOffers:0];
}
- (void) offerWallViewController:(SPOfferWallViewController *)offerWallVC isFinishedWithStatus:(int)status {
	
    // we could know if status determines a network error by comparing it with the
    // SPONSORPAY_ERR_NETWORK constant defined in SPOfferWallViewController.h
}


- (void) setLoadingScreen
{
    if(!loadingScreens){
        loadingScreens=[[UIView alloc] initWithFrame:self.view.bounds];
        [loadingScreens setBackgroundColor:[UIColor whiteColor]];
        
        UILabel *l1=[[UILabel alloc] initWithFrame:CGRectMake(0,70,320,25)];
        [l1 getFancy:20.0f];
        l1.textAlignment= UITextAlignmentCenter;
        l1.text=@"Upload Pictures";
        
        UILabel *l2=[[UILabel alloc] initWithFrame:CGRectMake(0,105,320,25)];
        [l2 getFancy:20.0f];
        
        l2.text=@"Earn Points";
        l2.textAlignment= UITextAlignmentCenter;

        UILabel *l3=[[UILabel alloc] initWithFrame:CGRectMake(0,140,320,25)];
        [l3 getFancy:20.0f];
        l3.textAlignment= UITextAlignmentCenter;
        l3.text=@"Get Free Gift Cards";
        [l3 setFont:[UIFont boldSystemFontOfSize:20.0f]];

        UILabel *l4=[[UILabel alloc] initWithFrame:CGRectMake(0,175,320,25)];
        [l4 getFancy:20.0f];
        l4.textAlignment= UITextAlignmentCenter;
        l4.text=@"Make Friends";

        [loadingScreens addSubview:l1];
        [loadingScreens addSubview:l2];
        [loadingScreens addSubview:l3];
        [loadingScreens addSubview:l4];

        UIActivityIndicatorView *loading=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        loading.center=loadingScreens.center;
        [loading startAnimating];
        [loadingScreens addSubview:loading];
    }
    [self setView:loadingScreens];
}

-(void)dropViewDidBeginRefreshing:(ODRefreshControl *)sender{
    self.refreshing=YES;
    [self reloadOffers:0];
    [Hud update];
}

-(void)reloadOffers:(int)index
{
   // NSLog(@"calls to reload offer");
    if(loadingMore==YES) return;
    if(hasMore==NO) return;
    loadingMore=YES;
    if(index==0 && showLoadingScreen){
        refreshing=YES;
        [self setLoadingScreen];
        showLoadingScreen=NO;
    }
    
    NSString *url= [NSString stringWithFormat:@"http://json999.com/pr/offers.php?t=1&uid=%d&start=%d&mac=%@&idfa=%@",getUid(),index,getMacAddress(),getIdfa()];
    start=index+10;
   // NSLog(@"%@",url);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) {
        receivedData = [NSMutableData data];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response

{
    [receivedData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data

{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection

{
    NSError *e;
    NSDictionary *oconf = [NSJSONSerialization JSONObjectWithData: receivedData
                                                              options: NSJSONReadingMutableContainers
                                                                           error: &e];
    if(!offers || refreshing==YES){
        offers=nil;
        offers=[[NSMutableArray alloc] init];
    }
    int count=0;
    if([oconf objectForKey:@"offers"]){
    
        for(NSDictionary *oStr in [oconf objectForKey:@"offers"]){
            count++;
            [offers addObject:[[Offer alloc] initFromNSDictionary:oStr]];
        }
    }
    fbbonus=[[oconf objectForKey:@"fb"] intValue];
    invitebonus=[[oconf objectForKey:@"invite"] intValue];
    inviteUpper=[[oconf objectForKey:@"inviteUpper"] intValue];
    enterbonus=[[oconf objectForKey:@"enterbonus"] intValue];
    showTutorial=[[oconf objectForKey:@"st"] intValue];
    loaded=YES;
    refreshing=NO;
    loadingMore=NO;
    if(count>0){
        [self updateUI];
    }else{
        [refreshControl endRefreshing];
        tableView.tableFooterView=nil;
    }
}
-(void)updateUI
{
    [tableView reloadData];
    [self setView:tableView];
    [refreshControl endRefreshing];
}

-(void)viewDidAppear:(BOOL)animated{
    [self loadImagesForOnscreenRows];
}

-(void)viewWillAppear:(BOOL)animated
{
    [Hud getK:self];
    [self.tabBarController.tabBar setHidden:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if(!loaded) return 0;
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

{
    if(!loaded) return @"Loading remote data";
    if(section==0 && invitebonus>0){
        return @"Invite Friends";
    }else if (section==1){
        return @"Upload Pictures For Points";
    }
    else return @"";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(!loaded) return 7;
    if(section==0){
        if(invitebonus==0) return 0;
        else if(enterbonus==0)return 1;
        else return 2;
    }else{
        return [offers count];
    }
}

#pragma mark - Table cell image support



// -------------------------------------------------------------------------------
//	loadImagesForOnscreenRows
//  This method is used in case the user scrolled into a set of cells that don't
//  have their app icons yet.
// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows
{
    if ([self.offers count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            if(indexPath.section==0) continue;
            Offer *offer = [self.offers objectAtIndex:indexPath.row];
            if(!offer.icon){
                [self startIconDownload:offer forIndexPath:indexPath];
            }
        }
    }
}

- (void)startIconDownload:(Offer *)offer forIndexPath:(NSIndexPath *)indexPath
{
    
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.offer = offer;
        [iconDownloader setCompletionHandler:^{
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            cell.imageView.image = offer.icon;

            CALayer * l = [cell.imageView layer];
            [l setMasksToBounds:YES];
            [l setCornerRadius:10.0];
            
            // You can even add a border
            [l setBorderWidth:2.0];
            [l setBorderColor:[[UIColor blackColor] CGColor]];
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
    }
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        [self loadMore];
    }
}
-(void) loadMore{
    if(hasMore==YES){
        [self reloadOffers:start];
        tableView.tableFooterView=footerView;
    }
}

#pragma mark - Alert view delegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0) return;
    if(alertView.tag==1){
        [delegate openSessionWithAllowLoginUI:YES];
        return;
    }
    if(alertView.tag==2){
        NSString *bonustxt=[alertView textFieldAtIndex:0].text;
        if([bonustxt isEqualToString:@""]){
            alert (@"Please enter a bonus code");
            return;
        }
        NSString *post=[NSString stringWithFormat:@"code=%@",bonustxt];
        NSString *url=@"https://www.json999.com/pr/bonus.php";
		httpPostShowPopup(post, url, nil);
		
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
    if(alertView.tag==2){
        [[alertView textFieldAtIndex:0] becomeFirstResponder];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    static NSString *bonuscodeCellIndentifier = @"bonuscodeCellIndentifier";
    static NSString *notloadedCellID=@"notloadedcell";
    UITableViewCell *cell;
    if(loaded==NO){
        cell=[self.tableView dequeueReusableCellWithIdentifier:notloadedCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:notloadedCellID];
        }
        cell.textLabel.text=@"";
        return cell;
    }
    if(indexPath.section==0 && indexPath.row==1){
        cell=[self.tableView dequeueReusableCellWithIdentifier:bonuscodeCellIndentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:bonuscodeCellIndentifier];
        }
    }else{
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            [cell.textLabel setTextColor:[UIColor blackColor]];
            [cell.textLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
            [cell.textLabel setBackgroundColor:[UIColor clearColor]];
            
            [cell.detailTextLabel setTextColor:[UIColor blackColor]];
            [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12]];
            [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
        }
    }
    if(indexPath.section==0 && indexPath.row==1){
        UIButton *ext = [UIButton buttonWithType:UIButtonTypeCustom];
        ext.frame=CGRectMake(30,5,260,50);
        UIImage *btnImg=[[UIImage imageNamed:@"greenButton.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        [ext setBackgroundImage:btnImg forState:UIControlStateNormal];
        [ext.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [ext setTitle:@"Enter Bonus Code" forState:UIControlStateNormal];
        [ext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [ext setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
        [ext addTarget:self action:@selector(showPrompt:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:ext];
        cell.imageView.clipsToBounds=YES;
        return cell;
    }

    
    // Configure the cell...

    if(indexPath.section==0 && indexPath.row==0){
        [cell.imageView setImage:[UIImage imageNamed:@"invite.jpg"]];
        cell.textLabel.text=@"Invite Friends";
        [cell.detailTextLabel setNumberOfLines:2];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%d to %d Points\n for each friend who join",invitebonus,inviteUpper];
        cell.accessoryType = UITableViewCellAccessoryNone;
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        buyButton.frame = CGRectMake(0, 0, 50, 50);
        [buyButton setTitle:[NSString stringWithFormat:@"%d+",invitebonus] forState:UIControlStateNormal];
        [buyButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [buyButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [buyButton setBackgroundColor :[UIColor colorWithPatternImage:[UIImage imageNamed:@"circle"]]];
        buyButton.tag = indexPath.row;
        
        cell.accessoryView = buyButton;
        return cell;
    }

    
     Offer *offer =[offers objectAtIndex:indexPath.row];
    
    // Only load cached images; defer new downloads until scrolling ends
    if (!offer.icon)
    {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            [self startIconDownload:offer forIndexPath:indexPath];
        }
        cell.imageView.image = [UIImage imageNamed:@"placeholder.png"];
    }
    else
    {
        cell.imageView.image = offer.icon;
    }
	[cell.textLabel sizeToFit];
	cell.textLabel.numberOfLines=2;
    cell.textLabel.text=offer.name;

    NSString *action=@"Upload A Snapshot";
    if(offer.action){
        action=offer.action;
    }

    cell.detailTextLabel.text=action;
    
    if(!offer.button){
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        buyButton.frame = CGRectMake(0, 0, 50, 50);
        [buyButton setTitle:offer.points forState:UIControlStateNormal];
        [buyButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [buyButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [buyButton setBackgroundColor :[UIColor colorWithPatternImage:[UIImage imageNamed:@"circle"]]];
        [buyButton setUserInteractionEnabled:NO];
        offer.button=buyButton;
    }    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = offer.button;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if(indexPath.row % 2 ==1){
        [cell setBackgroundColor:[UIColor colorWithRed:0.941 green:0.917 blue:0.83921 alpha:1.0]];
    }else{
             [cell setBackgroundColor:[UIColor whiteColor]];
    }
    return;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

	if(indexPath.section==0 && indexPath.row==0){
        PRViewController *inviteViewController=[[PRViewController alloc] init];
        inviteViewController.inviteBonus=invitebonus;
        inviteViewController.inviteUpper=inviteUpper;
        [self.navigationController pushViewController:inviteViewController animated:YES];
    }else if(indexPath.section==0 && indexPath.row==1){
        [self showPrompt:nil];
    }else if(indexPath.section==1){
		Offer *offer=[offers objectAtIndex:indexPath.row];
		self.currentOffer=offer;
		if(![offer.type isEqual:@"featured"]){
			
			OfferDetailsViewController *detailViewController = [[OfferDetailsViewController alloc] init];
			detailViewController.points = points;
			detailViewController.offer=[offers objectAtIndex:indexPath.row];
			detailViewController.uid=getUid();
			detailViewController.bonusCode=getUsername();
			detailViewController.bonusUpper=inviteUpper;
			[self.navigationController pushViewController:detailViewController animated:YES];

		}
		else if([offer.cmd isEqualToString:@"sponsorpayWall"]){
			[SponsorPaySDK startForAppId:@"23804"
								  userId:[NSString stringWithFormat:@"%d",getUid()] /* Your current User ID as NSString */
						   securityToken: @"177bed0c9ede4fe72a17f89e1a0f5032"];
			
			[SponsorPaySDK showOfferWallWithParentViewController:self];
			
			[Util ajax:[NSString stringWithFormat:@"http://json999.com/event.php?action=clicked&url=%@&refId=%@",@"sponsorpaysdk",self.currentOffer.refId] callback:nil];

		}else if([offer.cmd isEqualToString:@"tjWall"]){
			[self.navigationController pushViewController:[[TJControllerViewController alloc] initWithType:TapjoyWalll] animated:YES];
			[Util ajax:[NSString stringWithFormat:@"http://json999.com/event.php?action=clicked&url=%@&refId=%@",@"tapjoysdk",self.currentOffer.refId] callback:nil];

		}else if([offer.cmd isEqualToString:@"CPA"]){
			NSURL *url = [NSURL URLWithString:offer.url];
			[[UIApplication sharedApplication] openURL:url];
		}else if([offer.cmd isEqualToString:@"Video"]){
			self.playerItem=[AVPlayerItem playerItemWithURL:[NSURL URLWithString:offer.url]];
							 
			self.player=[AVPlayer playerWithPlayerItem:self.playerItem];
			
			
			//[self.player addObserver:self forKeyPath:@"status" options:0 context:nil];
			if(!self.playerView){
				self.playerView=[[PlayerView alloc] initWithFrame:self.view.bounds];
				self.playerView.layer.opacity=0.6f;
				[self.delegate.window.layer addSublayer:self.playerView.layer];
				self.playerView.layer.hidden=YES;
				[[NSNotificationCenter defaultCenter]
				 
				 addObserver:self
				 
				 selector:@selector(playerItemDidReachEnd:)
				 
				 name:AVPlayerItemDidPlayToEndTimeNotification
				 
				 object:[self.player currentItem]];
				

			}
			self.currentOffer=offer;
			[self. playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
			
			[self.playerView setPlayer:self.player];

		}else if ([offer.cmd isEqualToString:@"aarkiSDK"]){
			NSString *aarkiPlacement=[Util getConfig:@"aarkiSDK" withDefault:@"3027CF0149E717D6AA"];
			Aarki *aarki=[[Aarki alloc] init];
			[aarki showAds:aarkiPlacement withParent:self options:nil];
			
			
		}else if ([offer.cmd isEqualToString:@"aarkivideo"]){
			Aarki *aarki=[[Aarki alloc] init];
			NSString *aarkiPlacement=[Util getConfig:@"aarkiSDK" withDefault:@"3027CF0149E717D6AA"];

			[aarki showFullScreenAd:aarkiPlacement withParent:self options:nil completion:^(AarkiStatus status) {
				NSLog(@"%u",status);
			}];
			
			
		}else{
				 //[self.navigationController pushViewController:[[TJControllerViewController alloc] init] animated:YES];
		}
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object

                        change:(NSDictionary *)change context:(void *)context {
	if([keyPath isEqual:@"status"]){
		AVPlayer *thePlayer = (AVPlayer *)object;
		
        if ([thePlayer status] == AVPlayerStatusFailed) {
						
			
            return;
			
        }else if(thePlayer.status==AVPlayerItemStatusReadyToPlay){
			self.playerView.layer.hidden=NO;
			[self.player play];
		}else{
			NSLog(@"other");
		}
		return;
	}
	
	
	
    [super observeValueForKeyPath:keyPath ofObject:object
	 
						   change:change context:context];
	
    return;
	
}


-(void)showPrompt:(id)sender{
	NSString *title=@"Enter Bonus Code";
	NSString *msg=@"Points earned depends on your friend's XP Level";
	if([[Util getConfigs] objectForKey:@"bonus_code_prompt_title"]){
		title=[[Util getConfigs] objectForKey:@"bonus_code_prompt_title"];
	}
	if([[Util getConfigs] objectForKey:@"bonus_code_prompt_msg"]){
		title=[[Util getConfigs] objectForKey:@"bonus_code_prompt_msg"];
	}
    UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:title
                                                            message:msg
                                                           delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"Enter",nil), nil];

    [passwordAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    passwordAlert.tag=2;
    UITextField *someTextField = [passwordAlert textFieldAtIndex:0];
    someTextField.keyboardType = UIKeyboardTypeAlphabet;
    someTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
    someTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [passwordAlert show];
}
- (void)playerItemDidReachEnd:(NSNotification *)notification {
	
    [self.player seekToTime:kCMTimeZero];
	 self.playerView.layer.hidden=YES;
	[Util ajax:[NSString stringWithFormat:@"http://json999.com/event.php?action=watcheded&url=%@&refId=%@",urlencode(self.currentOffer.url),self.currentOffer.refId] callback:nil];
}
@end



@implementation PlayerView

+ (Class)layerClass {
	
    return [AVPlayerLayer class];
	
}

- (AVPlayer*)player {
	
    return [(AVPlayerLayer *)[self layer] player];
	
}

- (void)setPlayer:(AVPlayer *)player {
	
    [(AVPlayerLayer *)[self layer] setPlayer:player];
	
}


@end


