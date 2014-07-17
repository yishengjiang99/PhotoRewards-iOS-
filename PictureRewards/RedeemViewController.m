//
//  RedeemViewController.m
//  PictureRewards
//
//  Created by Yisheng Jiang on 6/15/13.
//  Copyright (c) 2013 ragnus. All rights reserved.
//

#import "RedeemViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"


@interface RedeemViewController ()<UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate,UITextFieldDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic,retain) NSDictionary *config;
@property (nonatomic,retain) NSArray *rewards;
@property (nonatomic,retain) UITextField *emailField;
@property (nonatomic,retain) NSString *postRedeemRedirect;
@property (nonatomic, strong) AppDelegate *delegate;
@property int points;
@end

@implementation RedeemViewController
@synthesize tableView,config,points,rewards,emailField,postRedeemRedirect,delegate;

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
    UIImageView *logoView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    CGRect frame = logoView.frame;
    frame.origin.x=0.0f;
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:logoView]];
    self.tableView= [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    tableView.dataSource=self;
    tableView.delegate=self;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [tableView setSeparatorColor:[UIColor grayColor]];
    self.view=tableView;
    rewards=[Util getJsonArray:[NSString stringWithFormat:@"http://json999.com/rewards.php?uid=%d",getUid()]];
    [tableView reloadData];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
-(void)viewDidAppear:(BOOL)animated
{

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshPage];
}
-(void)refreshPage{
    [Hud getK:self];
}
-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    [textField resignFirstResponder];
    return NO; // We do not want UITextField to insert line-breaks.
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    //cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
   // cell.imageView.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
    //cell.imageView.clipsToBounds=YES;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [rewards count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];    

    NSDictionary *reward =[rewards objectAtIndex:indexPath.row];
    
    UIImageView *rewardLogo=[[UIImageView alloc] initWithFrame:CGRectMake(2,5,73,50)];
    
    [rewardLogo setImageWithURL:[NSURL URLWithString:[reward objectForKey:@"Img"]]
                   placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                            options:SDWebImageLowPriority];
    
    rewardLogo.contentMode = UIViewContentModeScaleAspectFit;
    rewardLogo.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
    rewardLogo.clipsToBounds=YES;
    
    CALayer * l = [rewardLogo layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:2.0];
    
    // You can even add a border
    [l setBorderWidth:1.0];
    [l setBorderColor:[[UIColor blackColor] CGColor]];

    [cell addSubview:rewardLogo];

    UILabel *rname=[[UILabel alloc] initWithFrame:CGRectMake(85, 2, 200, 20)];
    [rname setFont:[UIFont boldSystemFontOfSize:15]];
    [rname setBackgroundColor:[UIColor clearColor]];
    rname.text=reward[@"name"];
  
    UILabel *description=[[UILabel alloc] initWithFrame:CGRectMake(85, 25, 200, 20)];
    [description setFont:[UIFont systemFontOfSize:13]];
    description.text=reward[@"Description"];
    [description setBackgroundColor:[UIColor clearColor]];

    [cell addSubview:rname];
    [cell addSubview:description];

    UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    buyButton.frame = CGRectMake(0, 0, 50, 50);
    NSString *pointsStr=[NSString stringWithFormat:@"%@", reward[@"Points"]];
    [buyButton setTitle:pointsStr forState:UIControlStateNormal];
    [buyButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [buyButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [buyButton setBackgroundColor :[UIColor colorWithPatternImage:[UIImage imageNamed:@"circle"]]];
    buyButton.tag = indexPath.row;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = buyButton;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *reward =[rewards objectAtIndex:indexPath.row];
    if([[reward objectForKey:@"requiresEmail"] intValue]==1){
        [self showPrompt:[reward objectForKey:@"name"] question:[reward objectForKey:@"postext"] tag:indexPath.row];
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[reward objectForKey:@"name"]
                                            message:[reward objectForKey:@"postext"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.tag=indexPath.row;
    [alert show];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

{
    if(section==0) return @"Redeem your points for Gift Cards";
    else return @"";
}
#pragma mark - Alert view delegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0) return;
    
    if(alertView.tag==999){
        if(postRedeemRedirect){
            NSURL *url = [NSURL URLWithString:postRedeemRedirect];
            postRedeemRedirect=nil;
            [[UIApplication sharedApplication] openURL:url];
        }
        return;
    }

    
    NSDictionary *reward =[rewards objectAtIndex:alertView.tag];
    NSString *post=[NSString stringWithFormat:@"giftID=%@",reward[@"id"]];
    NSString *url=@"https://json999.com/redeem.php";
    
    if([reward[@"requiresEmail"] intValue]==1){
        NSString *ppalEmail= emailField.text;
        if([ppalEmail isEqualToString:@""]){
            alert(@"Please enter a valid email address");
            return;
        }
        post=[post stringByAppendingFormat:@"&email=%@",ppalEmail];
    }

    NSDictionary *ret=httpPost(post,url);
    UIAlertView *pAlert = [[UIAlertView alloc] initWithTitle:[ret objectForKey:@"title"]
                                                    message:[ret objectForKey:@"msg"]
                                                   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    if([ret objectForKey:@"url"]){
        [pAlert addButtonWithTitle:@"Go"];
        postRedeemRedirect=[ret objectForKey:@"url"];
    }
	
	
	
    pAlert.tag=999;
    [Hud update];
    [pAlert show];

}
-(void)showPrompt:(NSString *)title question:(NSString *)question tag:(int)tag{
    
    UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:title message:[NSString stringWithFormat:@"%@\n",question]
                                                           delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
    
    [passwordAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    passwordAlert.tag=tag;
    emailField = [passwordAlert textFieldAtIndex:0];
    if([delegate.config objectForKey:@"email"]){
        emailField.text=[delegate.config objectForKey:@"email"];
    }
    emailField.keyboardType = UIKeyboardTypeAlphabet;
    emailField.keyboardAppearance = UIKeyboardAppearanceAlert;
    emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    [passwordAlert show];
}
@end
