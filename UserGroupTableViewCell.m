//
//  UserGroupTableViewCell.m
//  GUP
//
//  Created by Unicode Systems on 23/02/15.
//  Copyright (c) 2015 genora. All rights reserved.
//

#import "UserGroupTableViewCell.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@implementation UserGroupTableViewCell
@synthesize muteImageView;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    CGFloat addFont = [(AppDelegate*)[[UIApplication sharedApplication] delegate] increaseFont];
    
    if(self){
        
        if([reuseIdentifier isEqualToString:@"UserCell"]){
            pic = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
            pic.backgroundColor = [UIColor clearColor];
            pic.opaque = YES;
            pic.clearsContextBeforeDrawing = NO;
            pic.layer.cornerRadius = 25;
            pic.clipsToBounds = YES;
            pic.userInteractionEnabled = YES;
            [self.contentView addSubview:pic];
            
            
            UITapGestureRecognizer *tapUser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUserProfile)];
            [pic addGestureRecognizer:tapUser];
            
            nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(pic.frame.origin.x+pic.frame.size.width+10, 8, 210, 22)];
            nameLbl.backgroundColor = [UIColor clearColor];
            nameLbl.opaque = YES;
            nameLbl.clearsContextBeforeDrawing = NO;
            nameLbl.numberOfLines=1;
            nameLbl.font = [UIFont fontWithName:@"Dosis-Bold" size:18.0f + addFont];
            nameLbl.textColor= [UIColor colorWithRed:36.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1];
            [self.contentView addSubview:nameLbl];
            
            
            otherDetail = [[UILabel alloc] initWithFrame:CGRectMake(nameLbl.frame.origin.x, nameLbl.frame.origin.y+nameLbl.frame.size.height,
                                                                    self.contentView.frame.size.width - 80, 13 + addFont)];
            otherDetail.backgroundColor = [UIColor clearColor];
            otherDetail.opaque = YES;
            otherDetail.clearsContextBeforeDrawing = NO;
            otherDetail.numberOfLines=1;
            otherDetail.font = [UIFont fontWithName:@"Dosis-Regular" size:10.0f + addFont];
            otherDetail.textColor= [UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:1];
            [self.contentView addSubview:otherDetail];
            
          
            
            newChatIndecater = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-30, nameLbl.frame.origin.y, 20, 20)];
            newChatIndecater.backgroundColor = [UIColor clearColor];
            newChatIndecater.image = [UIImage imageNamed:@"chatindecater"];
            newChatIndecater.opaque = YES;
            newChatIndecater.hidden =YES;
            newChatIndecater.clearsContextBeforeDrawing = NO;
            newChatIndecater.clipsToBounds = YES;
            [self.contentView addSubview:newChatIndecater];
            
            muteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(newChatIndecater.frame.origin.x, newChatIndecater.frame.origin.y+newChatIndecater.frame.size.height+5, 20, 20)];
            muteImageView.backgroundColor = [UIColor clearColor];
            muteImageView.opaque = YES;
            muteImageView.clearsContextBeforeDrawing = NO;
            muteImageView.clipsToBounds = YES;
            [self.contentView addSubview:muteImageView];
            
            onlineIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(otherDetail.frame.origin.x, otherDetail.frame.origin.y+otherDetail.frame.size.height + 5, 15, 15)];
            onlineIndicator.backgroundColor = [UIColor clearColor];
            onlineIndicator.opaque = YES;
            onlineIndicator.clearsContextBeforeDrawing = NO;
            onlineIndicator.clipsToBounds = YES;
            onlineIndicator.image = [UIImage imageNamed:@"offline"];
            [self.contentView addSubview:onlineIndicator];
            
            privateLbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(onlineIndicator.frame) + 5, onlineIndicator.frame.origin.y - 3, 50, 20)];
            privateLbl.backgroundColor = [UIColor clearColor];
            privateLbl.opaque = YES;
            privateLbl.clearsContextBeforeDrawing = NO;
            privateLbl.numberOfLines=1;
            privateLbl.font = [UIFont fontWithName:@"Dosis-Regular" size:12.0f + addFont];
            privateLbl.textColor= [UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:1];
            [self.contentView addSubview:privateLbl];
            
            separator = [[UIView alloc] initWithFrame:CGRectMake(15, self.contentView.frame.size.height-1, self.contentView.frame.size.width-15, 1)];
            separator.backgroundColor = [UIColor colorWithRed:0.783922 green:0.780392 blue:0.8 alpha:1];
            [self.contentView addSubview:separator];
        }
        
        if([reuseIdentifier isEqualToString:@"GroupCell"]){
            pic = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
            pic.backgroundColor = [UIColor clearColor];
            pic.opaque = YES;
            pic.clearsContextBeforeDrawing = NO;
            pic.layer.cornerRadius = 18;
            pic.clipsToBounds = YES;
            [self.contentView addSubview:pic];
            
            pic.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGroup = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openGroupView)];
            [pic addGestureRecognizer:tapGroup];
            
            nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(pic.frame.origin.x+pic.frame.size.width+8, 10, 210, 22)];
            nameLbl.backgroundColor = [UIColor clearColor];
            nameLbl.opaque = YES;
            nameLbl.clearsContextBeforeDrawing = NO;
            nameLbl.numberOfLines=1;
            nameLbl.font = [UIFont fontWithName:@"Dosis-Bold" size:18.0f + addFont];
            nameLbl.textColor= [UIColor colorWithRed:36.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1];
            nameLbl.userInteractionEnabled = YES;
            [self.contentView addSubview:nameLbl];
            
            otherDetail = [[UILabel alloc] initWithFrame:CGRectMake(nameLbl.frame.origin.x, nameLbl.frame.origin.y+nameLbl.frame.size.height,
                                                                    self.contentView.frame.size.width - 80, 13 + addFont)];
            otherDetail.backgroundColor = [UIColor clearColor];
            otherDetail.opaque = YES;
            otherDetail.clearsContextBeforeDrawing = NO;
            otherDetail.numberOfLines=1;
            otherDetail.font = [UIFont fontWithName:@"Dosis-Regular" size:10.0f + addFont];
            otherDetail.textColor= [UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:1];
            [self.contentView addSubview:otherDetail];
            
            privateLbl = [[UILabel alloc] initWithFrame:CGRectMake(otherDetail.frame.origin.x, otherDetail.frame.origin.y+otherDetail.frame.size.height, 200, 20)];
            privateLbl.backgroundColor = [UIColor clearColor];
            privateLbl.opaque = YES;
            privateLbl.clearsContextBeforeDrawing = NO;
            privateLbl.numberOfLines=1;
            privateLbl.font = [UIFont fontWithName:@"Dosis-Regular" size:12.0f + addFont];
            privateLbl.textColor= [UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:1];
            [self.contentView addSubview:privateLbl];
            
            newChatIndecater = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-30, nameLbl.frame.origin.y, 20, 20)];
            newChatIndecater.backgroundColor = [UIColor clearColor];
            newChatIndecater.opaque = YES;
            newChatIndecater.image = [UIImage imageNamed:@"chatindecater"];
            newChatIndecater.clearsContextBeforeDrawing = NO;
            newChatIndecater.clipsToBounds = YES;
            newChatIndecater.hidden =YES;
            [self.contentView addSubview:newChatIndecater];
            
            muteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(newChatIndecater.frame.origin.x, newChatIndecater.frame.origin.y+newChatIndecater.frame.size.height+5, 20, 20)];
            muteImageView.backgroundColor = [UIColor clearColor];
            muteImageView.opaque = YES;
            muteImageView.clearsContextBeforeDrawing = NO;
            muteImageView.clipsToBounds = YES;
            [self.contentView addSubview:muteImageView];
            
            separator = [[UIView alloc] initWithFrame:CGRectMake(15, self.contentView.frame.size.height-1, self.contentView.frame.size.width-15, 1)];
            separator.backgroundColor = [UIColor colorWithRed:0.783922 green:0.780392 blue:0.8 alpha:1];
            [self.contentView addSubview:separator];
        }
        
    }
    
    return self;
}

-(void)openGroupView{
    
    [self.cellDelegate openGroupInfo:cellDatas];
}

-(void)openUserProfile {
    [self.cellDelegate openContactProfile:cellDatas];
}

-(void)plotCellData:(NSDictionary*)cellData withLat:(double)latitude andLng:(double)longitude {
    
    cellDatas= cellData;
    
    
    if([self.reuseIdentifier isEqualToString:@"UserCell"]){
        if([[cellData objectForKey:@"read"] isEqualToString:@"0"]) {
            newChatIndecater.hidden = NO;
        } else {
            newChatIndecater.hidden = YES;
        }
        nameLbl.text = [cellData objectForKey:@"user_name"];
        otherDetail.text = [cellData objectForKey:@"location"];
        NSString *imageurl = [NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,[cellData objectForKey:@"user_pic"]];
        [pic sd_setImageWithURL:[NSURL URLWithString:imageurl] placeholderImage:[UIImage imageNamed:@"defaultProfile"] completed:^(UIImage *image , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (image) {
                pic.image = image;
            }else{
                pic.image = [UIImage imageNamed:@"defaultProfile"];
            }
            
        }];
        if ([[cellData objectForKey:@"user_status"] isEqualToString:@"online"]) {
            privateLbl.text = @"Online";
            onlineIndicator.image = [UIImage imageNamed:@"online"];
        } else {
            privateLbl.text = @"Offline";
            onlineIndicator.image = [UIImage imageNamed:@"offline"];
        }
    }
    
    if([self.reuseIdentifier isEqualToString:@"GroupCell"]){
        
        if([[cellData objectForKey:@"read"] isEqualToString:@"0"]
           || [[cellData objectForKey:@"new_post"] isEqualToString:@"1"]) {
            newChatIndecater.hidden = NO;
        } else {
            newChatIndecater.hidden = YES;
        }
        nameLbl.text = [cellData objectForKey:@"group_name"];
        
        NSString* xtra;
        if([cellData objectForKey:@"total_members"] != nil && ![[cellData objectForKey:@"total_members"] isEqualToString:@""]){
            xtra = [NSString stringWithFormat:@"%@ members", [cellData objectForKey:@"total_members"]];
        } else {
            xtra = @"0 members";
        }
        if ([[cellData objectForKey:@"group_type"] containsString:@"global"]) {
            xtra = [xtra stringByAppendingString:@" | Global"];
        } else if ([[cellData objectForKey:@"group_type"] containsString:@"local"]) {
            NSString* locality = [cellData objectForKey:@"locality"];
            NSString* country = [cellData objectForKey:@"country"];
            
            if (locality && locality.length > 0 && ![locality isEqualToString:@"<null>"]) {
                xtra = [xtra stringByAppendingString:[NSString stringWithFormat:@" | %@", locality]];
                if (country && country.length > 0 && ![country isEqualToString:@"<null>"]) {
                    xtra = [xtra stringByAppendingString:[NSString stringWithFormat:@" , %@", country]];
                }
            } else {
                xtra = [xtra stringByAppendingString:@" | Local"];
            }
        }
        
        if ([[cellData objectForKey:@"group_type"] containsString:@"private"]) {
            xtra = [xtra stringByAppendingString:@" | Private"];
        } else if ([[cellData objectForKey:@"group_type"] containsString:@"public"]) {
            xtra = [xtra stringByAppendingString:@" | Public"];
        }

        otherDetail.text = xtra;
        NSString *imageurl = [NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,[cellData objectForKey:@"group_pic"]];
        [pic sd_setImageWithURL:[NSURL URLWithString:imageurl] placeholderImage:[UIImage imageNamed:@"defaultProfile"] completed:^(UIImage *image , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (image) {
                pic.image = image;
            }else{
                pic.image = [UIImage imageNamed:@"defaultProfile"];
            }
            
        }];
        if ([[cellData objectForKey:@"mute_notification"] isEqualToString:@"1"]) {
            muteImageView.image =[UIImage imageNamed:@"mute"];
             muteImageView.hidden =NO;
        }else{
            muteImageView.image =[UIImage imageNamed:@"mute"];
            muteImageView.hidden =YES;
        }
        

        if ([[cellData objectForKey:@"flag"] isEqualToString:@"1"]){
            privateLbl.text = @"Pending Approval!!!";
        } else {
            privateLbl.text = @"";
        }
    }
    separator.frame = CGRectMake(15, self.contentView.frame.size.height-1, self.contentView.frame.size.width-15, 1);
    newChatIndecater.frame = CGRectMake(self.contentView.frame.size.width-30, nameLbl.frame.origin.y, 20, 20);

//    separatopr.frame = CGRectMake(self.contentView.frame.origin.x+10, 69, self.contentView.frame.size.width-20,1);
}

@end
