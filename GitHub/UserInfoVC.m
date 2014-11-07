//
//  UserInfoVC.m
//  GitHub
//
//  Created by Евгений Богомолов on 06.11.14.
//  Copyright (c) 2014 Евгений Богомолов. All rights reserved.
//

#import "UserInfoVC.h"

@interface UserInfoVC () <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UILabel            *login;
    IBOutlet UIImageView        *imageView;
    IBOutlet UITableView        *repoTable;
    
    NSArray                     *repoData;
}
@end

@implementation UserInfoVC

@synthesize user = _user;
@synthesize img;

-(void)viewDidLoad
{
    
    self.title = [_user valueForKey:@"login"];
    login.text = [_user valueForKey:@"login"];
    [imageView setImage:img];
    
//    NSLog(@"user info %@", _user);
    
    repoTable.delegate = self;
    repoTable.dataSource = self;
    repoTable.backgroundColor = [UIColor clearColor];
    repoTable.separatorStyle = UITableViewCellSeparatorStyleNone;


    NSLog(@"Nav controller %@ item %@", [self navigationController], [self navigationItem]);
 
    [self getRepos];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) bringSublayerToFront:(CALayer *)layer
{
//    [layer removeFromSuperlayer];
//    [self.view insertSublayer:layer atIndex:[self.view.subviews count]];
}

#pragma mark - Network
- (void)getRepos
{
    NSURL *url = [NSURL URLWithString:[_user valueForKey:@"repos_url"]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:req delegate:self];
    [connection start];
    
    // send request
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil) {
             //             [self handleRequest:data];
             NSError *err = nil;
             id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
             if (err) {
                 
                 NSLog(@"Error %@", json);
             } else {
//                 NSLog(@"Recive req count %ld %@", [json count], json);
                 if ([json respondsToSelector:@selector(lastObject)]) {
                     
                     repoData = json;
//                     since = [[[json lastObject] objectForKey:@"id"] longValue];
//                     [tableViewData addObjectsFromArray:json];
//                     [refreshControl endRefreshing];
//                     [gitHubTableView.bottomRefreshControl endRefreshing];
                     [repoTable reloadData];
                 } else {
                     NSLog(@"Error %@", json);
                     [[[UIAlertView alloc] initWithTitle:@"Error" message:[json valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                 }
                 
             }
         }
         else if ([data length] == 0 && error == nil)
             NSLog(@"Error no data from request player");
         else if (error != nil && error.code == NSURLErrorTimedOut)
             NSLog(@"Error TimeOut request");
         else if (error != nil)
             NSLog(@"Error %@", error);
         
     }];
    
}
//-(void)setAvatar:(UIImage *)avatar
//{
//    [imageView setImage:avatar];
//}
#pragma mark - Table View
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"repo data count %ld", [repoData count]);
    return [repoData count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.textColor = [UIColor lightTextColor];
    //    cell.detailTextLabel.textColor = [UIColor lightTextColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [[repoData objectAtIndex:[indexPath row]] valueForKey:@"name"];
//    cell.textLabel.text = @"Test test";
//    cell.detailTextLabel.text = @"afsfafa";
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Repositories";
}
@end
