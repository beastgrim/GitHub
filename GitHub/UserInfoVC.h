//
//  UserInfoVC.h
//  GitHub
//
//  Created by Евгений Богомолов on 06.11.14.
//  Copyright (c) 2014 Евгений Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoVC : UIViewController {
    UIImage *img;
}

@property (nonatomic, strong) NSDictionary*                 user;
@property (nonatomic, strong) UIImage*                      img;

@end
