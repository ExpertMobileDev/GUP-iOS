//
//  ExploreViewController.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/13/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "PostListing.h"
#import "ExploreViewController.h"
#import "SecondViewController.h"
#import "GroupInfo.h"
#import "JSON.h"
#import "GroupTableCell.h"
#import "ViewContactProfile.h"
#import "DatabaseManager.h"
#import "ChatScreen.h"
#import "viewPrivateGroup.h"
#import "AppDelegate.h"
#import "newGroupCell.h"
#import "GroupViewController.h"
#import "FirstViewController.h"

@interface ExploreViewController ()

@end

@implementation ExploreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"Search", @"Search");
        self.navigationItem.title = @"Explore";
        //[self.navigationController.navigationBar setTitleTextAttributes:         [NSDictionary dictionaryWithObjectsAndKeys:          [UIColor greenColor],          UITextAttributeTextColor,          nil]];
        //self.tabBarItem.image = [UIImage imageNamed:@"search"];
//        UIImage *selectedImage = [UIImage imageNamed:@"searchActive"];
//        UIImage *unselectedImage = [UIImage imageNamed:@"searchTab"];
//        [self.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
//        self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
    return self;
}
- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
-(IBAction)dissmisal:(UIButton*)sender1
{//NSLog(@"sender %@",sender1);
    //NSLog(@"sender superview %@",sender1.superview);
    
    [self.parentViewController.parentViewController.view setUserInteractionEnabled:YES];
    [sender1.superview removeFromSuperview];
}
-(void)plistSpooler
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"AppData.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableDictionary *data;
    
    if ([fileManager fileExistsAtPath: path])
    {
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        //NSLog(@"data %@",data);
        if (![[data objectForKey:@"Explore"] boolValue]) {
            
            [data setObject:[NSNumber numberWithInt:true] forKey:@"Explore"];
            CGSize deviceSize=[UIScreen mainScreen].bounds.size;
            UIImageView *Back=[[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            UIImage *backimage=[UIImage imageNamed:@"quicksearch"];
            [Back setImage:[backimage stretchableImageWithLeftCapWidth:backimage.size.width topCapHeight:backimage.size.width]];
            //  [self.view addSubview:Back];
            //   [self.view sendSubviewToBack:Back];
            [Back setUserInteractionEnabled:YES];
            UIButton *dismiss=[[UIButton alloc]initWithFrame:CGRectMake(deviceSize.width-110, 32, 100, 30)];
            [dismiss setTitle:@"Done" forState:UIControlStateNormal];
            [dismiss setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:178.0/255.0 blue:55.0/255.0 alpha:1 ]];
            [dismiss setUserInteractionEnabled:YES];
            [dismiss addTarget:self action:@selector(dissmisal:) forControlEvents:UIControlEventTouchUpInside];
            // UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self                                                                                        action:@selector(dissmisal:)];
            
            // swipe.direction = UISwipeGestureRecognizerDirectionLeft;
            // [dismiss addGestureRecognizer:swipe];
            [Back addSubview:dismiss];
            
            //NSLog(@"self %@ \n back %@ \n backback %@ \n backbackback %@",self,self.parentViewController,self.parentViewController.parentViewController,self.parentViewController.parentViewController.parentViewController);
            //[self.parentViewController.parentViewController.view setUserInteractionEnabled:NO];
            [self.parentViewController.parentViewController.view addSubview:Back];
            [self.parentViewController.parentViewController.view bringSubviewToFront:Back ];
            
            //NSLog(@"hiii");
        }
        [data writeToFile: path atomically:YES];
        //NSLog(@"data %@",data);
        //NSLog(@"data %@",data);
    }
    else
    {
        
        data = [[NSMutableDictionary alloc] init];
        [data setObject:[NSNumber numberWithInt:true] forKey:@"IsSuccesfullRun"];
        // [data setObject:[NSNumber numberWithInt:false] forKey:@"ChatScreen"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"HomeScreen"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"CreateGroup"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"Location"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"Explore"];
        [data writeToFile: path atomically:YES];
        
        
    }

}


- (void)viewDidLoad
{
    [super viewDidLoad];
  //  [self plistSpooler];
    
    expndRow =-1;
    // Do any additional setup after loading the view from its nib.
    searchVariable = 0;
    categoryThumbnails  = [[NSMutableArray alloc] init];
    categoryNames = [[NSMutableArray alloc] init];
    categoryGroupNo = [[NSMutableArray alloc] init];
    categoryIds = [[NSMutableArray alloc] init];
    
    textLabel = [[NSMutableArray alloc] init];
    detailTextLabel = [[NSMutableArray alloc] init];
    imageView = [[NSMutableArray alloc] init];
    tableType = [[NSMutableArray alloc] init];
    typeArray = [[NSMutableArray alloc] init];
    resultIdArray = [[NSMutableArray alloc] init];
    userEmailId = [[NSMutableArray alloc] init];
    userStatus = [[NSMutableArray alloc] init];
    
    tempTextLabel = [[NSMutableArray alloc] init];
    tempDetailTextLabel = [[NSMutableArray alloc] init];
    tempImageView = [[NSMutableArray alloc] init];
    tempTableType = [[NSMutableArray alloc] init];
    tempTypeArray = [[NSMutableArray alloc] init];
    tempResultIdArray = [[NSMutableArray alloc] init];
    tempUserEmailId = [[NSMutableArray alloc] init];
    tempUserStatus = [[NSMutableArray alloc] init];
    selectedGroup = [[NSMutableArray alloc] init];
    
    searchData = [[NSMutableArray alloc] init];
    
    
    appUserId =[[DatabaseManager getSharedInstance]getAppUserID];
    
    userFilter=1;
    privateFilter=1;
    publicFilter=1;
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    UITextField *txfSearchField = [search valueForKey:@"_searchField"];
    txfSearchField.layer.cornerRadius =10.0;
    txfSearchField.layer.borderWidth =1.0f;
    txfSearchField.layer.borderColor =  [[UIColor colorWithRed:138/255.0 green:155/255.0 blue:160/255.0 alpha:1] CGColor];
    //[self setActivityIndicator];
    //[self listCategories];
    
    txfSearchField.font = [UIFont fontWithName:@"Dosis-Regular" size:17.0f];
    
    groupByCategoryLabel.font = [UIFont fontWithName:@"Dosis-Regular" size:15.0f];

    // Initialize Location
    latitude = 0;
    longitude = 0;
}

-(void)setActivityIndicator
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    pageno = 1;
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor lightGrayColor]];
    search.autocorrectionType = UITextAutocorrectionTypeNo;

    CLLocation* location = [[self appDelegate] getLocation];
    if (location) {
        latitude = location.coordinate.latitude;
        longitude = location.coordinate.longitude;
    }
    
    if(searchVariable==0 && groupCountConn == nil)
    {
        if (categoryNames.count == 0) {
            [self setActivityIndicator];
        }
        [self fetchGroupCount];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [search resignFirstResponder];
    search.showsCancelButton=FALSE;
}

#pragma mark Table View Data Source Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    NSLog(@"Table  initialized ");
    return 1;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(searchVariable==0)
    {
        NSLog(@"count cat %lu",(unsigned long)[categoryNames count]);
        return [categoryNames count];
    }
    
    else
    {
        if (tableView== filterTable.tableView)
            return 3;
        else
            return [searchData count];
    }
    
    
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{if(filterTable.tableView==tableView)
    if([[[self appDelegate].ver objectAtIndex:0] intValue] < 7)
        return 44;
    else
        return 0.5;
    else
        return 0.5;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(searchVariable != 0 && indexPath.row == searchData.count-1){//search
        [self nextPage];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(searchVariable==0)
    {
        static NSString *CellIdentifier = @"Cell Identifier";
        //[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            categoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
            categoryImageView.tag=3;
            categoryImageView.layer.cornerRadius = 5;
            categoryImageView.clipsToBounds = YES;
            [cell.contentView addSubview:categoryImageView];

            categoryNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(cell.frame.origin.x+60, cell.frame.origin.y+10,225,30)];
            [categoryNameLabel setBackgroundColor:[UIColor clearColor]];
            [categoryNameLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            categoryNameLabel.tag=1;
            categoryNameLabel.textColor= [UIColor colorWithRed:36.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1];
            categoryNameLabel.font = [UIFont fontWithName:@"Dosis-Bold" size:17.0f + [[self appDelegate] increaseFont]];
            [cell.contentView addSubview:categoryNameLabel];

            categoryGroups=[[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width-60, cell.frame.origin.y+10,50,30)];
            [categoryGroups setBackgroundColor:[UIColor clearColor]];
            categoryGroups.textAlignment =NSTextAlignmentRight;
            categoryGroups.tag=2;
            categoryGroups.font = [UIFont fontWithName:@"Dosis-Regular" size:15.f + [[self appDelegate] increaseFont]];
            [cell.contentView addSubview:categoryGroups];
            
            UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(15, 49, self.view.frame.size.width - 15, 1)];
            separator.backgroundColor = [UIColor colorWithRed:0.783922 green:0.780392 blue:0.8 alpha:1];
            [cell.contentView addSubview:separator];

        }
        
        BOOL isrecommended=[[categoryIds objectAtIndex:indexPath.row] isEqual:@"1"];
        //imageview
        for (UIView *cellS in cell.contentView.subviews) {
            NSLog(@"oo%@",cellS);
            if (cellS.tag==3) {
                UIImageView *ima=(UIImageView*)cellS;
                [ima setImage:[UIImage imageNamed:@"category_thumbnail"]];
                if ([categoryImageData count]<indexPath.row+1 )
                {
                    //download image and save in the cache
                    
                    NSFileManager *filemgr = [NSFileManager defaultManager];
                    NSString *Filepath=[self CachesPath:categoryThumbnails[indexPath.row]];
                    if ([filemgr fileExistsAtPath: Filepath ] == YES)
                    {NSLog(@"its there");
                        [ima setImage:[UIImage imageWithContentsOfFile:Filepath]];
                    }
                    else
                    {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/category_pics/%@",gupappUrl,categoryThumbnails[indexPath.row]]]];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //cell.imageView.image = [UIImage imageWithData:imgData];
                                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                                NSLog(@"paths=%@",paths);
                                // NSString *categoryPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",categoryThumbnails[indexPath.row]]];
                                //   NSLog(@"category pic path=%@",categoryPicPath);
                                //Writing the image file
                                [imgData writeToFile:Filepath atomically:YES];
                                [ima setImage:[UIImage imageNamed:Filepath]];
                                [ExploreTableView reloadData];
                            });
                            //
                        });
                        
                    }
                    
                    //  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    //   NSString *imgPathRetrieve = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",[categoryThumbnails objectAtIndex:indexPath.row]]];
                    //  NSData *pngData = [NSData dataWithContentsOfFile:imgPathRetrieve];
                    // ima.image = [UIImage imageWithData:pngData];
                }
                // else
                // ima.image = [UIImage imageWithData:[categoryImageData objectAtIndex:indexPath.row]];
                //[ima setHidden:isrecommended];
            }
            if (cellS.tag==1) {
                UILabel *catna=(UILabel*)cellS;
                catna.text=[categoryNames objectAtIndex:indexPath.row];
                if(isrecommended)
                {
                    //                    [cell setBackgroundColor:[UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1]];
                    //                    [cell.contentView setBackgroundColor:[UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1]];
                    //                    [catna setBackgroundColor:[UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1]];
                    //                    [catna setTextColor:[UIColor whiteColor]];
                    //                    [catna setTextAlignment:NSTextAlignmentLeft];
                }
                else
                {
                    //                    [cell setBackgroundColor:[UIColor whiteColor]];
                    //                    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
                    //                    [catna setBackgroundColor:[UIColor whiteColor]];
                    //                    [catna setTextColor:[UIColor blackColor]];
                    //                    [catna setTextAlignment:NSTextAlignmentLeft];
                }
            }
            if (cellS.tag==2) {
                UILabel *catgr=(UILabel*)cellS;
                NSLog(@"count %@",[categoryGroupNo objectAtIndex:indexPath.row]);
                catgr.text =[NSString stringWithFormat:@"%@",[categoryGroupNo objectAtIndex:indexPath.row]];
                //[catgr setTextColor:isrecommended?[UIColor whiteColor]:[UIColor blackColor]];
            }
            
        }
        
        
        return cell;
    }
    else
    {
        if (tableView== filterTable.tableView) {
            static NSString *Identifier2 = @"CellType2";
            // cell type 2
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier2];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier2];
            }
            filterOptionsList= [[NSMutableArray alloc]initWithObjects:@"Users",@"Private Groups",@"Public Groups", nil];
            cell.backgroundColor=[UIColor clearColor];
            cell.textLabel.text = [filterOptionsList objectAtIndex:indexPath.row];
            //cell.backgroundColor=[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
            cell.textLabel.font = [UIFont fontWithName:@"Dosis-Regular" size:17.f];
            cell.textLabel.textColor =[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            // set cell properties
            if (userFilter==1) {
                if (indexPath.row==0) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                
            }
            
            if (privateFilter==1) {
                if (indexPath.row==1) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                
            }
            if (publicFilter==1) {
                if (indexPath.row==2) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            
            return cell;
            
        }else{
            
            static NSString *simpleTableIdentifier = @"GroupTableCell";
            
            newGroupCell *cell= (newGroupCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            
            if (cell == nil)
            {
                cell = [[newGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
            }
            
            
            cell.cellDelegate = self;
            CGRect rect = cell.frame;
            rect.size.width = tableView.frame.size.width;
            [cell setFrame: rect];
            [cell drawCell:[searchData objectAtIndex:indexPath.row] withIndex:indexPath.row];
            
           
            return cell;
        }
    }
}

-(NSString *)CachesPath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat addHeight = ([[self appDelegate] increaseFont] == 0)? 0: 10;
    if(searchVariable==0 || tableView == filterTable.tableView){
        
        return 50;
        
    }else{
//        if(expndRow == indexPath.row){
//        return 60+[[[searchData objectAtIndex:indexPath.row] objectForKey:@"height"] floatValue];
//        }
        if (indexPath.row < searchData.count) {
            if ([[[searchData objectAtIndex:indexPath.row] objectForKey:@"height"] floatValue] > 20) {
                return [[[searchData objectAtIndex:indexPath.row] objectForKey:@"height"] floatValue] + 57 + addHeight;
            } else {
                return 70 + addHeight;
            }
        } else {
            return 70 + addHeight;
        }
        return 70 + addHeight;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(searchVariable==0)
    {
        [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc]
                                                   initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]];
        SecondViewController *detailCategoryPage = [[SecondViewController alloc]init];
        detailCategoryPage.chatTitle = [categoryNames objectAtIndex:indexPath.row];
        detailCategoryPage.categoryId = [categoryIds objectAtIndex:indexPath.row];
        detailCategoryPage.latitude = latitude;
        detailCategoryPage.longitude = longitude;
        [self.navigationController pushViewController:detailCategoryPage animated:NO];
    } else{
        if (tableView== filterTable.tableView) {
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if(indexPath.row==0) {
                
                if(cell.accessoryType== UITableViewCellAccessoryCheckmark){
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    userFilter=0;
                    
                }else{
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    userFilter=1;
                    
                    
                }
            }
            else if(indexPath.row==1){
                if (cell.accessoryType== UITableViewCellAccessoryCheckmark){
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    privateFilter=0;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    privateFilter=1;
                    
                    
                }
                
            }else if(indexPath.row==2){
                if (cell.accessoryType== UITableViewCellAccessoryCheckmark){
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    publicFilter=0;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    publicFilter=1;
                    
                    
                }
                
            }
            
            NSLog(@"printout private filter and public filter value %d, %d, %d",userFilter,privateFilter,publicFilter);
            
        }else{
          /*  [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc]
                                                       initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]];
            if ([[tableType objectAtIndex:indexPath.row] isEqualToString:@"group"]) {
                NSString *userId =[[DatabaseManager getSharedInstance]getAppUserID];
                if ([[typeArray objectAtIndex:indexPath.row]isEqualToString:@"private#local"]||[[typeArray objectAtIndex:indexPath.row]isEqualToString:@"private#global"]) {
                    [self setActivityIndicator];
                    selectedGroupId= [resultIdArray objectAtIndex:indexPath.row];
                    selectedGroupName=[textLabel objectAtIndex:indexPath.row];
                    selectedGroupPic=[imageView objectAtIndex:indexPath.row];
                    selectedGroupType=[typeArray objectAtIndex:indexPath.row];
                    
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                    NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@",selectedGroupId,userId];
                    NSLog(@"postdata%@",postData);
                    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/private_grp_user_status.php",gupappUrl]]];
                    [request setHTTPMethod:@"POST"];
                    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
                    initiateGroupJoinConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
                    [initiateGroupJoinConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                    [initiateGroupJoinConn start];
                    initiateGroupJoinResponse = [[NSMutableData alloc] init];
                    
                }else{
                    //check whter group is already added
                    selectedGroupId= [resultIdArray objectAtIndex:indexPath.row];
                    NSString *checkIfPublicGroupExists=[NSString stringWithFormat:@"select * from groups_public where group_server_id=%@",selectedGroupId];
                    BOOL publicGroupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfPublicGroupExists];
                    if (!publicGroupExistOrNot) {
                        [self setActivityIndicator];
                        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                        NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@",selectedGroupId,userId];
                        NSLog(@"postdata%@",postData);
                        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/add_fav.php",gupappUrl]]];
                        [request setHTTPMethod:@"POST"];
                        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
                        addFavGroupConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
                        [addFavGroupConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                        [addFavGroupConn start];
                        addFavGroupResponse = [[NSMutableData alloc] init];
                        
                    }else{
//                        ChatScreen *chatScreen = [[ChatScreen alloc]init];
//                        chatScreen.chatType = @"group";
//                        chatScreen.chatTitle=[textLabel objectAtIndex:indexPath.row];
//                        chatScreen.toJid =[NSString stringWithFormat:@"group_%d@%@",[selectedGroupId integerValue],(NSString*)groupJabberUrl];
//                        [chatScreen initWithUser:[NSString stringWithFormat:@"user_%d@%@",[selectedGroupId integerValue],(NSString*)jabberUrl]];
//                        chatScreen.groupType=[typeArray objectAtIndex:indexPath.row];
//                        [self.navigationController pushViewController:chatScreen animated:YES];
                        
                        
                        PostListing *detailPage = [[PostListing alloc]init];
                        detailPage.chatTitle=[textLabel objectAtIndex:indexPath.row];
                        detailPage.groupId = selectedGroupId;
                        detailPage.groupName = [textLabel objectAtIndex:indexPath.row];
                        detailPage.groupType=[typeArray objectAtIndex:indexPath.row];
                        [self appDelegate].isUSER=0;
                        [self.navigationController pushViewController:detailPage animated:YES];

                        
                    }
                }
            }else{
                NSString *userId =[[DatabaseManager getSharedInstance]getAppUserID];
                selectedContactId=[resultIdArray objectAtIndex:indexPath.row];
                if (![[DatabaseManager getSharedInstance]recordExistOrNot:[NSString stringWithFormat:@"select user_email from contacts where user_id=%@",selectedContactId]]) {
                    [self setActivityIndicator];
                    
                    selectedContactEmail=[userEmailId objectAtIndex:indexPath.row];
                    selectedContactName=[textLabel objectAtIndex:indexPath.row];
                    selectedContactPic=[imageView objectAtIndex:indexPath.row];
                    selectedContactStatus=[userStatus objectAtIndex:indexPath.row];
                    selectedContactLocation=[detailTextLabel objectAtIndex:indexPath.row];
                    
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                    NSString *postData = [NSString stringWithFormat:@"user_id=%@&contact_id=%@",userId,selectedContactId];
                    NSLog(@"postdata%@",postData);
                    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/add_to_contact.php",gupappUrl]]];
                    [request setHTTPMethod:@"POST"];
                    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
                    addContactConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
                    [addContactConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                    [addContactConn start];
                    addContactResponse = [[NSMutableData alloc] init];
                    
                }else{
                    
                    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:[NSString stringWithFormat:@"update contacts set deleted=0 where user_id=%@",selectedContactId]];
                    NSLog(@"open the chat screen here..");
                    ChatScreen *chatScreen = [[ChatScreen alloc]init];
                    chatScreen.chatType = @"personal";
                    chatScreen.chatTitle=[textLabel objectAtIndex:indexPath.row];
                    [chatScreen initWithUser:[NSString stringWithFormat:@"user_%d@%@",[selectedContactId integerValue],(NSString*)jabberUrl]];
                    chatScreen.groupType=@"";
                    [self.navigationController pushViewController:chatScreen animated:YES];
                    
                }
                
            }*/
        }
        
    }
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if(searchVariable==1)
    {
        /*if ([[tableType objectAtIndex:indexPath.row] isEqualToString:@"group"]) {
            // check whether the user is the admin of the group.
            
            
            NSLog(@"group id check:%@ userid:%@",[resultIdArray objectAtIndex:indexPath.row],appUserId);
            int is_admin=[[DatabaseManager getSharedInstance]isAdminOrNot:[resultIdArray objectAtIndex:indexPath.row] contactId:appUserId];
            NSLog(@"is_admin%i",is_admin);
            if (is_admin == 1) {
                viewPrivateGroup *viewGroupAsAdmin = [[viewPrivateGroup alloc]init];
                viewGroupAsAdmin.title = [textLabel objectAtIndex:indexPath.row];
                viewGroupAsAdmin.groupId = [resultIdArray objectAtIndex:indexPath.row];
                viewGroupAsAdmin.groupType =[typeArray objectAtIndex:indexPath.row];
                viewGroupAsAdmin.viewType = @"Explore";
                [self.navigationController pushViewController:viewGroupAsAdmin animated:NO];
            }
            else
            {
                
                GroupInfo *viewGroupPage = [[GroupInfo alloc]init];
                viewGroupPage.title = [textLabel objectAtIndex:indexPath.row];
                viewGroupPage.groupId = [resultIdArray objectAtIndex:indexPath.row];
                viewGroupPage.groupType = [typeArray objectAtIndex:indexPath.row];
                viewGroupPage.viewType = @"Explore";
                [self.navigationController pushViewController:viewGroupPage animated:NO];
                
            }
        }else{
            
            NSLog(@"in else for user");
            ViewContactProfile *viewContactPage = [[ViewContactProfile alloc]init];
            viewContactPage.triggeredFrom = @"explore";
            viewContactPage.userId=[resultIdArray objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:viewContactPage animated:NO];
            
        }*/
        
    }
    
    
}


// search bar delegates
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    searchBar.showsCancelButton=TRUE;
    //[ExploreTableView reloadData];
    //searchVariable =5;
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    //[self handleSearch:searchBar];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    searchBar.showsCancelButton=FALSE;
    [searchBar resignFirstResponder];
    [self setActivityIndicator];
    pageno = 1;
    [searchData removeAllObjects];
    [self handleSearch];
    
}

- (void)handleSearch {
    
    HUD.labelText = @"Searching....Please Wait !";
    
    NSLog(@"User searched for %@", search.text);
    [self clearArrays:@"array"];
    [self clearArrays:@"temp"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *searchText=[NSString stringWithFormat:@"%@",search.text];
    NSString *postData = [NSString stringWithFormat:@"search_data=%@&user_id=%@&latitude=%f&longitude=%f&current_page=%d",searchText,appUserId, latitude, longitude, pageno];
    NSLog(@"request %@",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/search_group_user_gps.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    //set post data of request
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    //initialize a connection from request
    searchConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [searchConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [searchConn start];
    searchResponse = [[NSMutableData alloc] init];
}

- (void)nextPage{
    
    if (searchData.count >= 100) {
        pageno++;
        [self handleSearch];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    NSLog(@"User canceled search");
    searchBar.showsCancelButton=FALSE;
    searchBar.text = @"";
    [searchBar resignFirstResponder];// if you want the keyboard to go away
    searchVariable = 0;
    [ExploreTableView reloadData];
    groupByCategoryLabel.text=@"BROWSE GROUPS BY CATEGORY";
    groupByCategoryLabel.textColor=[UIColor lightGrayColor];
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)fetchGroupCount
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postData = [NSString stringWithFormat:@"user_id=%@&latitude=%f&longitude=%f",appUserId, latitude, longitude];
    NSLog(@"request %@",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/fetch_category_update_gps.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    //set post data of request
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    groupCountConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [groupCountConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [groupCountConn start];
    groupCountResponse = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == searchConn) {
        [searchResponse setLength:0];
    }
    if (connection == addContactConn) {
        [addContactResponse setLength:0];
    }
    if (connection == initiateGroupJoinConn) {
        [initiateGroupJoinResponse setLength:0];
    }
    if (connection == addGroupConn) {
        [addGroupResponse setLength:0];
    }
    if (connection == addFavGroupConn) {
        [addFavGroupResponse setLength:0];
    }
    if (connection == groupCountConn) {
        [groupCountResponse setLength:0];
    }
    if (connection == multiJoinConn) {
        [multiJoinResponse setLength:0];
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"did recieve data");
    if (connection == searchConn) {
        [searchResponse appendData:data];
    }
    if (connection == addContactConn) {
        [addContactResponse appendData:data];
    }
    if (connection == initiateGroupJoinConn) {
        [initiateGroupJoinResponse appendData:data];
    }
    if (connection == addGroupConn) {
        [addGroupResponse appendData:data];
    }
    if (connection == addFavGroupConn) {
        [addFavGroupResponse appendData:data];
    }
    if (connection == groupCountConn) {
        [groupCountResponse appendData:data];
    }
    
    if (connection == multiJoinConn) {
        [multiJoinResponse appendData:data];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [HUD hide:YES];

    if (connection == groupCountConn) {
        groupCountConn = nil;
    }
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                     message:[error.userInfo objectForKey:@"NSLocalizedDescription"]
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [alert show];

}

-(CGSize)calculateHeight:(NSString*)data{
    
    CGFloat width = self.view.frame.size.width - 80;
    UIFont *font = [UIFont fontWithName:@"Dosis-Regular" size:12.0f + [[self appDelegate] increaseFont]];
    NSAttributedString *attributedText = [[NSAttributedString alloc]initWithString:data attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    return size;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@" finished loading");
    //searchVariable = 0;
    if (connection == groupCountConn) {
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:groupCountResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSArray *results = res[@"category_list"];
        if (categoryNames.count == 0) {
            [HUD hide:YES];
            if ([results count]==0 ) {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                                 message:@"No categories present."
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                [alert show];
            }
        }
        if ([results count] > 0) {
            NSLog(@"====EVENTS==3 %@",res);
            [categoryIds removeAllObjects];
            [categoryThumbnails removeAllObjects];
            [categoryNames removeAllObjects];
            [categoryGroupNo removeAllObjects];
            for (NSDictionary *result in results) {
                
                NSString *categoryId = result[@"category_id"];
                NSString *categoryName = result[@"category_name"];
                NSString *groupsAssociated = result[@"group_associated"];
                NSString *displayPic = result[@"display_pic_50"];
                
                NSLog(@"category id: %@",categoryId);
                NSLog(@"category name: %@",categoryName);
                NSLog(@"group no: %@",groupsAssociated);
                NSLog(@"display pic: %@",displayPic);
                
                [categoryIds addObject:categoryId];
                [categoryNames addObject:categoryName];
                [categoryGroupNo addObject:groupsAssociated];
                [categoryThumbnails addObject:displayPic];
            }
            [ExploreTableView reloadData];
        }
        groupCountConn=nil;
        [groupCountConn cancel];
    }
    
    if (connection == searchConn) {
        NSString *str = [[NSMutableString alloc] initWithData:searchResponse encoding:NSASCIIStringEncoding];
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *results = res[@"group_list"];
        NSDictionary *groups=results[@"list"];
        
        if ([groups count]==0 )
        {
            [HUD hide:YES];
            if (pageno == 1) {
                groupByCategoryLabel.textColor = [UIColor redColor];
                groupByCategoryLabel.text = @"NO MATCH FOUND";
            }
        }
        else{
            for (NSDictionary *result in groups) {
                if (![result[@"id"]isEqualToString:appUserId]){
                    
                    NSMutableDictionary *datav = [[NSMutableDictionary alloc]init];
                    [datav addEntriesFromDictionary:result];
                    NSString* description = [datav objectForKey:@"description"];
                    if (description == nil) {
                        description = @"";
                    }
                    
                    CGSize size =[self calculateHeight:[description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                    [datav setObject:[NSString stringWithFormat:@"%f",size.height] forKey:@"height"];
                    [datav setObject:@"0" forKey:@"is_exist"];
                    
                    if([[result objectForKey:@"type"] isEqualToString:@"public#local"]||[[result objectForKey:@"type"] isEqualToString:@"public#global"]){
                        
                        NSString *checkIfPublicGroupExists=[NSString stringWithFormat:@"select * from groups_public where group_server_id=%@",result[@"id"]];
                        BOOL publicGroupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfPublicGroupExists];
                        
                        if(!publicGroupExistOrNot){
                            
                            [datav setObject:@"0" forKey:@"is_exist"];
                        }else{
                            
                            [datav setObject:@"1" forKey:@"is_exist"];
                        }
                    }else if ([result[@"type"] isEqual:@"private#local"]||[result[@"type"] isEqual:@"private#global"])
                    {
                        
                        NSString *checkIfPrivateGroupExists=[NSString stringWithFormat:@"select * from groups_private where group_server_id=%@",result[@"id"]];
                        
                        BOOL privateGroupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfPrivateGroupExists];
                        
                        if (!privateGroupExistOrNot) {
                            
                            [datav setObject:@"0" forKey:@"is_exist"];
                            
                        }else{
                            
                            [datav setObject:@"1" forKey:@"is_exist"];
                        }
                        
                    }else{
                        
                        NSString *query  = [NSString stringWithFormat:@"select * from contacts where user_id = '%@'",result[@"id"]];
                        
                        BOOL recordExist = [[DatabaseManager getSharedInstance] recordExistOrNot:query];
                        
                        if (!recordExist) {
                            
                            [datav setObject:@"0" forKey:@"is_exist"];
                            
                        }else{
                            
                            [datav setObject:@"1" forKey:@"is_exist"];
                        }
                        
                    }
                    
                    [datav setObject:@"search" forKey:@"cell_type"];
                    
                    [searchData addObject:datav];
                    
                    expndRow =-1;
                    
                    
                }
                
            }
            
            if (searchData.count==0) {
                if (pageno == 1) {
                    groupByCategoryLabel.textColor = [UIColor redColor];
                    groupByCategoryLabel.text = @"NO MATCH FOUND";
                }
                
            }else{
                groupByCategoryLabel.textColor = [UIColor lightGrayColor];
                groupByCategoryLabel.text=@"SEARCH RESULTS";
                
            }
            
            
            NSArray *copy = [tempResultIdArray copy];
            NSInteger index = [copy count] - 1;
            for (id object in [copy reverseObjectEnumerator]) {
                if ([tempResultIdArray indexOfObject:object inRange:NSMakeRange(0, index)] != NSNotFound) {
                    [tempResultIdArray removeObjectAtIndex:index];
                }
                index--;
            }
            
        }
        searchVariable =1;
        [selectedGroup removeAllObjects];
        [ExploreTableView reloadData];
        [HUD hide:YES];
        
        joinButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 60.0f, 30.0f)];
        [joinButton setTitle:@"Join" forState:UIControlStateNormal];
        [joinButton addTarget:self action:@selector(joinAllGroup) forControlEvents:UIControlEventTouchUpInside];
        [joinButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:207.0/255.0 blue:13.0/255.0 alpha:1] forState:UIControlStateNormal];
        joinButton.titleLabel.font = [UIFont fontWithName:@"Dosis-Bold" size:20];
        
        [searchConn cancel];
        searchConn=nil;
    }
    if(connection == multiJoinConn){
        
        NSString *str1 = [[NSMutableString alloc] initWithData:multiJoinResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str1);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        
        NSDictionary *res= [jsonparser objectWithString:str1];
        
        NSLog(@" result %@",res);
        
        NSDictionary *response= res[@"response"];
    }
    if (connection == addContactConn) {
        NSLog(@"====EVENTS");
        NSString *str1 = [[NSMutableString alloc] initWithData:addContactResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str1);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        
        NSDictionary *res= [jsonparser objectWithString:str1];
        
        NSLog(@" result %@",res);
        
        NSDictionary *response= res[@"response"];
        
        NSLog(@"response %@",response);
        NSString *status = response[@"status"];
        NSString *error = response[@"error"];
        NSLog(@"status = %@ error =  %@",status,error);
        
        if ([status isEqualToString:@"0"]){
            NSLog(@"selected %@,%@,%@,%@,%@,%@",selectedContactId,selectedContactEmail,selectedContactName,selectedContactPic,selectedContactStatus,selectedContactLocation);
            NSString *insertQuery=[NSString stringWithFormat:@"insert into contacts (user_id, user_email, user_name, user_pic, user_status,user_location) values ('%@','%@','%@','%@','%@','%@')",selectedContactId,selectedContactEmail,[selectedContactName stringByReplacingOccurrencesOfString:@"'" withString:@"''"],selectedContactPic,selectedContactStatus,selectedContactLocation];
            [[self appDelegate]addFriendWithJid:[[NSString stringWithFormat:@"user_%@@",selectedContactId] stringByAppendingString:(NSString*)jabberUrl ] nickName:selectedContactName];
            
            NSLog(@"query %@",insertQuery);
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertQuery];
            
            //download image and save in the cache
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,selectedContactPic]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //cell.imageView.image = [UIImage imageWithData:imgData];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    NSLog(@"paths=%@",paths);
                    NSString *contactPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",selectedContactPic]];
                    NSLog(@"conatct pic path=%@",contactPicPath);
                    //imageData=UIImageJPEGRepresentation(groupPic.image, 1);
                    //Writing the image file
                    [imgData writeToFile:contactPicPath atomically:YES];
                    
                    
                });
                
            });
            
            [HUD  hide:YES];
            
            ChatScreen *chatScreen = [[ChatScreen alloc]init];
            
            chatScreen.chatType = @"personal";
            chatScreen.chatTitle=selectedContactName;
            [chatScreen initWithUser:[NSString stringWithFormat:@"user_%d@%@",[selectedContactId integerValue],(NSString*)jabberUrl]];
            
            chatScreen.groupType=@"";
            
            
            NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
            [attributeDic setValue:@"chat" forKey:@"type"];
            [attributeDic setValue:[selectedContactId JID]forKey:@"to"];
            [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
            [attributeDic setValue:@"0" forKey:@"isResend"];
            NSString *body=[NSString stringWithFormat:@"%@ has added you ",[[DatabaseManager getSharedInstance]getAppUserName]];
            NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
            [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID] forKey:@"from_user_id"];
            [elementDic setValue:@"text" forKey:@"message_type"];
            [elementDic setValue:@"1" forKey:@"contactUpdate"];
            [elementDic setValue:@"1" forKey:@"show_notification"];
            [elementDic setValue:@"1" forKey:@"is_notify"];
            [elementDic setValue:@"0" forKey:@"isgroup"];
            //  NSLog(@"gid %@",groupId);
            // [elementDic setValue:[NSString stringWithFormat:@"%@",groupId ] forKey:@"groupID"];
            [elementDic setValue:body forKey:@"body"];
            
            [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
            [self.navigationController pushViewController:chatScreen animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"User has been added to your contact list."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }else{
            
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        
        addContactConn=nil;
        
        [addContactConn cancel];
        
    }
    if (connection == initiateGroupJoinConn) {
        NSLog(@"====EVENTS");
        NSString *str1 = [[NSMutableString alloc] initWithData:initiateGroupJoinResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str1);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str1];
        NSLog(@" result %@",res);
        NSDictionary *response= res[@"response"];
        
        NSLog(@"response %@",response);
        NSString *status = response[@"status"];
        NSString *error = response[@"error"];
        NSLog(@"status = %@ error =  %@",status,error);
        if ([status isEqualToString:@"0"]){
            
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }else{
            
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.tag=1;
            [alert show];
            
        }
        [[self appDelegate]._chatDelegate buddyStatusUpdated];
        
        initiateGroupJoinConn=nil;
        
        [initiateGroupJoinConn cancel];
        
    }
    if (connection == addGroupConn) {
        NSLog(@"====EVENTS");
        NSString *str1 = [[NSMutableString alloc] initWithData:addGroupResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str1);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        
        NSDictionary *res= [jsonparser objectWithString:str1];
        
        NSLog(@" result %@",res);
        
        NSDictionary *response= res[@"response"];
        NSMutableArray *adminIdList= [[NSMutableArray alloc]init];
        
        adminIdList=response[@"admin_ids"];
        
        NSLog(@"admin id list: %@",adminIdList);
        NSLog(@"response %@",response);
        NSString *status = response[@"status"];
        NSString *error = response[@"error"];
        NSLog(@"status = %@ error =  %@",status,error);
        if ([status isEqualToString:@"0"]){
            
            [HUD hide:YES];
            
            NSString *checkIfGroupExists=[NSString stringWithFormat:@"select * from group_invitations where group_id=%@",selectedGroupId];
            BOOL groupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfGroupExists];
            if (groupExistOrNot) {
                NSString *updateQuery=[NSString stringWithFormat:@"update  group_invitations set group_id = '%@', group_name = '%@', group_pic = '%@', group_type ='%@' where group_id = '%@' ",selectedGroupId,[selectedGroupName normalizeDatabaseElement],selectedGroupPic,selectedGroupType,selectedGroupId];
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateQuery];
            }
            else
            {
                NSString *insertQuery=[NSString stringWithFormat:@"insert into group_invitations (group_id, group_name, group_pic, group_type) values ('%@','%@','%@','%@')",selectedGroupId,[selectedGroupName normalizeDatabaseElement],selectedGroupPic,selectedGroupType];
                NSLog(@"query %@",insertQuery);
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertQuery];
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            for (int j=0; j<[adminIdList count]; j++)
            {
                NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
                [attributeDic setValue:@"chat" forKey:@"type"];
                
                [attributeDic setValue:[[adminIdList objectAtIndex:j] JID] forKey:@"to"];
                [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
                [attributeDic setValue:@"0" forKey:@"isResend"];
                NSString *userName=[[DatabaseManager getSharedInstance]getAppUserName];
                NSString *body=[NSString stringWithFormat:@"%@ want to join your group %@",userName,selectedGroupName  ];
                NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                // [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] JID] forKey:@"from_user_id"];
                [elementDic setValue:@"text" forKey:@"message_type"];
                [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID] forKey:@"from_user_id"];
                
                
                // if ([[memberId objectAtIndex:j]isEqualToString:userID])
                [elementDic setValue:@"1" forKey:@"grpUpdate"];
                //  if ([userID isEqual:[memberId objectAtIndex:j]] ) {
                [elementDic setValue:@"1" forKey:@"show_notification"];
                [elementDic setValue:@"1" forKey:@"is_notify"];
                // }
                //  else
                //  {
                //     [elementDic setValue:@"0" forKey:@"is_notify"];
                //      [elementDic setValue:@"0" forKey:@"show_notification"];
                //  }
                [elementDic setValue:@"1" forKey:@"isgroup"];
                // NSLog(@"gid %@",groupId);
                //  [elementDic setValue:[NSString stringWithFormat:@"%@",groupId ] forKey:@"groupID"];
                [elementDic setValue:body forKey:@"body"];
                
                [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
                
                
            }
            
            
            [[self appDelegate]._chatDelegate buddyStatusUpdated];
        }
        else
        {
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        //     ChatScreen *chatScreen = [[ChatScreen alloc]init];
        //    chatScreen.chatType = @"group";
        //    chatScreen.chatTitle=selectedGroupName;
        //   [chatScreen initWithUser:[NSString stringWithFormat:@"user_%d@%@",[selectedGroupId integerValue],(NSString*)jabberUrl]];
        
        //   chatScreen.groupType=selectedGroupType ;
        //    [chatScreen retreiveHistory:nil];
        
        addGroupConn=nil;
        
        [addGroupConn cancel];
        
    }
    
    if (connection == addFavGroupConn) {
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:addFavGroupResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        NSLog(@"end connection");
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSDictionary *results = res[@"response"];
        NSLog(@"results: %@", results);
        NSDictionary *groups=results[@"Group_Details"];
        NSString *status=results[@"status"];
        NSLog(@"status: %@",status);
        NSLog(@"groups: %@", groups);
        NSDictionary *members=groups[@"member_details"];
        NSLog(@"members: %@",members);
        NSDictionary *deletedMembers = groups[@"deleted_members"];
        NSLog(@"deleted members%@",deletedMembers);
        NSString *error=results[@"error"];
        
        //[imageView removeAllObjects];
        if (![status isEqualToString:@"1"])
        {
            
            NSString *checkIfPublicGroupExists=[NSString stringWithFormat:@"select * from groups_public where group_server_id=%@",groups[@"id"]];
            BOOL publicGroupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfPublicGroupExists];
            if (publicGroupExistOrNot) {
                NSString *updatePublicGroup=[NSString stringWithFormat:@"update  groups_public set group_server_id = '%@', location_name = '%@', category_name = '%@', added_date ='%@',is_favourite ='1', group_name ='%@', group_type='%@', group_pic='%@', group_description='%@', total_members='%@' where group_server_id = '%@' ",groups[@"id"],groups[@"location_name"],groups[@"category_name"],groups[@"creation_date"],[groups[@"group_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],groups[@"group_type"],groups[@"group_pic"],[groups[@"group_description"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],groups[@"member_count"],groups[@"id"]];
                NSLog(@"query %@",updatePublicGroup);
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updatePublicGroup];
            }
            else
            {
                
                NSString *insertPublicGroup=[NSString stringWithFormat:@"insert into groups_public (group_server_id, location_name, category_name, added_date,is_favourite, group_name,group_type, group_pic,group_description,total_members) values ('%@','%@','%@','%@','%d','%@','%@','%@','%@','%@')",groups[@"id"],groups[@"location_name"],groups[@"category_name"],groups[@"creation_date"],1,[groups[@"group_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],groups[@"group_type"],groups[@"group_pic"],[groups[@"group_description"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],groups[@"member_count"]];
                NSLog(@"query %@",insertPublicGroup);
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertPublicGroup];
            }
            
            if ([members count]==0 )
            {
                NSLog(@"no members");
            }
            else
            {
                for (NSDictionary *member in members)
                {
                    NSString *checkIfMemberExists=[NSString stringWithFormat:@"select * from group_members where group_id=%@ and contact_id=%@ and deleted!=1",groups[@"id"],member[@"user_id"]];
                    BOOL memberExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfMemberExists];
                    if (memberExistOrNot) {
                        NSString *updateMembers=[NSString stringWithFormat:@"update  group_members set group_id = '%@', contact_id = '%@', is_admin = '%@', contact_name ='%@', contact_location ='%@', contact_image='%@' where group_id = '%@' and contact_id='%@' ",groups[@"id"],member[@"user_id"],member[@"is_admin"],[member[@"display_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],member[@"location_name"],member[@"profile_pic"],groups[@"id"],member[@"user_id"]];
                        NSLog(@"query %@",updateMembers);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMembers];
                    }else{
                        
//                        NSString *insertMembers=[NSString stringWithFormat:@"insert into group_members (group_id, contact_id, is_admin, contact_name, contact_location,contact_image) values ('%@','%@','%@','%@','%@','%@')",groups[@"id"],member[@"user_id"],member[@"is_admin"],[member[@"display_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],member[@"location_name"],member[@"profile_pic"]];
                        //                        NSLog(@"query %@",insertMembers);
//                                                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertMembers];
                    }
                    //download image and save in the cache
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,member[@"profile_pic"]]]];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //cell.imageView.image = [UIImage imageWithData:imgData];
                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                            NSLog(@"paths=%@",paths);
                            NSString *memberPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",member[@"profile_pic"]]];
                            NSLog(@"member pic path=%@",memberPicPath);
                            //Writing the image file
                            [imgData writeToFile:memberPicPath atomically:YES];
                            
                            
                        });
                        
                    });
                    
                    
                }
            }
            if ([deletedMembers count]==0 )
            {
                NSLog(@"no members");
            }
            else
            {
                for (NSDictionary *deletedMember in deletedMembers)
                {
                    NSLog(@"deleted user id%@ \n",deletedMember);
                    NSString *checkIfMemberToDeleteExists=[NSString stringWithFormat:@"select * from group_members where group_id=%@ and contact_id=%@ and deleted!=1",groups[@"id"],deletedMember];
                    BOOL memberToDeleteExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfMemberToDeleteExists];
                    if (memberToDeleteExistOrNot) {
                        // NSString *deleteMemberQuery=[NSString stringWithFormat:@"delete from group_members where group_id=%@ and contact_id=%@ ",groups[@"id"],deletedMember];
                        //NSLog(@"query %@",deleteMemberQuery);
                        // [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteMemberQuery];
                        NSString *updateMemberQuery=[NSString stringWithFormat:@"update group_members set deleted=1 where group_id=%@ and contact_id=%@ ",groups[@"id"],deletedMember];
                        NSLog(@"query %@",updateMemberQuery);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMemberQuery];
                    }
                    
                }
            }
            
            //download image and save in the cache
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,groups[@"group_pic"]]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //cell.imageView.image = [UIImage imageWithData:imgData];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    NSLog(@"paths=%@",paths);
                    NSString *memberPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",groups[@"group_pic"]]];
                    NSLog(@"member pic path=%@",memberPicPath);
                    //Writing the image file
                    [imgData writeToFile:memberPicPath atomically:YES];
                    
                    
                });
                
            });
            
            [HUD hide:YES];
            NSArray *tempmembersID=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_id from group_members where group_id=%@ and deleted!=1",groups[@"id"]]];
            NSMutableArray    *membersID=[[NSMutableArray alloc]init];
            for (int i=0; i<[tempmembersID count];i++)
            {
                [membersID addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_ID"]] ;
            }
            
            NSLog(@"membersID %@",membersID);
            
            
            for (int j=0; j<[membersID count]; j++){
                
                NSLog(@"%@ %@",membersID,membersID[j]);
                NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
                [attributeDic setValue:@"chat" forKey:@"type"];
                [attributeDic setValue:[[membersID objectAtIndex:j] JID] forKey:@"to"];
                [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
                [attributeDic setValue:@"0" forKey:@"isResend"];
                NSString *body=[NSString stringWithFormat:@"Your request to join %@ has been accepted",groups[@"group_name"] ];
                NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                // [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] JID] forKey:@"from_user_id"];
                [elementDic setValue:@"text" forKey:@"message_type"];
                [elementDic setValue:@"1" forKey:@"grpUpdate"];
                [elementDic setValue:@"0" forKey:@"show_notification"];
                [elementDic setValue:@"1" forKey:@"isgroup"];
                NSLog(@"gid %@",groups[@"id"]);
                [elementDic setValue:groups[@"id"] forKey:@"groupID"];
                [elementDic setValue:body forKey:@"body"];
                
                [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
            }
            
            [[self appDelegate]._chatDelegate buddyStatusUpdated];
            
            
            
            PostListing *detailPage = [[PostListing alloc]init];
            detailPage.chatTitle=groups[@"group_name"];
            detailPage.groupId = groups[@"id"];
            detailPage.groupName = groups[@"group_name"];
            detailPage.groupType=groups[@"group_type"];
            [self appDelegate].isUSER=0;
            [self.navigationController pushViewController:detailPage animated:YES];
            

            
        }else{
            
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            
        }
        
        addFavGroupConn=nil;
        [addFavGroupConn cancel];
    }
    
    
}
//uialertview delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1) {
        if (buttonIndex == 1) {
            [self setActivityIndicator];
            
            
            
            NSLog(@"You have clicked submit%@%@",selectedGroupId,appUserId);
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@",selectedGroupId,appUserId];
            NSLog(@"$[%@]",postData);
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/private_grp_request.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            addGroupConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [addGroupConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [addGroupConn start];
            addGroupResponse = [[NSMutableData alloc] init];
        }
        
    }
    
}

-(IBAction)setFilterTable:(id)sender
{
    [pop dismissPopoverAnimated:YES];
    //the view controller you want to present as popover
    //  UIViewController *controller = [[UIViewController alloc] init];
    filterTable = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    //initWithFrame:CGRectMake(15, 92, 100, 100) style:UITableViewStyleGrouped];
    [filterTable.tableView setFrame:CGRectMake(15, 92, 100, 100)];
    
    filterTable.tableView.backgroundColor=[UIColor clearColor];
    
    filterTable.tableView.delegate = self;
    filterTable.tableView.dataSource = self;
    filterTable.tableView.scrollEnabled=FALSE;
    //controller.view=filterTable;
    // controller.title = @"Filter";
    //our popover
    //pop=[[UIPopoverController alloc] initWithContentViewController:controller];
    
    navController = [[UINavigationController alloc] initWithRootViewController:filterTable];
    filterTable.title=@"Filter";
   // [navController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor] ,UITextAttributeTextColor,[UIFont fontWithName:@"Helvetica Neue" size:17],UITextAttributeFont, nil]];
    //  [navController.navigationBar setBackgroundColor:[UIColor greenColor] ];
    pop=[[UIPopoverController alloc]initWithContentViewController:navController ];
    
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 50.0f, 30.0f)];
    
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];//[UIColor
    [doneButton addTarget:self action:@selector(donefiltering:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitleColor:[UIColor colorWithRed:5.0/255.0 green:122/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
    // UIBarButtonItem *Cancel = [[UIBarButtonItem alloc]                initWithTitle:@"Cancel"                style:UIBarButtonItemStyleBordered                target:self                action:@selector(CancelForward)];
    navController.navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    UIButton *clearButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 50.0f, 30.0f)];
    [clearButton setTitle:@"Clear" forState:UIControlStateNormal];//[UIColor
    [clearButton addTarget:self action:@selector(cancelPop:) forControlEvents:UIControlEventTouchUpInside];
    [clearButton setTitleColor:[UIColor colorWithRed:5.0/255.0 green:122/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
    // UIBarButtonItem *Cancel = [[UIBarButtonItem alloc]                initWithTitle:@"Cancel"                style:UIBarButtonItemStyleBordered                target:self                action:@selector(CancelForward)];
    navController.navigationBar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:clearButton];
    
    // UIBarButtonItem *doneButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(donefiltering:)];
    // navController.navigationBar.topItem.rightBarButtonItem=doneButtonItem;
    // UIBarButtonItem *cancelButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPop:)];
    //   navController.navigationBar.topItem.leftBarButtonItem=cancelButtonItem;
    //[self.navigationController pushViewController:controller animated:YES];
    
    [pop setPopoverContentSize:CGSizeMake(self.view.frame.size.width-10, 180)];
    //[pop presentPopoverFromBarButtonItem:filterButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
    
    CGRect rect = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 10, 10);
    [pop presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
    
    /* popover = [[FPPopoverController alloc] initWithViewController:controller];
     popover.contentSize = CGSizeMake(200,182);
     
     popover.arrowDirection = FPPopoverNoArrow;
     popover.border = NO;
     [popover presentPopoverFromView:segControl];*/
}
-(void)donefiltering:(id)sender
{
    
    if (userFilter==1||privateFilter==1||publicFilter==1) {
        [self clearArrays:@"array"];
    }
    
    if (userFilter==1) {
        
        for (int m=0; m<tempResultIdArray.count; m++) {
            if ([tempTypeArray[m] isEqualToString:@"0"]) {
                [resultIdArray addObject:[tempResultIdArray objectAtIndex:m]];
                [textLabel addObject:[tempTextLabel objectAtIndex:m]];
                [tableType addObject:[tempTableType objectAtIndex:m]];
                [typeArray addObject:[tempTypeArray objectAtIndex:m]];
                [detailTextLabel addObject:[tempDetailTextLabel objectAtIndex:m]];
                [imageView addObject:[tempImageView objectAtIndex:m]];
                [userEmailId addObject:[tempUserEmailId objectAtIndex:m]];
                [userStatus addObject:[tempUserStatus objectAtIndex:m]];
            }
        }
    }
    if (privateFilter==1) {
        
        for (int m=0; m<tempResultIdArray.count; m++) {
            if ([tempTypeArray[m] isEqualToString:@"private#local"]||[tempTypeArray[m] isEqualToString:@"private#global"]) {
                [resultIdArray addObject:[tempResultIdArray objectAtIndex:m]];
                [textLabel addObject:[tempTextLabel objectAtIndex:m]];
                [tableType addObject:[tempTableType objectAtIndex:m]];
                [typeArray addObject:[tempTypeArray objectAtIndex:m]];
                [detailTextLabel addObject:[tempDetailTextLabel objectAtIndex:m]];
                [imageView addObject:[tempImageView objectAtIndex:m]];
                [userEmailId addObject:[tempUserEmailId objectAtIndex:m]];
                [userStatus addObject:[tempUserStatus objectAtIndex:m]];
            }
        }
    }
    if (publicFilter==1) {
        
        for (int m=0; m<tempResultIdArray.count; m++) {
            if ([tempTypeArray[m] isEqualToString:@"public#global"]||[tempTypeArray[m] isEqualToString:@"public#local"]) {
                [resultIdArray addObject:[tempResultIdArray objectAtIndex:m]];
                [textLabel addObject:[tempTextLabel objectAtIndex:m]];
                [tableType addObject:[tempTableType objectAtIndex:m]];
                [typeArray addObject:[tempTypeArray objectAtIndex:m]];
                [detailTextLabel addObject:[tempDetailTextLabel objectAtIndex:m]];
                [imageView addObject:[tempImageView objectAtIndex:m]];
                [userEmailId addObject:[tempUserEmailId objectAtIndex:m]];
                [userStatus addObject:[tempUserStatus objectAtIndex:m]];
            }
        }
    }
    
    if(resultIdArray .count==0)
    {
        groupByCategoryLabel.textColor = [UIColor redColor];
        groupByCategoryLabel.text=@"NO RESULTS";
    }
    else
    {
        groupByCategoryLabel.textColor = [UIColor lightGrayColor];
        groupByCategoryLabel.text=@"SEARCH RESULTS";
    }
    searchVariable =1;
    [ExploreTableView reloadData];
    //userFilter=0;
    //privateFilter=0;
    //publicFilter=0;
    
    [pop dismissPopoverAnimated:YES];
}
-(void)cancelPop:(id)sender
{
    userFilter=1;
    publicFilter=1;
    privateFilter=1;
    [filterTable.tableView reloadData];
    [self donefiltering:nil];
    [pop dismissPopoverAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)joinAllGroup{
    
    if (selectedGroup.count == 0) {
        return;
    }
    
    [self setActivityIndicator];
    
    NSMutableArray *users= [[NSMutableArray alloc] init];
    
    NSMutableArray *privateg= [[NSMutableArray alloc] init];
    
    NSMutableArray *publicg= [[NSMutableArray alloc] init];
    
    [selectedGroup enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSInteger row = [obj integerValue];
        
      
        
        if([[[searchData objectAtIndex:row] objectForKey:@"type"] isEqualToString:@"public#local"]||[[[searchData objectAtIndex:row] objectForKey:@"type"] isEqualToString:@"public#global"]){
            
            [publicg addObject:[searchData objectAtIndex:row][@"id"]];
          
        }else if ([[searchData objectAtIndex:row][@"type"] isEqual:@"private#local"]||[[searchData objectAtIndex:row][@"type"] isEqual:@"private#global"])
        {
            [privateg addObject:[searchData objectAtIndex:row][@"id"]];
        }else{
            
           [users addObject:[searchData objectAtIndex:row][@"id"]];
            
        }
        
        if(idx==selectedGroup.count-1){
            

            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
            AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
            
            NSString *ua = @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25";
            
            [requestSerializer setValue:ua forHTTPHeaderField:@"User-Agent"];
            [requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            
            manager.responseSerializer = responseSerializer;
            manager.requestSerializer = requestSerializer;
            manager.requestSerializer.timeoutInterval = 60*4;
            
            NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
            [data setValue:privateg forKey:@"private_group"];
            [data setValue:publicg forKey:@"public_group"];
            [data setValue:users forKey:@"users"];
            [data setValue:appUserId forKey:@"user_id"];
            
            NSString *url =[NSString stringWithFormat:@"%@/scripts/multi_group_user_join.php",gupappUrl];
            [manager POST:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [HUD hide:YES];
                self.navigationItem.rightBarButtonItem = nil;
                NSData * data = (NSData*)responseObject;
                NSError *error = nil;
                NSArray *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
               
                [selectedGroup enumerateObjectsUsingBlock:^(id objs, NSUInteger idx, BOOL *stop) {
                    
                    NSInteger rows = [objs integerValue];
                    
                    [[searchData objectAtIndex:rows] setObject:@"1" forKey:@"is_exist"];
                    
                    if ([[searchData objectAtIndex:row][@"type"] containsString:@"private"]) {
                    }else if ([[searchData objectAtIndex:row][@"type"] containsString:@"public"]){
                    } else {
                        NSString *insertQuery=[NSString stringWithFormat:@"insert into contacts (user_id, user_email, user_name, user_pic, user_status,user_location) values ('%@','%@','%@','%@','%@','%@')",[searchData objectAtIndex:rows][@"id"],[searchData objectAtIndex:rows][@"email"],[searchData objectAtIndex:rows][@"name"],[searchData objectAtIndex:rows][@"display_pic"],[searchData objectAtIndex:rows][@"status"],[searchData objectAtIndex:rows][@"bottom_display"]];
                        [[self appDelegate]addFriendWithJid:[[NSString stringWithFormat:@"user_%@@",selectedContactId] stringByAppendingString:(NSString*)jabberUrl ] nickName:selectedContactName];
                        
                        NSLog(@"query %@",insertQuery);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertQuery];
                    }
                }];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"The selected groups and users will be available in your profile soon. Private groups will be activated once the group administrator has approved your request."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
                if (privateg.count > 0 || publicg.count > 0) {
                    GroupViewController* groupViewController = (GroupViewController*)[self appDelegate].groupViewController;
                    [groupViewController setNeedFetch:YES];
                } else if (users.count > 0){
                    FirstViewController* firstViewController = (FirstViewController*)[self appDelegate].firstViewController;
                    [firstViewController setNeedFethc:YES];
                }
                
                [selectedGroup removeAllObjects];
                
                expndRow =-1;
                
                [ExploreTableView reloadData];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               [HUD hide:YES];
                
            }];
           
            
        }
        
    }];
   
}

-(void)clearArrays:(NSString *)variable
{
    if ([variable isEqualToString:@"temp"]) {
        [tempResultIdArray removeAllObjects];
        [tempTextLabel removeAllObjects];
        [tempTableType removeAllObjects];
        [tempTypeArray removeAllObjects];
        [tempDetailTextLabel removeAllObjects];
        [tempImageView removeAllObjects];
        [tempUserEmailId removeAllObjects];
        [tempUserStatus removeAllObjects];
    }
    else
    {
        [resultIdArray removeAllObjects];
        [textLabel removeAllObjects];
        [tableType removeAllObjects];
        [typeArray removeAllObjects];
        [detailTextLabel removeAllObjects];
        [imageView removeAllObjects];
        [userEmailId removeAllObjects];
        [userStatus removeAllObjects];
    }
}

#pragma - mark NewGroupCellDelegate
-(BOOL)checkifSelected:(NSInteger)row{
    if([selectedGroup  containsObject:[NSString stringWithFormat:@"%ld",(long)row]]){
        
        return true;
        
    }else{
        
        return false;
    }
}

-(BOOL)checkiffull:(NSInteger)row{
    if(expndRow==row){
        
        return true;
        
    }else{
        
        return false;
    }
}

-(void)expandCellHeight:(UIButton*)btn withIndex:(NSInteger)row{
    newGroupCell *pcell;
    if ([[btn superview] isKindOfClass:[newGroupCell class]]) {
        pcell = (newGroupCell *)[btn superview];
    }
    else if ([[[btn superview] superview] isKindOfClass:[newGroupCell class]]){
        pcell = (newGroupCell *)[[btn superview] superview];
    }
    expndRow = row;
    NSIndexPath *morePath =[ExploreTableView indexPathForCell:pcell];
    [ExploreTableView beginUpdates];
    [ExploreTableView reloadSections:[NSIndexSet indexSetWithIndex:morePath.section] withRowAnimation:UITableViewRowAnimationNone];
    [self tableView:ExploreTableView heightForRowAtIndexPath:morePath];
    [ExploreTableView endUpdates];
}

-(void)groupSelected:(UIButton*)btn withIndex:(NSInteger)row{
    
    if([selectedGroup  containsObject:[NSString stringWithFormat:@"%ld",(long)row]]){
        
        [selectedGroup removeObject:[NSString stringWithFormat:@"%ld",(long)row]];
        
    }else{
        
        [selectedGroup addObject:[NSString stringWithFormat:@"%ld",(long)row]];
    }
    
    if(selectedGroup.count>0){
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:joinButton];
        
    }else{
        
        self.navigationItem.rightBarButtonItem = nil;
    }
    newGroupCell *pcell;
    if ([[btn superview] isKindOfClass:[newGroupCell class]]) {
        pcell = (newGroupCell *)[btn superview];
    }
    else if ([[[btn superview] superview] isKindOfClass:[newGroupCell class]]){
        pcell = (newGroupCell *)[[btn superview] superview];
    }
    NSIndexPath *morePath =[ExploreTableView indexPathForCell:pcell];
    [ExploreTableView beginUpdates];
    [ExploreTableView reloadSections:[NSIndexSet indexSetWithIndex:morePath.section] withRowAnimation:UITableViewRowAnimationNone];
    [self tableView:ExploreTableView heightForRowAtIndexPath:morePath];
    [ExploreTableView endUpdates];
}

- (void)openGroupInfo:(NSDictionary *)data {
    int is_admin=[[DatabaseManager getSharedInstance]isAdminOrNot:[data objectForKey:@"id"] contactId:appUserId];
    
    if(is_admin == 1){
        viewPrivateGroup *viewGroupAsAdmin = [[viewPrivateGroup alloc]init];
        viewGroupAsAdmin.title = [data objectForKey:@"name"];
        viewGroupAsAdmin.groupId = [data objectForKey:@"id"];
        viewGroupAsAdmin.groupType =[data objectForKey:@"type"];
        [self.navigationController pushViewController:viewGroupAsAdmin animated:NO];
        
        
    }else{
        
        GroupInfo *viewGroupPage = [[GroupInfo alloc]init];
        viewGroupPage.title = [data objectForKey:@"name"];
        viewGroupPage.groupId = [data objectForKey:@"id"];
        viewGroupPage.groupType = [data objectForKey:@"type"];
        viewGroupPage.groupFlog  = [data objectForKey:@"flag"];
        [self.navigationController pushViewController:viewGroupPage animated:NO];
        
        
    }
    
}

- (void)openContactProfile:(NSDictionary *)data {
    ViewContactProfile *viewContact = [[ViewContactProfile alloc]init];
    viewContact.userId = [data objectForKey:@"id"];
    viewContact.userName = [data objectForKey:@"name"];
    viewContact.userImageURL = [data objectForKey:@"thumbnail"];
    viewContact.userLocation = [data objectForKey:@"location_name"];
    [self.navigationController pushViewController:viewContact animated:YES];
}

@end
