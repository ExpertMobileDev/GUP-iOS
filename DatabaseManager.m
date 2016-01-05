//
//  DatabaseManager.m
//  GUPver 1.0
//
//  Created by Deepesh_Genora on 11/12/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "DatabaseManager.h"
#import <sqlite3.h>
#import "NSString+Utils.h"
#import "AppDelegate.h"
static DatabaseManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation DatabaseManager
{
   
}
- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
#pragma deepeshQueries
+(DatabaseManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}
-(BOOL)createDB{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent: @"gup_app_db.sqlite"]];
    NSLog(@"path %@",databasePath);
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSError *ERROR;
    NSString* appVersion = [self appVersion];
    NSString* dbVersion = [self getDatabaseVersion];
    

    if ([filemgr fileExistsAtPath: databasePath ] == NO || dbVersion == nil || ![dbVersion isEqualToString:appVersion]){
        
        NSString *writableDBPath = databasePath;
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"gup_app_db.sqlite"];
        NSLog(@"%i",[filemgr fileExistsAtPath: defaultDBPath]);
        NSArray *masterTable = nil;
        if ([filemgr fileExistsAtPath: writableDBPath]) {
            masterTable =   [self retrieveDataFromTableWithQuery:@"select display_name, logged_in_user_id, social_login, social_login_type, social_login_id, email, password, verified, display_pic, location_id, location, last_logged_in, version_no, status, about_us from master_table"];
            [filemgr removeItemAtPath:writableDBPath error:nil];
        }
        success = [filemgr copyItemAtPath:defaultDBPath toPath:writableDBPath error:&ERROR];
//        [self executeQueryWithQuery:@"ALTER TABLE `chat_personal` ADD `received_time` DATETIME NOT NULL default '0'"];
//        [self executeQueryWithQuery:@"ALTER TABLE `chat_personal` ADD `sender_image` VARCHAR NOT NULL default ' '"];
//        [self executeQueryWithQuery:@"ALTER TABLE `chat_group` ADD `sender_image` VARCHAR NOT NULL default ' '"];
//        [self executeQueryWithQuery:@"ALTER TABLE `chat_group` ADD `received_time` DATETIME NOT NULL default '0'"];
//        [self executeQueryWithQuery:@"ALTER TABLE `chat_group` ADD `chat_received_time` DATETIME NOT NULL"];
//        [self executeQueryWithQuery:@"ALTER TABLE `master_table` ADD `about_us` VARCHAR NOT NULL default ' '"];
//        [self executeQueryWithQuery:@"ALTER TABLE `master_table` ADD `version_no` DOUBLE NOT NULL default '0'"];
//        [self executeQueryWithQuery:@"ALTER TABLE `master_table` ADD `contact_timestamp` DATETIME NOT NULL default '0'"];
//        [self executeQueryWithQuery:@"ALTER TABLE `master_table` ADD `group_timestamp` DATETIME NOT NULL default '0'"];
//        [self executeQueryWithQuery:@"ALTER TABLE `groups_private` ADD `admin_id` DATETIME NOT NULL default '0'"];
//        [self executeQueryWithQuery:@"ALTER TABLE `groups_public` ADD `admin_id` DATETIME NOT NULL default '0'"];
//        [self executeQueryWithQuery:@"ALTER TABLE `groups_private` ADD `group_member` VARCHAR NOT NULL default '0'"];
//        [self executeQueryWithQuery:@"ALTER TABLE `groups_public` ADD `group_member` VARCHAR NOT NULL default '0'"];
//        [self executeQueryWithQuery:@"ALTER TABLE `chat_group` ADD `sendername` VARCHAR NOT NULL default ' '"];
//        [self executeQueryWithQuery:@"ALTER TABLE `chat_group` ADD `orignal_time` VARCHAR NOT NULL default ' '"];
//        [self executeQueryWithQuery:@"ALTER TABLE `groups_private` ADD `latitude` VARCHAR"];
//        [self executeQueryWithQuery:@"ALTER TABLE `groups_private` ADD `longitude` VARCHAR"];
//        [self executeQueryWithQuery:@"ALTER TABLE `groups_private` ADD `locality` VARCHAR"];
//        [self executeQueryWithQuery:@"ALTER TABLE `groups_private` ADD `country` VARCHAR"];
        
        
        if (success) {
            [self setDatabaseVersion:appVersion];
            if (masterTable != nil && masterTable.count > 0) {
                NSDictionary* master = (NSDictionary*)[masterTable objectAtIndex:0];
                int userID = [master[@"LOGGED_IN_USER_ID"] intValue];
                NSString* name = master[@"DISPLAY_NAME"];// isEqual:[NSNull null]]? @"": master[@"DISPLAY_NAME"];
                NSString* email = master[@"EMAIL"];// isEqual:[NSNull null]]? @"": master[@"EMAIL"];
                NSString* password = master[@"PASSWORD"];// isEqual:[NSNull null]]? @"": master[@"PASSWORD"];
                int verified = [master[@"VERIFIED"] intValue];
                NSString* picture = master[@"DISPLAY_PIC"];// isEqual:[NSNull null]]? @"": master[@"DISPLAY_PIC"];
                int socialLogin = [master[@"SOCIAL_LOGIN"] intValue];
                NSString* socialType = master[@"SOCIAL_LOGIN_TYPE"];// isEqual:[NSNull null]]? @"": master[@"SOCIAL_LOGIN_TYPE"];
                NSString* socialID = master[@"SOCIAL_LOGIN_ID"];// isEqual:[NSNull null]]? @"": master[@"SOCIAL_LOGIN_ID"];
                int locationID = [master[@"LOCATION_ID"] intValue];
                NSString* location = master[@"LOCATION"];// isEqual:[NSNull null]]? @"": master[@"LOCATION"];
                NSString* lastLogin = master[@"LAST_LOGGED_IN"];// isEqual:[NSNull null]]? @"": master[@"LAST_LOGGED_IN"];
                NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                NSString* status = master[@"STATUS"];// isEqual:[NSNull null]]? @"": master[@"STATUS"];
                NSString* about = master[@"ABOUT_US"];// isEqual:[NSNull null]]? @"": master[@"ABOUT_US"];
                
                [self saveDataInTableWithQuery:@"delete from master_table"];
                isSuccess = [self saveDataInTableWithQuery:[NSString stringWithFormat:@"INSERT INTO master_table (id, logged_in_user_id,email, password,verified, display_name, display_pic,social_login,social_login_type,social_login_id,location_id,location,last_logged_in,version_no,status,about_us) VALUES(%i,%i,'%@','%@',%i,'%@','%@',%i,'%@','%@',%i,'%@','%@',%@,'%@','%@')", 1, userID, email, password, verified, name, picture, socialLogin, socialType, socialID, locationID, location, lastLogin, version, status, about]];

            }
        } else {
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [ERROR localizedDescription]);
            isSuccess=NO;
        }
        
    }else {
        isSuccess = YES;
        //NSLog(@"FILE DO EXIST");
//        [self executeQueryWithQuery:@"ALTER TABLE `chat_personal` ADD `received_time` DATETIME NOT NULL default '0'"];
//        [self executeQueryWithQuery:@"ALTER TABLE `chat_group` ADD `received_time` DATETIME NOT NULL default '0'"];
//        [self executeQueryWithQuery:@"ALTER TABLE `chat_group` ADD `chat_received_time` DATETIME NOT NULL"];
//        [self executeQueryWithQuery:@"ALTER TABLE `master_table` ADD `version_no` DOUBLE NOT NULL default '0'"];
//        [self executeQueryWithQuery:@"ALTER TABLE `master_table` ADD `contact_timestamp` DATETIME NOT NULL default '0'"];
//        [self executeQueryWithQuery:@"ALTER TABLE `master_table` ADD `group_timestamp` DATETIME NOT NULL default '0'"];
//        [self executeQueryWithQuery:@"ALTER TABLE `groups_private` ADD `admin_id` DATETIME NOT NULL default '0'"];
//        [self executeQueryWithQuery:@"ALTER TABLE `groups_public` ADD `admin_id` DATETIME NOT NULL default '0'"];
//        [self executeQueryWithQuery:@"ALTER TABLE `groups_private` ADD `group_member` VARCHAR NOT NULL default '0'"];
//        [self executeQueryWithQuery:@"ALTER TABLE `groups_public` ADD `group_member` VARCHAR NOT NULL default '0'"];
//        [self executeQueryWithQuery:@"ALTER TABLE `chat_group` ADD `sendername` VARCHAR NOT NULL default ' '"];
//        [self executeQueryWithQuery:@"ALTER TABLE `chat_group` ADD `orignal_time` VARCHAR NOT NULL default ' '"];
//        
//        [self executeQueryWithQuery:@"ALTER TABLE `groups_private` ADD `latitude` VARCHAR"];
//        [self executeQueryWithQuery:@"ALTER TABLE `groups_private` ADD `longitude` VARCHAR"];
//        [self executeQueryWithQuery:@"ALTER TABLE `groups_private` ADD `locality` VARCHAR"];
//        [self executeQueryWithQuery:@"ALTER TABLE `groups_private` ADD `country` VARCHAR"];
        
    }
    return isSuccess;
}

- (NSString*)appVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *appVersion = [NSString stringWithFormat:@"Version-%@ Build-%@", majorVersion, minorVersion];
    return appVersion;
}

- (NSString*)getDatabaseVersion {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* version = [defaults objectForKey:@"GupDababaseVersion"];
    return version;
}

- (void) setDatabaseVersion:(NSString*)version {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:version forKey:@"GupDababaseVersion"];
    [defaults synchronize];
}


-(BOOL)executeQueryWithQuery:(NSString*)Query{
    NSLog(@"query %@ databasePath %@",Query,databasePath);  
    int result;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK){
        
        const char *insert_stmt = [Query UTF8String];
        result=  sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
      //  sqlite3_bind_text(statement, 1, [str UTF8String], -1, SQLITE_TRANSIENT);
        if (sqlite3_step(statement) ==SQLITE_DONE ){
            sqlite3_finalize(statement);
            sqlite3_close(database);
    
            return YES;
        } else {
            sqlite3_finalize(statement);
            sqlite3_close(database);
            
            return NO;
        }//delete from favorite where restaurantsID=83
        sqlite3_reset(statement);
        
    }
    return NO;

    
}
- (BOOL) saveDataInTableWithQuery:(NSString*)Query{
    return [self executeQueryWithQuery:Query];
}
- (BOOL) deleteDataWithQuery:(NSString*)Query{
    NSLog(@"query %@ databasePath %@",Query,databasePath);
    int result;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK){
        
        const char *insert_stmt = [Query UTF8String];
        result=  sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
        
        if (sqlite3_step(statement) ==SQLITE_DONE ){
            sqlite3_finalize(statement);
            sqlite3_close(database);
            
            return YES;
        } else {
            sqlite3_finalize(statement);
            sqlite3_close(database);
            
            return NO;
        }//delete from favorite where restaurantsID=83
        sqlite3_reset(statement);
        
    }
    return NO;
}
-(NSDictionary*)DatabaseOutputParserRetrieveRowFromRowIndex:(NSInteger)index FromOutput:(NSArray*)output{
    if([output count]>=index)
    return [output objectAtIndex:index];
    else
        return NULL;

}
-(NSString*)DatabaseRowParserRetrieveColumnFromColumnName:(NSString*)columnname givenRow:(NSDictionary*)row{
    if ([row objectForKey:columnname])
        return [row objectForKey:columnname];
    else
      return  NULL;
}
-(NSString*)DatabaseRowParserRetrieveColumnFromColumnName:(NSString*)columnname ForRowIndex:(NSInteger)index givenOutput:(NSArray*)output{
    if ([output count]>index)
    {
       NSDictionary *row= [self DatabaseOutputParserRetrieveRowFromRowIndex:index FromOutput:output];
        //NSLog(@"row %@",row);
       NSString *returnValue= [self DatabaseRowParserRetrieveColumnFromColumnName:columnname givenRow:row];
         //NSLog(@"coulumnValue %@",returnValue);
        return returnValue;
    }
    else
        return NULL;
    
}

- (NSArray*) retrieveDataFromTableWithQuery:(NSString*)Query{
    
    //NSLog(@"query %@",Query);
    NSLog(@"query %@ databasePath %@",Query,databasePath);
    NSString *QUERY=[Query uppercaseString];
    NSString *substring=[QUERY stringBetweenString:@"SELECT" andString:@"FROM"];
    substring= [substring stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *columnNames=[substring componentsSeparatedByString:@","];
    NSMutableArray *returnArray=[[NSMutableArray alloc]init];
    //NSLog(@"array =%@ ,count =%i",columnNames,[columnNames count]);
    //NSLog(@"query =%@",QUERY);
    const char *dbpath = [databasePath UTF8String];
    if(sqlite3_open(dbpath, &database) == SQLITE_OK){
        const char *query_stmt = [Query UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            while ( sqlite3_step(statement)==SQLITE_ROW){
                NSMutableDictionary *arrayElements=[[NSMutableDictionary alloc]init];
                //NSLog(@"count %i",[columnNames count]);
                for (int i=0; i<[columnNames count]; i++){
                    
                    NSString *VAlUE = ((char *)sqlite3_column_text(statement,i)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, i)] :(NSString*)[NSNull null];
                    [arrayElements setObject:VAlUE forKey:[columnNames objectAtIndex:i]];
                   //NSLog(@"value=%@ coloumnName=%@",VAlUE,[columnNames objectAtIndex:i]);
                    
                }
                [returnArray addObject:arrayElements];
            }
        }else{
            //NSLog(@"Not found");
            return nil;
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
       
        
    }
    //NSLog(@"array =%@",returnArray);
    return returnArray;
}
// Initialise database

-(void)initialiseDatabase
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"gup_app_db.sqlite"];
    success = [fileMgr fileExistsAtPath:dbPath];
  //  databasePath=[dbPath UTF8String];
    if (!success) {
        NSLog(@"Cannot locate Database file.");
    }
    else
    {
        NSLog(@"success");
    }
    if (!(sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK))
    {
        NSLog(@"Error occured.");
    }

   // NSLog(@"path %@ database ",dbPath);
}

// To retrieve profile data

-(NSArray*) getProfileData{
    
    NSString *userName,*emailId,*location,*displayPic;
    int loggedInUserId;
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    [self initialiseDatabase];
    NSString *querySQL,*about;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    
    querySQL = [NSString stringWithFormat:@"SELECT logged_in_user_id,email,display_name,location,display_pic,social_login_type,about_us from master_table"];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
   // //NSLog(@"%@",sqlStatement1);
    if (result == SQLITE_OK)
    {
        if (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            loggedInUserId = sqlite3_column_int(sqlStatement1, 0);
            emailId = ((char *)sqlite3_column_text(sqlStatement1,1)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 1)] :nil;
            userName = ((char *)sqlite3_column_text(sqlStatement1,2)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 2)] : nil;
            location = ((char *)sqlite3_column_text(sqlStatement1,3)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 3)] : nil;
            displayPic = ((char *)sqlite3_column_text(sqlStatement1,4)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 4)] : nil;
          NSString *SocialLoginType = ((char *)sqlite3_column_text(sqlStatement1,5)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 5)] : nil;
            about = ((char *)sqlite3_column_text(sqlStatement1,6)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 6)] : nil;
            //NSLog(@"profile pic %@",displayPic);
            [resultArray addObject:[NSString stringWithFormat:@"%d",loggedInUserId]];
            [resultArray addObject:emailId==nil?SocialLoginType:emailId];
            [resultArray addObject:userName];
            [resultArray addObject:location];
            [resultArray addObject:displayPic];
            [resultArray addObject:about];
            
            
        }
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
    NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return resultArray;
}


//To update profile data

/*-(void)profileUpdate:(NSString*)userName userLoggedInId:(NSString*)logged_in_user_id
{
    NSLog(@"username in db=%@",userName);
    NSLog(@"logged in user id=%@",logged_in_user_id);
    [self initialiseDatabase];
    
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement;
    
    
    //insert into credential table
    NSLog(@"before sql query");
    querySQL = [NSString stringWithFormat:@"update  master_table set display_name = '%@' where logged_in_user_id = '%@' ",userName,logged_in_user_id];
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement, NULL);
    
    if (result == SQLITE_OK){
        
    }
    else{
        
    }
    
    if(sqlite3_step(sqlStatement) == SQLITE_ROW)
    {
        success=YES;
    }
    
    NSLog(@"SUCCESS=%i",success);
    sqlite3_finalize(sqlStatement);
    sqlite3_close(database);
}*/

//To update profile update variable

-(void)setUpdateProfileVariable:(int)profileUpdate userLoggedInId:(NSString*)logged_in_user_id
{
    //NSLog(@"profile update variable in db=%i",profileUpdate);
    [self initialiseDatabase];
    
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement;
    
    
    //insert into credential table
    //NSLog(@"before sql query");
    querySQL = [NSString stringWithFormat:@"update  master_table set profile_update = '%i' where logged_in_user_id = '%@' ",profileUpdate,logged_in_user_id];
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement, NULL);
    
    if (result == SQLITE_OK){
        
    }
    else{
        
    }
    
    if(sqlite3_step(sqlStatement) == SQLITE_ROW)
    {
        success=YES;
    }
    
    //NSLog(@"SUCCESS=%i",success);
    sqlite3_finalize(sqlStatement);
    sqlite3_close(database);
}


//To update password

/*-(void)updatePassword:(NSString*)newPassword userLoggedInId:(NSString*)logged_in_user_id
{
    NSLog(@"password in db=%@",newPassword);
    [self initialiseDatabase];
    
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement;
    
    
    //insert into credential table
    NSLog(@"before sql query");
    querySQL = [NSString stringWithFormat:@"update  master_table set password = '%@' where logged_in_user_id = '%@' ",newPassword,logged_in_user_id];
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement, NULL);
    
    if (result == SQLITE_OK){
        
    }
    else{
        
    }
    
    if(sqlite3_step(sqlStatement) == SQLITE_ROW)
    {
        success=YES;
    }
    
    //NSLog(@"SUCCESS=%i",success);
    sqlite3_finalize(sqlStatement);
    sqlite3_close(database);
}*/
-(void)updateLocation:(NSString*)location locationId:(int)locID userLoggedInId:(NSString*)logged_in_user_id
{
    //NSLog(@"password in db=%@",location);
    [self initialiseDatabase];
    
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement;
    
    
    //insert into credential table
    //NSLog(@"before sql query");
    querySQL = [NSString stringWithFormat:@"update  master_table set location = '%@',location_id = '%i' where logged_in_user_id = '%@' ",location,locID, logged_in_user_id];
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement, NULL);
    
    if (result == SQLITE_OK){
        
    }
    else{
        
    }
    
    if(sqlite3_step(sqlStatement) == SQLITE_ROW)
    {
        success=YES;
    }
    
    //NSLog(@"SUCCESS=%i",success);
    sqlite3_finalize(sqlStatement);
    sqlite3_close(database);
    
}

-(NSMutableArray*) getUsersData
{
    NSString *contactName,*contactPic,*contactStatus,*messageTime,*messageType,*messageText,*msgread,*muteNotify,*location;
    int contactId;
    // NSString *defaultValue=@"null";
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    NSLog(@"datapath =%@",databasePath);
    querySQL = [NSString stringWithFormat:@"SELECT c.user_name,c.user_pic,user_status,c.user_id,cp.time_stamp,cm.message_type,cm.message_text,cp.read,c.mute_notification,c.user_location  FROM contacts c left join chat_personal cp on c.user_id = cp.user_id or cp.receivers_id=c.user_id left join chat_message cm on cm.id=cp.message_id where c.blocked=0 and c.deleted=0 GROUP BY c.user_id ORDER BY cp.time_stamp desc,c.user_name asc"];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    
    if (result == SQLITE_OK){
        
        while (sqlite3_step(sqlStatement1) == SQLITE_ROW){
            
            NSMutableArray *resultArray = [[NSMutableArray alloc]init];
            //loggedInUserId = sqlite3_column_int(sqlStatement1, 0);
            contactName = ((char *)sqlite3_column_text(sqlStatement1,0)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 0)] : nil;
            contactPic = ((char *)sqlite3_column_text(sqlStatement1,1)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 1)] : nil;
            contactStatus = ((char *)sqlite3_column_text(sqlStatement1,2)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 2)] : nil;
            contactId = sqlite3_column_int(sqlStatement1, 3);
            messageTime = ((char *)sqlite3_column_text(sqlStatement1,4)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 4)] : nil;
            messageType = ((char *)sqlite3_column_text(sqlStatement1,5)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 5)] : nil;
            messageText = ((char *)sqlite3_column_text(sqlStatement1,6)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 6)] : nil;
            msgread = ((char *)sqlite3_column_text(sqlStatement1,7)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 7)] : nil;
            muteNotify = ((char *)sqlite3_column_text(sqlStatement1,8)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 8)] : nil;
            location = ((char *)sqlite3_column_text(sqlStatement1,9)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 9)] : nil;
            if(contactName != nil) {
                [resultArray addObject:contactName];
            }else{
                [resultArray addObject:@""];
            }
            if(contactPic != nil) {
                [resultArray addObject:contactPic];
            }else{
                [resultArray addObject:@""];
            }if(contactStatus != nil) {
                [resultArray addObject:contactStatus];
            }else{
                [resultArray addObject:@""];
            }
            
            NSString *userId = [NSString stringWithFormat:@"%d",contactId];
            if(userId != nil) {
                [resultArray addObject:userId];
            }else{
                [resultArray addObject:@""];
            }
            
            if(messageTime != nil) {
                [resultArray addObject:messageTime];
            }else{
                [resultArray addObject:@""];
            }
            if(messageType != nil) {
                [resultArray addObject:messageType];
            }else{
                [resultArray addObject:@""];
            }
            
            if(messageText != nil) {
                [resultArray addObject:messageText];
            }else{
                [resultArray addObject:@""];
            }
            if(msgread != nil) {
                [resultArray addObject:msgread];
            }else{
                [resultArray addObject:@""];
            }
            if(muteNotify != nil) {
                [resultArray addObject:muteNotify];
            }else{
                [resultArray addObject:@""];
            }
            if(location != nil) {
                [resultArray addObject:location];
            }else{
                [resultArray addObject:@""];
            }
            
            
            [returnArray addObject:resultArray];
        }
        //NSLog(@"users returned:%d",[returnArray count]);
    }else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
  //  NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return returnArray;
    
}



-(NSArray*) getContactMuteAndBlockStatus:(NSString*)user_id{
    NSString *muteStatus,*blockStatus;
    //int loggedInUserId;
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    
    querySQL = [NSString stringWithFormat:@"SELECT blocked,mute_notification from contacts where user_id= %@",user_id];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    
    if (result == SQLITE_OK){
        if (sqlite3_step(sqlStatement1) == SQLITE_ROW){
            
            muteStatus = ((char *)sqlite3_column_text(sqlStatement1,0)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 0)] : nil;
            blockStatus = ((char *)sqlite3_column_text(sqlStatement1,1)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 1)] : nil;
            [resultArray addObject:muteStatus];
            [resultArray addObject:blockStatus];
            
        }
    }else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
 //   NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return resultArray;
    
}
-(NSArray*) getViewProfileData:(NSString*)user_id
{
    NSString *userName,*userLocation,*userDisplayPic;
    //int loggedInUserId;
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    
    querySQL = [NSString stringWithFormat:@"SELECT user_name,user_location,user_pic from contacts where user_id= %@",user_id];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    
    if (result == SQLITE_OK){
        if (sqlite3_step(sqlStatement1) == SQLITE_ROW){
            
            userName = ((char *)sqlite3_column_text(sqlStatement1,0)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 0)] : nil;
            userLocation = ((char *)sqlite3_column_text(sqlStatement1,1)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 1)] : nil;
            userDisplayPic = ((char *)sqlite3_column_text(sqlStatement1,2)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 2)] : nil;
            [resultArray addObject:userName];
            [resultArray addObject:userLocation];
            [resultArray addObject:userDisplayPic];
        }
    }else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
 //   NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return resultArray;
    
}
-(NSMutableArray*) getGroupsJoinedByUsers:(NSString*)user_id{
    NSString *groupName,*groupDetail,*groupType;
    int groupId;
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    //NSLog(@"datapath =%@",databasePath);
    querySQL = [NSString stringWithFormat:@"select group_server_id,group_name,location_name,group_type from groups_public gp inner join group_members gm on gm.group_id = gp.group_server_id where gm.contact_id=%@ union select group_server_id,group_name,created_by,group_type from groups_private gp inner join group_members gm on gm.group_id = gp.group_server_id where gm.contact_id=%@",user_id,user_id];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    
    if (result == SQLITE_OK){
        
        while (sqlite3_step(sqlStatement1) == SQLITE_ROW){
            NSMutableArray *resultArray = [[NSMutableArray alloc]init];
            groupId = sqlite3_column_int(sqlStatement1, 0);
            groupName = ((char *)sqlite3_column_text(sqlStatement1,1)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 1)] : nil;
            groupDetail = ((char *)sqlite3_column_text(sqlStatement1,2)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 2)] : nil;
            groupType = ((char *)sqlite3_column_text(sqlStatement1,3)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 3)] : nil;
            
            //NSLog(@"contact name %@",groupName);
            [resultArray addObject:[NSString stringWithFormat:@"%d",groupId]];
            [resultArray addObject:groupName];
            [resultArray addObject:groupDetail];
            [resultArray addObject:groupType];
            [returnArray addObject:resultArray];
        }
        //NSLog(@"users returned:%d",[returnArray count]);
    }else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
  //  NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return returnArray;
    
    
}

-(BOOL)checkTableExist:(NSString*) table Column: (NSString*) column
{
    BOOL columnExists = NO;
    sqlite3_stmt *selectStmt;
    
    [self initialiseDatabase];
    NSString* querySQL = [NSString stringWithFormat:@"select %@ from %@", column, table];
    const char *sqlStatement = [querySQL UTF8String];
    if(sqlite3_prepare_v2(database, sqlStatement, -1, &selectStmt, NULL) == SQLITE_OK)
        columnExists = YES;
    
    sqlite3_finalize(selectStmt);
    sqlite3_close(database);
    
    return columnExists;
}

-(NSArray*) getPrivateGroupInfo:(NSString*)group_id{
    NSString *groupPic,*groupDesc,*groupAdmin,*groupCategory,*groupMembers,*groupCreatedDate,*groupName,*groupLatitude,*groupLongitude,*groupLocality,*groupCountry;
    //int loggedInUserId;
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    BOOL existGeoColumn = [self checkTableExist:@"groups_private" Column:@"latitude"];
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    
    if (existGeoColumn) {
        querySQL = [NSString stringWithFormat:@"SELECT group_pic,group_description,created_by,category_name,total_members,created_on,group_name,latitude,longitude,locality,country from groups_private where group_server_id=%@",group_id];
    } else {
        querySQL = [NSString stringWithFormat:@"SELECT group_pic,group_description,created_by,category_name,total_members,created_on,group_name from groups_private where group_server_id=%@",group_id];
    }
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    
    if (result == SQLITE_OK)
    {
        if (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            
            groupPic = ((char *)sqlite3_column_text(sqlStatement1,0)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 0)] : nil;
            groupDesc = ((char *)sqlite3_column_text(sqlStatement1,1)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 1)] : nil;
            groupAdmin = ((char *)sqlite3_column_text(sqlStatement1,2)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 2)] : nil;
            groupCategory = ((char *)sqlite3_column_text(sqlStatement1,3)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 3)] : nil;
            groupMembers = ((char *)sqlite3_column_text(sqlStatement1,4)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 4)] : nil;
            groupCreatedDate = ((char *)sqlite3_column_text(sqlStatement1,5)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 5)] : nil;
            groupName = ((char *)sqlite3_column_text(sqlStatement1,6)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 6)] : nil;
            
            [resultArray addObject:groupPic];
            [resultArray addObject:groupDesc];
            [resultArray addObject:groupAdmin];
            [resultArray addObject:groupCategory];
            [resultArray addObject:groupMembers];
            [resultArray addObject:groupCreatedDate];
            [resultArray addObject:groupName];
            
            if (existGeoColumn) {
                groupLatitude = ((char *)sqlite3_column_text(sqlStatement1,7)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 7)] : nil;
                groupLongitude = ((char *)sqlite3_column_text(sqlStatement1,8)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 8)] : nil;
                groupLocality = ((char *)sqlite3_column_text(sqlStatement1,9)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 9)] : nil;
                groupCountry = ((char *)sqlite3_column_text(sqlStatement1,10)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 10)] : nil;
                if (groupLatitude) {
                    [resultArray addObject:groupLatitude];
                }
                if (groupLongitude) {
                    [resultArray addObject:groupLongitude];
                }
                if (groupLocality) {
                    [resultArray addObject:groupLocality];
                }
                if (groupCountry) {
                    [resultArray addObject:groupCountry];
                }
            }
        }
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
    //NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return resultArray;
    
}

-(NSArray*) getPublicGroupInfo:(NSString*)group_id
{
    NSString *groupPic,*groupDesc,*groupLocation,*groupCategory,*groupMembers,*groupCreatedDate,*groupType,*groupName,*groupLatitude,*groupLongitude,*groupLocality,*groupCountry;
    //int loggedInUserId;
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    BOOL existGeoColumn = [self checkTableExist:@"groups_public" Column:@"latitude"];
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    if (existGeoColumn) {
        querySQL = [NSString stringWithFormat:@"SELECT group_pic,group_description,category_name,total_members,location_name,added_date,group_type,group_name,latitude,longitude,locality,country from groups_public where group_server_id=%@",group_id];
    } else {
        querySQL = [NSString stringWithFormat:@"SELECT group_pic,group_description,category_name,total_members,location_name,added_date,group_type,group_name from groups_public where group_server_id=%@",group_id];
    }
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    
    if (result == SQLITE_OK)
    {
        if (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            
            groupPic = ((char *)sqlite3_column_text(sqlStatement1,0)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 0)] : nil;
            groupDesc = ((char *)sqlite3_column_text(sqlStatement1,1)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 1)] : nil;
            groupCategory = ((char *)sqlite3_column_text(sqlStatement1,2)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 2)] : nil;
            groupMembers = ((char *)sqlite3_column_text(sqlStatement1,3)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 3)] : nil;
            groupLocation = ((char *)sqlite3_column_text(sqlStatement1,4)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 4)] : nil;
            groupCreatedDate = ((char *)sqlite3_column_text(sqlStatement1,5)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 5)] : nil;
            groupType = ((char *)sqlite3_column_text(sqlStatement1,6)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 6)] : nil;
            groupName = ((char *)sqlite3_column_text(sqlStatement1,7)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 7)] : nil;
            
            [resultArray addObject:groupPic];
            [resultArray addObject:groupDesc];
            [resultArray addObject:groupCategory];
            [resultArray addObject:groupMembers];
            [resultArray addObject:groupLocation];
            [resultArray addObject:groupCreatedDate];
            [resultArray addObject:groupType];
            [resultArray addObject:groupName];
            
            if (existGeoColumn) {
                groupLatitude = ((char *)sqlite3_column_text(sqlStatement1,8)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 8)] : nil;
                groupLongitude = ((char *)sqlite3_column_text(sqlStatement1,9)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 9)] : nil;
                groupLocality = ((char *)sqlite3_column_text(sqlStatement1,10)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 10)] : nil;
                groupCountry = ((char *)sqlite3_column_text(sqlStatement1,11)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 11)] : nil;
                if (groupLatitude) {
                    [resultArray addObject:groupLatitude];
                }
                if (groupLongitude) {
                    [resultArray addObject:groupLongitude];
                }
                if (groupLocality) {
                    [resultArray addObject:groupLocality];
                }
                if (groupCountry) {
                    [resultArray addObject:groupCountry];
                }
            }
        }
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
    // NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return resultArray;
    
}

-(NSMutableArray*) getMembersOfGroup:(NSString*)group_id
{
    NSString *memberName,*memberLocation,*memberPic;
    int memberId;
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    //NSLog(@"datapath =%@",databasePath);
    querySQL = [NSString stringWithFormat:@"SELECT contact_id,contact_name,contact_image,contact_location FROM group_members where group_id=%@ and deleted=0",group_id];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    
    if (result == SQLITE_OK)
    {
        
        while (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            NSMutableArray *resultArray = [[NSMutableArray alloc]init];
            memberId = sqlite3_column_int(sqlStatement1, 0);
            memberName = ((char *)sqlite3_column_text(sqlStatement1,1)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 1)] : nil;
            memberPic = ((char *)sqlite3_column_text(sqlStatement1,2)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 2)] : nil;
            memberLocation = ((char *)sqlite3_column_text(sqlStatement1,3)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 3)] : nil;
            
            
            [resultArray addObject:[NSString stringWithFormat:@"%d",memberId]];
            [resultArray addObject:memberName];
            [resultArray addObject:memberPic];
            [resultArray addObject:memberLocation];
            [returnArray addObject:resultArray];
        }
        //NSLog(@"users returned:%d",[returnArray count]);
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
    //NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return returnArray;
    
    
}

-(BOOL)recordExistOrNot:(NSString *)query{
    BOOL recordExist=NO;
    [self initialiseDatabase];
    sqlite3_stmt *sqlStatement1;
    //const char *query_stmt;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &sqlStatement1, nil)==SQLITE_OK)
    {
        if (sqlite3_step(sqlStatement1)==SQLITE_ROW)
        {
            recordExist=YES;
        }
        else
        {
            //////NSLog(@"%s,",sqlite3_errmsg(database));
        }
        sqlite3_finalize(sqlStatement1);
        sqlite3_close(database);
    }
    // NSLog(@"record value:%d",recordExist);
    return recordExist;
}

// To get App user id
-(NSString*)getAppUserID
{
    NSString *loggedInUserId;
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    
    querySQL = [NSString stringWithFormat:@"SELECT logged_in_user_id from master_table"];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    
    if (result == SQLITE_OK)
    {
        if (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            loggedInUserId = ((char *)sqlite3_column_text(sqlStatement1,0)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 0)] : nil;
        }
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
  //  NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return loggedInUserId;
    
}
-(NSMutableArray*) getCategories
{
    
    NSString *categoryName,*categoryId;
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    
    querySQL = [NSString stringWithFormat:@"SELECT category_id, category_name from group_category"];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    
    if (result == SQLITE_OK)
    {
        while (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            NSMutableArray *resultArray = [[NSMutableArray alloc]init];
            categoryId = ((char *)sqlite3_column_text(sqlStatement1,0)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 0)] : nil;
            categoryName = ((char *)sqlite3_column_text(sqlStatement1,1)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 1)] : nil;
            [resultArray addObject:categoryId];
            [resultArray addObject:categoryName];
            [returnArray addObject:resultArray];
        }
        //NSLog(@"cat returned:%d",[returnArray count]);
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
   // NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return returnArray;
    
}

-(NSString*)getAppUserName
{
    NSString *loggedInUserName;
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    
    querySQL = [NSString stringWithFormat:@"SELECT display_name from master_table"];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    
    if (result == SQLITE_OK)
    {
        if (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            loggedInUserName = ((char *)sqlite3_column_text(sqlStatement1,0)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 0)] : nil;
        }
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
   // NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return loggedInUserName;
    
}
-(NSString*)getAppUserLocationId
{
    NSString *loggedInUserLocationId;
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    
    querySQL = [NSString stringWithFormat:@"SELECT location_id from master_table"];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    
    if (result == SQLITE_OK)
    {
        if (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            loggedInUserLocationId = ((char *)sqlite3_column_text(sqlStatement1,0)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 0)] : nil;
        }
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
    //NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return loggedInUserLocationId;
    
    
}
-(NSString*)getAppUserLocationName
{
    NSString *loggedInUserLocation;
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    
    querySQL = [NSString stringWithFormat:@"SELECT location from master_table"];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    
    if (result == SQLITE_OK)
    {
        if (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            loggedInUserLocation = ((char *)sqlite3_column_text(sqlStatement1,0)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 0)] : nil;
        }
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
   // NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return loggedInUserLocation;
}


-(NSMutableArray*)getContactList
{
    NSString *contactName,*contactPic,*contactLocation,*contactId;
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    
    querySQL = [NSString stringWithFormat:@"SELECT user_id, user_name, user_pic, user_location from contacts"];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    
    if (result == SQLITE_OK)
    {
        while (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            NSMutableArray *resultArray = [[NSMutableArray alloc]init];
            contactId= ((char *)sqlite3_column_text(sqlStatement1,0)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 0)] : nil;
            contactName = ((char *)sqlite3_column_text(sqlStatement1,1)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 1)] : nil;
            contactPic = ((char *)sqlite3_column_text(sqlStatement1,2)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 2)] : nil;
            contactLocation = ((char *)sqlite3_column_text(sqlStatement1,3)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 3)] : nil;
            [resultArray addObject:contactId];
            [resultArray addObject:contactName];
            [resultArray addObject:contactPic];
            [resultArray addObject:contactLocation];
            [returnArray addObject:resultArray];
        }
        //NSLog(@"cat returned:%d",[returnArray count]);
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
   // NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return returnArray;
    
    
}


-(int)countGroupMembers:(NSString*)group_id
{
    int groupMembers=0;
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    
    querySQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM group_members where group_id=%@ and deleted=0",group_id];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    if (result == SQLITE_OK)
    {
        if (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            groupMembers = sqlite3_column_int(sqlStatement1, 0);
            
        }
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
    
    //NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return groupMembers;
}


-(int)isAdminOrNot:(NSString*)groupId contactId:(NSString*)contactId
{
    
    int is_admin=0;
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    
    querySQL = [NSString stringWithFormat:@"SELECT admin_id FROM groups_private where group_server_id=%@ and admin_id=%@ UNION SELECT admin_id FROM groups_public where  group_server_id=%@ and admin_id=%@",groupId,contactId,groupId,contactId];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    if (result == SQLITE_OK)
    {
        if (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            is_admin = 1;
            
        }
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
    
    //  NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return is_admin;
    
    
}

-(NSMutableArray*)getGroupMembersList:(NSString*)groupId
{
    NSString *contactName,*contactPic,*contactLocation,*contactId,*isAdmin;
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    
    querySQL = [NSString stringWithFormat:@"SELECT contact_id, is_admin, contact_name, contact_location,contact_image from group_members where group_id=%@ and deleted=0",groupId];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    
    if (result == SQLITE_OK)
    {
        while (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            NSMutableArray *resultArray = [[NSMutableArray alloc]init];
            contactId= ((char *)sqlite3_column_text(sqlStatement1,0)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 0)] : nil;
            isAdmin = ((char *)sqlite3_column_text(sqlStatement1,1)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 1)] : nil;
            
            contactName = ((char *)sqlite3_column_text(sqlStatement1,2)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 2)] : nil;
            contactLocation = ((char *)sqlite3_column_text(sqlStatement1,3)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 3)] : nil;
            contactPic = ((char *)sqlite3_column_text(sqlStatement1,4)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 4)] : nil;
            
            if(contactId != nil) {
                [resultArray addObject:contactId];
            }
            else
            {
                [resultArray addObject:@""];
            }
            if(isAdmin != nil) {
                [resultArray addObject:isAdmin];
            }
            else
            {
                [resultArray addObject:@""];
            }
            if(contactName != nil) {
                [resultArray addObject:contactName];
            }
            else
            {
                [resultArray addObject:@""];
            }
            if(contactLocation != nil) {
                [resultArray addObject:contactLocation];
            }
            else
            {
                [resultArray addObject:@""];
            }
            if(contactPic != nil) {
                [resultArray addObject:contactPic];
            }
            else
            {
                [resultArray addObject:@""];
            }
            
            [returnArray addObject:resultArray];
        }
        //NSLog(@"cat returned:%d",[returnArray count]);
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
   // NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return returnArray;
    
}

-(int)countGroupAdmins:(NSString*)group_id
{
    int groupAdmins=0;
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    
    querySQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM group_members where group_id=%@ and is_admin=%d and deleted=0",group_id,1];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    if (result == SQLITE_OK)
    {
        if (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            groupAdmins = sqlite3_column_int(sqlStatement1, 0);
            
        }
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
    
  //  NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return groupAdmins;
}

-(NSMutableArray*) getGroupsData
{
    NSString *groupName,*groupType,*muteNotification,*read,*groupId,*flag,*groupPic,*members,*location,*latitude,*longitude,*locality,*country,*isFav,*newPost;
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    NSLog(@"datapath =%@",databasePath);
    querySQL = [NSString stringWithFormat:@"SELECT p.group_id as group_server_id,p.group_pic, p.group_name, p.group_type, '-' as mute_notification, '-' as read,  '-' as time_stamp , '1' as flag,p.updatetime,p.total_members,p.location_name,'0' as latitude,'0' as longitude,'' as locality,'' as country, '' as is_fav, '' as new_post FROM group_invitations p UNION SELECT p.group_server_id,p.group_pic, p.group_name, p.group_type, p.mute_notification, p.read, p.time_stamp,  '2' as flag,p.updatetime,p.total_members,location_name,p.latitude,p.longitude,p.locality,p.country,p.is_fav,p.new_post FROM (groups_private p left join (select *  from  chat_group order by group_id, read)  cg on p.group_server_id= cg.group_id left join Post pst on cg.post_id = pst.post_id) as p GROUP BY p.group_server_id UNION SELECT p.group_server_id,p.group_pic, p.group_name, p.group_type, p.mute_notification, p.read, p.time_stamp , '2' as flag,p.updatetime,p.total_members,location_name,p.latitude,p.longitude,p.locality,p.country,p.is_fav,p.new_post FROM (groups_public p left join (select *  from  chat_group order by group_id, read) cg on p.group_server_id= cg.group_id left join Post pst on cg.post_id = pst.post_id) as p GROUP BY p.group_server_id ORDER BY  flag asc , p.updatetime desc, p.group_name asc"];
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    
    if (result == SQLITE_OK){
        
        while (sqlite3_step(sqlStatement1) == SQLITE_ROW){
            
            NSMutableArray *resultArray = [[NSMutableArray alloc]init];
            groupId = ((char *)sqlite3_column_text(sqlStatement1,0)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 0)] : nil;
            groupPic = ((char *)sqlite3_column_text(sqlStatement1,1)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 1)] : nil;
            groupName = ((char *)sqlite3_column_text(sqlStatement1,2)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 2)] : nil;
            groupType = ((char *)sqlite3_column_text(sqlStatement1,3)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 3)] : nil;
            muteNotification = ((char *)sqlite3_column_text(sqlStatement1,4)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 4)] : nil;
            read = ((char *)sqlite3_column_text(sqlStatement1,5)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 5)] : nil;
            flag = ((char *)sqlite3_column_text(sqlStatement1,7)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 7)] : nil;
            members = ((char *)sqlite3_column_text(sqlStatement1,9)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 9)] : nil;
            location = ((char *)sqlite3_column_text(sqlStatement1,10)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 10)] : nil;
            latitude = ((char *)sqlite3_column_text(sqlStatement1,11)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 11)] : nil;
            longitude = ((char *)sqlite3_column_text(sqlStatement1,12)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 12)] : nil;
            locality = ((char *)sqlite3_column_text(sqlStatement1,13)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 13)] : nil;
            country = ((char *)sqlite3_column_text(sqlStatement1,14)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 14)] : nil;
            isFav = ((char *)sqlite3_column_text(sqlStatement1,15)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 15)] : nil;
            newPost = ((char *)sqlite3_column_text(sqlStatement1,16)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 16)] : nil;
            //NSLog(@"group name %@",groupName);
            //NSLog(@"group pic %@",groupPic);
            //NSLog(@"message time %@",groupType);
            //NSLog(@"contact time %@",groupId);
            //NSLog(@"mute notify %@",muteNotification);
            //NSLog(@"flag %@",flag);
            
            if(groupId != nil) {
                [resultArray addObject:groupId];
            }
            else
            {
                [resultArray addObject:@""];
            }
            if(groupPic != nil) {
                [resultArray addObject:groupPic];
            }
            else
            {
                [resultArray addObject:@""];
            }
            if(groupName != nil) {
                [resultArray addObject:groupName];
            }
            else
            {
                [resultArray addObject:@""];
            }
            if(groupType != nil) {
                [resultArray addObject:groupType];
            }
            else
            {
                [resultArray addObject:@""];
            }
            if(muteNotification != nil) {
                [resultArray addObject:muteNotification];
            }
            else
            {
                [resultArray addObject:@""];
            }
            if(read != nil && isFav != nil) {
                if ([isFav isEqualToString:@"1"]) {
                    [resultArray addObject:read];
                } else {
                    [resultArray addObject:@""];
                }
            }
            else
            {
                [resultArray addObject:@""];
            }
            if(flag != nil) {
                [resultArray addObject:flag];
            }
            else
            {
                [resultArray addObject:@""];
            }
            if(members != nil) {
                [resultArray addObject:members];
            }
            else
            {
                [resultArray addObject:@""];
            }
            if(location && ![location isEqualToString:@" "] ) {
                [resultArray addObject:location];
            }
            else
            {
                [resultArray addObject:@""];
            }
            // Latitude
            if(latitude &&  latitude.length > 1) {
                [resultArray addObject:latitude];
            }
            else {
                [resultArray addObject:@""];
            }
            // Longitude
            if(longitude &&  longitude.length > 1) {
                [resultArray addObject:longitude];
            }
            else {
                [resultArray addObject:@""];
            }
            // Locality
            if(locality &&  locality.length > 1) {
                [resultArray addObject:locality];
            }
            else {
                [resultArray addObject:@""];
            }
            // Country
            if(country &&  country.length > 1) {
                [resultArray addObject:country];
            }
            else {
                [resultArray addObject:@""];
            }
            // Has New Post or not
            if(newPost) {
                [resultArray addObject:newPost];
            }
            else {
                [resultArray addObject:@""];
            }
            
            [returnArray addObject:resultArray];
        }
        //NSLog(@"users returned:%d",[returnArray count]);
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
    //NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return returnArray;
    
}

-(int)countNoOfUnreadMsgs:(NSString *)sentId contactOrGroup:(NSString*)contactOrGroup
{
    int noOfUnreadMsgs=0;
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    
    if ([contactOrGroup isEqualToString:@"contact"]) {
        querySQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM chat_personal where user_id=%@ and read=%d",sentId,0];
    }
    else
    {
        querySQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM chat_group where group_id=%@ and read=%d and user_id!=%@",sentId,0,[self appDelegate].myUserID];
    }
    
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    if (result == SQLITE_OK)
    {
        if (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            noOfUnreadMsgs = sqlite3_column_int(sqlStatement1, 0);
            
        }
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
    
  //  NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return noOfUnreadMsgs;
    
}

-(NSString*)getAppUserImage

{
    
    NSString *appUserImage;
    
    [self initialiseDatabase];
    
    NSString *querySQL;
    
    const char *query_stmt;
    
    int result;
    
    sqlite3_stmt *sqlStatement1;
    
    
    
    querySQL = [NSString stringWithFormat:@"SELECT display_pic from master_table"];
    
    //NSLog(@"querySQL %@",querySQL);
    
    query_stmt = [querySQL UTF8String];
    
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    
    
    
    if (result == SQLITE_OK)
        
    {
        
        if (sqlite3_step(sqlStatement1) == SQLITE_ROW)
            
        {
            
            appUserImage = ((char *)sqlite3_column_text(sqlStatement1,0)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 0)] : nil;
            
        }
        
    }
    
    else{
        
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
        
    }
    
   // NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    
    sqlite3_finalize(sqlStatement1);
    
    sqlite3_close(database);
    
    return appUserImage;
    
    
    
    
    
    
}

-(int)groupAdminId:(NSString*)group_id
{
    int groupAdminId=0;
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    
    querySQL = [NSString stringWithFormat:@"select contact_id from group_members where group_id=%@ and is_admin=1 and deleted=0",group_id];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    if (result == SQLITE_OK)
    {
        if (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            groupAdminId = sqlite3_column_int(sqlStatement1, 0);
            
        }
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
    
   // NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return groupAdminId;
    
}

-(int)fetchGroupJoinRequestCount:(NSString*)group_id
{
    int groupJoinRequestCount=0;
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    
    querySQL = [NSString stringWithFormat:@"select group_join_request_count from groups_private where group_server_id=%@",group_id];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    if (result == SQLITE_OK)
    {
        if (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            groupJoinRequestCount = sqlite3_column_int(sqlStatement1, 0);
            
        }
    }
    else{
        //NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
    
   // NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return groupJoinRequestCount;
}

-(NSMutableArray*) getBlockedUsers
{
    NSString *userId,*userName,*userPic,*userLocation;
    
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    //NSLog(@"datapath =%@",databasePath);
    querySQL = [NSString stringWithFormat:@"SELECT user_id,user_name,user_pic,user_location from contacts where blocked=1"];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    
    if (result == SQLITE_OK)
    {
        
        while (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            NSMutableArray *resultArray = [[NSMutableArray alloc]init];
            userId = ((char *)sqlite3_column_text(sqlStatement1,0)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 0)] : nil;
            userName = ((char *)sqlite3_column_text(sqlStatement1,1)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 1)] : nil;
            userPic = ((char *)sqlite3_column_text(sqlStatement1,2)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 2)] : nil;
            userLocation = ((char *)sqlite3_column_text(sqlStatement1,3)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 3)] : nil;
            
            [resultArray addObject:userId];
            [resultArray addObject:userName];
            [resultArray addObject:userPic];
            [resultArray addObject:userLocation];
            [returnArray addObject:resultArray];
        }
        //NSLog(@"users returned:%d",[returnArray count]);
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
    //NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return returnArray;
    
}

-(int)fetchBlockedUsersCount
{
    int blockedUsersCount=0;
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    
    querySQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM contacts where blocked=1"];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    if (result == SQLITE_OK)
    {
        if (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            blockedUsersCount = sqlite3_column_int(sqlStatement1, 0);
            
        }
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
    
   // NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return blockedUsersCount;
    
    
}

-(NSArray*)fetchFileNamesToBeDeleted
{
    NSString *fileName;
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    
    querySQL = [NSString stringWithFormat:@"SELECT message_filename from chat_message where message_type = 'audio' or message_type= 'image'"];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    
    if (result == SQLITE_OK)
    {
        while (sqlite3_step(sqlStatement1) == SQLITE_ROW)
        {
            fileName = ((char *)sqlite3_column_text(sqlStatement1,0)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 0)] : nil;
            [resultArray addObject:fileName];
        }
    }
    else{
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    }
   // NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    sqlite3_finalize(sqlStatement1);
    sqlite3_close(database);
    return resultArray;
}

-(NSString*)getAdminList:(NSString*)group_id
{
    NSString *adminName;
    NSString *adminList=@"";
    [self initialiseDatabase];
    NSString *querySQL;
    const char *query_stmt;
    int result;
    sqlite3_stmt *sqlStatement1;
    querySQL = [NSString stringWithFormat:@"SELECT contact_name FROM group_members where is_admin=1  and group_id=%@ and deleted=0",group_id];
    //NSLog(@"querySQL %@",querySQL);
    query_stmt = [querySQL UTF8String];
    result = sqlite3_prepare_v2(database, query_stmt, -1, &sqlStatement1, NULL);
    if (result == SQLITE_OK)
        
    {
        while (sqlite3_step(sqlStatement1) == SQLITE_ROW)
            
        {
            adminName = ((char *)sqlite3_column_text(sqlStatement1,0)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement1, 0)] : nil;
            if ([adminList isEqualToString:@""]) {
                adminList = [NSString stringWithFormat:@"%@",adminName];
            }
            else
            {
                adminList = [NSString stringWithFormat:@"%@,%@",adminList,adminName];
            }

        }
    }
    
    else{
        
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
        
    }
    
  //  NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(database));
    
    sqlite3_finalize(sqlStatement1);
    
    sqlite3_close(database);
    
    return adminList;
}




@end
