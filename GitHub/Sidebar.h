//
//  Sidebar.h
//  GitHub
//
//  Created by Евгений Богомолов on 05.11.14.
//  Copyright (c) 2014 Евгений Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Sidebar;

@protocol SidebarDelegate <NSObject>
@optional
- (void)sidebar:(Sidebar *)sidebar willShowOnScreenAnimated:(BOOL)animatedYesOrNo;
- (void)sidebar:(Sidebar *)sidebar didShowOnScreenAnimated:(BOOL)animatedYesOrNo;
- (void)sidebar:(Sidebar *)sidebar willDismissFromScreenAnimated:(BOOL)animatedYesOrNo;
- (void)sidebar:(Sidebar *)sidebar didDismissFromScreenAnimated:(BOOL)animatedYesOrNo;
- (void)sidebar:(Sidebar *)sidebar didTapItemAtIndex:(NSUInteger)index;
- (void)sidebar:(Sidebar *)sidebar didEnable:(BOOL)itemEnabled itemAtIndex:(NSUInteger)index;
@end

@interface Sidebar : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView         *table;
}

@property (nonatomic, assign) CGFloat width;

// The duration of the show and hide animations
// Default 0.25
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, strong) NSMutableArray *contentUsers;

@property (nonatomic, strong) UIImageView *blurView;

@property (nonatomic, weak) id <SidebarDelegate> delegate;

- (void)show;
@end
