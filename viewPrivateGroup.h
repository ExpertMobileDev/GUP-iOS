//
//  viewPrivateGroup.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/1/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface viewPrivateGroup : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,MBProgressHUDDelegate,LocalityDelegate>
{
    NSString *groupPic,*groupDesc,*categoryName,*groupName,*groupLocation,*GName;
    IBOutlet UIScrollView *scrollView;
    
    IBOutlet UIImageView *groupImageView;
    
    CGRect TXFRAME;
    
    UIActivityIndicatorView *activityIndicator;
    UIView *freezer;
    NSURLConnection *updateDescriptionConn,*updateNameConn,*memberConnection;
    NSMutableData *updateDescriptionResponse,*updateNameResponse,*memberRsponce;
    
    NSURLConnection *editCategoryConn,*uploadGroupPicConn,*editLocationConn,*editGeoLocationConn,*deleteImageConn,*getGroupJoinRequestCountConn,*leaveGroupConn;//*makeAdminConn,*leaveAsAdminConn;
    NSMutableData *editCategoryResponse,*uploadGroupPicResponse,*editLocationResponse,*editGeoLocationResponse,*deleteImageResponse,*getGroupJoinRequestCountResponse,*leaveGroupResponse;//*makeAdminResponse,*leaveAsAdminResponse;
    
    NSString *categoryID;
    UITapGestureRecognizer *tapRecognizer;
    UIImagePickerController *iPicker;
    NSData *imageData;
    int groupJoinCount;
    int totalMembersCount;
    
    UIImage *chosenImage;
    UIActivityIndicatorView *imageActivityIndicator;
    
    MBProgressHUD *HUD;
    
    // location members
    NSString* locationText;
    BOOL waitLocation;
    double latitude;
    double longitude;
    NSString* country;
    NSString* locality;
}

@property(strong,nonatomic)NSString *groupType;
@property (strong, nonatomic) NSString  *groupId;
@property(strong,nonatomic)NSString *startLoading;
@property(strong,nonatomic)NSString *viewType;
@property (weak, nonatomic) IBOutlet UILabel *categoryInfo;
@property (weak, nonatomic) IBOutlet UILabel *createdInfo;
@property (strong, nonatomic) IBOutlet UILabel *typeInfo;
@property (weak, nonatomic) IBOutlet UILabel *totalMembers;
@property (weak, nonatomic) IBOutlet UILabel *sharelabel;
@property (weak, nonatomic) IBOutlet UIButton *iconMembers;
@property (weak, nonatomic) IBOutlet UIButton *iconType;
@property (weak, nonatomic) IBOutlet UIButton *iconShare;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) IBOutlet UIButton *pendinglabel;
@property (weak, nonatomic) IBOutlet UIButton *pendingImage;
@property (weak, nonatomic) IBOutlet UIButton *locationLbl;
@property (weak, nonatomic) IBOutlet UIButton *locationImage;
@property (weak, nonatomic) IBOutlet UIButton *resetGeoButton;

-(void)updateCategory:(NSString*)newCategory categoryId:(NSString*)catId;
@property (strong, nonatomic) IBOutlet UITextView *groupNameTextView;
-(void)updateLocationLable:(NSString*)newLocation locationID:(NSInteger)locID;
@property (strong, nonatomic) IBOutlet UITextView *groupDescTextView;

-(void)uploadDisplayPicToServer;
- (IBAction)handleSingleTap:(UITapGestureRecognizer *)recognizer;
-(IBAction)shareGroupInfo:(id)sender;
-(void)getGroupJoinRequestCount;
-(IBAction)leaveGroup:(id)sender;
-(void)refreshGroupInfo;
- (IBAction)Addmember:(id)sender;
- (IBAction)pendingGroups:(id)sender;
- (IBAction)manageMembers:(id)sender;


@end
