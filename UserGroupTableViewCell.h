//
//  UserGroupTableViewCell.h
//  GUP
//
//  Created by Unicode Systems on 23/02/15.
//  Copyright (c) 2015 genora. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserGroupTableViewCellDelegate
-(void)openGroupInfo:(NSDictionary*)data;
-(void)openContactProfile:(NSDictionary*)data;
@end


@interface UserGroupTableViewCell : UITableViewCell{
    UIImageView *pic;//,*separatopr;
    UILabel *nameLbl;
    UILabel *privateLbl;
    UIImageView *onlineIndicator;
    UIImageView *newChatIndecater,*muteImageView;
    UILabel *otherDetail;
    NSDictionary *cellDatas;
    UIView* separator;
    BOOL flag;
}
@property (nonatomic, strong)  id<UserGroupTableViewCellDelegate> cellDelegate;

@property(nonatomic,retain) UIImageView *muteImageView;
-(void)plotCellData:(NSDictionary*)cellData withLat:(double)latitude andLng:(double)longitude;



@end
