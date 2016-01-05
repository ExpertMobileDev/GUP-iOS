//
//  CategoryList.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/1/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "newGroupCell.h"
#import "Afnetworking.h"


@interface CategoryList : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate, NewGroupCellDelegate>
{
    IBOutlet UITableView *CategoryListTable;
    NSMutableArray *categoryIds,*categoryNames;
    NSMutableArray *selectedGroup,*groupData;
    
    NSURLConnection *groupJoinedConn,*fetchCategoryConn;
    NSMutableData *groupJoinedResponse,*fetchCategoryResponse;
    
    UIActivityIndicatorView *activityIndicator;
    UIView *freezer;
    
    id insta;
    MBProgressHUD *HUD;
    
    NSIndexPath *lasRow;
    
    BOOL lastSelectedCell;
    int lockRow,lastIndexPath;
    UIButton *joinButton;


}

@property (nonatomic, retain) NSString  *userId;
@property (nonatomic, retain) NSString  *triggeredFrom;
@property (nonatomic, retain) NSString  *distinguishFactor;

-(void)fetchGroupJoinedList;
-(void)wantToChangeCategoryFrom:(id)instance ;
@end
