//
//  StoreViewController.m
//  PictureRewards
//
//  Created by Yisheng Jiang on 6/18/13.
//  Copyright (c) 2013 ragnus. All rights reserved.
//

#import "StoreViewController.h"
#import "REComposeViewController.h"
#import "TutorialViewController.h"
#import "NSData+Base64.h"
@interface StoreViewController ()
@property (strong, nonatomic) NSArray *products;
@property UIActivityIndicatorView* activityIndicator;
@property UIView* overlay;
@property (nonatomic,retain) NSDictionary *config;
@property int points;
@property (nonatomic,strong) NSArray *history;
@end

@implementation StoreViewController
@synthesize products,activityIndicator,overlay,config,points,inbox,unread,history;
-(id)init{
    return [self initWithStyle:UITableViewStyleGrouped];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //- (void)requestProducts:(NSString *)url withCompletionHandler:(RequestProductsCompletionHandler)completionHandler {

    UIImageView *logoView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    CGRect frame = logoView.frame;
    frame.origin.x=0.0f;
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:logoView]];
   // [self loadInbox];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void) refreshPage
{
    [Hud getK:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) loadInbox{
 
    self.inbox=[Util getJsonArray:[NSString stringWithFormat:@"https://www.json999.com/pr/inbox.php?t=1&uid=%d",getUid()]];
    self.unread=0;
    for(NSDictionary *msg in self.inbox){
        if([[msg objectForKey:@"readmsg"] intValue]==0){
            self.unread++;
        }
    }
    if(self.unread>0){
        [[[[[self tabBarController] tabBar] items] objectAtIndex:3] setBadgeValue:[NSString stringWithFormat:@"%d", self.unread ]];
    }
    NSRange range = NSMakeRange(0, 1);
    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationRight];
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if(section==0) {
        return [inbox count];
    }
    if(section==1){
        if(!history) return 1;
        else return [history count];
    }
    if(section==2) return 1;
    return 0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

{
    if(section==0) return @"Inbox";
    if(section==1) return @"History";
    if(section==2) return @"";
    return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *cellid=[NSString stringWithFormat:@"sec%d",indexPath.section];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellid];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellid];
    }
    if(indexPath.section==0){
        NSDictionary *msg = [self.inbox objectAtIndex:indexPath.row];
        NSString *from=[msg objectForKey:@"From"];
        NSString *txt=[msg objectForKey:@"msg"];
        NSString *new=@"";
        if([[msg objectForKey:@"readmsg"] intValue]==0){
            new=@"(NEW)";
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.textLabel.text=[NSString stringWithFormat:@"%@From %@",new,from];
        cell.selectionStyle=
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text=txt;
    }else if(indexPath.section==1){
        if(!history){
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text=@"Load History";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            NSDictionary *entry=[history objectAtIndex:indexPath.row];
            cell.textLabel.text=[entry objectForKey:@"Item"];
            cell.detailTextLabel.text=[entry objectForKey:@"Reward"];
            if([entry objectForKey:@"picid"]){
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }else{
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }else if(indexPath.section==2 && indexPath.row==0){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text=@"Read Terms and Conditions";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}
- (void)viewDidAppear:(BOOL)animated {
    [self refreshPage];
    [self loadInbox];
    [self.tabBarController.tabBar setHidden:NO];
 }




#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0){
        NSDictionary *msg = [self.inbox objectAtIndex:indexPath.row];
        NSString *from=[msg objectForKey:@"From"];
        NSString *txt=[msg objectForKey:@"msg"];
        int fromUid=[[msg objectForKey:@"from_uid"] intValue];
        int msgId=[[msg objectForKey:@"msg_id"] intValue];

        REComposeViewController *composeViewController = [[REComposeViewController alloc] init];
        [composeViewController setModalInPopover:NO];
        
        UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        titleImageView.frame = CGRectMake(0, 0, 140, 30);
        composeViewController.navigationItem.titleView = titleImageView;
        composeViewController.title = @"Photo Rewards";
        composeViewController.hasAttachment = NO;
        composeViewController.placeholderText = [NSString stringWithFormat:@"Reply to %@\n-----\n%@",from,txt];
        composeViewController.completionHandler = ^(REComposeViewController *composeViewController, REComposeResult result) {
            [composeViewController dismissViewControllerAnimated:YES completion:nil];
            if (result == REComposeResultCancelled) {
                NSLog(@"Cancelled");
            }
            if (result == REComposeResultPosted) {
                NSString *post=[NSString stringWithFormat:@"toUid=%d&%msg=%@&from=%d&replyto=%d",fromUid,composeViewController.text,getUid(),msgId];
                NSString *url=@"https://www.json999.com/pr/msg.php";
                NSDictionary *ret=httpPost(post,url);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[ret objectForKey:@"title"]
                                                                message:[ret objectForKey:@"msg"]
                                                               delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        };
        [composeViewController presentFromRootViewController];
        [Util ajax:[NSString stringWithFormat:@"https://www.json999.com/pr/msgdone.php?msgid=%d",msgId] callback:nil];
        return;
    }
    if(indexPath.section==1 && indexPath.row==0 && !history){
        history=[Util getJsonArray:[NSString stringWithFormat:@"https://www.json999.com/pr/history.php?uid=%d",getUid()]];
        NSRange range = NSMakeRange(1, 1);
        NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];                                     
        [tableView reloadSections:section withRowAnimation:UITableViewRowAnimationRight];
        return;
    }
    if(indexPath.section==1 && history){
        NSDictionary *entry=[history objectAtIndex:indexPath.row];
        if([entry objectForKey:@"picid"]){
            NSString *url =[NSString stringWithFormat:@"https://www.json999.com/pr/picture.php?id=%@",[entry objectForKey:@"picid"]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
        return;
    }
    if(indexPath.section==2 && indexPath.row==0){
        UIViewController *webViewController = [[UIViewController alloc] init];
        
        UIWebView *uiWebView = [[UIWebView alloc] initWithFrame: CGRectMake(0,0,320,480)];
        [uiWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.json999.com/pr/terms.php"]]];
        
        [webViewController.view addSubview: uiWebView];
    
        [self.navigationController pushViewController:webViewController animated:YES];
        return;
    }
    if(indexPath.section==2 && indexPath.row==1){
        TutorialViewController *tut=[[TutorialViewController alloc] init];
        [self.navigationController pushViewController:tut animated:YES];
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    return;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
}

@end
