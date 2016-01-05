//
//  SearchLocation.h
//  GUPver 1.0
//
//  Created by Deepesh_Genora on 11/26/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"
@interface SearchLocation : UIViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,UISearchBarDelegate,MBProgressHUDDelegate>
{NSMutableArray *loactionArray,*initiallocation;
    NSMutableURLRequest *request1;
    NSURLConnection *fetchLocation;
    NSMutableData *locationResponse;
    IBOutlet UITableView *listing;
    IBOutlet UISearchBar *search;
    id insta;
    
    //current location param(logi ,lati ,addr)
    CGFloat Longitude,Latitude;
    
    UIView *freezer;
    UIActivityIndicatorView *progress;
    
    MBProgressHUD *HUD;
}

-(void)setinitialContent:(NSArray*)passedArray :(id)instace;
-(void)wontToChangeLocationFrom:(id)instance ;
@end
