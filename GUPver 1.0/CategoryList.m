//
//  CategoryList.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/1/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "CategoryList.h"
#import "AppDelegate.h"
#import "GroupTableCell.h"
#import "DatabaseManager.h"
#import "GroupInfo.h"
#import "JSON.h"
#import "CreateGroup.h"
#import "viewPrivateGroup.h"
#import "GroupViewController.h"


@interface CategoryList ()

@end

@implementation CategoryList
@synthesize userId,triggeredFrom,distinguishFactor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = @"Category";
    }
    //Dosis-SemiBold
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    lockRow=1;
    
    CategoryListTable.allowsMultipleSelection=NO;
    
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    //categoryImages = [NSArray arrayWithObjects:@"business.png", @"education.png", @"finance.png", @"hospitality.png", @"accounting.png",nil];
    joinButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 60.0f, 30.0f)];
    [joinButton setTitle:@"Join" forState:UIControlStateNormal];
    [joinButton addTarget:self action:@selector(joinAllGroup) forControlEvents:UIControlEventTouchUpInside];
    [joinButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:207.0/255.0 blue:13.0/255.0 alpha:1] forState:UIControlStateNormal];
    joinButton.titleLabel.font = [UIFont fontWithName:@"Dosis-Bold" size:20];
    
    groupData = [[NSMutableArray alloc]init];
    selectedGroup = [[NSMutableArray alloc]init];
    
    if ([distinguishFactor isEqualToString:@"Groups"]){
        

        CategoryListTable.tag = 1;
        if ([triggeredFrom isEqualToString:@"explore"]){
            
            [self startActivityIndicator];
            [self fetchGroupJoinedList];
        }else{
            
            NSLog(@"user id:%@",userId);
            
            NSMutableArray* getData = [[DatabaseManager getSharedInstance]getGroupsJoinedByUsers:userId];
            if([getData count]>0){
                for (NSMutableArray *result in getData) {
                    NSMutableDictionary *datav = [[NSMutableDictionary alloc]init];
                    [datav setObject:[result objectAtIndex:0] forKey:@"id"];
                    [datav setObject:[result objectAtIndex:1] forKey:@"name"];
                    [datav setObject:[result objectAtIndex:2] forKey:@"description"];
                    [datav setObject:[result objectAtIndex:3] forKey:@"type"];
                    
                    CGSize size =[self calculateHeight:[datav objectForKey:@"description"]];
                    [datav setObject:[NSString stringWithFormat:@"%f",size.height] forKey:@"height"];
                    
                    [datav setObject:@"0" forKey:@"is_exist"];
                    
                    if([[datav objectForKey:@"type"] isEqualToString:@"public#local"]||[[datav objectForKey:@"type"] isEqualToString:@"public#global"]){
                        
                        NSString *checkIfPublicGroupExists=[NSString stringWithFormat:@"select * from groups_public where group_server_id=%@",datav[@"id"]];
                        BOOL publicGroupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfPublicGroupExists];
                        
                        if(!publicGroupExistOrNot){
                            
                            [datav setObject:@"0" forKey:@"is_exist"];
                        }else{
                            
                            [datav setObject:@"1" forKey:@"is_exist"];
                        }
                    }else if ([datav[@"type"] isEqual:@"private#local"]||[datav[@"type"] isEqual:@"private#global"])
                    {
                        
                        NSString *checkIfPrivateGroupExists=[NSString stringWithFormat:@"select * from groups_private where group_server_id=%@",datav[@"id"]];
                        
                        BOOL privateGroupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfPrivateGroupExists];
                        
                        if (!privateGroupExistOrNot) {
                            
                            [datav setObject:@"0" forKey:@"is_exist"];
                            
                        }else{
                            
                            [datav setObject:@"1" forKey:@"is_exist"];
                        }
                        
                    }
                    
                    [groupData addObject:datav];
                }
                
            }
            if ([getData count]== 0) {
                NSLog(@"no groups joined");
            }
        }
    }else{
        CategoryListTable.tag =0;
        categoryIds = [[NSMutableArray alloc]init];
        categoryNames = [[NSMutableArray alloc]init];
        NSString *checkIfCategoriesExist;
        checkIfCategoriesExist=[NSString stringWithFormat:@"select * from group_category"];
        BOOL categoriesExist=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfCategoriesExist];
        NSLog(@"bool added %d",categoriesExist);
        if (categoriesExist) {
            NSMutableArray *categoryData = [[NSMutableArray alloc]init];
            categoryData = [[DatabaseManager getSharedInstance]getCategories];
            
            if([categoryData count]>0){
                for(int i=0;i<[categoryData count];i++){
                    
                    NSMutableArray *categories = [categoryData objectAtIndex:i];
                    NSLog(@"getcategory categories %@\n",categories);
                    [categoryIds addObject:[categories objectAtIndex:0]];
                    [categoryNames addObject:[categories objectAtIndex:1]];
                }
            }
            
        }else{
            [self startActivityIndicator];
            [self loadCategories];
            
        }
    }
}

-(void)startActivityIndicator{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
}

- (void)loadCategories{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url=[NSString stringWithFormat:@"%@/scripts/fetch_all_cat.php",gupappUrl ];
    NSLog(@"Url final=%@",url);
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    fetchCategoryConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [fetchCategoryConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [fetchCategoryConn start];
    fetchCategoryResponse = [[NSMutableData alloc] init];
    
    
}
#pragma Actions

-(void)dismissView:(UIBarButtonItem*)barButton
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}




#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 0) {
        NSLog(@"categ names count == %i",[categoryNames count]);
        return [categoryNames count];
        
    }else
        return [groupData count];
    
    
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section{
    return 1.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == 0) {
        static NSString *CellIdentifier = @"Cell Identifier";
        //[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text =[categoryNames objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:@"Dosis-Regular" size:17.f];
        return cell;
        
    }else{
        static NSString *groupTableIdentifier = @"GroupTableItem";
        newGroupCell *cell= (newGroupCell *)[tableView dequeueReusableCellWithIdentifier:groupTableIdentifier];
        
        if (cell == nil) {
            cell = [[newGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:groupTableIdentifier];
        }
        cell.cellDelegate = self;
        CGRect rect = cell.frame;
        rect.size.width = tableView.frame.size.width;
        [cell setFrame: rect];
        [cell drawCell:[groupData objectAtIndex:indexPath.row] withIndex:indexPath.row];
        return cell;
    }
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat addHeight = ([[self appDelegate] increaseFont]==0)? 0: 10;

    if(tableView.tag == 0){
        return 44;
    }else{
        if (indexPath.row < groupData.count) {
            if ([[[groupData objectAtIndex:indexPath.row] objectForKey:@"height"] floatValue] > 20) {
                return [[[groupData objectAtIndex:indexPath.row] objectForKey:@"height"] floatValue] + 57 + addHeight;
            } else {
                return 70 + addHeight;
            }
        } else {
            return 70 + addHeight;
        }
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 0)     {
       UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *categoryID = [categoryIds objectAtIndex:indexPath.row];
        [insta updateCategory:cell.textLabel.text categoryId:categoryID];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}



-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 0){
        
    }
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    // check whether the user is the admin of the group.
//    NSString *appUserId =[[DatabaseManager getSharedInstance]getAppUserID];
//    
//    NSLog(@"group id check:%@ userid:%@",[groupId objectAtIndex:indexPath.row],userId);
//    int is_admin=[[DatabaseManager getSharedInstance]isAdminOrNot:[groupId objectAtIndex:indexPath.row] contactId:appUserId];
//    NSLog(@"is_admin%i",is_admin);
//    if (is_admin == 1) {
//        viewPrivateGroup *viewGroupAsAdmin = [[viewPrivateGroup alloc]init];
//        viewGroupAsAdmin.title = [groupName objectAtIndex:indexPath.row];
//        viewGroupAsAdmin.groupId = [groupId objectAtIndex:indexPath.row];
//        viewGroupAsAdmin.groupType =[groupType objectAtIndex:indexPath.row];
//        [self.navigationController pushViewController:viewGroupAsAdmin animated:NO];
//    }else{
//        GroupInfo *viewGroupPage = [[GroupInfo alloc]init];
//        viewGroupPage.title = [groupName objectAtIndex:indexPath.row];
//        viewGroupPage.groupId = [groupId objectAtIndex:indexPath.row];
//        viewGroupPage.groupType =[groupType objectAtIndex:indexPath.row];
//        if (![triggeredFrom isEqualToString:@"explore"]) {
//            viewGroupPage.startLoading =@"contacts";
//        }
//        [self.navigationController pushViewController:viewGroupPage animated:NO];
//    }
    
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)fetchGroupJoinedList{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postData = [NSString stringWithFormat:@"user_id=%@",userId];
    NSLog(@"$[%@]",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/user_group.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    groupJoinedConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [groupJoinedConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [groupJoinedConn start];
    groupJoinedResponse = [[NSMutableData alloc] init];
    
}

//NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == groupJoinedConn) {
        [groupJoinedResponse setLength:0];
        
    }
    if (connection == fetchCategoryConn) {
        [fetchCategoryResponse setLength:0];
        
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"did recieve data");
    
    if (connection == groupJoinedConn) {
        [groupJoinedResponse appendData:data];
        
    }
    if (connection == fetchCategoryConn) {
        
        [fetchCategoryResponse appendData:data];
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == groupJoinedConn) {
        
        [HUD hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        
        [alert show];
    }else{
        [HUD hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        
        [alert show];
        
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    
    if (connection == groupJoinedConn) {
        
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:groupJoinedResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        NSDictionary *results = res[@"group_list"];
        NSLog(@"results: %@", results);
        NSDictionary *groups=results[@"list"];
        NSLog(@"groups: %@", groups);
        
        if ([groups count]==0 ){
            [HUD hide:YES];
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                             message:@"No results found."
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            alert.tag=11;
            [alert show];
        }else{
            
            [selectedGroup removeAllObjects];
            [groupData removeAllObjects];
            
            for (NSDictionary *result in groups) {
                NSMutableDictionary *datav = [[NSMutableDictionary alloc]init];
                [datav addEntriesFromDictionary:result];
                CGSize size =[self calculateHeight:[datav objectForKey:@"description"]];
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
                    
                }
                
                [groupData addObject:datav];
            }
            
            [CategoryListTable reloadData];
            [HUD hide:YES];
        }
        groupJoinedConn=nil;
        [groupJoinedConn cancel];
    }
    
    
    if (connection == fetchCategoryConn) {
        
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
        for (NSDictionary *result in categories){
            NSString *checkIfExists=[NSString stringWithFormat:@"select * from group_category where category_id=%@",result[@"category_id"]];
            BOOL existOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfExists];
            if (existOrNot) {
                NSString *updateCategory=[NSString stringWithFormat:@"update  group_category set category_id = '%@', category_name = '%@' where category_id = '%@' ",result[@"category_id"],result[@"category_name"],result[@"category_id"]];
                NSLog(@"query %@",updateCategory);
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateCategory];
            }else{
                NSString *insertCategory=[NSString stringWithFormat:@"insert into group_category (category_id, category_name) values ('%@','%@')",result[@"category_id"],result[@"category_name"]];
                NSLog(@"query %@",insertCategory);
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertCategory];
            }
            [categoryIds addObject:result[@"category_id"]];
            [categoryNames addObject:result[@"category_name"]];
            
            
        }
        [CategoryListTable reloadData];
        
        [HUD hide:YES];
        fetchCategoryConn=nil;
        
        [fetchCategoryConn cancel];
        
        
    }
    
}

//uialertview delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==11) {
        if (buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}
-(void)wantToChangeCategoryFrom:(id)instance{
    insta=instance;
}

-(CGSize)calculateHeight:(NSString*)data{
    
    CGFloat width = self.view.frame.size.width - 80;
    UIFont *font = [UIFont fontWithName:@"Dosis-Regular" size:12.0f+[[self appDelegate] increaseFont]];
    NSAttributedString *attributedText = [[NSAttributedString alloc]initWithString:data attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    return size;
}

-(void)joinAllGroup{
    
    [self startActivityIndicator];
    
    NSMutableArray *users= [[NSMutableArray alloc] init];
    
    NSMutableArray *privateg= [[NSMutableArray alloc] init];
    
    NSMutableArray *publicg= [[NSMutableArray alloc] init];
    
    [selectedGroup enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSInteger row = [obj integerValue];
        
        
        
        if([[[groupData objectAtIndex:row] objectForKey:@"type"] isEqualToString:@"public#local"]||[[[groupData objectAtIndex:row] objectForKey:@"type"] isEqualToString:@"public#global"]){
            
            [publicg addObject:[groupData objectAtIndex:row][@"id"]];
            
        }else if ([[groupData objectAtIndex:row][@"type"] isEqual:@"private#local"]||[[groupData objectAtIndex:row][@"type"] isEqual:@"private#global"])
        {
            [privateg addObject:[groupData objectAtIndex:row][@"id"]];
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
            [data setValue:[[DatabaseManager getSharedInstance] getAppUserID] forKey:@"user_id"];
            
            NSString *url =[NSString stringWithFormat:@"%@/scripts/multi_group_user_join.php",gupappUrl];
            [manager POST:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [HUD hide:YES];
                self.navigationItem.rightBarButtonItem = nil;
                
                [selectedGroup enumerateObjectsUsingBlock:^(id objs, NSUInteger idx, BOOL *stop) {
                    
                    NSInteger rows = [objs integerValue];
                    
                    [[groupData objectAtIndex:rows] setObject:@"1" forKey:@"is_exist"];
                    
                }];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"The selected groups will be available in your profile soon."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
                if (privateg.count > 0 || publicg.count > 0) {
                    GroupViewController* groupViewController = (GroupViewController*)[self appDelegate].groupViewController;
                    [groupViewController setNeedFetch:YES];
                }
                
                [selectedGroup removeAllObjects];
                
                [CategoryListTable reloadData];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [HUD hide:YES];
                
            }];
            
        }
        
    }];
    
}

-(AppDelegate*)appDelegate{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
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
    NSIndexPath *morePath =[CategoryListTable indexPathForCell:pcell];
    [CategoryListTable beginUpdates];
    [CategoryListTable reloadSections:[NSIndexSet indexSetWithIndex:morePath.section] withRowAnimation:UITableViewRowAnimationNone];
    [self tableView:CategoryListTable heightForRowAtIndexPath:morePath];
    [CategoryListTable endUpdates];
}

-(BOOL)checkifSelected:(NSInteger)row{
    if([selectedGroup  containsObject:[NSString stringWithFormat:@"%ld",(long)row]]){
        return true;
    }else{
        return false;
    }
}

-(BOOL)checkiffull:(NSInteger)row{
    return false;
}

-(void)expandCellHeight:(UIButton*)btn withIndex:(NSInteger)row{
}

-(void)openGroupInfo:(NSDictionary *)data {
}

-(void)openContactProfile:(NSDictionary *)data {
}



@end
