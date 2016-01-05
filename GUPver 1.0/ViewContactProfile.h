//
//  ViewContactProfile.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 12/4/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"
@interface ViewContactProfile : UIViewController<MBProgressHUDDelegate>
{
    IBOutlet UIImageView *viewContactImageView;
    IBOutlet UILabel *userNameLabel;
    NSArray *getData;
    IBOutlet UIView *customView;
    
    IBOutlet UILabel *aboutLbl;
    NSURLConnection *contactDetailConn;
    NSMutableData *contactDetailResponse;
    
    IBOutlet UIImageView *line;
    IBOutlet UILabel *aboutDiscriptionLbl;
    
    IBOutlet UIButton *locationLabel;
    IBOutlet UIButton *groupsLabel;
    MBProgressHUD *HUD;
   
}
@property (nonatomic, retain) NSString  *userId;
@property (nonatomic, retain) NSString  *userName;
@property (nonatomic, retain) NSString  *userImageURL;
@property (nonatomic, retain) NSString  *userLocation;

@property (nonatomic, retain) NSString  *triggeredFrom;

-(IBAction)openGroupList:(id)sender;

-(void)refreshContactInfo;
@end
