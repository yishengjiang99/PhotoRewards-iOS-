//
//  RequestViewController.m
//  PictureRewards
//
//  Created by Yisheng Jiang on 6/18/13.
//  Copyright (c) 2013 ragnus. All rights reserved.
//

#import "RequestViewController.h"
#import "UILabel+UILabel_fonts.h"
#import "UIButton+SnapAdditions.h"
#import "AppDelegate.h"
#import "MyOfferViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>

@interface RequestViewController ()<UIPickerViewDelegate,UIPickerViewDataSource, UIScrollViewDelegate,UITextFieldDelegate,MFMailComposeViewControllerDelegate>
@property (strong,retain) UIScrollView *steps;
@property (strong,retain) UIPageControl *pageControl;
@property (strong, retain) NSString *title;
@property (strong, retain) NSString *description;
@property (strong, retain) NSString *category;
@property (strong, retain) NSString *sms;
@property (strong, retain) NSString *url;
@property (strong, retain) NSString *email;
@property (strong, nonatomic) UILabel *xpLabel;
@property (strong, nonatomic) NSString *myNumber;
@property int offerId;
@property int cashBid;
@property int quantity;
@property int points;
@property (strong, nonatomic) UITextField *titleText;
@property (strong, nonatomic) UITextField *descText;
@property (strong, nonatomic) UITextField *urlText;
@property (strong, nonatomic) UITextField *emailText;
@property (strong, nonatomic) UITextField *smsField;
@property (strong, nonatomic) UITextField *emailField;
@property (strong, retain) NSArray *categories;
@property (strong, retain) NSArray *bidtiers;
@property (nonatomic, strong) AppDelegate *delegate;

@property (strong, retain) NSArray *quantities;
@end

@implementation RequestViewController
@synthesize steps,pageControl,title,description,cashBid,titleText,descText,urlText,emailText,categories,bidtiers,smsField,emailField,quantity,category,quantities,sms,email,url,points,xpLabel,offerId,myNumber,delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImageView *logoView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        CGRect frame = logoView.frame;
        frame.origin.x=0.0f;
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:logoView]];
    }
    return self;
}
-(void)loadHeader
{
    [Hud getK:self];
}
-(void)viewDidAppear:(BOOL)animated{
    [self loadHeader];
}
- (void)viewDidLoad
{
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSDictionary *bidConfigs=delegate.config;
    if([[UIDevice currentDevice].systemVersion floatValue]>=7.0){
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:1]];
    categories=bidConfigs[@"categories"];
    bidtiers=bidConfigs[@"bidtiers"];
    myNumber=bidConfigs[@"myNumber"];
    quantities=@[@99,@50,@40,@20,@10,@5];
    quantity=20;
    cashBid=[[bidtiers objectAtIndex:2] intValue];
    [super viewDidLoad];
    
    CGFloat height=self.view.bounds.size.height;
    steps = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
    steps.contentSize=CGSizeMake(320*5, height);
    steps.pagingEnabled=YES;
    [steps setScrollEnabled:YES];
    
    UIView *step0=[[UIView alloc] initWithFrame:CGRectMake(0,0,320,height)];
    UILabel *q0=[[UILabel alloc] initWithFrame:CGRectMake(10,30,300, 80)];
    [q0 setBackgroundColor:[UIColor clearColor]];
    q0.numberOfLines=4;
    [q0 getFancy:15.0f];
    q0.textAlignment=UITextAlignmentCenter;
    q0.text=@"Post an Offer for Pictures.\nGain 10 XP for every point you spend.\nLeveling up = more powerful Bonus Code";
    [step0 addSubview:q0];
    
    UIButton *newOffer = [UIButton buttonWithType:UIButtonTypeSystem];
    [newOffer setTitle:@"New Offer" forState:UIControlStateNormal];
    newOffer.frame=CGRectMake(160-71,100,142,52);
    newOffer.tag=0;
    
    [newOffer addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *myListing = [UIButton buttonWithType:UIButtonTypeSystem];
    [myListing setTitle:@"My Listings" forState:UIControlStateNormal];
     myListing.frame=CGRectMake(160-71,180,142,52);
     myListing.tag=9;
    [myListing addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    [step0 addSubview:newOffer];
    [step0 addSubview:myListing];
    
    UIButton *questions = [UIButton buttonWithType:UIButtonTypeSystem];
    [questions setTitle:@"Questions?" forState:UIControlStateNormal];
    questions.frame=CGRectMake(160-71,280,142,52);
    [questions addTarget:self action:@selector(callUs:) forControlEvents:UIControlEventTouchUpInside];
    
    [step0 addSubview:questions];
    
    [steps addSubview:step0];

    //**********step 1*********************
    UIView *step1=[[UIView alloc] initWithFrame:CGRectMake(320,0,320,height)];
    UILabel *q1=[[UILabel alloc] initWithFrame:CGRectMake(10,10,300, 35)];
    [q1 setBackgroundColor:[UIColor clearColor]];
    [q1 getFancy:20.0f];

    q1.text=@"Enter a Title for the picture";
    
    titleText = [[UITextField alloc] initWithFrame:CGRectMake(10, 40, 300, 50)];
    titleText.borderStyle = UITextBorderStyleRoundedRect;
    titleText.font = [UIFont systemFontOfSize:15];
    titleText.placeholder = @"enter title";
    titleText.returnKeyType = UIReturnKeyNext;
    titleText.clearButtonMode = UITextFieldViewModeWhileEditing;
    titleText.delegate=self;
    
    UILabel *q11=[[UILabel alloc] initWithFrame:CGRectMake(10,100,300, 35)];
    [q11 setBackgroundColor:[UIColor clearColor]];
    [q11 getFancy:20.0f];
    q11.text=@"Pick a HashTag";
    [step1 addSubview:q11];
    UIPickerView *categoryPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 140, 320, 170)];
    categoryPicker.delegate = self;
    categoryPicker.showsSelectionIndicator = YES;
    categoryPicker.dataSource=self;
    categoryPicker.tag=0;
    
    int categoryindex=1;
    category = [categories objectAtIndex:categoryindex];
    [categoryPicker selectRow:categoryindex inComponent:0 animated:YES];
    
    UIButton *hashTagContact = [UIButton buttonWithType:UIButtonTypeSystem];
    [hashTagContact setTitle:@"Other HashTags" forState:UIControlStateNormal];

    hashTagContact.frame=CGRectMake(10,310,142,52);
    hashTagContact.tag=1;
    [hashTagContact addTarget:self action:@selector(emailUs:) forControlEvents:UIControlEventTouchUpInside];
    
    [step1 addSubview:hashTagContact];
    [step1 addSubview:categoryPicker];
    
    UIButton *b1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [b1 setTitle:@"Next" forState:UIControlStateNormal];
    b1.frame=CGRectMake(167,310,143,52);
    b1.tag=1;
    [b1 addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    [step1 addSubview:q1];
    [step1 addSubview:titleText];
    [step1 addSubview:b1];
    [steps insertSubview:step1 atIndex:0];
    
    //***************STEP 2****
    UIView *step33=[[UIView alloc] initWithFrame:CGRectMake(640,0,320,height)];
    UILabel *q33=[[UILabel alloc] initWithFrame:CGRectMake(4,10,150, 35)];
    [q33 getFancy:15.0f];

    q33.text=@"Select a bid price";
    
    UIPickerView *pricePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(4,50,150, 200)];
    pricePicker.delegate = self;
    pricePicker.showsSelectionIndicator = YES;
    pricePicker.dataSource=self;
    pricePicker.tag=1;
    [pricePicker selectRow:2 inComponent:0 animated:YES];

    UILabel *q333=[[UILabel alloc] initWithFrame:CGRectMake(155,10,150, 35)];
    [q333 getFancy:15.0f];
    q333.text=@"Maximum quantity";
    
    UIPickerView *qPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(160, 50, 150, 200)];
    qPicker.delegate = self;
    qPicker.showsSelectionIndicator = YES;
    qPicker.dataSource=self;
    qPicker.tag=2;
    [qPicker selectRow:2 inComponent:0 animated:YES];

    UIButton *b33 = [UIButton buttonWithType:UIButtonTypeSystem];
    [b33 setTitle:@"Save" forState:UIControlStateNormal];
    b33.frame=CGRectMake(167,310,143,52);
    b33.tag=2;
    [b33 setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    [b33 addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    
    xpLabel=[[UILabel alloc] initWithFrame:CGRectMake(20,265,280, 30)];
    [xpLabel getFancy:20.0f];

    xpLabel.text=@"";
    
    [step33 addSubview:q33];
    [step33 addSubview:pricePicker];
    [step33 addSubview:b33];
    [step33 addSubview:qPicker];
    [step33 addSubview:q333];
    [step33 addSubview:xpLabel];
    [steps insertSubview:step33 atIndex:2];
    
    //***************stepbreak****
    UIView *step2=[[UIView alloc] initWithFrame:CGRectMake(960,0,320,height)];
    UILabel *q2=[[UILabel alloc] initWithFrame:CGRectMake(10,10,300, 35)];
    [q2 getFancy:20.0f];
   // [q2 setBackgroundColor:[UIColor blackColor]];
    q2.text=@"Give some specific details?";
    UITextField *a2 = [[UITextField alloc] initWithFrame:CGRectMake(10, 40, 300, 100)];
    a2.borderStyle = UITextBorderStyleRoundedRect;
    a2.font = [UIFont systemFontOfSize:15];
    a2.placeholder = @"This step is optional";
    a2.returnKeyType = UIReturnKeyDone;
    a2.clearButtonMode = UITextFieldViewModeWhileEditing;
    a2.delegate=self;
    
    UILabel *q22=[[UILabel alloc] initWithFrame:CGRectMake(10,160,300,35)];
    [q22 getFancy:20.0f];

    q22.text=@"An URL for reference";
    UITextField *a22 = [[UITextField alloc] initWithFrame:CGRectMake(10, 200, 300, 50)];
    a22.borderStyle = UITextBorderStyleRoundedRect;
    a22.font = [UIFont systemFontOfSize:15];
    a22.placeholder = @"Also Optional";
    a22.returnKeyType = UIReturnKeyDone;
    a22.clearButtonMode = UITextFieldViewModeWhileEditing;
    a22.keyboardType=UIKeyboardTypeURL;
    a22.delegate=self;
    
    UIButton *done2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [done2 setTitle:@"Done" forState:UIControlStateNormal];
    done2.frame=CGRectMake(10,310,143,52);
    done2.tag=5;
    [done2 addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    [done2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [done2 setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    
    UIButton *b2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [b2 setTitle:@"Next" forState:UIControlStateNormal];
    
    b2.frame=CGRectMake(167,310,143,52);
    b2.tag=3;
    
    [b2 addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    [step2 addSubview:q2];
    [step2 addSubview:a2];
    [step2 addSubview:b2];
    [step2 addSubview:q22];
    [step2 addSubview:done2];
    [step2 addSubview:a22];
    [steps insertSubview:step2 atIndex:1];
    descText=a2;
    urlText=a22;
    
///*** pstep 4****************************
    UIView *step4=[[UIView alloc] initWithFrame:CGRectMake(960+320,0,320,height)];
    UILabel *q4=[[UILabel alloc] initWithFrame:CGRectMake(10,10,300, 50)];
    q4.numberOfLines=2;
    [q4 getFancy:20.0f];

    q4.text=@"Txt me when someone uploads\na picture (optional)";
    smsField = [[UITextField alloc] initWithFrame:CGRectMake(10, 65, 300, 50)];
    smsField.borderStyle = UITextBorderStyleRoundedRect;
    smsField.font = [UIFont systemFontOfSize:15];
    smsField.placeholder = @"(US Only) e.g. 650-804-6836";
    smsField.returnKeyType = UIReturnKeyDone;
    smsField.keyboardType=UIKeyboardTypeDefault;
    smsField.delegate=self;

    UILabel *q44=[[UILabel alloc] initWithFrame:CGRectMake(10,130,300,35)];
    [q44 getFancy:20.0f];
    q44.text=@"Or Email";
    emailField = [[UITextField alloc] initWithFrame:CGRectMake(10, 165, 300, 50)];
    emailField.borderStyle = UITextBorderStyleRoundedRect;
    emailField.font = [UIFont systemFontOfSize:15];
    emailField.placeholder = @"Also Optional";
    emailField.returnKeyType =UIReturnKeyDone;
    emailField.keyboardType=UIKeyboardTypeEmailAddress;
    emailField.delegate=self;
    
    UIButton *b4 = [UIButton buttonWithType:UIButtonTypeSystem];
    [b4 setTitle:@"Done" forState:UIControlStateNormal];
    b4.frame=CGRectMake(167,310,143,52);
    b4.tag=4;
    [b4 addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    [step4 addSubview:q4];
    [step4 addSubview:smsField];
    [step4 addSubview:emailField];
    [step4 addSubview:q44];
    [step4 addSubview:b4];
    
    [steps insertSubview:step4 atIndex:3];
    
    //********************page break*****
    steps.showsHorizontalScrollIndicator=YES;
    steps.delegate=self;
    pageControl = [[UIPageControl alloc] init];
    pageControl.frame = CGRectMake(110,350,100,100);
    pageControl.numberOfPages = 5;
    pageControl.currentPage = 0;
    pageControl.backgroundColor = [UIColor clearColor];

    [self.view addSubview:steps];
    [self.view addSubview:pageControl];
    
    [self updateXp];
}
-(void)updateXp
{
    xpLabel.text=[NSString stringWithFormat:@"Total XP earning: %d",cashBid*quantity*10];
}
-(void)next:(UIButton *)sender{
    int tag=sender.tag;
    if(tag==0){
        [self scrollTo:1];
    }
    if(tag==1){
        [steps setScrollEnabled:TRUE];
        title=titleText.text;
        if(title==nil || [title isEqualToString:@""]){
            alert(@"Title must not be empty");
            return;
        }
        [self scrollTo:2];
    }
    if(tag==2){
        NSString *post=[NSString stringWithFormat:@"title=%@&category=%@&bid=%d&q=%d",title,category,cashBid,quantity];
        NSString *posturl=@"https://www.json999.com/pr/request.php";
        NSDictionary *ret=httpPost(post,posturl);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[ret objectForKey:@"title"]
                                                        message:[ret objectForKey:@"msg"]
                                                       delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        offerId=[[ret objectForKey:@"offerId"] intValue];
        [alert show];
        [self scrollTo:3];
    }
    if(tag==3){
        [steps setScrollEnabled:FALSE];
        description=descText.text;
        url=urlText.text;
        [self scrollTo:4];
    }
    if(tag==4){
        sms=smsField.text;
        email=emailField.text;
        if(!offerId) return;
        NSString *post=[NSString stringWithFormat:@"cmd=moreInfo&offerId=%d&description=%@&url=%@&sms=%@&email=%@",offerId,description,url,sms,email];
        NSString *posturl=@"https://www.json999.com/pr/request.php";
        NSDictionary *ret=httpPost(post,posturl);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[ret objectForKey:@"title"]
                                                        message:[ret objectForKey:@"msg"]
                                                       delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [self scrollTo:0];
        [steps setScrollEnabled:FALSE];
        
    }if (tag==5) {
        smsField.text=@"";
        titleText.text=@"";
        descText.text=@"";
        urlText.text=@"";
        emailField.text=@"";
        [self scrollTo:0];
        [steps setScrollEnabled:FALSE];

    }
    if(tag==9){
        MyOfferViewController *mylist=[[MyOfferViewController alloc] init];
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController pushViewController:mylist animated:YES];
    }
}

-(void)emailUs:(UIButton *)sender{
    NSString *emailTitle = @"Hello from [PictureRewards]";

    if(sender.tag==1){
        // Email Subject
        emailTitle = @"Request for HashTag [PictureRewards]";
    }else if(sender.tag==2){
        emailTitle =@"Question about listing Picture Offers [PictureRewards]";
    }
    [self emailWithTitle:emailTitle];
}
-(void)emailWithTitle:(NSString *)emailTitle{
    // Email Content
    NSString *messageBody =[NSString stringWithFormat:@"My username is %@",getUsername()];
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"yisheng.jiang@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
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

-(void)scrollTo:(int)page{
    CGRect frame = steps.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [steps scrollRectToVisible:frame animated:YES];
}
-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    [textField resignFirstResponder];
    return NO; // We do not want UITextField to insert line-breaks.
}
-(void)callUs:(id) sender{
    if(myNumber) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:myNumber]];
    else [self emailWithTitle:@"Question about listing Picture Offers [PictureRewards]"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    if(pickerView.tag==0){
        category=[categories objectAtIndex:row];
    }else if(pickerView.tag==1){
        cashBid=[[bidtiers objectAtIndex:row] intValue];
        [self updateXp];
    }else{
        quantity=[[quantities objectAtIndex:row] intValue];
        [self updateXp];
    }
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if(pickerView.tag==0){
        return [categories count];
    }else if(pickerView.tag==1){
        return [bidtiers count];
    }else{
        return [quantities count];
    }
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

//// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(pickerView.tag==0){
        return [categories objectAtIndex:row];
    }else if(pickerView.tag==1){
        return [NSString stringWithFormat:@"%@ Points",[bidtiers objectAtIndex:row]];
    }else{
        return [NSString stringWithFormat:@"%@ People",[quantities objectAtIndex:row]];
    }
}
// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if(pickerView.tag==1 || pickerView.tag==2){
        return 120;
    }else{
        return 300;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    if(pickerView.tag==1 || pickerView.tag==2){
        return 25;
    }else{
        return 57;
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.steps.frame.size.width; // you need to have a **iVar** with getter for scrollView
    float fractionalPage = self.steps.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page; // you need to have a **iVar** with getter for pageControl
}

@end
