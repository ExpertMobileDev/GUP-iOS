//
//  ViewContactProfile.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 12/4/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "ViewContactProfile.h"
#import "DatabaseManager.h"
#import "CategoryList.h"
#import "JSON.h"

@interface ViewContactProfile ()

@end

@implementation ViewContactProfile
@synthesize userId, userName, userImageURL, userLocation, triggeredFrom;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.navigationItem.title = @"Profile";
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    self.view.frame = [[UIScreen mainScreen] bounds];
    viewContactImageView.frame = CGRectMake(self.view.frame.size.width/2-60, viewContactImageView.frame.origin.y,viewContactImageView.frame.size.width, viewContactImageView.frame.size.height);
    viewContactImageView.layer.cornerRadius = 60;
    viewContactImageView.layer.borderWidth = 2;
    viewContactImageView.layer.borderColor = [UIColor clearColor].CGColor;
    viewContactImageView.clipsToBounds = YES;
    
    line.frame = CGRectMake(11, line.frame.origin.y, self.view.frame.size.width-22, line.frame.size.height);
    userNameLabel.frame = CGRectMake(self.view.frame.size.width/2 - userNameLabel.frame.size.width/2, userNameLabel.frame.origin.y, userNameLabel.frame.size.width-22, userNameLabel.frame.size.height);
    userNameLabel.center = CGPointMake(viewContactImageView.center.x, userNameLabel.center.y);
    aboutLbl.center = CGPointMake(userNameLabel.center.x, aboutLbl.center.y);

    if (userName) {
        self.title = [NSString stringWithFormat:@"%@'s Profile",userName];
        userNameLabel.text = userName;
        [groupsLabel setTitle:[NSString stringWithFormat:@" View %@'s Groups", userName] forState:UIControlStateNormal];
    } else {
        
    }
    if([userNameLabel.text componentsSeparatedByString:@" "].count>1) {
        aboutLbl.text = [NSString stringWithFormat:@"About %@",[[userNameLabel.text componentsSeparatedByString:@" "] firstObject]];
    } else {
        aboutLbl.text = [NSString stringWithFormat:@"About %@",userNameLabel.text];
    }
    if (userLocation) {
        [locationLabel setTitle:userLocation forState:UIControlStateNormal];
    }
    if (userImageURL) {
        NSString* imagefile = [userImageURL stringByReplacingOccurrencesOfString:@"_50" withString:@"_300"];
        UIActivityIndicatorView *imageActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        imageActivityIndicator.frame = CGRectMake(65.0, 65.0, 30.0, 30.0);
        imageActivityIndicator.center = viewContactImageView.center;
        
        imageActivityIndicator.color = [UIColor blackColor];
        [self.view addSubview:imageActivityIndicator];
        [imageActivityIndicator startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,imagefile]]];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                viewContactImageView.image = [UIImage imageWithData:imgData];
                [viewContactImageView.layer setBorderColor:[UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1].CGColor];
                
                [imageActivityIndicator removeFromSuperview];
                
            });
            
        });
    }
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
    NSLog(@"explore user%@",userId);
    [self refreshContactInfo];
}

-(IBAction)openGroupList:(id)sender {
    
    CategoryList *detailPage = [[CategoryList alloc]init];
    detailPage.title=[NSString stringWithFormat:@"%@'s Groups",userNameLabel.text];
    detailPage.userId = userId;
    detailPage.triggeredFrom = @"explore";
    detailPage.distinguishFactor= @"Groups";
    [self.navigationController pushViewController:detailPage animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)refreshContactInfo
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *postData = [NSString stringWithFormat:@"user_id=%@",userId];
    NSLog(@"$[%@]",postData);
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/member_detail.php",gupappUrl]]];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    contactDetailConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    [contactDetailConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [contactDetailConn start];
    
    contactDetailResponse = [[NSMutableData alloc] init];
}

//NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == contactDetailConn) {
        
        [contactDetailResponse setLength:0];
        
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"did recieve data");
    
    if (connection == contactDetailConn) {
        
        [contactDetailResponse appendData:data];
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == contactDetailConn) {
        
        [HUD hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    
    if (connection == contactDetailConn) {
        
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:contactDetailResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);

        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSDictionary *results = res[@"response"];
        NSLog(@"results: %@", results);
        NSDictionary *userDetails=results[@"User_Details"];
        
        NSLog(@"user count %i",[userDetails count]);
        if ([userDetails count]==0 )
        {
            [HUD hide:YES];
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                   
                                                             message:@"Unable to retrieve user details."
                                   
                                                            delegate:nil
                                   
                                                   cancelButtonTitle:@"OK"
                                   
                                                   otherButtonTitles:nil];
            [alert show];
        }
        else
        {
        
            NSLog(@"====EVENTS==3 %@",res);
            [HUD hide:YES];
            
            if (!userName) {
                userName = userDetails[@"display_name"];
                self.title = [NSString stringWithFormat:@"%@'s Profile",userName];
                userNameLabel.text = userName;
                [groupsLabel setTitle:[NSString stringWithFormat:@" View %@'s Groups", userName] forState:UIControlStateNormal];
                if([userNameLabel.text componentsSeparatedByString:@" "].count>1) {
                    aboutLbl.text = [NSString stringWithFormat:@"About %@",[[userNameLabel.text componentsSeparatedByString:@" "] firstObject]];
                } else {
                    aboutLbl.text = [NSString stringWithFormat:@"About %@",userNameLabel.text];
                }
            }
            if (!userLocation) {
                userLocation = userDetails[@"location_name"];
                [locationLabel setTitle:userLocation forState:UIControlStateNormal];
            }
            if (!userImageURL) {
                userImageURL = userDetails[@"profile_pic"];
                NSString* imagefile = [userImageURL stringByReplacingOccurrencesOfString:@"_50" withString:@"_300"];
                UIActivityIndicatorView *imageActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                imageActivityIndicator.frame = CGRectMake(65.0, 65.0, 30.0, 30.0);
                imageActivityIndicator.center = viewContactImageView.center;
                
                imageActivityIndicator.color = [UIColor blackColor];
                [self.view addSubview:imageActivityIndicator];
                [imageActivityIndicator startAnimating];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,imagefile]]];
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        viewContactImageView.image = [UIImage imageWithData:imgData];
                        [viewContactImageView.layer setBorderColor:[UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1].CGColor];
                        
                        [imageActivityIndicator removeFromSuperview];
                        
                    });
                    
                });
            }
            NSString* description = userDetails[@"about_us"];
            if (description) {
                CGRect originRect = aboutDiscriptionLbl.frame;
                UIFont *font = aboutDiscriptionLbl.font;
                NSAttributedString *attributedText = [[NSAttributedString alloc]initWithString:description
                                                                                    attributes:@{NSFontAttributeName: font}];
                CGRect newRect = [attributedText boundingRectWithSize:(CGSize){originRect.size.width, CGFLOAT_MAX}
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                           context:nil];
                if (originRect.size.height < newRect.size.height) {
                    CGFloat delta = newRect.size.height - originRect.size.height;
                    originRect.size.height = newRect.size.height;
                    [aboutDiscriptionLbl setFrame:originRect];
                    [aboutDiscriptionLbl setText:description];
                    
                    CGRect rect = customView.frame;
                    rect.origin.y += delta;
                    [customView setFrame:rect];
                }
                
            }
        }
        
    }
    contactDetailConn=nil;
    
    [contactDetailConn cancel];
}


@end
