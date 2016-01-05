//
//  CreateGroup.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/31/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "XMPPRoomMemoryStorage.h"
#import "XMPPRoom.h"

@interface CreateGroup : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,NSURLConnectionDelegate,MBProgressHUDDelegate,XMPPRoomDelegate,XMPPMUCDelegate,LocalityDelegate>{

    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *groupPic;
    IBOutlet UITextView *groupNameTextView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UIImageView *nameChecked;
    IBOutlet UITableView *createGroupTable;
    
    int noOfSections;
    BOOL defaultImage;
    UITextView *groupDescTextView;
    UITapGestureRecognizer *tapGesture;
    UILabel *groupNameTitle;
    
    int status;
    UIButton *butarray[4];
    XMPPJID *roomJID;
    //camera
    BOOL newMedia;
    UIImagePickerController *iPicker;
    NSData *imageData;
    
    XMPPRoomCoreDataStorage *roomMemory;
    XMPPRoom *xmpproom;
    
    CGRect TXFRAME;
    NSString *group_id;
    NSURLConnection *createGroupConn,*fetchCategoryConn,*uniquenessCheckConn;
    NSMutableData *createGroupResponse,*fetchCategoryResponse,*eventsResponse;
    
    NSString *groupType,*groupName,*groupDesc,*groupCategory,*globalType,*categoryID,*appUserId,*appUserLocationId,*appUserLocation,*appUserName,*appUserImage;
    
    UIActivityIndicatorView *loadingLocation;
    UIView *freezer;
    BOOL flags[4];
    MBProgressHUD *HUD;
    
    // location members
    UILabel *locationLabel;
    NSString* locationText;
    BOOL waitLocation;
    double latitude;
    double longitude;
    NSString* country;
    NSString* locality;
}

@property(nonatomic,strong) XMPPRoomCoreDataStorage *roomMemory;
@property(nonatomic,strong) XMPPRoom *xmpproom;

-(void)viewPublicInfo:(id)sender;
-(void)viewPrivateInfo:(id)sender;
-(void)viewLocalInfo:(id)sender;
-(void)viewGlobalInfo:(id)sender;
- (IBAction)handleSingleTap:(UITapGestureRecognizer *)recognizer;
//- (void)loadCategories;
-(void)updateCategory:(NSString*)newCategory categoryId:(NSString*)catId;

@end
