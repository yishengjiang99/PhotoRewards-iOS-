//
//  TutorialViewController.m
//  PictureRewards
//
//  Created by Yisheng Jiang on 6/25/13.
//  Copyright (c) 2013 ragnus. All rights reserved.
//

#import "TutorialViewController.h"
#import "UILabel+UILabel_fonts.h"
@interface TutorialViewController ()<UIScrollViewDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) UIScrollView *steps;
@property (strong, nonatomic) UIPageControl *pageControl;

@end

@implementation TutorialViewController
@synthesize steps,pageControl;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title=@"How It Works";
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    NSArray *instructions=[Util getJsonArray:@"http://www.json999.com/pr/instructions.php?t=1"];
    CGFloat height=self.view.frame.size.height;
    steps = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
    steps.contentSize=CGSizeMake(320*7, height);
    steps.pagingEnabled=YES;
    [steps setBackgroundColor:[UIColor lightGrayColor]];
    [steps setScrollEnabled:YES];
    for(int i=0;i<6;i++){
        [steps addSubview:[self makeStep:i withtext:[instructions objectAtIndex:i]]];
    }

    [self.view addSubview:steps];
    //********************page break*****
    steps.delegate=self;
    pageControl = [[UIPageControl alloc] init];
    pageControl.frame = CGRectMake(110,380,100,100);
    pageControl.numberOfPages = 6;
    pageControl.currentPage = 0;
    pageControl.backgroundColor = [UIColor clearColor];
    [self.view addSubview:steps];
    [self.view addSubview:pageControl];
    [self.tabBarController.tabBar setHidden:YES];

//    [steps setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"reqbackground"]]];

	// Do any additional setup after loading the view.
}
-(UIView *)makeStep:(int) stepInt withtext:(NSString *)text
{
    int xo=320*stepInt;
    UIView *stepview=[[UIView alloc] initWithFrame:CGRectMake(xo,0,320,self.view.frame.size.height)];
    UILabel *instr=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    instr.textAlignment=UITextAlignmentCenter;
    instr.text=text;
    if(stepInt>=4){
        [instr getFancy:14.0f];
    }else{
        [instr getFancy:17.0f];
    }
    [instr setTextColor:[UIColor whiteColor]];
    UIImage *img=[UIImage imageNamed:[NSString stringWithFormat:@"step%d",stepInt]];
    UIImageView* imgView=[[UIImageView alloc] initWithImage:img];
    imgView.contentMode=UIViewContentModeScaleAspectFit;
    if(stepInt==5){
        imgView.frame=CGRectMake(60, 30, 180, 480*180/320);
    }else{
        imgView.frame=CGRectMake(60, 30, 180, 568*180/320);
    }
    [stepview addSubview:imgView];

    UILabel *i2=[[UILabel alloc] initWithFrame:CGRectMake(0, 360, 320, 20)];
    i2.textAlignment=UITextAlignmentCenter;
    [i2 setTextColor:[UIColor blackColor]];
    [i2 setFont:[UIFont systemFontOfSize:12.0f]];
    [i2 setBackgroundColor:[UIColor clearColor]];
    
    if(stepInt<5){
        i2.text=[NSString stringWithFormat:@"Swipe For Next Step"];
    }else{
        if([text isEqual:@"Be sure to read and follow the rules!"]){
            UIButton *readTerms=[UIButton buttonWithType:UIButtonTypeRoundedRect];
            [readTerms setTitle:@"Read Terms" forState:UIControlStateNormal];
            [readTerms addTarget:self action:@selector(readTerms) forControlEvents:UIControlEventTouchUpInside];
            readTerms.frame=CGRectMake(30,320,100,40);
            
            UIButton *agree=[UIButton buttonWithType:UIButtonTypeRoundedRect];
            [agree setTitle:@"Agree" forState:UIControlStateNormal];
            [agree addTarget:self action:@selector(agreeTerms) forControlEvents:UIControlEventTouchUpInside];
            agree.frame=CGRectMake(190,320,100,40);
            i2.text=[NSString stringWithFormat:@"Swipe to agree and start with PhotoRewards"];
            [stepview addSubview:readTerms];
            [stepview addSubview:agree];
        }else{
            i2.text=[NSString stringWithFormat:@"Swipe to get started with PhotoRewards"];
        }
    }

    [instr setTextColor:[UIColor whiteColor]];
    [stepview addSubview:imgView];
    [stepview addSubview:instr];
    [stepview addSubview:i2];
    
    return stepview;
}
-(void)readTerms{
    UIViewController *webViewController = [[UIViewController alloc] init];
    UIWebView *uiWebView = [[UIWebView alloc] initWithFrame: CGRectMake(0,0,320,480)];
    [uiWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.json999.com/pr/terms.php"]]];
    
    [webViewController.view addSubview: uiWebView];
    [self.navigationController pushViewController:webViewController animated:YES];
}
-(void)agreeTerms{
    [self.navigationController popViewControllerAnimated:NO];
    return;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.view.frame.size.width; // you need to have a **iVar** with getter for scrollView
    float fractionalPage = self.steps.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    if(page>5){
        [self.navigationController popViewControllerAnimated:NO];
        return;
    }
    self.pageControl.currentPage = page; // you need to have a **iVar** with getter for pageControl
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
