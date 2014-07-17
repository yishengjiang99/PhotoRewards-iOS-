//
//  Hud.m
//  PictureRewards
//
//  Created by Yisheng Jiang on 6/23/13.
//  Copyright (c) 2013 ragnus. All rights reserved.
//

#import "Hud.h"

@implementation Hud
static Hud *k;
@synthesize controller;
+(Hud *) getK: (UIViewController *)viewController
{
    if(!k) k=[[self alloc] init];
    k.controller=viewController;
    [k setBtn];
    return k;
}

-(Hud *) init {
    self=[super init];
    if(self){

    }
    return self;
}
-(void)setBtn{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 104.0, 40.0)];
    label.font = [UIFont boldSystemFontOfSize:12];
    label.backgroundColor=[UIColor clearColor];
   // label.textColor = [UIColor colorWithRed:255 green:255 blue:0 alpha:1];
    label.text=[NSString stringWithFormat:@"Points: %d\nXP: %d ",getUserPoints(),getXp()];
    label.numberOfLines=2;
    label.textAlignment=NSTextAlignmentRight;
    self.btn=[[UIBarButtonItem alloc] initWithCustomView:label];
    [self.controller.navigationItem setRightBarButtonItem:k.btn];
}

+(void)update
{
    double delayInSeconds=0.30;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [Util getConfigs];
        [k setBtn];
    });

}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
