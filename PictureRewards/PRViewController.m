//
//  PRViewController.m
//  PictureRewards
//
//  Created by Yisheng Jiang on 6/22/13.
//  Copyright (c) 2013 ragnus. All rights reserved.
//

#import "PRViewController.h"
#import "UILabel+UILabel_fonts.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
@interface PRViewController ()<UITextFieldDelegate,FBFriendPickerDelegate,MFMailComposeViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,MFMessageComposeViewControllerDelegate>

@property int xp;
@property int level;
@property int levelPercentage;
@property (nonatomic,weak) NSString* bonusNextLevel;
@property (nonatomic,weak) NSString* ptrange;
@property (nonatomic,weak) NSMutableDictionary* fbparams;
@property (nonatomic,weak) NSArray *friendsSelected;
@property (nonatomic,strong) NSMutableArray *friendsWithEmails;
@property (nonatomic,strong) NSMutableArray *friendsWithPhone;
@property (nonatomic,strong) NSMutableSet *emailFriends;
@property (nonatomic,strong) NSMutableSet *textFriends;
@property (nonatomic,strong) NSArray *sections;
@property (nonatomic,strong) NSString *redirect;
@property (nonatomic,strong) NSString *tweetmsg;
@property (nonatomic,strong) NSString *emailMsg;
@property (nonatomic,strong) NSString *fbmsg;



@property BOOL readContacts;
@property (nonatomic,weak) AppDelegate* appdelegate;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@end

@implementation PRViewController
@synthesize inviteBonus,xp,level,levelPercentage,bonusNextLevel,appdelegate,friendPickerController,ptrange,fbparams,friendsSelected,friendsWithPhone,friendsWithEmails,readContacts,inviteUpper,redirect,tweetmsg,emailMsg,fbmsg;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        readContacts=NO;
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [Hud getK:self];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if([[UIDevice currentDevice].systemVersion floatValue]>=7.0){
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
    self.sections = [NSArray arrayWithObjects:@"#", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", nil];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *xpInfo =delegate.config;
    xp=[[xpInfo objectForKey:@"xp"] intValue];
    level=[[xpInfo objectForKey:@"level"] intValue];
    levelPercentage=[[xpInfo objectForKey:@"levelPercentage"] intValue];
    bonusNextLevel=[xpInfo objectForKey:@"bonusNextLevel"];
    redirect=[xpInfo objectForKey:@"redirect"];
    tweetmsg=[xpInfo objectForKey:@"tweetmsg"];
    emailMsg=[xpInfo objectForKey:@"emailmsg"];
    fbmsg=[xpInfo objectForKey:@"fbmsg"];
    NSLog(@"%@ fb",fbmsg);
    NSLog(@"%@ emal",emailMsg);

    
    UIView *top=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 62)];
    UIImageView *logo=[[UIImageView alloc] initWithFrame:CGRectMake(5,2,53,53)];
    [logo setImage:[UIImage imageNamed:@"invite.jpg"]];

    [top addSubview:logo];
    
    UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    buyButton.frame = CGRectMake(260, 10, 50, 50);
    [buyButton setTitle:[NSString stringWithFormat:@"%d+",inviteBonus] forState:UIControlStateNormal];
    [buyButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [buyButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [buyButton setBackgroundColor :[UIColor colorWithPatternImage:[UIImage imageNamed:@"circle"]]];
    [top addSubview:buyButton];
    
    UILabel *name =[[UILabel alloc] initWithFrame:CGRectMake(82, 20, 180, 20)];
    [name setFont:[UIFont boldSystemFontOfSize:15]];
    [name setBackgroundColor:[UIColor clearColor]];
    name.text=@"Invite A Friend";
    [top addSubview:name];
    [self.view addSubview:top];

    UILabel *subt =[[UILabel alloc] initWithFrame:CGRectMake(20, 62, 280, 38)];
    [subt setFont:[UIFont boldSystemFontOfSize:15]];
    subt.numberOfLines=0;
    [subt setBackgroundColor:[UIColor clearColor]];
    subt.text=[NSString stringWithFormat:@"%d to %d Points for each friend",inviteBonus,inviteUpper];
    [self.view addSubview:subt];
    
    ptrange=[NSString stringWithFormat:@"%d to %d Points",inviteBonus,inviteUpper];    
    
    UIView *actionpanel =[[UIView alloc] initWithFrame:CGRectMake(0, 100, 320, 123)];
    
    UILabel *bonusCode =[[UILabel alloc] initWithFrame:CGRectMake(10, 12, 150, 30)];
    bonusCode.text=@"Your bonus code is: ";
    [bonusCode getFancy:15.0f];
    
    UITextField *bonusField = [[UITextField alloc] initWithFrame:CGRectMake(162, 12, 150, 30)];
    bonusField.borderStyle = UITextBorderStyleRoundedRect;
    bonusField.font = [UIFont systemFontOfSize:15.0];
    [bonusField setEnabled:NO];
    bonusField.text=getUsername();
    bonusField.delegate=self;

    UILabel *xpLabel =[[UILabel alloc] initWithFrame:CGRectMake(10, 42, 150, 30)];
    xpLabel.text=@"You have: ";
    [xpLabel getFancy:15.0f];
    
    UILabel *xpOut =[[UILabel alloc] initWithFrame:CGRectMake(162, 42, 150, 30)];
    xpOut.text=[NSString stringWithFormat:@"%d XP (Level %d)",xp,level];
    [xpOut getFancy:15.0f];
    
    UILabel * nextL =[[UILabel alloc] initWithFrame:CGRectMake(10, 72, 150, 30)];
    nextL.text=@"Next Level Bonus: ";
    [nextL getFancy:15.0f];
    
    UILabel *nextO =[[UILabel alloc] initWithFrame:CGRectMake(162, 72, 150, 30)];
    [nextO setText:bonusNextLevel];
    [nextO getFancy:15.0f];
    
    UILabel *nextLL =[[UILabel alloc] initWithFrame:CGRectMake(10, 102, 150, 30)];
    nextLL.text=@"Next Level: ";
    [nextLL getFancy:15.0f];

    UILabel *NextLo =[[UILabel alloc] initWithFrame:CGRectMake(162, 102, 150, 30)];
    [NextLo setText:[NSString stringWithFormat:@"%d percent complete", levelPercentage]];
    [NextLo getFancy:15.0f];
    

    [actionpanel addSubview:bonusCode];
    [actionpanel addSubview:bonusField];
    [actionpanel addSubview:xpLabel];
    [actionpanel addSubview:xpOut];
    [actionpanel addSubview:nextO];
    [actionpanel addSubview:nextL];
    [actionpanel addSubview:NextLo];
    [actionpanel addSubview:nextLL];
    [self.view addSubview:actionpanel];
    
    UIView *invitePanel =[[UIView alloc] initWithFrame:CGRectMake(0, 230, 320, 250)];
    UIButton *fb = [self greenBtn:@"Facebook" img:[UIImage imageNamed:@"fblogo"]];
    fb.frame=CGRectMake(10,12,143,52);
    fb.tag=0;
    [fb addTarget:self action:@selector(shareBtn:) forControlEvents:UIControlEventTouchUpInside];
    [invitePanel addSubview:fb];
    
    UIButton *weibo = [self greenBtn:@"Twitter" img:[UIImage imageNamed:@"twitter"]];
    weibo.frame=CGRectMake(158,12,143,52);
    weibo.tag=1;
    [weibo addTarget:self action:@selector(shareBtn:) forControlEvents:UIControlEventTouchUpInside];
    [invitePanel addSubview:weibo];

    UIButton *emailBtn = [self greenBtn:@"Email" img:[UIImage imageNamed:@"email"]];
    [invitePanel addSubview:emailBtn];
    emailBtn.frame=CGRectMake(10,75,143,52);

    emailBtn.tag=2;
    [emailBtn addTarget:self action:@selector(shareBtn:) forControlEvents:UIControlEventTouchUpInside];
    [invitePanel addSubview:emailBtn];

    UIButton *smsBtn = [self greenBtn:@"SMS" img:[UIImage imageNamed:@"sms"]];
    smsBtn.frame=CGRectMake(158,75,143,52);
    [smsBtn addTarget:self action:@selector(shareBtn:) forControlEvents:UIControlEventTouchUpInside];
    smsBtn.tag=3;
    [invitePanel addSubview:smsBtn];
    [self.view addSubview:invitePanel];
}
-(void) shareBtn:(UIButton *) sender{
    int tag=sender.tag;
    if(tag==0){
        [self publishPictureToFb];
    }else if(tag==1){
        [self tweet];

    }else if(tag==2){
        [self showContact:1];
        
    }else if(tag==3){
        [self showContact:2];
    }
}
-(void) publishPictureToFb{
    UIImage *logo =    [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://d1y3yrjny3p2xa.cloudfront.net/addfree.png"]]];

    BOOL displayedNativeDialog =
    [FBNativeDialogs
     presentShareDialogModallyFrom:self
     initialText:fbmsg
     image:logo
     url:[NSURL URLWithString:redirect]
     handler:^(FBNativeDialogResult result, NSError *error) {
         if (error) {
             /* handle failure */
         } else {
             if (result == FBNativeDialogResultSucceeded) {
                 alert(@"Facebook story posted!");
                 [Util ajax:@"http://www.json999.com/pr/xp.php?e=fb_posted&e1=native" callback:nil];
             } else {
                 /* handle user cancel */
                 [Util ajax:@"http://www.json999.com/pr/xp.php?e=fb_post_user_canceled&e1=native" callback:nil];
             }
         }
     }];
    if (!displayedNativeDialog) {
        NSMutableDictionary *params =
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
         @"Upload Pictures, get free gift cards", @"name",
         @"Upload Pictures, get free gift cards", @"caption",
         fbmsg, @"description",
         redirect, @"link",
         @"http://www.json999.com/pr/logo.png", @"picture",
         nil];
        if (!FBSession.activeSession.isOpen) {
            NSArray *permissions = [[NSArray alloc] initWithObjects:
                                    @"email",
                                    nil];
            [FBSession openActiveSessionWithReadPermissions:permissions
                                               allowLoginUI:YES
                                          completionHandler:^(FBSession *session,
                                                              FBSessionState state,
                                                              NSError *error) {
                                              if(!error){
                                                  [self postToFb:params];
                                              }
                                          }];
            return;
        }else{
            [self postToFb:params];
        }
    }
}
-(void)postToFb:(NSDictionary *)params{
    // Invoke the dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:
     ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or publishing a story.
             NSLog(@"Error publishing story.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled story publishing.");
             } else {
                 // Handle the publish feed callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"post_id"]) {
                     // User clicked the Cancel button
                     NSLog(@"User canceled story publishing.");
                 } else {
                     [Util ajax:@"http://www.json999.com/pr/xp.php?e=fb_posted&e1=webdialog" callback:nil];
                     alert(@"Facebook story posted!");
                 }
             }
         }
     }];
}

-(void) tweet{
    [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://d1y3yrjny3p2xa.cloudfront.net/addfree.png"]]];
    UIImage *logo =    [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://d1y3yrjny3p2xa.cloudfront.net/addfree.png"]]];

    NSString *msg=tweetmsg;
    TWTweetComposeViewController *tweet = [[TWTweetComposeViewController alloc] init];
    [tweet setInitialText:msg];
    [tweet addImage:logo];
    [Util ajax:@"http://www.json999.com/pr/xp.php?e=tweeted_bonus" callback:nil];
    [self presentModalViewController:tweet animated:YES];
}

- (void)showContact:(int)type {
    if(readContacts==YES){ // phone
        [self selectContacts:type];
        return;
    }
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) {
        // then, prompt out the notification
        ABAddressBookRequestAccessWithCompletion(addressBook,
                                                 ^(bool granted, CFErrorRef error) {
                                                     [self selectContacts:type];
                                                 });
    }else {
        [self selectContacts:type];
    }
}
-(void)selectContacts:(int) type;
{
    NSLog(@"start select");
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
    self.friendsWithEmails=[[NSMutableArray alloc] init];
    self.friendsWithPhone=[[NSMutableArray alloc] init];
    for ( int i = 0; i < CFArrayGetCount(allPeople); i++ ){
        ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
        NSString *name = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonFirstNameProperty));
        ABMultiValueRef emailMultiValue = ABRecordCopyValue(ref, kABPersonEmailProperty);
        NSArray *emailAddresses = (NSArray *)CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(emailMultiValue));
        if([emailAddresses count]>0){
            NSString *emails=[emailAddresses componentsJoinedByString:@","];
            [self.friendsWithEmails addObject:[NSString stringWithFormat:@"%@_____%@",name,emails]];
            NSLog(@"%@_____%@",name,emails);
        }
        
        CFRelease(emailMultiValue);

        ABMultiValueRef phonesRef = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        NSArray *phoneNumbers = (NSArray *)CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(phonesRef));
        if([phoneNumbers count]>0){
            NSString *phones=[phoneNumbers componentsJoinedByString:@","];
            [self.friendsWithPhone addObject:[NSString stringWithFormat:@"%@_____%@",name,phones]];
            NSLog(@"%@_____%@",name,phones);
        }
        CFRelease(phonesRef);
    }
    readContacts=YES;
    NSLog(@"done select");

    [self pushContactSelector:type];
}
-(void) pushContactSelector:(int)type{
    self.emailFriends=[[NSMutableSet alloc] init];
    self.textFriends=[[NSMutableSet alloc] init];

    UITableViewController *table=[[UITableViewController alloc] init];
    table.tableView.frame=CGRectMake(0,0,320,self.view.frame.size.height-self.tabBarController.view.frame.size.height);
    
    table.tableView.dataSource=self;
    table.tableView.delegate=self;
    table.tableView.tag=type;
    [table.tableView reloadData];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc ] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(contactSelectorDone:)];
    table.navigationItem.rightBarButtonItem=doneButton;
    doneButton.tag=type;
    NSLog(@"start select");

    [self.navigationController pushViewController:table animated:NO];
}
-(void) contactSelectorDone:(UIBarButtonItem*)sender{
    [self.navigationController popViewControllerAnimated:YES];

    
    NSString *msg=emailMsg;
    

    if(sender.tag==1){
      
        // Email Subject
        NSString *emailTitle = @"Hello from PictureRewards";
        // Email Content
        NSString *messageBody =msg;
        // To address
        NSArray *toRecipents = [self.emailFriends allObjects];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }else if (sender.tag==2){
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText])
        {
            controller.body = msg;
            controller.recipients =  [self.textFriends allObjects];;
            controller.messageComposeDelegate = self;
            [self presentModalViewController:controller animated:YES];
        }
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
          //  [Util ajax:@"http://www.json999.com/events.php?e=email_cancelled" callback:nil];
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            alert(@"Email Sent!");
            [Util ajax:@"http://www.json999.com/pr/xp.php?e=email_sent" callback:nil];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissModalViewControllerAnimated:YES];
    
    if (result == MessageComposeResultCancelled)
        NSLog(@"Message cancelled");
    else if (result == MessageComposeResultSent)
        NSLog(@"Message sent");
    else
        NSLog(@"Message failed");
}

-(void)viewDidUnload{
    self.friendPickerController = nil;
}

-(UIButton *)greenBtn:(NSString *)txt img:(UIImage *)insertImage{
    UIButton *ext = [UIButton buttonWithType:UIButtonTypeSystem];
    [ext setTitle:txt forState:UIControlStateNormal];
    [ext setBackgroundColor:[UIColor whiteColor]];
    [ext setTintColor:[UIColor blueColor]];
    CALayer * l = [ext layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:11.0];
    // You can even add a border
    [l setBorderWidth:2.0];
    [l setBorderColor:[[UIColor blueColor] CGColor]];
    
    [ext.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];

    return ext;
}
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 27;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sections;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index
{
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(tableView.tag==1){
        NSArray *sectionArray = [friendsWithEmails filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [self.sections objectAtIndex:section]]];
            return [sectionArray count];
    }else{
        NSArray *sectionArray = [friendsWithPhone filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [self.sections objectAtIndex:section]]];
        return [sectionArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    // Configure the cell...
    NSString *contact;
    if(tableView.tag==1){
        NSArray *sectionArray = [friendsWithEmails filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [self.sections objectAtIndex:indexPath.section]]];
        contact=[sectionArray objectAtIndex:indexPath.row];
    }else{
        NSArray *sectionArray = [friendsWithPhone filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [self.sections objectAtIndex:indexPath.section]]];
        contact=[sectionArray objectAtIndex:indexPath.row];
    }
    NSArray *ct=[contact componentsSeparatedByString:@"_____"];
    cell.textLabel.text=ct[0];
    cell.detailTextLabel.text=ct[1];
    return cell;
}

// Return the index for the location of the first item in an array that begins with a certain character
- (NSInteger)indexForFirstChar:(NSString *)character inArray:(NSArray *)array
{
    NSUInteger count = 0;
    for (NSString *str in array) {
        if ([str hasPrefix:character]) {
            return count;
        }
        count++;
    }
    return 0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    NSString *contact;
    if(tableView.tag==1){
        NSArray *sectionArray = [friendsWithEmails filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [self.sections objectAtIndex:path.section]]];
       contact=[sectionArray objectAtIndex:path.row];
    }else{
        NSArray *sectionArray = [friendsWithPhone filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [self.sections objectAtIndex:path.section]]];
       contact=[sectionArray objectAtIndex:path.row];
    }
    NSArray *ct=[contact componentsSeparatedByString:@"_____"];
    NSString *ctobj=ct[1];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:path];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        if(tableView.tag==1){
            [self.emailFriends removeObject:ctobj];
        }else{
            [self.textFriends removeObject:ctobj];
        }
    } else {
        if(tableView.tag==1){
            [self.emailFriends addObject:ctobj];
        }else{
            [self.textFriends addObject:ctobj];
        }
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}


@end
