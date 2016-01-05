//
//  SecondViewController.m
//  GUPver 1.0
//
//  Created by genora on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "PostListing.h"
#import "SecondViewController.h"
#import "viewPrivateGroup.h"
#import "CategoryList.h"
#import "GroupInfo.h"
#import "JSON.h"
#import "GroupTableCell.h"
#import "DatabaseManager.h"
#import "ChatScreen.h"
#import "AppDelegate.h"
#import "ViewContactProfile.h"
#import "FirstViewController.h"
#import "GroupViewController.h"

@interface SecondViewController ()


@end

@implementation SecondViewController
@synthesize categoryId, chatTitle, latitude, longitude;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"Search", @"Search");
        //self.navigationItem.title = @"Category Name";
    }
    return self;
}

- (void)viewDidLoad{
    expndRow =-1;
    selectedGroup =[[NSMutableArray alloc] init];
    groupData = [[NSMutableArray alloc]init];
    filteredData = [[NSMutableArray alloc]init];
    
    userId =[[DatabaseManager getSharedInstance]getAppUserID];
    NoOfRows=0;
    filterCriteria=0;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    sortByOptions = [NSArray arrayWithObjects:@"Popularity", @"Alphabetical", nil];
   
    UITextField *txfSearchField = [search valueForKey:@"_searchField"];
    txfSearchField.layer.cornerRadius =10.0;
    txfSearchField.layer.borderWidth =1.0f;
    txfSearchField.layer.borderColor =  [[UIColor colorWithRed:138/255.0 green:155/255.0 blue:160/255.0 alpha:1] CGColor];
    
    txfSearchField.font = [UIFont fontWithName:@"Dosis-Regular" size:17.0f];
    
    joinButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 60.0f, 30.0f)];
    [joinButton setTitle:@"Join" forState:UIControlStateNormal];
    [joinButton addTarget:self action:@selector(joinAllGroup) forControlEvents:UIControlEventTouchUpInside];
    [joinButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:207.0/255.0 blue:13.0/255.0 alpha:1] forState:UIControlStateNormal];
    joinButton.titleLabel.font = [UIFont fontWithName:@"Dosis-Bold" size:20];
    
    privateFilter=1;
    publicFilter=1;
    
    [self initialiseView];
    //ios 7
    for(UIView *subView in [search subviews]) {
        if([subView conformsToProtocol:@protocol(UITextInputTraits)]) {
            [(UITextField *)subView setReturnKeyType: UIReturnKeyDone];
        } else {
            for(UIView *subSubView in [subView subviews]) {
                if([subSubView conformsToProtocol:@protocol(UITextInputTraits)]) {
                    [(UITextField *)subSubView setReturnKeyType: UIReturnKeyDone];
                }
            }
        }
        
    }
    [self setActivityIndicator];
    [self listGroupsAssociatedToCategory];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    CGSize  textSize = {self.navigationController.navigationBar.frame.size.width-170, 30 };
    CGSize size = [chatTitle sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0f]                  constrainedToSize:textSize                      lineBreakMode:NSLineBreakByWordWrapping];
    contactNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(15,5,size.width,30)];
    [contactNameLabel setBackgroundColor:[UIColor clearColor]];
    [contactNameLabel setTextColor:[UIColor blackColor]];
    contactNameLabel.textAlignment =NSTextAlignmentCenter;
    // contactNameLabel.layer.borderWidth=2;
    contactNameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17.f];
    
    
    [self.navigationController.navigationBar addSubview:contactNameLabel];
    [contactNameLabel setCenter:CGPointMake(self.navigationController.navigationBar.frame.size.width/2,self.navigationController.navigationBar.frame.size.height/2)];
    // [self.navigationController.navigationBar addSubview:navigationTitleView];
    self.navigationItem.title = chatTitle;
    self.navigationItem.titleView.hidden=YES;
    
}

-(void)viewWillDisappear:(BOOL)animated
{[contactNameLabel removeFromSuperview];
    listGroupsConn=Nil;
    [listGroupsConn cancel];
}


-(void)initialiseView
{
//    [sortByLabel setHidden:YES];
//    CGRect rect = searchTable.frame;
//    rect.origin.y -= 25;
//    rect.size.height += 25;
//    [searchTable setFrame:rect];
//    [searchTable setNeedsLayout];
    
//    } else {
//        click = [UIButton buttonWithType:UIButtonTypeCustom];
//        //  [click setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
//        [click addTarget:self
//                  action:@selector(setSearchFilter:)
//        forControlEvents:UIControlEventTouchDown];
//        [click setImage:[UIImage imageNamed:@"dropdown"] forState:UIControlStateNormal];
//        CGSize deviceSize=[UIScreen mainScreen].bounds.size;
//        click.frame = CGRectMake(deviceSize.width-35, 48.0, 30.0, 30.0);
//        [self.view addSubview:click];
//    }
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
}


-(void)addGroup
{
    //self.navigationItem.leftBarButtonItem.title = @"Online";
}


-(void)setSearchFilter:(id)sender
{
    NoOfRows=2;
    [searchTable reloadData];
    click.hidden=true;
}

-(void)doneStatus:(id)sender{
    
    
    [pop dismissPopoverAnimated:YES];
}





#pragma mark Table View Data Source Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView== filterTable.tableView)
        return 1;
    else
        return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==1) {
        return [filteredData count];
    }
    else{
        if (tableView== filterTable.tableView)
            return 2;
        else
            return NoOfRows;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        
        static NSString *groupTableIdentifier = @"GroupTableItem";
        newGroupCell *cell= (newGroupCell *)[tableView dequeueReusableCellWithIdentifier:groupTableIdentifier];
        
        if (cell == nil) {
            cell = [[newGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:groupTableIdentifier];
        }
        cell.cellDelegate = self;
        CGRect rect = cell.frame;
        rect.size.width = tableView.frame.size.width;
        [cell setFrame: rect];
        [cell drawCell:[filteredData objectAtIndex:indexPath.row] withIndex:indexPath.row];
        return cell;
    }
    else
    {
        if (tableView== filterTable.tableView)
        {
            static NSString *Identifier2 = @"CellType2";
            // cell type 2
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier2];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier2];
            }
            filterOptionsList= [[NSMutableArray alloc]initWithObjects:@"Private Groups",@"Public Groups", nil];
            cell.backgroundColor=[UIColor clearColor];
            cell.textLabel.text = [filterOptionsList objectAtIndex:indexPath.row];
            //cell.backgroundColor=[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            // set cell properties
            if (privateFilter==1) {
                if (indexPath.row==0) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                
            }
            if (publicFilter==1) {
                if (indexPath.row==1) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            
            
            return cell;
            
        }
        
        else
            
        {
            static NSString *CellIdentifier = @"Cell Identifier";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            cell.imageView.image=nil;
            cell.detailTextLabel.text=@"";
            cell.textLabel.text = [sortByOptions objectAtIndex:indexPath.row];
            if (indexPath.row==filterCriteria)
            {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                [cell.textLabel setTextColor:[UIColor blackColor]];
            }
            else
            {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell.textLabel setTextColor:[UIColor lightGrayColor]];
            }
            
            return cell;
            
        }
    }
    
    //return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == searchTable){
//        if(expndRow == indexPath.row){
//            return 60+[[[groupData objectAtIndex:indexPath.row] objectForKey:@"height"] floatValue];
//        }
        CGFloat addHeight = ([[self appDelegate] increaseFont] == 0)? 0: 10;
        if (indexPath.row < filteredData.count) {
            if ([[[filteredData objectAtIndex:indexPath.row] objectForKey:@"height"] floatValue] > 20) {
                return [[[filteredData objectAtIndex:indexPath.row] objectForKey:@"height"] floatValue] + 57 + addHeight;
            } else {
                return 70 + addHeight;
            }
        } else {
            return 70 + addHeight;
        }
    }else{
        
        if(indexPath.section==1)
            return 44;
        else
            return 40;
    }
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
//    if(filterTable.tableView==tableView)
//        if([[[self appDelegate].ver objectAtIndex:0] intValue] < 7)
//            return 44;
//        else
//            return 1.0;
//        else
            return 1.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==1)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setSelected:NO];
    }else{
        if (tableView == filterTable.tableView) {
            
            NSLog(@"u have clicked on the table");
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (indexPath.row==0) {
                
                if (cell.accessoryType== UITableViewCellAccessoryCheckmark)
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    privateFilter=0;
                    
                }
                else
                {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    privateFilter=1;
                    
                    
                }
            }
            else if(indexPath.row==1){
                if (cell.accessoryType== UITableViewCellAccessoryCheckmark)
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    publicFilter=0;
                }
                else
                {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    publicFilter=1;
                    
                    
                }
                
            }
            NSLog(@"printout private filter and public filter value %d, %d",privateFilter,publicFilter);
            
            
        }else{
            NoOfRows=0;
            if (indexPath.row==0){
                filterCriteria=0;
                temporatyString=@"popular";
            }else{
                temporatyString=@"alphabetical";
                filterCriteria=1;
            }
            [self sortBy:temporatyString];
            [searchTable reloadData];
            
            click.hidden=false;
        }
        
    }
}

-(void)sortBy:(NSString*)factor
{
//    NSSortDescriptor *sortBy;
//    if ([factor isEqualToString:@"alphabetical"]) {
//        sortBy = [NSSortDescriptor sortDescriptorWithKey:@"group_name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
//    }
//    else if([factor isEqualToString:@"popular"]){
//        //sortBy = [NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:NO ];
//        sortBy = [NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:NO comparator:^(id obj1, id obj2){
//            return [obj1 intValue] - [obj2 intValue];
//        }];
//        
//    }
//    
//    [filteredData sortUsingDescriptors:[NSMutableArray arrayWithObject:sortBy]];
//    
//    NSLog(@"groups array after sort: %@",filteredData);
}


-(void)setActivityIndicator
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Loading Groups";
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{  // check whether the user is the admin of the group.
    NSString *appUserId =[[DatabaseManager getSharedInstance]getAppUserID];
    
    int is_admin=[[DatabaseManager getSharedInstance]isAdminOrNot:[[filteredData objectAtIndex:indexPath.row] objectForKey:@"group_id"] contactId:appUserId];
    NSLog(@"is_admin%i",is_admin);
    if (is_admin == 1) {
        viewPrivateGroup *viewGroupAsAdmin = [[viewPrivateGroup alloc]init];
        viewGroupAsAdmin.title = [[filteredData objectAtIndex:indexPath.row] objectForKey:@"group_name"];
        viewGroupAsAdmin.groupId = [[filteredData objectAtIndex:indexPath.row] objectForKey:@"group_id"];
        viewGroupAsAdmin.groupType =[[filteredData objectAtIndex:indexPath.row] objectForKey:@"type"];
        viewGroupAsAdmin.viewType = @"Explore";
        [self.navigationController pushViewController:viewGroupAsAdmin animated:NO];
    }
    else
    {
        
        GroupInfo *viewGroupPage = [[GroupInfo alloc]init];
        viewGroupPage.title = [[filteredData objectAtIndex:indexPath.row] objectForKey:@"group_name"];
        viewGroupPage.groupId = [[filteredData objectAtIndex:indexPath.row] objectForKey:@"group_id"];
        viewGroupPage.groupType =[[filteredData objectAtIndex:indexPath.row] objectForKey:@"type"];
        viewGroupPage.viewType = @"Explore";
        [self.navigationController pushViewController:viewGroupPage animated:YES];
        
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==sortByTable)
    {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    }
    /*if (tableView==filterTable) {
     [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
     }*/
}
// search bar delegates


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchbartextdidbeginediting");
    searchBar.showsCancelButton=TRUE;
    /*for (UIView *subview in searchBar.subviews)
     
     {
     
     for (UIView *subSubview in subview.subviews)
     
     {
     
     if ([subSubview conformsToProtocol:@protocol(UITextInputTraits)])
     
     {
     
     UITextField *textField = (UITextField *)subSubview;
     textField.delegate=self;
     textField.returnKeyType = UIReturnKeyDefault;
     
     break;
     
     }
     
     }
     
     }*/
    
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [search setShowsCancelButton:NO animated:NO];
    //[search endEditing:YES];
    return YES;
}

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"User searched for %@", searchText);
    NSString* search = [searchText uppercaseString];
    [filteredData removeAllObjects];
    if([searchBar.text length]==0)
    {
        isFiltered = FALSE;
        [filteredData addObjectsFromArray:groupData];
    }
    else
    {
        isFiltered = TRUE;
        
        for (int i = 0; i < groupData.count; i++) {
            NSString* name = [[groupData objectAtIndex:i] objectForKey:@"group_name"];
            name = [name uppercaseString];
            if ([name containsString:search]) {
                [filteredData addObject:[groupData objectAtIndex:i]];
            }
        }
    }
    
    [searchTable reloadData];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    NSLog(@"User canceled search");
    searchBar.showsCancelButton=FALSE;
    [searchBar resignFirstResponder]; // if you want the keyboard to go away
    searchBar.text = @"";
    isFiltered = FALSE;
    [filteredData removeAllObjects];
    [filteredData addObjectsFromArray:groupData];
    [searchTable reloadData];
    
}

-(IBAction)openCategoryList:(id)sender
{
    CategoryList *browseCategory = [[CategoryList alloc]init];
    [self.navigationController pushViewController:browseCategory animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)listGroupsAssociatedToCategory
{
    
    NSString *postData;
    NSLog(@"$[%@]",postData);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //NSString *postData = [NSString stringWithFormat:@"username=%@",userName];
    //NSLog(@"$[username=%@]",postData);
    if ([categoryId isEqualToString:@"1"]) {
        postData = [NSString stringWithFormat:@"category_id=%@&user_id=%@&latitude=%f&longitude=%f",categoryId, userId, latitude, longitude];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/fetch_cat_groups_rec_gps.php",gupappUrl]]];
    }
    else if([categoryId isEqualToString:@"1000"]) {
        postData = [NSString stringWithFormat:@"user_id=%@&latitude=%f&longitude=%f", userId, latitude, longitude];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/near_me_groups.php",gupappUrl]]];
    }
    else if([categoryId isEqualToString:@"1001"]) {
        postData = [NSString stringWithFormat:@"user_id=%@&latitude=%f&longitude=%f", userId, latitude, longitude];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/new_groups_gps.php",gupappUrl]]];
    }
    else{
        postData = [NSString stringWithFormat:@"category_id=%@&user_id=%@&latitude=%f&longitude=%f",categoryId, userId, latitude, longitude];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/fetch_cat_groups_gps.php",gupappUrl]]];
    }
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    listGroupsConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [listGroupsConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [listGroupsConn start];
    listGroupsResponse = [[NSMutableData alloc] init];
}

//NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (connection == listGroupsConn) {
        
        [listGroupsResponse setLength:0];
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
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"did recieve data");
    
    if (connection == listGroupsConn) {
        [listGroupsResponse appendData:data];
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
    
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [HUD hide:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    
    if (connection == listGroupsConn) {
        
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:listGroupsResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSDictionary *results = res[@"group_list"];
        NSLog(@"results: %@", results);
        groups=results[@"list"];
        NSLog(@"groups: %@", groups);
        
        if ([groups count]==0 )
        {
            [HUD hide:YES];
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                             message:[NSString stringWithFormat:@"There are no groups in %@",chatTitle]
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            alert.tag=11;
            [alert show];
        }
        else
        {
            NSLog(@"====EVENTS==3 %@",res);
            [selectedGroup removeAllObjects];
            [groupData removeAllObjects];
            
            for (NSDictionary *result in groups) {
                NSMutableDictionary *datav = [[NSMutableDictionary alloc]init];
                [datav addEntriesFromDictionary:result];
                CGSize size =[self calculateHeight:[datav objectForKey:@"description"]];
                [datav setObject:[NSString stringWithFormat:@"%f",size.height] forKey:@"height"];
                
                [datav setObject:@"0" forKey:@"is_exist"];
                
                if([[result objectForKey:@"type"] isEqualToString:@"public#local"]||[[result objectForKey:@"type"] isEqualToString:@"public#global"]){
                    
                    NSString *checkIfPublicGroupExists=[NSString stringWithFormat:@"select * from groups_public where group_server_id=%@",result[@"group_id"]];
                    BOOL publicGroupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfPublicGroupExists];
                    
                    if(!publicGroupExistOrNot){
                        
                        [datav setObject:@"0" forKey:@"is_exist"];
                    }else{
                        
                        [datav setObject:@"1" forKey:@"is_exist"];
                    }
                }else if ([result[@"type"] isEqual:@"private#local"]||[result[@"type"] isEqual:@"private#global"])
                {
                    
                    NSString *checkIfPrivateGroupExists=[NSString stringWithFormat:@"select * from groups_private where group_server_id=%@",result[@"group_id"]];
                    
                    BOOL privateGroupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfPrivateGroupExists];
                    
                    if (!privateGroupExistOrNot) {
                        
                        [datav setObject:@"0" forKey:@"is_exist"];
                        
                    }else{
                        
                        [datav setObject:@"1" forKey:@"is_exist"];
                    }
                    
                }
                
                [groupData addObject:datav];
            }
            
            expndRow =-1;
            
            [filteredData addObjectsFromArray:groupData];
            [self sortBy:@"popular"];
            [searchTable reloadData];
            [HUD hide:YES];
        }
        
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
            
        }
        else
        {
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
                [elementDic setValue:@"text" forKey:@"message_type"];
                [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID] forKey:@"from_user_id"];
                [elementDic setValue:@"1" forKey:@"show_notification"];
                [elementDic setValue:@"1" forKey:@"is_notify"];
                [elementDic setValue:@"1" forKey:@"isgroup"];
                [elementDic setValue:body forKey:@"body"];
                
                [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
                
                
            }
        }
        else
        {
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        [[self appDelegate]._chatDelegate buddyStatusUpdated];
        
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
        NSDictionary *group=results[@"Group_Details"];
        NSString *status=results[@"status"];
        NSLog(@"status: %@",status);
        NSLog(@"groups: %@", group);
        NSDictionary *members=group[@"member_details"];
        NSLog(@"members: %@",members);
        NSDictionary *deletedMembers = group[@"deleted_members"];
        NSLog(@"deleted members%@",deletedMembers);
        NSString *error=results[@"error"];
        
        //[imageView removeAllObjects];
        if (![status isEqualToString:@"1"])
        {
            
            NSString *checkIfPublicGroupExists=[NSString stringWithFormat:@"select * from groups_public where group_server_id=%@",group[@"id"]];
            BOOL publicGroupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfPublicGroupExists];
            if (publicGroupExistOrNot) {
                NSString *updatePublicGroup=[NSString stringWithFormat:@"update  groups_public set group_server_id = '%@', location_name = '%@', category_name = '%@', added_date ='%@',is_favourite ='1', group_name ='%@', group_type='%@', group_pic='%@', group_description='%@', total_members='%@' where group_server_id = '%@' ",group[@"id"],group[@"location_name"],group[@"category_name"],group[@"creation_date"],[group[@"group_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],group[@"group_type"],group[@"group_pic"],[group[@"group_description"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],group[@"member_count"],group[@"id"]];
                NSLog(@"query %@",updatePublicGroup);
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updatePublicGroup];
            }
            else
            {
                
                NSString *insertPublicGroup=[NSString stringWithFormat:@"insert into groups_public (group_server_id, location_name, category_name, added_date,is_favourite, group_name,group_type, group_pic,group_description,total_members) values ('%@','%@','%@','%@','%d','%@','%@','%@','%@','%@')",group[@"id"],group[@"location_name"],group[@"category_name"],group[@"creation_date"],1,[group[@"group_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],group[@"group_type"],group[@"group_pic"],[group[@"group_description"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],group[@"member_count"]];
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
                    NSString *checkIfMemberExists=[NSString stringWithFormat:@"select * from group_members where group_id=%@ and contact_id=%@ and deleted!=1",group[@"id"],member[@"user_id"]];
                    BOOL memberExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfMemberExists];
                    if (memberExistOrNot) {
                        NSString *updateMembers=[NSString stringWithFormat:@"update  group_members set group_id = '%@', contact_id = '%@', is_admin = '%@', contact_name ='%@', contact_location ='%@', contact_image='%@' where group_id = '%@' and contact_id='%@' ",group[@"id"],member[@"user_id"],member[@"is_admin"],[member[@"display_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],member[@"location_name"],member[@"profile_pic"],group[@"id"],member[@"user_id"]];
                        NSLog(@"query %@",updateMembers);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMembers];
                    }
                    else
                    {
                        
//                                                NSString *insertMembers=[NSString stringWithFormat:@"insert into group_members (group_id, contact_id, is_admin, contact_name, contact_location,contact_image) values ('%@','%@','%@','%@','%@','%@')",group[@"id"],member[@"user_id"],member[@"is_admin"],[member[@"display_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],member[@"location_name"],member[@"profile_pic"]];
                        //                        NSLog(@"query %@",insertMembers);
//                                                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertMembers];
                    }
                    //download image and save in the cache
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
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
                    NSString *checkIfMemberToDeleteExists=[NSString stringWithFormat:@"select * from group_members where group_id=%@ and contact_id=%@ and deleted!=1",group[@"id"],deletedMember];
                    BOOL memberToDeleteExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfMemberToDeleteExists];
                    if (memberToDeleteExistOrNot) {
                        // NSString *deleteMemberQuery=[NSString stringWithFormat:@"delete from group_members where group_id=%@ and contact_id=%@ ",group[@"id"],deletedMember];
                        // NSLog(@"query %@",deleteMemberQuery);
                        NSString *updateMemberQuery=[NSString stringWithFormat:@"update group_members set deleted=1 where group_id=%@ and contact_id=%@ ",group[@"id"],deletedMember];
                        NSLog(@"query %@",updateMemberQuery);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMemberQuery];
                    }
                    
                }
            }
            
            //download image and save in the cache
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,group[@"group_pic"]]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //cell.imageView.image = [UIImage imageWithData:imgData];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    NSLog(@"paths=%@",paths);
                    NSString *memberPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",group[@"group_pic"]]];
                    NSLog(@"member pic path=%@",memberPicPath);
                    //Writing the image file
                    [imgData writeToFile:memberPicPath atomically:YES];
                    
                    
                });
                
            });
            
            [HUD hide:YES];
            ChatScreen *chatScreen = [[ChatScreen alloc]init];
            NSArray *tempmembersID=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_id from group_members where group_id=%@ and deleted!=1",group[@"id"]]];
            NSMutableArray    *membersID=[[NSMutableArray alloc]init];
            for (int i=0; i<[tempmembersID count];i++)
            {//if(![[tempmembersID objectAtIndex:i]isEqual:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]])
                [membersID addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_ID"]] ;
            }
            
            NSLog(@"membersID %@",membersID);
            
            //4552
            for (int j=0; j<[membersID count]; j++)
            {NSLog(@"%@ %@",membersID,membersID[j]);
                NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
                [attributeDic setValue:@"chat" forKey:@"type"];
                [attributeDic setValue:[[membersID objectAtIndex:j] JID] forKey:@"to"];
                [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
                [attributeDic setValue:@"0" forKey:@"isResend"];
                NSString *body=[NSString stringWithFormat:@"Your request to join %@ has been accepted",group[@"group_name"] ];
                NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                // [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] JID] forKey:@"from_user_id"];
                [elementDic setValue:@"text" forKey:@"message_type"];
                [elementDic setValue:@"1" forKey:@"grpUpdate"];
                [elementDic setValue:@"0" forKey:@"show_notification"];
                [elementDic setValue:@"1" forKey:@"isgroup"];
                NSLog(@"gid %@",group[@"id"]);
                [elementDic setValue:group[@"id"] forKey:@"groupID"];
                [elementDic setValue:body forKey:@"body"];
                
                [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
            }
            
            
            PostListing *detailPage = [[PostListing alloc]init];
            detailPage.chatTitle=group[@"group_name"];
            detailPage.groupId = group[@"id"];
            detailPage.groupName = group[@"group_name"];;
            detailPage.groupType=group[@"group_type"] ;;
            [self appDelegate].isUSER=0;
            [self.navigationController pushViewController:detailPage animated:YES];

        }
        
        else
        {
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        
        addFavGroupConn=nil;
        
        [addFavGroupConn cancel];
    }
    
    
}
- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}
//uialertview delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1) {
        if (buttonIndex == 1) {
            [self setActivityIndicator];
            
            NSString *appUserId = [[DatabaseManager getSharedInstance]getAppUserID];
            
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
    if (alertView.tag==11) {
        if (buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
    
}

//-(IBAction)setFilterTable:(id)sender
//{
//    search.text=@"";
//    search.showsCancelButton=FALSE;
//    [search resignFirstResponder];
//    [pop dismissPopoverAnimated:YES];
//    //the view controller you want to present as popover
//    filterTable = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
//    //initWithFrame:CGRectMake(15, 92, 100, 100) style:UITableViewStyleGrouped];
//    [filterTable.tableView setFrame:CGRectMake(15, 92, 100, 100)];
//    
//    filterTable.tableView.backgroundColor=[UIColor clearColor];
//    
//    filterTable.tableView.delegate = self;
//    filterTable.tableView.dataSource = self;
//    filterTable.tableView.scrollEnabled=FALSE;
//    //controller.view=filterTable;
//    // controller.title = @"Filter";
//    //our popover
//    //pop=[[UIPopoverController alloc] initWithContentViewController:controller];
//    
//    navController = [[UINavigationController alloc] initWithRootViewController:filterTable];
//    filterTable.title=@"Filter";
//    //[navController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor] ,UITextAttributeTextColor,[UIFont fontWithName:@"Dosis-Regular" size:17],UITextAttributeFont, nil]];
//    //  [navController.navigationBar setBackgroundColor:[UIColor greenColor] ];
//    pop=[[UIPopoverController alloc]initWithContentViewController:navController ];
//    
//    
//    UIButton *doneButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 50.0f, 30.0f)];
//    
//    [doneButton setTitle:@"Done" forState:UIControlStateNormal];//[UIColor
//    [doneButton addTarget:self action:@selector(donefiltering:) forControlEvents:UIControlEventTouchUpInside];
//    [doneButton setTitleColor:[UIColor colorWithRed:5.0/255.0 green:122/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
//    // UIBarButtonItem *Cancel = [[UIBarButtonItem alloc]                initWithTitle:@"Cancel"                style:UIBarButtonItemStyleBordered                target:self                action:@selector(CancelForward)];
//    navController.navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
//    UIButton *clearButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 50.0f, 30.0f)];
//    [clearButton setTitle:@"Clear" forState:UIControlStateNormal];//[UIColor
//    [clearButton addTarget:self action:@selector(cancelPop:) forControlEvents:UIControlEventTouchUpInside];
//    [clearButton setTitleColor:[UIColor colorWithRed:5.0/255.0 green:122/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
//    // UIBarButtonItem *Cancel = [[UIBarButtonItem alloc]                initWithTitle:@"Cancel"                style:UIBarButtonItemStyleBordered                target:self                action:@selector(CancelForward)];
//    navController.navigationBar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:clearButton];
//    
//    
//    [pop setPopoverContentSize:CGSizeMake(self.view.frame.size.width-10, 130)];
//    //[pop presentPopoverFromBarButtonItem:filterButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
//    
//    CGRect rect = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 10, 10);
//    [pop presentPopoverFromRect:rect inView:self.view permittedArrowDirections:NO animated:NO];
//    
//    
//}
//-(void)donefiltering:(id)sender
//{
//    
//    
//    [array removeAllObjects];
//    // if ([filter isEqualToString:@"Private Groups"]) {
//    if (privateFilter==1 && publicFilter==0) {
//        [groupIds removeAllObjects];
//        [adminNames removeAllObjects];
//        [groupDisplayThumbnails removeAllObjects];
//        [groupNames removeAllObjects];
//        [groupLocations removeAllObjects];
//        [groupTypes removeAllObjects];
//        [popularityFactor removeAllObjects];
//        
//        [tempGroupIds removeAllObjects];
//        [tempAdminNames removeAllObjects];
//        [tempGroupDisplayThumbnails removeAllObjects];
//        [tempGroupNames removeAllObjects];
//        [tempGroupLocations removeAllObjects];
//        [tempGroupTypes removeAllObjects];
//        [tempPopularityFactor removeAllObjects];
//        for (NSDictionary *result in groups)
//        {
//            
//            if ([result[@"type"]isEqualToString:@"private#local"]||[result[@"type"]isEqualToString:@"private#global"]) {
//                [array addObject:result];
//            }
//            
//        }
//        
//        
//        
//        for (int m=0; m<additionalGroupIds.count; m++) {
//            if ([additionalGroupTypes[m] isEqualToString:@"private#local"]||[additionalGroupTypes[m] isEqualToString:@"private#global"]) {
//                [groupIds addObject:[additionalGroupIds objectAtIndex:m]];
//                [adminNames addObject:[additionalAdminNames objectAtIndex:m]];
//                [groupDisplayThumbnails addObject:[additionalGroupDisplayThumbnails objectAtIndex:m]];
//                [groupNames addObject:[additionalGroupNames objectAtIndex:m]];
//                [groupLocations addObject:[additionalGroupLocations objectAtIndex:m]];
//                [groupTypes addObject:[additionalGroupTypes objectAtIndex:m]];
//                [popularityFactor addObject:[additionalPopularityFactor objectAtIndex:m]];
//                
//                [tempGroupIds addObject:[additionalGroupIds objectAtIndex:m]];
//                [tempAdminNames addObject:[additionalAdminNames objectAtIndex:m]];
//                [tempGroupDisplayThumbnails addObject:[additionalGroupDisplayThumbnails objectAtIndex:m]];
//                [tempGroupNames addObject:[additionalGroupNames objectAtIndex:m]];
//                [tempGroupLocations addObject:[additionalGroupLocations objectAtIndex:m]];
//                [tempGroupTypes addObject:[additionalGroupTypes objectAtIndex:m]];
//                [tempPopularityFactor addObject:[additionalPopularityFactor objectAtIndex:m]];
//            }
//            
//        }
//        if (filterCriteria==0) {
//            [self sortBy:@"popular"];
//        }
//        else if(filterCriteria==1)
//        {
//            [self sortBy:@"alphabetical"];
//        }
//        
//        [searchTable reloadData];
//        
//    }
//    //else if([filter isEqualToString:@"Public Groups"])
//    if (privateFilter==0 && publicFilter==1)
//    {
//        [groupIds removeAllObjects];
//        [adminNames removeAllObjects];
//        [groupDisplayThumbnails removeAllObjects];
//        [groupNames removeAllObjects];
//        [groupLocations removeAllObjects];
//        [groupTypes removeAllObjects];
//        [popularityFactor removeAllObjects];
//        
//        [tempGroupIds removeAllObjects];
//        [tempAdminNames removeAllObjects];
//        [tempGroupDisplayThumbnails removeAllObjects];
//        [tempGroupNames removeAllObjects];
//        [tempGroupLocations removeAllObjects];
//        [tempGroupTypes removeAllObjects];
//        [tempPopularityFactor removeAllObjects];
//        NSLog(@"filter groupnames: %@",groupNames);
//        for (NSDictionary *result in groups)
//        {
//            
//            if ([result[@"type"]isEqualToString:@"public#local"]||[result[@"type"]isEqualToString:@"public#global"]) {
//                [array addObject:result];
//            }
//            
//        }
//        
//        
//        
//        
//        for (int m=0; m<additionalGroupIds.count; m++) {
//            if ([additionalGroupTypes[m] isEqualToString:@"public#local"]||[additionalGroupTypes[m] isEqualToString:@"public#global"]) {
//                [groupIds addObject:[additionalGroupIds objectAtIndex:m]];
//                [adminNames addObject:[additionalAdminNames objectAtIndex:m]];
//                [groupDisplayThumbnails addObject:[additionalGroupDisplayThumbnails objectAtIndex:m]];
//                [groupNames addObject:[additionalGroupNames objectAtIndex:m]];
//                [groupLocations addObject:[additionalGroupLocations objectAtIndex:m]];
//                [groupTypes addObject:[additionalGroupTypes objectAtIndex:m]];
//                [popularityFactor addObject:[additionalPopularityFactor objectAtIndex:m]];
//                
//                [tempGroupIds addObject:[additionalGroupIds objectAtIndex:m]];
//                [tempAdminNames addObject:[additionalAdminNames objectAtIndex:m]];
//                [tempGroupDisplayThumbnails addObject:[additionalGroupDisplayThumbnails objectAtIndex:m]];
//                [tempGroupNames addObject:[additionalGroupNames objectAtIndex:m]];
//                [tempGroupLocations addObject:[additionalGroupLocations objectAtIndex:m]];
//                [tempGroupTypes addObject:[additionalGroupTypes objectAtIndex:m]];
//                [tempPopularityFactor addObject:[additionalPopularityFactor objectAtIndex:m]];
//                
//            }
//            
//        }
//        if (filterCriteria==0) {
//            [self sortBy:@"popular"];
//        }
//        else if(filterCriteria==1)
//        {
//            [self sortBy:@"alphabetical"];
//        }
//        
//        [searchTable reloadData];
//        
//        
//    }
//    if (privateFilter==1 && publicFilter==1)
//    {
//        [groupIds removeAllObjects];
//        [adminNames removeAllObjects];
//        [groupDisplayThumbnails removeAllObjects];
//        [groupNames removeAllObjects];
//        [groupLocations removeAllObjects];
//        [groupTypes removeAllObjects];
//        [popularityFactor removeAllObjects];
//        
//        [tempGroupIds removeAllObjects];
//        [tempAdminNames removeAllObjects];
//        [tempGroupDisplayThumbnails removeAllObjects];
//        [tempGroupNames removeAllObjects];
//        [tempGroupLocations removeAllObjects];
//        [tempGroupTypes removeAllObjects];
//        [tempPopularityFactor removeAllObjects];
//        for (NSDictionary *result in groups)
//        {
//            [array addObject:result];
//            
//        }
//        
//        [groupIds addObjectsFromArray:additionalGroupIds];
//        [adminNames addObjectsFromArray:additionalAdminNames];
//        [groupDisplayThumbnails addObjectsFromArray:additionalGroupDisplayThumbnails];
//        [groupNames addObjectsFromArray:additionalGroupNames];
//        [groupLocations addObjectsFromArray:additionalGroupLocations];
//        [groupTypes addObjectsFromArray:additionalGroupTypes];
//        [popularityFactor addObjectsFromArray:additionalPopularityFactor];
//        
//        [tempGroupIds addObjectsFromArray:additionalGroupIds];
//        [tempAdminNames addObjectsFromArray:additionalAdminNames];
//        [tempGroupDisplayThumbnails addObjectsFromArray:additionalGroupDisplayThumbnails];
//        [tempGroupNames addObjectsFromArray:additionalGroupNames];
//        [tempGroupLocations addObjectsFromArray:additionalGroupLocations];
//        [tempGroupTypes addObjectsFromArray:additionalGroupTypes];
//        [tempPopularityFactor addObjectsFromArray:additionalPopularityFactor];
//        if (filterCriteria==0) {
//            [self sortBy:@"popular"];
//        }
//        else if(filterCriteria==1)
//        {
//            [self sortBy:@"alphabetical"];
//        }
//        
//        [searchTable reloadData];
//    }
//    if (privateFilter==0 && publicFilter==0)
//    {
//        [pop dismissPopoverAnimated:YES];
//    }
//    //publicFilter=0;
//    //privateFilter=0;
//    [pop dismissPopoverAnimated:YES];
//}
//-(void)cancelPop:(id)sender
//{
//    publicFilter=1;
//    privateFilter=1;
//    [filterTable.tableView reloadData];
//    [self donefiltering:nil];
//    [pop dismissPopoverAnimated:YES];
//}




-(void)joinAllGroup{
    
    [self setActivityIndicator];
    
    NSMutableArray *users= [[NSMutableArray alloc] init];
    
    NSMutableArray *privateg= [[NSMutableArray alloc] init];
    
    NSMutableArray *publicg= [[NSMutableArray alloc] init];
    
    [selectedGroup enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSInteger row = [obj integerValue];
        
        
        
        if([[[groupData objectAtIndex:row] objectForKey:@"type"] isEqualToString:@"public#local"]||[[[groupData objectAtIndex:row] objectForKey:@"type"] isEqualToString:@"public#global"]){
            
            [publicg addObject:[groupData objectAtIndex:row][@"group_id"]];
            
        }else if ([[groupData objectAtIndex:row][@"type"] isEqual:@"private#local"]||[[groupData objectAtIndex:row][@"type"] isEqual:@"private#global"])
        {
            [privateg addObject:[groupData objectAtIndex:row][@"group_id"]];
        }else{
            
            [users addObject:[groupData objectAtIndex:row][@"group_id"]];
            
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
            [data setValue:userId forKey:@"user_id"];
            
            NSString *url =[NSString stringWithFormat:@"%@/scripts/multi_group_user_join.php",gupappUrl];
            [manager POST:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [HUD hide:YES];
                self.navigationItem.rightBarButtonItem = nil;
                
                [selectedGroup enumerateObjectsUsingBlock:^(id objs, NSUInteger idx, BOOL *stop) {
                    
                    NSInteger rows = [objs integerValue];
                    
                    [[groupData objectAtIndex:rows] setObject:@"1" forKey:@"is_exist"];
                    
                }];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"The selected groups will be available in your profile soon. Private groups will be activated once the group administrator has approved your request."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
                
                [searchTable reloadData];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [HUD hide:YES];
                
            }];
            
            
        }
        
    }];
    
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

#pragma - mark NewGroupCellDelegate
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
    NSIndexPath *morePath =[searchTable indexPathForCell:pcell];
    [searchTable beginUpdates];
    [searchTable reloadSections:[NSIndexSet indexSetWithIndex:morePath.section] withRowAnimation:UITableViewRowAnimationNone];
    [self tableView:searchTable heightForRowAtIndexPath:morePath];
    [searchTable endUpdates];
}

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
    NSIndexPath *morePath =[searchTable indexPathForCell:pcell];
    [searchTable beginUpdates];
    [searchTable reloadSections:[NSIndexSet indexSetWithIndex:morePath.section] withRowAnimation:UITableViewRowAnimationNone];
    [self tableView:searchTable heightForRowAtIndexPath:morePath];
    [searchTable endUpdates];
}

-(void)openGroupInfo:(NSDictionary *)data {
    int is_admin=[[DatabaseManager getSharedInstance]isAdminOrNot:[data objectForKey:@"group_id"] contactId:userId];
    
    if(is_admin == 1){
        viewPrivateGroup *viewGroupAsAdmin = [[viewPrivateGroup alloc]init];
        viewGroupAsAdmin.title = [data objectForKey:@"group_name"];
        viewGroupAsAdmin.groupId = [data objectForKey:@"group_id"];
        viewGroupAsAdmin.groupType =[data objectForKey:@"type"];
        [self.navigationController pushViewController:viewGroupAsAdmin animated:NO];
        
        
    }else{
        
        GroupInfo *viewGroupPage = [[GroupInfo alloc]init];
        viewGroupPage.title = [data objectForKey:@"group_name"];
        viewGroupPage.groupId = [data objectForKey:@"group_id"];
        viewGroupPage.groupType = [data objectForKey:@"type"];
        viewGroupPage.groupFlog  = [data objectForKey:@"flag"];
        [self.navigationController pushViewController:viewGroupPage animated:NO];
        
        
    }
    
}

-(void)openContactProfile:(NSDictionary *)data {
}

@end
