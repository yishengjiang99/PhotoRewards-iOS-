//
//  OfferDetailsViewController.m
//  PictureRewards
//
//  Created by Yisheng Jiang on 6/14/13.
//  Copyright (c) 2013 ragnus. All rights reserved.
//

#import "OfferDetailsViewController.h"
#import "UILabel+UILabel_fonts.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "Offer.h"
#import <Twitter/Twitter.h>
#import "REComposeViewController.h"
#import <AVFoundation/AVFoundation.h>
 #import <ImageIO/CGImageProperties.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "JSON.h"
#import "TJControllerViewController.h"

@interface OfferDetailsViewController ()<SPOfferWallViewControllerDelegate>
{
	NSDictionary *imageMeta;
}
@property (nonatomic,retain) UIImagePickerController *imgPicker;
@property (nonatomic,strong) UIImage *userPic;
@property (nonatomic,strong) UIViewController *uploader;
@property (nonatomic,strong) UIScrollView *scroll;
@property (nonatomic,strong) NSString *uploadedPicture;
@property (nonatomic,strong) NSArray *piclist;
@property (nonatomic,strong) AppDelegate *delegate;

@property (nonatomic, strong) IBOutlet UIButton *confirm;
@property int pointsEarned;
@property (nonatomic,strong) IBOutlet UISwitch *shareToFb;
@property BOOL shareToFbBool;
@end

@implementation OfferDetailsViewController
@synthesize offer,points,imgPicker,uploader,scroll,uid,bonusCode,bonusUpper,piclist,shareToFb,shareToFbBool,delegate,uploadedPicture,pointsEarned,confirm;
- (void) offerWallViewController:(SPOfferWallViewController *)offerWallVC isFinishedWithStatus:(int)status {
	
    // we could know if status determines a network error by comparing it with the
    // SPONSORPAY_ERR_NETWORK constant defined in SPOfferWallViewController.h
}
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.imgPicker=[[UIImagePickerController alloc] init];
        imgPicker.delegate=self;
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
    UIView *top=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 62)];
    UIImageView *logo=[[UIImageView alloc] initWithFrame:CGRectMake(20,10,65,65)];
    if(offer.icon){
        [logo setImage:offer.icon];
    }else{
        [logo setImageWithURL:[NSURL URLWithString:offer.imageUrl]
             placeholderImage:[UIImage imageNamed:@"camera"]
                    completed:nil];
    }
    [self.view setBackgroundColor:[UIColor whiteColor]];
    CALayer * l = [logo layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
    
    // You can even add a border
    [l setBorderWidth:2.0];
    [l setBorderColor:[[UIColor blackColor] CGColor]];
    [top addSubview:logo];
    UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    buyButton.frame = CGRectMake(267, 10, 50, 50);
    
    [buyButton setTitle:offer.points forState:UIControlStateNormal];
    [buyButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [buyButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [buyButton setBackgroundColor :[UIColor colorWithPatternImage:[UIImage imageNamed:@"circle"]]];
    [top addSubview:buyButton];
    UILabel *name =[[UILabel alloc] initWithFrame:CGRectMake(90, 10, 170, 20)];
    [name setFont:[UIFont boldSystemFontOfSize:14]];
    name.lineBreakMode=UILineBreakModeTailTruncation;
    [name setBackgroundColor:[UIColor clearColor]];
    name.text=offer.name;
    [name setNumberOfLines:2];
    
    [top addSubview:name];
    NSString *action=@"Upload A Snapshot";
    if(offer.action){
        action=offer.action;
    }
    
    UILabel *subt =[[UILabel alloc] initWithFrame:CGRectMake(90, 30, 170, 40)];
    [subt setFont:[UIFont systemFontOfSize:11]];
    [subt setText:action];
    [subt setNumberOfLines:0];
    [subt sizeToFit];
    [top addSubview:subt];
    [self.view addSubview:top];
    
    UIView *actionpanel =[[UIView alloc] initWithFrame:CGRectMake(0, 72, 320, 55)];
    if(![offer.cmd isEqual:@""] || (offer.url && ![offer.url isEqualToString:@"(null)"] && ![offer.url isEqualToString:@""])){
		
        if(!offer.hint) offer.hint=@"Hint";
        UIButton *ext = [UIButton buttonWithType:UIButtonTypeCustom];
        ext.frame=CGRectMake(20,12,140,40);
        UIImage *btnImg=[[UIImage imageNamed:@"greenButton.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        [ext setBackgroundImage:btnImg forState:UIControlStateNormal];
        [ext.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [ext setTitle:offer.hint forState:UIControlStateNormal];
        [ext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [ext setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
        [ext addTarget:self action:@selector(hintClicked:) forControlEvents:UIControlEventTouchUpInside];
        [actionpanel addSubview:ext];
    }
    if(![offer.type isEqualToString:@"CPA"]){
        UIButton *up = [UIButton buttonWithType:UIButtonTypeSystem];
        CALayer * l = [up layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:11.0];
        // You can even add a border
        [l setBorderWidth:2.0];
        [l setBorderColor:[[UIColor blueColor] CGColor]];
        up.frame=CGRectMake(170,12,140,40);
        [up setImage:[UIImage imageNamed:@"upload"] forState:UIControlStateNormal];
        [up.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
        [up setTitle:@"Upload" forState:UIControlStateNormal];
        [up setImage:[UIImage imageNamed:@"upload"] forState:UIControlStateNormal];
        CGFloat spacing = 10; // the amount of spacing to appear between image and title
        up.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
        up.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
        [actionpanel addSubview:up];
        [up addTarget:self action:@selector(uploadTapped:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        
    }
    [actionpanel setBackgroundColor:[UIColor colorWithWhite:0.99 alpha:0.3]];
    [self.view addSubview:actionpanel];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.navigationController setNavigationBarHidden:NO];
    [self loadUploadedPictures];
    
}

-(void)hintClicked:(id)sender{
	
	if(!self.offer.url){
		self.offer.url = self.offer.cmd;
	}
	if(!self.offer.url) {
		return;
	}
	[Util ajax:[NSString stringWithFormat:@"http://json999.com/event.php?action=clicked&url=%@&refId=%@",urlencode(self.offer.url),self.offer.refId] callback:nil];
	
	if([offer.cmd isEqualToString:@"sponsorpayWall"]){
		[SponsorPaySDK startForAppId:@"23804"
							  userId:[NSString stringWithFormat:@"%d",getUid()] /* Your current User ID as NSString */
					   securityToken: @"177bed0c9ede4fe72a17f89e1a0f5032"];
		
		[SponsorPaySDK showOfferWallWithParentViewController:self];
		
		[Util ajax:[NSString stringWithFormat:@"http://json999.com/event.php?action=clicked&url=%@&refId=%@",@"sponsorpaysdk",offer.refId] callback:nil];
		
	}else if([offer.cmd isEqualToString:@"tjWall"]){
		[self.navigationController pushViewController:[[TJControllerViewController alloc] initWithType:TapjoyWalll] animated:YES];
		[Util ajax:[NSString stringWithFormat:@"http://json999.com/event.php?action=clicked&url=%@&refId=%@",@"tapjoysdk",offer.refId] callback:nil];
		
	}else if([offer.cmd isEqualToString:@"CPA"]){
		NSURL *url = [NSURL URLWithString:offer.url];
		[[UIApplication sharedApplication] openURL:url];
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
	}
	
    NSURL *url = [NSURL URLWithString:offer.url];
    if (![[UIApplication sharedApplication] openURL:url])
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
}
-(void)uploadTapped:(id)sender{
    if(offer.canUpload!=1){
        NSString *canupload=[Util httpget:[NSString stringWithFormat:@"http://www.json999.com/pr/canupload.php?uid=%d&refId=%@",getUid(),offer.refId]];
        if([canupload isEqualToString:@"no"]){
            NSString *dir=@"You must try this app and take a screenshot from within the app before you can upload a picture.";
            if([delegate.config objectForKey:@"dir"]){
                dir=[delegate.config objectForKey:@"dir"];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Pictures for Giftcards"
                                                            message:dir
                                                           delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
            [alert show];
            return;
        }else{
            offer.type=@"DoneApp";
            offer.refId=canupload;
        }
    }
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    sheet.tag=999;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [sheet addButtonWithTitle:@"Take Photo"];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [sheet addButtonWithTitle:@"Choose Existing"];
    }
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    [sheet showFromTabBar:self.tabBarController.tabBar];
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0) return;
    else if(buttonIndex==1){
		[self hintClicked:nil];

    }else{
        UIViewController * viewController=[[UIViewController alloc] init];
        viewController.navigationItem.title =@"How to take a screen shot";
        UIImageView *iv=[[UIImageView alloc] initWithFrame:viewController.view.frame];
        iv.contentMode=UIViewContentModeScaleAspectFit;
        [iv setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        iv.clipsToBounds=YES;
        [iv setImage:[UIImage imageNamed:@"screenshothow"]];
        viewController.view=iv;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}


- (UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    CGFloat scaleFactor;
    if (oldWidth > oldHeight) {
        scaleFactor = width / oldWidth;
    } else {
        scaleFactor = height / oldHeight;
    }
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    return [self imageWithImage:image scaledToSize:newSize];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)howSnap:(UIButton *)sender{
    UIImageView *iv=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screenshothow"]];
    iv.contentMode=UIViewContentModeScaleAspectFit;
    UIViewController * viewController=[[UIViewController alloc] init];
    viewController.navigationItem.title =@"How to take a screen shot";
    viewController.view=iv;
    [self.navigationController pushViewController:viewController animated:YES];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;
    int tag=actionSheet.tag;
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if(tag<500){
        
        NSDictionary *pic=[piclist objectAtIndex:tag];
        NSString *picId=[pic objectForKey:@"id"];
        NSString *post=[NSString stringWithFormat:@"picid=%@&complaint=%@",picId,buttonTitle];
        NSString *url=@"http://www.json999.com/pr/report.php";
        NSDictionary *ret=httpPost(post,url);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[ret objectForKey:@"title"]
                                                        message:[ret objectForKey:@"msg"]
                                                       delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if ([@"Take Photo" isEqual:buttonTitle]) {
		NSArray *devices = [[NSArray alloc]init];
		devices = [AVCaptureDevice devices];

        self.imgPicker.sourceType=UIImagePickerControllerSourceTypeCamera;

        [self.navigationController presentViewController:imgPicker animated:YES completion:nil];
    }
    else if([@"Choose Existing" isEqual:buttonTitle]) {
        self.imgPicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        [self.navigationController presentViewController:imgPicker animated:YES completion:nil];
    }else{
        return;
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	[self.imgPicker dismissModalViewControllerAnimated:NO];
    NSLog(@"canceled");
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self.imgPicker dismissModalViewControllerAnimated:NO];
    //self.tabBarController.tabBar.hidden=YES;
	UIImage* img = [info objectForKey:UIImagePickerControllerOriginalImage];
    if(!img) return;

	imageMeta = (NSDictionary *)[info valueForKey:UIImagePickerControllerMediaMetadata];
		
	if(!imageMeta){
		NSURL *url=[info valueForKey:UIImagePickerControllerReferenceURL];
		static ALAssetsLibrary *lib;
		if(!lib){
			lib = [[ALAssetsLibrary alloc] init];
		}
		
		[lib assetForURL:url resultBlock:^(ALAsset *asset) {
			// only include photos with latitude and longitude and startdate
			imageMeta = asset.defaultRepresentation.metadata;
			CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
			
		} failureBlock:^(NSError *error) {
			NSLog(@"err %@", error);
		}];
	}
	
    
    UIImage *newpic = [self imageWithImage:img scaledToMaxWidth:260   maxHeight:390];
    self.userPic=newpic;
    uploader=[[UIViewController alloc] init];
    if([[UIDevice currentDevice].systemVersion floatValue]>=7.0){
        uploader.edgesForExtendedLayout=UIRectEdgeNone;
    }
    UIImageView *uiv=[[UIImageView alloc] initWithImage:newpic];
    uiv.frame=CGRectMake(30, 5, 260, 370);
    uiv.contentMode=UIViewContentModeTop;
    uiv.clipsToBounds=YES;
    [uploader.view addSubview:uiv];
    confirm =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    confirm.frame=CGRectMake(320/2-75,375,150,40);
    [confirm setBackgroundColor:[UIColor whiteColor]];
    [confirm setTintColor:[UIColor blueColor]];
    CALayer * l = [confirm layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:11.0];
    // You can even add a border
    [l setBorderWidth:2.0];
    [l setBorderColor:[[UIColor blueColor] CGColor]];
    
    [confirm setTitle:@"Upload" forState:UIControlStateNormal];
    [confirm addTarget:self action:@selector(confirmUpload:) forControlEvents:UIControlEventTouchUpInside];
    [uploader.view addSubview:confirm];
    uploader.hidesBottomBarWhenPushed = YES;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:uploader animated:YES];
}

- (IBAction)shareFlipped:(UISwitch*)fbSwitch {
    shareToFbBool=fbSwitch.on;
    [[NSUserDefaults standardUserDefaults] setBool:shareToFbBool forKey:@"shareToFb"];
}
-(void)confirmUpload:(id)sender{
    self.uploadedPicture=nil;
    NSString *refid=@"";
    if(offer.refId) refid=offer.refId;
    NSString *otype=offer.type;
    [confirm setTitle:@"Uploading..." forState:UIControlStateNormal];
    [confirm setUserInteractionEnabled:NO];
    NSString *url=[NSString
                   stringWithFormat:@"http://www.json999.com/pr/uploadPicture.php?uid=%d&type=jpeg&offerId=%@&refId=%@&otype=%@",
                   getUid(),offer.storeId,refid,otype];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    // Fetch the JSON response
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    // Make synchronous request
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                    returningResponse:&response
                                                error:&error];
    NSString *ret= [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    NSArray *tok =[ret componentsSeparatedByString:@"|"];
    
    self.uploadedPicture=tok[1];
    pointsEarned=[tok[0] intValue];
    NSString *server=tok[2];
    NSString *msg=tok[3];
    NSString *winMsg=tok[4];
    if(![msg isEqual:@""]){
        alert(msg);
        [confirm setTitle:@"Upload" forState:UIControlStateNormal];
        [confirm setUserInteractionEnabled:YES];
        return;
    }
	
    [self uploadImage:self.userPic to:uploadedPicture enpoint:server winMsg:winMsg];
}
-(void) uploadImage:(UIImage*)img to:(NSString *)filename enpoint:(NSString *) enpoint winMsg:(NSString *)winMsg
{
	
    NSData *imageData = UIImageJPEGRepresentation(img,0);     //change Image to NSData
    
    if (imageData != nil)
    {
        
        NSLog(@"uploading%@", filename);
        
        NSString *urlString =enpoint;
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
		

		
		
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"filenames\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[filename dataUsingEncoding:NSUTF8StringEncoding]];
		
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", filename]
                          dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", filename]
                          dataUsingEncoding:NSUTF8StringEncoding]];

        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:imageData]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[[NSOperationQueue alloc] init]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                                   dispatch_sync( dispatch_get_main_queue(),^{
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You Win" message:winMsg
                                                                                      delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                       [alert show];
                                       [self.navigationController popViewControllerAnimated:YES];
                                       [confirm setTitle:@"Upload" forState:UIControlStateNormal];
                                       [confirm setUserInteractionEnabled:YES];
                                       [self loadUploadedPictures];
                                       [Hud update];
									   [imageMeta objectForKey:@""];
									   if(imageMeta){
										   NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:imageMeta];
										NSMutableURLRequest *mr= [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://json999.com/pr/meta.php"]];
										   mr.HTTPMethod=@"POST";
										   [mr setHTTPBody:myData];
										   [NSURLConnection sendAsynchronousRequest:mr queue:[NSOperationQueue mainQueue] completionHandler:nil];
									   }
                                   });
                               }];
    }
}


-(void) loadUploadedPictures
{
    CGFloat screenHeight=self.view.frame.size.height;
    [self.scroll removeFromSuperview];
    scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 127, 320, screenHeight-117)];
    [self.view addSubview:scroll];
    [Util ajaxArray:[NSString stringWithFormat:
                     @"http://www.json999.com/pr/getUploaded.php?v=2&refId=%@&storeId=%@&otype=%@&uid=%d",offer.refId,offer.storeId,offer.type,getUid()]
           callback:^(NSArray* picdata){
               piclist=picdata;
               [self addPictures];
           }];
}
-(void)addPictures
{
    
    CGFloat screenHeight=self.view.frame.size.height;
    int viewHeight=screenHeight-132;
    int viewWidth =self.view.frame.size.width;
    int cnt=[piclist count];
    [scroll setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:1]];
    scroll.pagingEnabled = YES;
    scroll.contentSize = CGSizeMake(self.view.frame.size.width * [piclist count], screenHeight-157);
    
    UIImage *leftarrow=[UIImage imageNamed:@"leftarrow"];
    UIImage *rightarrow=[UIImage imageNamed:@"rightarrow"];
    UILabel *swipe=[[UILabel alloc] init];
    swipe.text=@"swipe";
    
    for (int i = 0; i < cnt; i++) {
        NSDictionary *pic=[piclist objectAtIndex:i];
        NSString *url=pic[@"url"];
        CGFloat xOrigin = i * self.view.frame.size.width;
        UIImageView *awesomeView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin+10, 20, viewWidth*0.7, viewHeight*0.8)];
        [awesomeView setImageWithURL:[NSURL URLWithString:url]
                    placeholderImage:[UIImage imageNamed:@"loading"]
                             options:SDWebImageCacheMemoryOnly|SDWebImageLowPriority|SDWebImageProgressiveDownload];
        
        awesomeView.contentMode=UIViewContentModeScaleAspectFit;
        awesomeView.tag=i;
        [awesomeView setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *pgr = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(handlePan:)];
        pgr.delegate = self;
        [awesomeView addGestureRecognizer:pgr];
        [scroll addSubview:awesomeView];
        
        
        //[scroll addSubview:awesomeView];
        UIView *actionPanel = [[UIView alloc] initWithFrame:CGRectMake(xOrigin+10+viewWidth*0.7,20,viewWidth*0.3,viewHeight)];
        if([pic objectForKey:@"text"]){
            UILabel *picloader =[[UILabel alloc] init];
            [picloader setBackgroundColor:[UIColor clearColor]];
            picloader.frame=CGRectMake(xOrigin+10,2,310,12);
            picloader.text=[pic objectForKey:@"text"];
            [picloader sizeToFit];
            [scroll addSubview:picloader];
        }
        else if([pic objectForKey:@"firstname"]){
            UILabel *picloader =[[UILabel alloc] init];
            [picloader setBackgroundColor:[UIColor clearColor]];
            picloader.frame=CGRectMake(xOrigin+10,2,310,12);
            picloader.text=[NSString stringWithFormat:@"From %@ (%d Points Earned)",[pic objectForKey:@"firstname"],
                            [[pic objectForKey:@"points_earned"] intValue]];
            [picloader sizeToFit];
            [scroll addSubview:picloader];
        }
        if([pic objectForKey:@"fbid"] && ![[pic objectForKey:@"fbid"] isEqualToString:@"0"]){
            UIImageView *ppic=[[UIImageView alloc]initWithFrame:CGRectMake(2,2, 52, 52)];
            NSString *imageUrl=[NSString stringWithFormat: @"https://graph.facebook.com/%@/picture?width=200&height=200",[pic objectForKey:@"fbid"]];
            [ppic setImageWithURL:[NSURL URLWithString:imageUrl]
                 placeholderImage:nil];
            [actionPanel addSubview:ppic];
        }else if([pic objectForKey:@"fbid"]){
            UIImageView *ppic=[[UIImageView alloc]initWithFrame:CGRectMake(2,2, 52, 52)];
            [ppic setImageWithURL:[NSURL URLWithString:@"http://d1y3yrjny3p2xa.cloudfront.net/blankfb.jpeg"]
                 placeholderImage:nil];
            [actionPanel addSubview:ppic];
        }
        UIButton *like =[UIButton buttonWithType:UIButtonTypeSystem];
        [like setBackgroundColor:[UIColor clearColor]];
        [like.layer setCornerRadius:10.0];
        like.frame=CGRectMake(2,60,80,30);
        [like.layer setBorderColor:[[UIColor blueColor] CGColor]];
        [like.layer setBorderWidth:2.0];
        like.tag=i;
        [like setTitle:@"Like" forState:UIControlStateNormal];
        [like setTintColor:[UIColor blueColor]];
        [like addTarget:self action:@selector(likedPicture:) forControlEvents:UIControlEventTouchUpInside];
        [actionPanel addSubview:like];
        
        UIButton *share =[UIButton buttonWithType:UIButtonTypeSystem];
        share.frame=CGRectMake(2,100,80,30);
        [share setBackgroundColor:[UIColor clearColor]];
        [share.layer setCornerRadius:10.0];
        [share.layer setBorderColor:[[UIColor blueColor] CGColor]];
        [share.layer setBorderWidth:2.0];
        [share setTintColor:[UIColor blueColor]];
        share.tag=i;
        [share setTitle:@"Tweet" forState:UIControlStateNormal];
        [share addTarget:self action:@selector(sharePicture:) forControlEvents:UIControlEventTouchUpInside];
        [actionPanel addSubview:share];
        if([pic objectForKey:@"uid"]){
            UIButton *msg =[UIButton buttonWithType:UIButtonTypeSystem];
            msg.frame=CGRectMake(2,140,80,30);
            msg.tag=i;
            msg.titleLabel.adjustsFontSizeToFitWidth = YES;
            [msg setBackgroundColor:[UIColor whiteColor]];
            [msg.layer setCornerRadius:10.0];
            [msg.layer setBorderColor:[[UIColor blueColor] CGColor]];
            [msg.layer setBorderWidth:2.0];
            [msg setTintColor:[UIColor blueColor]];
            [msg setTitle:@"Message" forState:UIControlStateNormal];
            [msg addTarget:self action:@selector(msgUser:) forControlEvents:UIControlEventTouchUpInside];
            [actionPanel addSubview:msg];
            
            UIButton *report =[UIButton buttonWithType:UIButtonTypeSystem];
            report.frame=CGRectMake(2,180,80,30);
            [report setBackgroundColor:[UIColor whiteColor]];
            [report.layer setCornerRadius:10.0];
            [report.layer setBorderColor:[[UIColor redColor] CGColor]];
            [report.layer setBorderWidth:2.0];
            [report setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [report setTintColor:[UIColor redColor]];
            report.tag=i;
            [report setTitle:@"Report" forState:UIControlStateNormal];
            [report addTarget:self action:@selector(reportPicture:) forControlEvents:UIControlEventTouchUpInside];
            [actionPanel addSubview:report];
        }
        
        
        BOOL addSwipe=NO;
        if(i>0){
            UIImageView *swipeLeft=[[UIImageView alloc] initWithFrame:CGRectMake(2, 210, 20, 20)];
            [swipeLeft setImage:leftarrow];
            [actionPanel addSubview:swipeLeft];
            addSwipe=YES;
        }
        if(i<cnt-1){
            UIImageView *swipeRight=[[UIImageView alloc] initWithFrame:CGRectMake(62, 210, 20, 20)];
            [swipeRight setImage:rightarrow];
            [actionPanel addSubview:swipeRight];
            addSwipe=YES;
        }
        if(addSwipe){
            //            UILabel *swipe=[[UILabel alloc] init];
            //            swipe.text=@"swipe";
            //            [swipe setFont:[UIFont systemFontOfSize:10]];
            //            swipe.frame=CGRectMake(28, 210, 40, 20);
            //            [actionPanel addSubview:swipe];
        }
        [scroll addSubview:actionPanel];
    }
    [self.view setNeedsDisplay];
}
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    if ([recognizer state] == UIGestureRecognizerStateEnded) {
        NSDictionary *pic=[piclist objectAtIndex:recognizer.view.tag];
        NSString *url=[NSString stringWithFormat:@"http://www.json999.com/pr/go.php?imgurl=%@",[pic objectForKey:@"url"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}
-(void)msgUser:(UIButton *)sender{
    NSDictionary *pic=[piclist objectAtIndex:sender.tag];
    int toUid=[[pic objectForKey:@"uid"] intValue];
    NSString *toName=[pic objectForKey:@"firstname"];
    REComposeViewController *composeViewController = [[REComposeViewController alloc] init];
    composeViewController.hasAttachment = YES;
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    titleImageView.frame = CGRectMake(0, 0, 110, 30);
    composeViewController.navigationItem.titleView = titleImageView;
    composeViewController.title = @"Photo Rewards";
    composeViewController.hasAttachment = NO;
    composeViewController.placeholderText = [NSString stringWithFormat:@"To %@",toName];
    composeViewController.completionHandler = ^(REComposeViewController *composeViewController, REComposeResult result) {
        [composeViewController dismissViewControllerAnimated:YES completion:nil];
        
        if (result == REComposeResultCancelled) {
            NSLog(@"Cancelled");
        }
        
        if (result == REComposeResultPosted) {
            NSString *ref=@"";
            if([pic objectForKey:@"id"]){
                ref=[pic objectForKey:@"id"];
            }
            NSString *post=[NSString stringWithFormat:@"toUid=%d&%msg=%@&from=%d&ref=%@",toUid,composeViewController.text,getUid(),ref];
            NSString *url=@"https://www.json999.com/pr/msg.php";
            httpPostAsync(post, url);
        }
    };
    [composeViewController presentFromRootViewController];
}

-(void)sharePicture:(UIButton *)sender{
    NSDictionary *pic=[piclist objectAtIndex:sender.tag];
    NSString *url=pic[@"url"];
    NSString *msg=@"";
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    if([pic objectForKey:@"firstname"]!=nil && [pic objectForKey:@"points_earned"]!=nil){
        NSString *fname=[pic objectForKey:@"firstname"];
        NSString *hisPoints=[pic objectForKey:@"points_earned"];
        msg =[NSString stringWithFormat:@"%@ uploaded this picture for %@ points. ",fname,hisPoints];
    }else{
        msg=[NSString stringWithFormat:@"Great picture about '%@'. ",offer.name];
    }
    NSString *append=(NSString *)[delegate.config objectForKey:@"tweetmsg"];
    if(append) msg = [msg stringByAppendingString:append];
    TWTweetComposeViewController *tweet = [[TWTweetComposeViewController alloc] init];
    [tweet setInitialText:msg];
    [tweet addImage:image];
    
    [self presentModalViewController:tweet animated:YES];
    [sender setTitle:@"Shared" forState:UIControlStateNormal];
    [sender setEnabled:NO];
}
-(void)reportPicture:(UIButton *)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    sheet.tag=sender.tag;
    NSArray *conplaints=[[delegate.config objectForKey:@"cc"] componentsSeparatedByString:@","];
    for(NSString *c in conplaints){
        [sheet addButtonWithTitle:c];
    }
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    [sheet showFromTabBar:self.tabBarController.tabBar];
}

-(void)likedPicture:(UIButton *)sender{
    
    NSDictionary *pic=[piclist objectAtIndex:sender.tag];
    int liked=[[pic objectForKey:@"liked"] intValue];
    liked=liked+1;
    NSString *url=pic[@"url"];
    
    NSString *msg=@"";
    if([pic objectForKey:@"firstname"]!=nil && [pic objectForKey:@"points_earned"]!=nil){
        NSString *fname=[pic objectForKey:@"firstname"];
        NSString *hisPoints=[pic objectForKey:@"points_earned"];
        msg =[NSString stringWithFormat:@"%@ uploaded this picture for %@ points.",fname,hisPoints];
    }else{
        
    }
    NSString *append=(NSString *)[delegate.config objectForKey:@"tweetmsg"];
    msg = [msg stringByAppendingString:append];
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    
    [FBNativeDialogs
     presentShareDialogModallyFrom:self
     initialText:msg
     image:image
     url:nil
     handler:^(FBNativeDialogResult result, NSError *error) {
         if (error) {
             /* handle failure */
         } else {
             if (result == FBNativeDialogResultSucceeded) {
                 [Util ajax:[NSString stringWithFormat:@"http://www.json999.com/pr/xp.php?e=liked_picture&refId=%@",pic[@"id"]]
                   callback:^(NSDictionary* dict){
                       [Hud update];
                   }];
             } else {
                 /* handle user cancel */
                 //   [Util ajax:@"http://www.json999.com/pr/xp.php?e=fb_post_user_canceled&e1=native" callback:nil];
             }
         }
     }];
    [sender setTitle:@"liked" forState:UIControlStateNormal];
    [sender setEnabled:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
