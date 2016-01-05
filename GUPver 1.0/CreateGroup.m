//
//  CreateGroup.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/31/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "CreateGroup.h"
#import "XMPPMUC.h"
#import "NSString+Utils.h"
#import "CategoryList.h"
#import "ContactList.h"
#import "JSON.h"
#import "DatabaseManager.h"

@interface CreateGroup (){
    XMPPRoom *xmppRoom;
    NSString *val;
}


@end

@implementation CreateGroup
@synthesize roomMemory;
@synthesize xmpproom;
- (AppDelegate *)appDelegate

{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Create Group";
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}
-(IBAction)dissmisal:(UIButton*)sender1
{
    
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
    
    if ([fileManager fileExistsAtPath: path]){
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        NSLog(@"data %@",data);
        if (![[data objectForKey:@"CreateGroup"] boolValue]) {
            
            [data setObject:[NSNumber numberWithInt:true] forKey:@"CreateGroup"];
            CGSize deviceSize=[UIScreen mainScreen].bounds.size;
            UIImageView *Back=[[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            UIImage *backimage=[UIImage imageNamed:@"create group"];
            [Back setImage:[backimage stretchableImageWithLeftCapWidth:backimage.size.width topCapHeight:backimage.size.height-10]];
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
            //  [dismiss addGestureRecognizer:swipe];
            [Back addSubview:dismiss];
            
            NSLog(@"self %@ \n back %@ \n backback %@ \n backbackback %@",self,self.parentViewController,self.parentViewController.parentViewController,self.parentViewController.parentViewController.parentViewController);
            // [self.parentViewController.parentViewController.view setUserInteractionEnabled:NO];
            [self.parentViewController.parentViewController.view addSubview:Back];
            [self.parentViewController.parentViewController.view bringSubviewToFront:Back ];
            
            NSLog(@"hiii");
        }
        [data writeToFile: path atomically:YES];
        NSLog(@"data %@",data);
        NSLog(@"data %@",data);
    }
    else
    {
        
        data = [[NSMutableDictionary alloc] init];
        [data setObject:[NSNumber numberWithInt:true] forKey:@"IsSuccesfullRun"];
        //  [data setObject:[NSNumber numberWithInt:false] forKey:@"ChatScreen"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"HomeScreen"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"CreateGroup"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"Location"];
        [data writeToFile: path atomically:YES];
        
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [createGroupTable reloadData];
    
    
}


- (void)viewDidLoad{
    [super viewDidLoad];
    [self getLocality];
    loadingLocation=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    defaultImage = YES;
    UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 60.0f, 30.0f)];
    [backButton setTitle:@"Done" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(createGroup) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:207.0/255.0 blue:13.0/255.0 alpha:1] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont fontWithName:@"Dosis-Bold" size:20];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.rightBarButtonItem = addButton;
    

    //[self plistSpooler];
    XMPPMUC *muc = [[XMPPMUC alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    [muc addDelegate:self delegateQueue:dispatch_get_main_queue()];
    status=4;
    locationText = @"Location";
    groupCategory=[[NSString alloc]init];
    groupCategory=@"";
    groupType = @"public";
    globalType=@"local";

    createGroupTable.separatorStyle=0;
    
    groupNameTextView.text = @"Group Name";
    groupNameTextView.textColor = [UIColor lightGrayColor];
    groupNameTextView.delegate = self;

    nameChecked.hidden = YES;
    activityIndicator.hidden = YES;
    
    // Do any additional setup after loading the view from its nib.
    //[self loadCategories];
    noOfSections = 2;
    globalType=@"local";
    //publicGroupIdentifier = @"private";
    scrollView.scrollEnabled=true;
    scrollView.showsVerticalScrollIndicator=true;
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width,380)];
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    // Create and initialize a tap gesture
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    // Specify that the gesture must be a single tap
    tapGesture.numberOfTapsRequired = 1;
    // Add the tap gesture recognizer to the view
    [groupPic addGestureRecognizer:tapGesture];
    
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer{
    NSLog(@"choose pic");
    NSString *option1 = @"Camera Shot";
    NSString *option2 = @"Gallery";
    NSString *option3 = @"Remove Photo";
    NSString *cancelTitle = @"Cancel";
    if ([groupPic.image isEqual:[UIImage imageNamed:@"defaultGroup.png"]]){
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@""
                                      delegate:self
                                      cancelButtonTitle:cancelTitle
                                      destructiveButtonTitle:Nil
                                      otherButtonTitles:option1, option2, nil];
        [actionSheet  showInView:self.view];
    }else{
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@""
                                      delegate:self
                                      cancelButtonTitle:cancelTitle
                                      destructiveButtonTitle:Nil
                                      otherButtonTitles:option1, option2, option3, nil];
        [actionSheet  showInView:self.view];
    }
    
    
    
}

- (void) keyboardWillShow:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSLog(@"hei %f wi %f",kbSize.height,kbSize.width);
    float keyBdHeight;
    if (kbSize.height<kbSize.width){
        
        keyBdHeight=kbSize.height;
        
    }else{
        keyBdHeight=kbSize.width;
    }
    
}

- (void) keyboardWillHide:(NSNotification *)notification {
}

- (CGRect) convertView:(UIView*)view
{
    CGRect rect = view.frame;
    while(view.superview){
        view = view.superview;
        rect.origin.x += view.frame.origin.x;
        rect.origin.y += view.frame.origin.y;
    }
    return rect;
}

#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return  2;
    else if (section == 1)
        return  2;
    else
        return 2;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 100;
    } else {
        return 37;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIView *line;
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    UIButton *image;
    // Add Seperator line
    if(indexPath.section==0)
    {
        if(indexPath.row==0)
        {
            line=[[UIView alloc]initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, tableView.frame.size.width, 0.50)];
            line.backgroundColor=[UIColor colorWithRed:138.0/255.0 green:155.0/255.0 blue:160.0/255.0 alpha:1];
            [cell addSubview:line];
        } else {
            line=[[UIView alloc]initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, tableView.frame.size.width, 0.50)];
            line.backgroundColor=[UIColor colorWithRed:138.0/255.0 green:155.0/255.0 blue:160.0/255.0 alpha:1];
            [cell addSubview:line];
        }
    }
    else if (indexPath.section==1&&indexPath.row==0)
    {
        line=[[UIView alloc]initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, tableView.frame.size.width, 0.50)];
        line.backgroundColor=[UIColor colorWithRed:138.0/255.0 green:155.0/255.0 blue:160.0/255.0 alpha:1];
        [cell addSubview:line];
    }
    else if (indexPath.section==2)
    {
        if(indexPath.row==0)
        {
            line=[[UIView alloc]initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, tableView.frame.size.width, 0.50)];
            line.backgroundColor=[UIColor colorWithRed:138.0/255.0 green:155.0/255.0 blue:160.0/255.0 alpha:1];
            [cell addSubview:line];
        }
        if(indexPath.row==1)
        {
            line=[[UIView alloc]initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y+cell.frame.size.height, tableView.frame.size.width, 0.50)];
            line.backgroundColor=[UIColor colorWithRed:138.0/255.0 green:155.0/255.0 blue:160.0/255.0 alpha:1];
            [cell addSubview:line];
        }
    }
    
    // Set Cell
    if(indexPath.section == 0){
        switch(indexPath.row) {
                
            case 0:// Description
            {
                if (!groupDescTextView) {
                    groupDesc = @"";
                }
                groupDescTextView=[[UITextView alloc] initWithFrame:CGRectMake(cell.frame.origin.x+10, cell.frame.origin.y + 1,cell.frame.size.width - 20 ,98)];
                [groupDescTextView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                groupDescTextView.font = [UIFont fontWithName:@"Dosis-Regular" size:17.f];
                groupDescTextView.autocorrectionType = UITextAutocorrectionTypeDefault;
                groupDescTextView.delegate = self;
                groupDescTextView.textColor = [UIColor lightGrayColor];
                if ([groupDesc isEqualToString:@""]) {
                    groupDescTextView.text = @"Description";
                } else {
                    groupDescTextView.text = groupDesc;
                }
                
                [cell addSubview:groupDescTextView];
                cell.textLabel.font = [UIFont fontWithName:@"Dosis-Regular" size:17.f];
            }
                break;
                
            case 1:// Category
            {
                
                NSLog(@"c %@",groupCategory);
                if ([groupCategory isEqual:@""]) {
                    groupCategory=@"Category";
                }
                
                [cell.textLabel setText:groupCategory];
                NSLog(@"group category%@",groupCategory);
                cell.textLabel.font = [UIFont fontWithName:@"Dosis-Regular" size:17.f];
            }
                break;
        }
    }else if(indexPath.section == 1){
        switch(indexPath.row) {
            case 0:// Private
            {
                
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                cell.textLabel.text = @"Private Group";
                cell.textLabel.font = [UIFont fontWithName:@"Dosis-Regular" size:17.f];
                //[cell setAccessoryType:UITableViewCellAccessoryDetailButton];
                UIButton *disclosureButton1= [[UIButton alloc] init];
                [disclosureButton1 setImage:[UIImage imageNamed:@"indicator"] forState:UIControlStateNormal];
                [disclosureButton1 addTarget:self action:@selector(viewPrivateInfo:) forControlEvents:UIControlEventTouchDown];
                disclosureButton1.frame =  CGRectMake(140.0, cell.center.y-13,20, 20);
                
                [cell addSubview:disclosureButton1];
                image=[[UIButton alloc]initWithFrame:CGRectMake(tableView.frame.size.width-32.0, cell.center.y-13,20,20)];
                image.tag=1;
                [image setImage:[UIImage imageNamed:@"groupCheckMarkDeSelected"] forState:UIControlStateNormal] ;
                [image setImage:[UIImage imageNamed:@"groupCheckMarkSelected"] forState:UIControlStateSelected] ;
                [cell addSubview:image];
                
                if ([groupType isEqualToString:@"private"]){
                    image.selected=YES;
                } else {
                    image.selected=NO;
                }
            }
                break;
            case 1: // Public
            {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                cell.textLabel.text = @"Public Group";
                cell.textLabel.font = [UIFont fontWithName:@"Dosis-Regular" size:17.f];
                //[cell setAccessoryType:UITableViewCellAccessoryDetailButton];
                UIButton *disclosureButton2= [[UIButton alloc] init];
                [disclosureButton2 setImage:[UIImage imageNamed:@"indicator"] forState:UIControlStateNormal];
                [disclosureButton2 addTarget:self action:@selector(viewPublicInfo:) forControlEvents:UIControlEventTouchDown];
                disclosureButton2.frame =  CGRectMake(140.0, cell.center.y-13,20, 20);
                [cell addSubview:disclosureButton2];
                image=[[UIButton alloc]initWithFrame:CGRectMake(tableView.frame.size.width-32.0, cell.center.y-13,20,20)];
                image.tag=2;
                [image setImage:[UIImage imageNamed:@"groupCheckMarkDeSelected"] forState:UIControlStateNormal] ;
                [image setImage:[UIImage imageNamed:@"groupCheckMarkSelected"] forState:UIControlStateSelected] ;
                
                [cell addSubview:image];
                
                if ([groupType isEqualToString:@"public"]){
                    image.selected=YES;
                } else {
                    image.selected=NO;
                }
                
            }
                break;
        }
    }
    else if(indexPath.section == 2)
    {
        switch(indexPath.row) {
            case 0: // Local
            {
                // Location Label
                locationLabel = cell.textLabel;
                locationLabel.text = locationText;
                locationLabel.font = [UIFont fontWithName:@"Dosis-Regular" size:17.f];
                locationLabel.textColor =[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
                
                [loadingLocation setBackgroundColor:[UIColor clearColor]];
                [loadingLocation setFrame:CGRectMake(createGroupTable.frame.size.width-32,15 , 20,20)];
                [loadingLocation setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin];
                [cell addSubview:loadingLocation];
                
                if ([globalType isEqualToString:@"local"] && waitLocation){
                    [loadingLocation startAnimating];
                }
                
            }
                break;
                
            case 1: // Global
            {
                cell.textLabel.text = @"Set as Global";
                cell.textLabel.font = [UIFont fontWithName:@"Dosis-Regular" size:17.f];
                //[cell setAccessoryType:UITableViewCellAccessoryDetailButton];
                UIButton *disclosureButton4= [[UIButton alloc] init];
                [disclosureButton4 setImage:[UIImage imageNamed:@"indicator"] forState:UIControlStateNormal];
                
                [disclosureButton4 addTarget:self action:@selector(viewGlobalInfo:) forControlEvents:UIControlEventTouchDown];
                disclosureButton4.frame = CGRectMake(140.0, cell.center.y-13,20, 20);
                [cell addSubview:disclosureButton4];
                
                image=[[UIButton alloc]initWithFrame:CGRectMake(tableView.frame.size.width-32.0, cell.center.y-13,20,20)];
                image.tag=4;
                [image setImage:[UIImage imageNamed:@"groupCheckMarkDeSelected"] forState:UIControlStateNormal] ;
                [image setImage:[UIImage imageNamed:@"groupCheckMarkSelected"] forState:UIControlStateSelected] ;
                
                [cell addSubview:image];
                if ([globalType isEqualToString:@"global"]){
                    image.selected=YES;
                } else {
                    image.selected=NO;
                }
            }
                break;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        switch(indexPath.row) {
            case 0:
            {
                [createGroupTable reloadData];
            }
                break;
            case 1:
            {
                CategoryList *openCategoryList = [[CategoryList alloc]init];
                openCategoryList.title = @"Category";
                [openCategoryList wantToChangeCategoryFrom:self];
                [self.navigationController pushViewController:openCategoryList animated:YES];
            }
                break;
                
        }
    }
    else if(indexPath.section == 1)
    {
        switch(indexPath.row) {
            case 0: // Private
            {
                groupType = @"private";
            }
                break;
            case 1: // Public
            {
                groupType = @"public";
            }
                break;
        }
        [createGroupTable reloadData];
    }
    else if(indexPath.section == 2)
    {
        switch(indexPath.row) {
            case 0: // Local
            {
                if ([globalType isEqualToString:@"local"]
                    && [locationText isEqualToString:@"Location"]) {
                    [self getLocality];
                }
            }
                break;
            case 1: // Global
            {
                if ([globalType isEqualToString:@"local"]) {
                    globalType = @"global";
                } else {
                    globalType = @"local";
                    if ([locationText isEqualToString:@"Location"] && !waitLocation) {
                        [self getLocality];
                    }
                }
            }
                break;
        }
        [createGroupTable reloadData];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%i",indexPath.section);
    if (indexPath.section==2)
        
    {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    }
}


-(void)viewPublicInfo:(id)sender
{
    NSLog(@"view info");
    UIAlertView *publicInfoAlert = [[UIAlertView alloc] initWithTitle:@""
                                                              message:@"Choose this option, if you want conversations to be public and for members to join and leave at their free will."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
    
    [publicInfoAlert show];
}
-(void)viewPrivateInfo:(id)sender
{
    UIAlertView *privateInfoAlert = [[UIAlertView alloc] initWithTitle:@""
                                                               message:@"As an admin you can control who joins the group. Conversations will only be visible to group members."
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles: nil];
    
    [privateInfoAlert show];
    
}
-(void)viewLocalInfo:(id)sender
{
    UIAlertView *localInfoAlert = [[UIAlertView alloc] initWithTitle:@""
                                                             message:@"Will only be visible to other users in your city. More apt for local topics."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles: nil];
    
    [localInfoAlert show];
    
}
-(void)viewGlobalInfo:(id)sender
{
    UIAlertView *globalInfoAlert = [[UIAlertView alloc] initWithTitle:@""
                                                              message:@"Will be visible to all users and anyone from around the world can join."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
    
    [globalInfoAlert show];
    
}

-(void)createGroup{
    
    [self uniquenessCheckForGroupName];
    
}

-(void)doneGroupRequest{
    
    if(status==0){
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.delegate = self;
        HUD.dimBackground = YES;
        HUD.labelText = @"Please Wait";
        
        groupName = groupNameTextView.text;
        groupDesc = groupDescTextView.text;
        if ([[groupName stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] || [groupName isEqualToString:@"Group Name"]) {
            [HUD hide:YES];
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter group name."   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [warningAlert show];
        } else if ([[groupDesc stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] || [groupDesc isEqualToString:@"Description"]) {
            [HUD hide:YES];
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter group description."   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [warningAlert show];
        }else if ([groupType isEqualToString:@""]) {
            [HUD hide:YES];
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please select group type."   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [warningAlert show];
        }else if ([globalType isEqualToString:@"local"] && [locationText isEqualToString:@"Location"]) {
            [HUD hide:YES];
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please select group location."   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [warningAlert show];
        }else{
            if ([groupCategory isEqualToString:@"Category"]){
                categoryID=@"0";
                groupCategory=@"General/Life";
            }
            appUserId = [[DatabaseManager getSharedInstance]getAppUserID];
            appUserLocationId = [[DatabaseManager getSharedInstance]getAppUserLocationId];
            imageData = UIImageJPEGRepresentation(groupPic.image, 0.9);
            NSLog(@"You have clicked submit%@%@%@%@%@%@%@%@",groupType,groupName,groupDesc,globalType,groupCategory,categoryID,appUserId,appUserLocationId);
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/add_group_gps.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            NSMutableData *body = [NSMutableData data];
            NSString *boundary = @"---------------------------14737809831466499882746641449";
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
            [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
            if (!defaultImage){
                
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Disposition: form-data; name=\"group_pic\"; filename=\"a.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                //                if ([groupPic.image isEqual:[UIImage imageNamed:@"defaultGroup.png"]]){
                //                 imageData=NULL;
                //                 }
                [body appendData:[NSData dataWithData:imageData]];
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                
            }
            
            //  parameter groupType
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"group_type\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            if ([groupType isEqualToString:@"private"]) {
                NSString *type =@"1";
                [body appendData:[type dataUsingEncoding:NSUTF8StringEncoding]];
            }else if([groupType isEqualToString:@"public"]){
                NSString *type =@"2";
                [body appendData:[type dataUsingEncoding:NSUTF8StringEncoding]];
            }
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            //  parameter location id
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"location_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[appUserLocationId dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            //  parameter groupName
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"group_name\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[groupName dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            // parameter groupDescription
            
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"group_description\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[groupDesc dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            //parameter categoryId
            NSLog(@"%@",categoryID);
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"category_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[categoryID dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            //parameter globalType
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"global_type\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            if ([globalType isEqualToString:@"local"]) {
                NSString *global =@"0";
                [body appendData:[global dataUsingEncoding:NSUTF8StringEncoding]];
            }else if([globalType isEqualToString:@"global"]){
                NSString *global =@"1";
                [body appendData:[global dataUsingEncoding:NSUTF8StringEncoding]];
            }
            //[body appendData:[globalType dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            if ([globalType isEqualToString:@"local"]) {
                //parameter latitude
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"latitude\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"%f", latitude] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                //parameter longitude
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"longitude\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"%f", longitude] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                //parameter locality
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"locality\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[locality dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                //parameter country
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"country\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[country dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }

            //parameter createdBy
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"created_by\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[appUserId dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            // close form
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            // setting the body of the post to the reqeust
            [request setHTTPBody:body];
            createGroupConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [createGroupConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [createGroupConn start];
            createGroupResponse = [[NSMutableData alloc] init];
            //creating group to
            
            
            //            [HUD hide:YES];
        }
    }else{
        if ([self appDelegate].hasInet){
            UIAlertView *userName=[[UIAlertView alloc]initWithTitle:Nil message:@"Please Enter Unique Group Name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [userName show];
            
        }else{
            UIAlertView *userName=[[UIAlertView alloc]initWithTitle:Nil message:@"Internet connection is not avialaible" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [userName show];
        }
        
    }

}

/*- (void)loadCategories
 {
 NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
 NSString *url=[NSString stringWithFormat:@"http://gupapp.com/Gup_demo/scripts/fetch_all_cat.php"];
 NSLog(@"Url final=%@",url);
 [request setURL:[NSURL URLWithString:url]];
 [request setHTTPMethod:@"GET"];
 
 fetchCategoryConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
 [fetchCategoryConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
 [fetchCategoryConn start];
 fetchCategoryResponse = [[NSMutableData alloc] init];
 
 
 }*/



//NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == createGroupConn) {
        
        [createGroupResponse setLength:0];
        
    }
    /*if (connection == fetchCategoryConn) {
     
     [fetchCategoryResponse setLength:0];
     
     }*/
    if (connection == uniquenessCheckConn) {
        
        [eventsResponse setLength:0];
        
    }
    
    
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"did recieve data");
    
    if (connection == createGroupConn) {
        
        [createGroupResponse appendData:data];
        
    }
    /*if (connection == fetchCategoryConn) {
     
     [fetchCategoryResponse appendData:data];
     
     }*/
    if (connection == uniquenessCheckConn) {
        
        [eventsResponse appendData:data];
        
    }
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    if (connection == uniquenessCheckConn) {
        [activityIndicator stopAnimating];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];

        groupNameTextView.editable = YES;
        [nameChecked stopAnimating];
        nameChecked.hidden = YES;
    }
    else
    {
        [HUD hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    if (connection == uniquenessCheckConn) {
        
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:eventsResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *responce= res[@"response"];
        status= [responce[@"status"] integerValue];

        groupNameTextView.editable = YES;
        [activityIndicator stopAnimating];
        activityIndicator.hidden = YES;
        nameChecked.hidden = NO;
        if (status==0) {
            nameChecked.image=[UIImage imageNamed:@"tick" ];
            [self doneGroupRequest];
        }
        else {
            nameChecked.image=[UIImage imageNamed:@"cancel"];
        }
        uniquenessCheckConn=nil;
        [uniquenessCheckConn cancel];
    }
    
    if (connection == createGroupConn) {
        
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:createGroupResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *results = res[@"response"];
        NSLog(@"====EVENTS==3 %@",res);
        
        NSString *status1 = results[@"status"];
        
        group_id = [results[@"group_id"] stringValue];
        NSString *error = results[@"error"];
        NSString *group_pic_name = results[@"image_name"];
        NSString *created_date = results[@"created_date"];
        
        NSLog(@"response:status:%@,group_id:%@,error:%@",status1,group_id,error);
        
        if ([status1 isEqualToString:@"1"]){
            
            [HUD hide:YES];
            UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"" message:error  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [failureAlert show];
        }else{
            appUserLocation = [[DatabaseManager getSharedInstance]getAppUserLocationName];
            appUserName = [[DatabaseManager getSharedInstance]getAppUserName];
            appUserImage = [[DatabaseManager getSharedInstance]getAppUserImage];
            
            //create group on openfire: Aprajita
            roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"group_%@@%@",group_id,groupJabberUrl]];
            
            XMPPRoomMemoryStorage *roomMemoryStorage = [[XMPPRoomMemoryStorage alloc] init];
            xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomMemoryStorage
                                                         jid:roomJID
                                               dispatchQueue:dispatch_get_main_queue()];
            
            [xmppRoom activate:[self appDelegate].xmppStream];
            [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
            [xmppRoom joinRoomUsingNickname:[NSString stringWithFormat:@"%@",[[[self appDelegate].myjid componentsSeparatedByString:@"@"] firstObject]] history:nil];
            
            // end of update
            NSString* query;
            if ([globalType isEqualToString:@"global"]) {
                query=[NSString stringWithFormat:@"insert into groups_public (group_server_id, location_name, category_name, added_date, group_name,group_type, group_pic,group_description,total_members,admin_id) values ('%@','%@','%@','%@','%@','%@','%@','%@','%d','%@')",group_id,appUserLocation,groupCategory,created_date,[groupName normalizeDatabaseElement],[NSString stringWithFormat:@"%@#%@",groupType,globalType],group_pic_name,[groupDesc normalizeDatabaseElement],1,[self appDelegate].myUserID];
            } else {
                if ([groupType isEqualToString:@"private"]) {
                    query=[NSString stringWithFormat:@"insert into groups_private (group_server_id, created_on, created_by, group_name, group_pic,category_id, category_name,location_name,group_type,total_members,group_description,admin_id,latitude,longitude,locality,country) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%d','%@','%@','%f','%f','%@','%@')",group_id,created_date, [appUserName normalizeDatabaseElement],[groupName normalizeDatabaseElement],group_pic_name,categoryID,groupCategory,appUserLocation,[NSString stringWithFormat:@"%@#%@",groupType,globalType],1,[groupDesc normalizeDatabaseElement],[self appDelegate].myUserID,latitude, longitude, locality, country];
                } else {
                    query=[NSString stringWithFormat:@"insert into groups_public (group_server_id, location_name, category_name, added_date, group_name,group_type, group_pic,group_description,total_members,admin_id,latitude,longitude,locality,country) values ('%@','%@','%@','%@','%@','%@','%@','%@','%d','%@','%f','%f','%@','%@')",group_id,appUserLocation,groupCategory,created_date,[groupName normalizeDatabaseElement],[NSString stringWithFormat:@"%@#%@",groupType,globalType],group_pic_name,[groupDesc normalizeDatabaseElement],1,[self appDelegate].myUserID, latitude, longitude, locality, country];
                }
            }
            
            NSLog(@"query %@",query);
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            
            // save group image to cache
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            //NSLog(@"paths=%@",paths);
            NSString *groupPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",group_pic_name]];
            //NSLog(@"group pic path=%@",groupPicPath);
            //imageData=UIImageJPEGRepresentation(groupPic.image, 1);
            //Writing the image file
            [imageData writeToFile:groupPicPath atomically:YES];
            //            [HUD hide:YES];
            [[self appDelegate]._chatDelegate buddyStatusUpdated];
            
            // Open contact list
            
            
        }
    }
    /*if (connection == fetchCategoryConn) {
     
     NSLog(@"====EVENTS");
     
     NSString *response = [[NSMutableString alloc] initWithData:fetchCategoryResponse encoding:NSASCIIStringEncoding];
     
     NSLog(@"categoryResponse:%@",response);
     if (response) {
     NSString *query=[NSString stringWithFormat:@"delete from group_category"];
     NSLog(@"query %@",query);
     [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
     }
     SBJSON *jsonparser=[[SBJSON alloc]init];
     NSDictionary *res= [jsonparser objectWithString:response];
     NSDictionary *results = res[@"category_list"];
     NSArray *categories = results[@"list"];
     NSLog(@"====EVENTS==3 %@",res);
     for (NSDictionary *result in categories)
     {
     NSString *categoryId = result[@"category_id"];
     NSString *categoryName = result[@"category_name"];
     NSLog(@"category id = %@ \n\n category name =  %@",categoryId,categoryName);
     NSString *query=[NSString stringWithFormat:@"insert into group_category (category_id, category_name) values ('%@','%@')",categoryId,categoryName];
     NSLog(@"query %@",query);
     [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
     }
     }*/
}


-(NSXMLElement *)setConfig{
    
    NSXMLElement *x = [[NSXMLElement alloc] initWithName:@"x" xmlns:@"jabber:x:data"];
    NSXMLElement *field = [[NSXMLElement alloc] initWithName:@"field"];
    [field addAttributeWithName:@"var" stringValue:@"FORM_TYPE"];
    NSXMLElement *value = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"http://jabber.org/protocol/muc#roomconfig"];
    [field addChild:value];
    
    NSXMLElement *field1 = [[NSXMLElement alloc] initWithName:@"field"];
    [field1 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomname"];
    NSXMLElement *value1 = [[NSXMLElement alloc] initWithName:@"value" stringValue:groupName];
    [field1 addChild:value1];
    
    NSXMLElement *field2 = [[NSXMLElement alloc] initWithName:@"field"];
    [field2 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_membersonly"];
    NSXMLElement *value2 = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"0"];
    [field2 addChild:value2];
    
    NSXMLElement *field3 = [[NSXMLElement alloc] initWithName:@"field"];
    [field3 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"];
    NSXMLElement *value3 = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"1"];
    [field3 addChild:value3];
    
    //    NSXMLElement *field3 = [[NSXMLElement alloc] initWithName:@"field"];
    //    [field3 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"];
    //    NSXMLElement *value3 = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"1"];
    //    [field3 addChild:value3];
    
    
    NSXMLElement *fieldz = [[NSXMLElement alloc] initWithName:@"field"];
    [fieldz addAttributeWithName:@"var" stringValue:@"muc#roomconfig_whois"];
    NSXMLElement *valuez = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"anyone"];
    [fieldz addChild:valuez];
    
    NSXMLElement *field4 = [[NSXMLElement alloc] initWithName:@"field"];
    [field4 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_publicroom"];
    
    NSXMLElement *value4;
    if([groupType isEqualToString:@"private"])
        value4 = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"0"];
    else
        value4 = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"1"];
    [field4 addChild:value4];
    
    NSXMLElement *field5 = [[NSXMLElement alloc] initWithName:@"field"];
    [field5 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomadmins"];
    NSXMLElement *value5 = [[NSXMLElement alloc] initWithName:@"value" stringValue:[self appDelegate].myjid];
    [field5 addChild:value5];
    
    NSXMLElement *field6 = [[NSXMLElement alloc] initWithName:@"field"];
    [field6 addAttributeWithName:@"label" stringValue:@"Short Description of Room"];
    [field6 addAttributeWithName:@"type" stringValue:@"text-single"];
    [field6 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomdesc"];
    NSXMLElement *value6 = [[NSXMLElement alloc] initWithName:@"value" stringValue:groupDesc];
    [field6 addChild:value6];
    
    NSXMLElement *field7 = [[NSXMLElement alloc] initWithName:@"field"];
    [field7 addAttributeWithName:@"label" stringValue:@"Allow Occupants to change nicknames"];
    [field7 addAttributeWithName:@"var" stringValue:@"x-muc#roomconfig_canchangenick"];
    NSXMLElement *value7 = [[NSXMLElement alloc] initWithName:@"value" stringValue:val];
    [field7 addChild:value7];
    
    [x addChild:field];
    [x addChild:field1];
    [x addChild:field2];
    [x addChild:field3];
    //    [x addChild:field4];
    //    [x addChild:fieldz];
    //    [x addChild:field5];
    [x addChild:field6];
    [x addChild:field7];
    return x;
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm{
    
    NSArray *fields = [configForm elementsForName:@"field"];
    for (NSXMLElement *field in fields) {
        if([[[field attributeForName:@"label"] stringValue] isEqualToString:@"Allow Occupants to change nicknames"]){
            NSString *value = [[field elementForName:@"value"] stringValue];
            if ([value intValue] == 1)
                val = @"0";
            else
                val = @"1";
            break;
        }
        
    }
    [sender configureRoomUsingOptions:[self setConfig] from:[self appDelegate].myjid];
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult{
    NSLog(@"configer success");
    [HUD hide:YES];
    [sender joinRoomUsingNickname:[[[self appDelegate].myjid componentsSeparatedByString:@"@"] firstObject] history:nil];
    ContactList *openContactList = [[ContactList alloc]init];
    openContactList.groupStatus = [NSString stringWithFormat:@"%@#%@",groupType,globalType];
    openContactList.groupId = group_id;
    openContactList.groupJID = [NSString stringWithFormat:@"%@",roomJID];
    openContactList.xmppRoom =xmppRoom;
    openContactList.groupName = groupName;
    
    [self.navigationController pushViewController:openContactList animated:NO];
    
}
- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult{
    NSLog(@"configer success fail");
}

- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    NSLog(@"xmppRoomDidCreate - group %@",sender);
    [xmppRoom fetchConfigurationForm];
    
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    NSLog(@"xmppRoomDidJoin - group %@",sender);
}

//action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    iPicker = [[UIImagePickerController alloc] init];
    [iPicker setDelegate:self];
    iPicker.allowsEditing = YES;
    //Get the name of the current pressed button
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSLog(@"button title:%i,%@",buttonIndex ,buttonTitle);
    if ([buttonTitle isEqualToString:@"Camera Shot"]) {
        NSLog(@"Other 1 pressed");{
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                //[self.tabBarController.tabBar setHidden:YES];
                //[[UIApplication sharedApplication] setStatusBarHidden:YES];
                iPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:iPicker animated:YES completion:NULL];
                
            }else{
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@""
                                                                      message:@"Device has no camera"
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil];
                [myAlertView show];
                
            }
            
        }
        
    }
    
    if ([buttonTitle isEqualToString:@"Gallery"]) {
        
        NSLog(@"Other 2 pressed");
        iPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [iPicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        [self presentViewController:iPicker animated:YES completion:NULL];
    }
    if ([buttonTitle isEqualToString:@"Remove Photo"]) {
        NSLog(@"Other 3 pressed");
        groupPic.image=Nil;
        defaultImage =YES;
        [groupPic setImage:[UIImage imageNamed:@"defaultGroup.png"]];
    }
    
    if ([buttonTitle isEqualToString:@"Cancel"]) {
        
        NSLog(@"Cancel pressed --> Cancel ActionSheet");
        
    }
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    groupPic.image = chosenImage;
    //imageData=UIImageJPEGRepresentation(chosenImage, 1);
    [iPicker dismissViewControllerAnimated:YES completion:NULL];
    defaultImage = false;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    NSLog(@"imagePickerDidCancel");
    [iPicker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma - mark UITextViewDelegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    if (textView == groupNameTextView) {
        if ([groupNameTextView.text isEqualToString:@"Group Name"]) {
            groupNameTextView.text = @"";
            groupNameTextView.textColor=[UIColor colorWithRed:27.0/255.0 green:168.0/255.0 blue:168.0/255.0 alpha:1.0];
        }
        activityIndicator.hidden = YES;
        nameChecked.hidden = YES;
    } else if (textView == groupDescTextView && [groupDescTextView.text isEqualToString:@"Description"]) {
        groupDescTextView.text = @"";
        groupDescTextView.textColor = [UIColor blackColor];
    }
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    NSString* after = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (textView == groupNameTextView && after.length > 50) {
        return NO;
    } else if (textView == groupDescTextView && after.length > 1000) {
        return NO;
    }
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (textView == groupNameTextView && [groupNameTextView.text isEqualToString:@""]) {
        groupNameTextView.text = @"Group Name";
        groupNameTextView.textColor = [UIColor lightGrayColor];
    } else if (textView == groupDescTextView && [groupDescTextView.text isEqualToString:@""]) {
        groupDescTextView.text = @"Description";
        groupDescTextView.textColor = [UIColor lightGrayColor];
    }
    [textView resignFirstResponder];
    return YES;
}


-(void)uniquenessCheckForGroupName
{
    [groupNameTextView resignFirstResponder];
    [groupDescTextView resignFirstResponder];
    
    if ([[groupDescTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@"GroupName"]
        || [[groupNameTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter group name"   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } else if ([[groupDescTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@"Description"]
        || [[groupDescTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])
    {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter group description."   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [warningAlert show];
    }
    else
    {
        groupNameTextView.editable = NO;

        nameChecked.hidden = YES;
        activityIndicator.hidden = NO;
        [activityIndicator startAnimating];
        
        NSString *group_name=[NSString stringWithFormat:@"%@",groupNameTextView.text];
        NSString *postData = [NSString stringWithFormat:@"group_name=%@",group_name];
        NSLog(@"$[%@]",postData);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/check_group_name.php",gupappUrl]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        uniquenessCheckConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [uniquenessCheckConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [uniquenessCheckConn start];
        eventsResponse = [[NSMutableData alloc] init];
        
    }
    
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)updateCategory:(NSString*)newCategory categoryId:(NSString*)catId
{
    categoryID=catId;
    NSLog(@"category ID %@",categoryID);
    groupCategory = newCategory;
    NSIndexPath *cellindex=[NSIndexPath indexPathForRow:2 inSection:0];
    UITableViewCell *tempcell=[createGroupTable cellForRowAtIndexPath:cellindex];
    
    [tempcell.textLabel setText:newCategory];
    
    NSLog(@"group cate in update category:%@",groupCategory);
    
}

-(void)getLocality
{
    waitLocation = YES;
    [[self appDelegate] setLocalityDelegate:self];
    [[self appDelegate] getLocality:@"We need to access your current location in order for you to create a Local group. Please allow access to your location using the Settings option or select Cancel to continue with a Global group."];
}

-(void)completeFetch {
    if (waitLocation) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Fetch Location request timed out. Please check internet connection."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - LocalityDelegate
- (void) didGetLocality:(NSDictionary *)localityDict {

    waitLocation = NO;
    [loadingLocation stopAnimating];

    NSLog(@"didGetLocality: %@", [localityDict debugDescription]);
    latitude = [[localityDict objectForKey:@"latitude"] doubleValue];
    longitude = [[localityDict objectForKey:@"longitude"] doubleValue];
    locality = [localityDict objectForKey:@"locality"];
    country = [localityDict objectForKey:@"country"];

    locationText = [NSString stringWithFormat:@"%@, %@", locality, country];
    [locationLabel setText:locationText];
}

- (void) didCancelLocality {
    waitLocation = NO;
    [loadingLocation stopAnimating];

    globalType = @"global";
    groupType = @"public";
    [createGroupTable reloadData];
}

@end

