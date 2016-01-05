//
//  CreateProfile.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/31/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface CreateProfile : UIViewController<UIScrollViewDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate,MBProgressHUDDelegate>
{
    IBOutlet UIImageView *PROFILEIMAGE;
    IBOutlet UIScrollView *mainScroll;
    IBOutlet UITableView *form;
    
    UIImage* profileImage;
    CGFloat Longitude,Latitude;
    CGRect TXFRAME;
    NSInteger locationID;
    NSString *social_login_type,*social_login_idl_login;
    NSString *location;
    NSArray *locations;
    UITextField *userNameTextField;
    NSURLConnection *connection1,*usernameUniqueCheck,*getLocation;
    NSMutableData *SignUpResponse,*usernameUniqueCheckResponse,*getLoctionResponse;
    BOOL usernameIsUnique;
    UIActivityIndicatorView *nameVerification,*loadingLocation;
    UITapGestureRecognizer *tapRecognizer;
    UIImagePickerController *Ipicker;
    MBProgressHUD *HUD;
    NSString * appVersionString ;

}

-(IBAction)openHomePage:(id)sender;
-(void)initCreatePofileWith:(NSString*)socialLoginType social_Login_ID:(NSString*)uniqueID;

@end
