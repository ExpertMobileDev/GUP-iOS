//
//  newGroupCell.m
//  GUP
//
//  Created by Aprajita Singh on 20/02/15.
//  Copyright (c) 2015 genora. All rights reserved.
//

#import "newGroupCell.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "NSString+Utils.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



@implementation newGroupCell

@synthesize post_desc, user_image, username, expand, extraInfo, selectButton, border, separator;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    CGFloat addFont = [(AppDelegate*)[[UIApplication sharedApplication] delegate] increaseFont];
    
    if (self) {
        
        border = [[UIView alloc] initWithFrame:CGRectZero];
        border.backgroundColor = [UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:0.9];
        border.opaque = YES;
        border.clearsContextBeforeDrawing = NO;
        [self addSubview:border];
        
        username = [[UILabel alloc] initWithFrame:CGRectZero];
        username.backgroundColor = [UIColor clearColor];
        username.opaque = YES;
        username.clearsContextBeforeDrawing = NO;
        username.numberOfLines=1;
        username.font = [UIFont fontWithName:@"Dosis-Bold" size:18.0f + addFont];
        username.textColor= [UIColor colorWithRed:36.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1];
        username.userInteractionEnabled = YES;
        [self addSubview:username];
               
        post_desc = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        post_desc.backgroundColor = [UIColor clearColor];
        post_desc.delegate = self;
        post_desc.opaque = YES;
        post_desc.clearsContextBeforeDrawing = NO;
        post_desc.numberOfLines=0;
        post_desc.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        post_desc.font = [UIFont fontWithName:@"Dosis-Regular" size:12.0f + addFont];
        post_desc.textColor= [UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:1];
        [self addSubview:post_desc];
        
        user_image = [[UIImageView alloc] initWithFrame:CGRectZero];
        user_image.backgroundColor = [UIColor clearColor];
        user_image.opaque = YES;
        user_image.clearsContextBeforeDrawing = NO;
        user_image.layer.cornerRadius =18.0f;
        user_image.clipsToBounds = YES;
        user_image.userInteractionEnabled = YES;
        [self addSubview:user_image];
        UITapGestureRecognizer *tapIcon = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapIcon)];
        [user_image addGestureRecognizer:tapIcon];

        selectButton= [UIButton buttonWithType:UIButtonTypeCustom];
        selectButton.tag = 3;
        [selectButton addTarget:self action:@selector(selectGroup:) forControlEvents:UIControlEventTouchUpInside];
        [selectButton setBackgroundImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
        selectButton.backgroundColor = [UIColor clearColor];
        [self addSubview:selectButton];
        
        extraInfo = [[UILabel alloc] init];
        extraInfo.textColor = [UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:1];
        extraInfo.tag = 2;
        extraInfo.backgroundColor = [UIColor clearColor];
        [extraInfo setFont:[UIFont fontWithName:@"Dosis-Regular" size:10.0f + addFont]];
        extraInfo.lineBreakMode = NSLineBreakByWordWrapping;
        extraInfo.numberOfLines=2;
        [self addSubview:extraInfo];

        separator = [[UIView alloc] init];
        separator.backgroundColor = [UIColor colorWithRed:0.783922 green:0.780392 blue:0.8 alpha:1];
        [self.contentView addSubview:separator];

        expand= [UIButton buttonWithType:UIButtonTypeCustom];
        [expand addTarget:self action:@selector(readFullView:) forControlEvents:UIControlEventTouchUpInside];
        expand.tag = 3;
        [expand setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        expand.backgroundColor = [UIColor clearColor];
        [self addSubview:expand];
        
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleFingerTap];

    }
    return self;
}

-(void)clearCell{
    
}

//UIImageView *iconImage= [[UIImageView alloc]initWithFrame:CGRectMake(18, 18, 18, 18)];
////iconImage.image = [UIImage imageNamed:@"globe"];
//
//if ([[[searchData objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"private#local"]){
//    iconImage.image =[UIImage imageNamed:@"private_local"];
//}else if([[[searchData objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"private#global"]){
//    iconImage.image =[UIImage imageNamed:@"private_global"];
//}else if ([[[searchData objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"public#local"]){
//    iconImage.image =[UIImage imageNamed:@"pin15"];
//}else if ([[[searchData objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"public#global"]){
//    iconImage.image =[UIImage imageNamed:@"globe15"];
//}else{
//    iconImage.image = [UIImage imageNamed:nil];
//}
//[cell.imageView addSubview:iconImage];
//
//cell.textLabel.font = [UIFont fontWithName:@"Dosis-SemiBold" size:17.f];
//cell.textLabel.textColor = [UIColor colorWithRed:36.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1];
//cell.textLabel.text = [[searchData objectAtIndex:indexPath.row] objectForKey:@"name"];
//
//cell.detailTextLabel.text = [[searchData objectAtIndex:indexPath.row] objectForKey:@"description"];
//cell.detailTextLabel.font = [UIFont fontWithName:@"Dosis-Regular" size:11.f];
//
//if ( [[[self appDelegate].ver objectAtIndex:0] intValue] >= 7 )
//[cell setAccessoryType: UITableViewCellAccessoryDetailButton];
//else
//[cell setAccessoryType: UITableViewCellAccessoryDetailDisclosureButton];
//

- (void)drawCell:(NSDictionary*)data withIndex:(NSInteger)rows{
    
    cellData = data;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.row = rows;
    
    if([data objectForKey:@"cell_type"]){
        
        self.username.text = [data objectForKey:@"name"];
        
        if([[data objectForKey:@"is_exist"] intValue])
            selectButton.hidden = YES;
        else
            selectButton.hidden = NO;
        
        if ([[data objectForKey:@"type"] isEqualToString:@"private#local"]
            ||[[data objectForKey:@"type"] isEqualToString:@"private#global"]
            ||[[data objectForKey:@"type"] isEqualToString:@"public#local"]
            ||[[data objectForKey:@"type"] isEqualToString:@"public#global"]) {
            
            user_image.layer.cornerRadius = 18;
            [user_image sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,[data objectForKey:@"thumbnail"]]] placeholderImage:[UIImage imageNamed:@"defaultProfile"] completed:^(UIImage *image , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                if (image) {
                    user_image.image = image;
                }else{
                    user_image.image = [UIImage imageNamed:@"defaultProfile"];
                }
                
            }];
            
            NSString* xtra;
            if([data objectForKey:@"member_count"] != nil){
                xtra = [NSString stringWithFormat:@"%@ members", [data objectForKey:@"member_count"]];
            } else {
                xtra = @"0 members";
            }
            if ([[data objectForKey:@"type"] containsString:@"global"]) {
                xtra = [xtra stringByAppendingString:@" , Global"];
            } else if ([[data objectForKey:@"type"] containsString:@"local"]) {
                if ([data objectForKey:@"distance"] != nil) {
                    float distance = [[data objectForKey:@"distance"] floatValue];
                    xtra = [xtra stringByAppendingString:[NSString stringWithFormat:@" , %.1f miles", distance]];
                }
                NSString* locality = [data objectForKey:@"locality"];
                NSString* country = [data objectForKey:@"country"];
                NSString* location = @"";
                
                if (locality.length > 1) {
                    location = [location stringByAppendingString:[NSString stringWithFormat:@"%@", locality]];
                }
                if (country.length > 1) {
                    location = [location stringByAppendingString:[NSString stringWithFormat:@" , %@", country]];
                }
                if ([self calculateWidth:[NSString stringWithFormat:@"%@ | %@", xtra, location]] > screenWidth - 120) {
                    xtra = [xtra stringByAppendingString:[NSString stringWithFormat:@"\n%@", location]];
                } else if (location.length > 1){
                    xtra = [xtra stringByAppendingString:[NSString stringWithFormat:@" | %@", location]];
                }
                
            } else {
                NSString* locality = [data objectForKey:@"locality"];
                NSString* country = [data objectForKey:@"country"];
                
                if (locality.length > 1) {
                    xtra = [xtra stringByAppendingString:[NSString stringWithFormat:@" | %@", locality]];
                }
                if (country.length > 1) {
                    xtra = [xtra stringByAppendingString:[NSString stringWithFormat:@" , %@", country]];
                }
            }
            if ([[data objectForKey:@"type"] containsString:@"private"]) {
                xtra = [xtra stringByAppendingString:@" | Private"];
            } else if ([[data objectForKey:@"type"] containsString:@"public"]) {
                xtra = [xtra stringByAppendingString:@" | Public"];
            }
            self.extraInfo.text = xtra;
            
        }else{
            
            user_image.layer.cornerRadius = 25;
            [user_image sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,[data objectForKey:@"thumbnail"]]] placeholderImage:[UIImage imageNamed:@"defaultProfile"] completed:^(UIImage *image , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                if (image) {
                    user_image.image = image;
                }else{
                    user_image.image = [UIImage imageNamed:@"defaultProfile"];
                }
                
            }];
            
            self.extraInfo.text = data[@"bottom_display"];
           
        }
        
    }else{
        
        if ([data objectForKey:@"group_name"]) {
            self.username.text = [data objectForKey:@"group_name"];
        } else if ([data objectForKey:@"name"]) {
            self.username.text = [data objectForKey:@"name"];
        }
        
        NSString *xtra;
        if ([data objectForKey:@"total_members"] != nil){
            xtra = [NSString stringWithFormat:@"%@ members", [data objectForKey:@"total_members"]];
        } else if ([data objectForKey:@"total_member"] != nil) {
            xtra = [NSString stringWithFormat:@"%@ members", [data objectForKey:@"total_member"]];
        } else {
            xtra = @"0 members";
        }
        if ([[data objectForKey:@"type"] containsString:@"global"]) {
            xtra = [xtra stringByAppendingString:@" , Global"];
        } else if ([[data objectForKey:@"type"] containsString:@"local"]) {
            
            if ([data objectForKey:@"distance"] != nil) {
                float distance = [[data objectForKey:@"distance"] floatValue];
                xtra = [xtra stringByAppendingString:[NSString stringWithFormat:@" , %.1f miles", distance]];
            }
            
            NSString* locality = [data objectForKey:@"locality"];
            NSString* country = [data objectForKey:@"country"];
            NSString* location = @"";
            
            if (locality.length > 1) {
                location = [location stringByAppendingString:[NSString stringWithFormat:@"%@", locality]];
            }
            if (country.length > 1) {
                location = [location stringByAppendingString:[NSString stringWithFormat:@" , %@", country]];
            }
            if ([self calculateWidth:[NSString stringWithFormat:@"%@ | %@", xtra, location]] > screenWidth - 120) {
                xtra = [xtra stringByAppendingString:[NSString stringWithFormat:@"\n%@", location]];
            } else if (location.length > 1){
                xtra = [xtra stringByAppendingString:[NSString stringWithFormat:@" | %@", location]];
            } else {
                xtra = [xtra stringByAppendingString:[NSString stringWithFormat:@" , Local"]];
            }
            
        } else {
            NSString* locality = [data objectForKey:@"locality"];
            NSString* country = [data objectForKey:@"country"];
            
            if (locality.length > 1) {
                xtra = [xtra stringByAppendingString:[NSString stringWithFormat:@" | %@", locality]];
            }
            if (country.length > 1) {
                xtra = [xtra stringByAppendingString:[NSString stringWithFormat:@" , %@", country]];
            }
        }
        if ([[data objectForKey:@"type"] containsString:@"private"]) {
            xtra = [xtra stringByAppendingString:@" | Private"];
        } else if ([[data objectForKey:@"type"] containsString:@"public"]) {
            xtra = [xtra stringByAppendingString:@" | Public"];
        }

        self.extraInfo.text = xtra;
        
        user_image.layer.cornerRadius = 18;
        NSString* imagefile = nil;
        if ([data objectForKey:@"display_pic_50"]) {
            imagefile = [data objectForKey:@"display_pic_50"];
        } else if ([data objectForKey:@"group_pic"]){
            imagefile = [data objectForKey:@"group_pic"];
        }
        [user_image sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,imagefile]] placeholderImage:[UIImage imageNamed:@"defaultProfile"] completed:^(UIImage *image , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (image) {
                user_image.image = image;
            }else{
                user_image.image = [UIImage imageNamed:@"defaultProfile"];
            }
            
        }];
    }
    user_image.frame = CGRectMake(10, 10, 50, 50);
    selectButton.frame = CGRectMake(screenWidth-40, 10, 30, 30);
    username.frame = CGRectMake(70, 8, screenWidth - 120, 22);
    CGFloat height = [self calculateHeight:self.extraInfo.text width:screenWidth - 120];
    extraInfo.frame = CGRectMake(70, 30, screenWidth - 120, height);
    post_desc.frame  = CGRectMake(70, 30 + height, screenWidth - 80, [[data objectForKey:@"height"] floatValue]);
    self.post_desc.text = [data objectForKey:@"description"];
    expand.frame = CGRectMake(0,0,0,0);
    
    CGFloat cellHeight = ([[data objectForKey:@"height"] floatValue] > 20)? [[data objectForKey:@"height"] floatValue] + 57: 70;
    cellHeight += ([(AppDelegate*)[[UIApplication sharedApplication] delegate] increaseFont] == 0)? 0: 10;
    separator.frame = CGRectMake(15, cellHeight - 1, screenWidth - 15, 1);

    if([self.cellDelegate checkifSelected:self.row]){
        [selectButton setBackgroundImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    }else{
        [selectButton setBackgroundImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
    }
    
    if([[data objectForKey:@"is_exist"] intValue])
        selectButton.hidden = YES;
    else
        selectButton.hidden = NO;
}

-(CGFloat)calculateHeight:(NSString*)data width:(CGFloat)width{
    
    UIFont *font = [UIFont fontWithName:@"Dosis-Regular" size:10.0f+[(AppDelegate*)[[UIApplication sharedApplication] delegate] increaseFont]];
    NSAttributedString *attributedText = [[NSAttributedString alloc]initWithString:data attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect.size.height;
}

-(CGFloat)calculateWidth:(NSString*)data{
    
    UIFont *font = [UIFont fontWithName:@"Dosis-Regular" size:10.0f+[(AppDelegate*)[[UIApplication sharedApplication] delegate] increaseFont]];
    NSAttributedString *attributedText = [[NSAttributedString alloc]initWithString:data attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){CGFLOAT_MAX, 15}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect.size.width;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    if (!selectButton.hidden) {
        [self selectGroup:selectButton];
    }
}

-(void)selectGroup:(UIButton*)btn{
    
    [self.cellDelegate groupSelected:btn withIndex:self.row];
}
-(void)readFullView:(UIButton*)btn{
    
    //[self.groupDelegate expandCellHeight:btn withIndex:self.row];
}

- (void) onTapIcon {
    if([cellData objectForKey:@"cell_type"]){
        
        if ([[cellData objectForKey:@"type"] isEqualToString:@"private#local"]
            ||[[cellData objectForKey:@"type"] isEqualToString:@"private#global"]
            ||[[cellData objectForKey:@"type"] isEqualToString:@"public#local"]
            ||[[cellData objectForKey:@"type"] isEqualToString:@"public#global"]) {
           
            [self.cellDelegate openGroupInfo:cellData];
        } else {
            [self.cellDelegate openContactProfile:cellData];
        }

    } else {
        [self.cellDelegate openGroupInfo:cellData];
    }
}

@end
