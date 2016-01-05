//
//  SignUp.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/31/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@class TPKeyboardAvoidingScrollView;


@interface SignUp : UIViewController<UIAlertViewDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate,MBProgressHUDDelegate,UIAlertViewDelegate>
{
    IBOutlet UIImageView *UserImage;
    IBOutlet UITableView *form;
    //current location param(logi ,lati ,addr)
    UIImage* profileImage;
    CGFloat Longitude,Latitude;
    int offset;
    NSMutableData *locationResponse;
    NSURLConnection *location_events;
    NSInteger locationID;
    NSString *addressName;
    NSString *location;
    NSString *userId;
    
    UITextField *userNameTextField,*emailIdTextField,*passwordTextField,*confirmPasswordTextField;
    float animatedDistance;
    IBOutlet UITableView *signUptable;
    CGRect TXFRAME;
    UILabel *loc;
    NSMutableURLRequest *request1;
    UITextView *aboutme;
    __weak IBOutlet UITextField *username;
    
    UIActivityIndicatorView *nameVerification,*loadingLocation;
    BOOL usernameIsUnique;
    NSArray *locations;
    UITapGestureRecognizer *tapRecognizer;
    UIImagePickerController *Ipicker;
    NSString * appVersionString ;
    MBProgressHUD *HUD;
}

@property(strong,nonatomic)NSURLConnection *connection1,*usernameUniqueCheck,*getLocation,*updateUser;
@property(strong,nonatomic) NSMutableData *SignUpResponse,*usernameUniqueCheckResponse,*getLoctionResponse,*updateResponce;
@property (nonatomic, retain) IBOutlet TPKeyboardAvoidingScrollView *mainScroll;

- (IBAction)openTabbar:(id)sender;
- (IBAction)handleSingleTap:(UITapGestureRecognizer *)recognizer;
- (void)updateLocationLable:(NSString *)locationName locationID:(NSInteger)locID;

@end
