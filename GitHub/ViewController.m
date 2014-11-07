//
//  ViewController.m
//  GitHub
//
//  Created by Евгений Богомолов on 05.11.14.
//  Copyright (c) 2014 Евгений Богомолов. All rights reserved.
//

#import "ViewController.h"
#import <CCBottomRefreshControl/UIScrollView+BottomRefreshControl.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "RNFrostedSidebar.h"
#import "UserInfoVC.h"

@implementation RNFrostedSidebar (Search)



- (void) setDelagates:(id)object
{
    self.searchBar.delegate = object;
    self.contentView.dataSource = object;
}

@end

@interface ViewController () <RNFrostedSidebarDelegate, UIGestureRecognizerDelegate, UITabBarDelegate, UITableViewDataSource, UISearchBarDelegate> {
    NSMutableArray              *tableViewData;
    NSMutableArray              *last5users;
    NSMutableArray              *searchData;

    BOOL                        isUpdating;
    BOOL                        isSearch;
    
    RNFrostedSidebar            *sideBar;
    IBOutlet UITableView        *gitHubTableView;
    UIRefreshControl            *refreshControl;
    
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"GitHub";
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    
    if (tableViewData == nil) tableViewData = [[NSMutableArray alloc] init];
    if (last5users == nil)      last5users = [[NSMutableArray alloc] init ];
    if (searchData == nil)      searchData = [[NSMutableArray alloc] init ];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
//    [self setRefreshControl:refreshControl];
    UIRefreshControl *butRefresh = [UIRefreshControl new];
    [butRefresh addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    gitHubTableView.bottomRefreshControl = butRefresh;
    gitHubTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [gitHubTableView addSubview:refreshControl];

    sideBar = [[RNFrostedSidebar alloc] initWithTopController:self];
    [sideBar setWidth:200];
    sideBar.delegate = self;
    [sideBar setDelagates:self];
    [sideBar showFromRight];
//    sideBar.itemSize = CGSizeMake(150, 150);
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(showSidePanel:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    
    [self.view addGestureRecognizer:panRecognizer];
    
//    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(getNextBatch)];
//    self.navigationItem.rightBarButtonItem = rightButton;
    [self getNextBatch];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
//    [self getNextBatch];
    
//    UserInfoVC *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"userInfo"];
//    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Base
- (void) showSidePanel:(UIPanGestureRecognizer*)recognizer
{
    [[[recognizer view] layer] removeAllAnimations];
    CGPoint velocity = [recognizer velocityInView:[recognizer view]];

    if([recognizer state] == UIGestureRecognizerStateBegan) {
  
        if(velocity.x > 50 && velocity.y < 300 && velocity.y > -300) {
            if (!sideBar.isFirstResponder) {
                [sideBar show];
            }
        }
        else {
            [sideBar dismissAnimated:YES];
        }
        
    }
    
}

- (void) refreshTable
{
    NSLog(@"refreshTable");

    [self getNextBatch];
}

#pragma mark - FrostedSideBar Delegate
-(void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index
{
    NSLog(@"didTapItemAtIndex %ld", index);
    [sideBar dismissAnimated:NO];

    UserInfoVC *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"userInfo"];
    
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:index];
    
    if (isSearch) {
        [controller setUser:[searchData objectAtIndex:index]];
        [controller setImg:[sideBar.contentView cellForRowAtIndexPath:path].imageView.image];
        
    } else {
        [controller setUser:[last5users objectAtIndex:index]];
        [controller setImg:[sideBar.contentView cellForRowAtIndexPath:path].imageView.image];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)sidebar:(RNFrostedSidebar *)sidebar didDismissFromScreenAnimated:(BOOL)animatedYesOrNo
{
    if (!animatedYesOrNo) {
        
    }
}

#pragma mark - Gesture Recognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Table View Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == gitHubTableView) {
        return [tableViewData count];

    } else {

        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == gitHubTableView) {

        return 0;
    } else {
        
        return 10;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == gitHubTableView) {
        
        return 1;
    } else {
//        NSLog(@"last5users count %ld", [last5users count]);
        if (!isSearch)
            return [last5users count];
        else
            return [searchData count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"index path %ld", [indexPath row]);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    id user;
    if (tableView == gitHubTableView) {
        user = [tableViewData objectAtIndex:[indexPath row]];

    } else {
        if (!isSearch)
            user = [last5users objectAtIndex:[indexPath section]];
        else
            user = [searchData objectAtIndex:[indexPath section]];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.textLabel.textColor = [UIColor lightTextColor];
//    cell.detailTextLabel.textColor = [UIColor lightTextColor];

    cell.textLabel.text = [user objectForKey:@"login"];
    cell.detailTextLabel.text = @"";
//    cell.imageView.image = [UIImage imageNamed:@"help.png"];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[user valueForKey:@"avatar_url"]] placeholderImage:[UIImage imageNamed:@"no-avatar.png"]];
    
    return cell;
}
//-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
//{
//    NSLog(@"scrollViewWillBeginDecelerating");
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath %ld %ld", indexPath.section, indexPath.row);

    if (tableView == gitHubTableView) {
        if ([last5users indexOfObject:[tableViewData objectAtIndex:[indexPath row]]] == NSNotFound) {
            [last5users addObject:[tableViewData objectAtIndex:[indexPath row]]];

        }
        if ([last5users count] > 5) {
            [last5users removeObjectAtIndex:0];
        }
        UserInfoVC *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"userInfo"];
        [self.navigationController pushViewController:controller animated:YES];
        [controller setUser:[tableViewData objectAtIndex:[indexPath row]]];
        [controller setImg:[gitHubTableView cellForRowAtIndexPath:indexPath].imageView.image];
        
    } else {
        NSLog(@"DISSMISS");
//        [sideBar dismissAnimated:NO];
    }
    
}

#pragma mark - Network
- (void)getNextBatch
{
    static long since = 0;
    NSString *strReq = [NSString stringWithFormat:@"https://api.github.com/users?since=%ld",since];
    NSURL *url = [[NSURL alloc] initWithString:strReq];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:req delegate:self];
    [connection start];
    
    // send request
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil) {
             NSError *err = nil;
             id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
             if (err) {
                 
                 NSLog(@"Error %@", json);
             } else {
//                 NSLog(@"Recive req count %ld %@", [json count], json);
                 if ([json respondsToSelector:@selector(lastObject)]) {
                     since = [[[json lastObject] objectForKey:@"id"] longValue];
                     [tableViewData addObjectsFromArray:json];

                     [gitHubTableView reloadData];
                 } else {
                     NSLog(@"Error %@", json);
                     [[[UIAlertView alloc] initWithTitle:@"Error" message:[json valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                 }
                 
                 [refreshControl endRefreshing];
                 [gitHubTableView.bottomRefreshControl endRefreshing];

             }
         }
         else if ([data length] == 0 && error == nil)
             NSLog(@"Error no data from request player");
         else if (error != nil && error.code == NSURLErrorTimedOut)
             NSLog(@"Error TimeOut request");
         else if (error != nil)
             NSLog(@"Error %@", error);
         
         isUpdating = NO;
     }];
}

#pragma mark - Search Bar Delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
//    NSLog(@"textDidChange");
    if (searchText.length == 0) {
        isSearch = NO;
        [sideBar.contentView reloadData];
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    isSearch = NO;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Start search");
    [searchBar endEditing:YES];
    
    NSString *strReq = [NSString stringWithFormat:@"https://api.github.com/search/users?q=%@",searchBar.text];
    NSURL *url = [[NSURL alloc] initWithString:strReq];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:req delegate:self];
    [connection start];
    
    // send request
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil) {
             NSError *err = nil;
             id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
             if (err) {
                 
                 NSLog(@"Error %@", json);
             } else {
//                 NSLog(@"Recive req count %ld %@", [json count], json);
                 if ([json respondsToSelector:@selector(objectForKey:)]) {
                     
                     if ([[[json valueForKey:@"total_count"] stringValue] isEqualToString:@"0" ]) {
                         [[[UIAlertView alloc] initWithTitle:@"No Search Results" message:@"Users with such request name does not exist..." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];

                         return ;
                     }
                     [searchData removeAllObjects];
                     [searchData addObjectsFromArray:[json objectForKey:@"items"]];
                     isSearch = YES;
                     [sideBar.contentView reloadData];

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
         
         isUpdating = NO;
     }];
}


#pragma mark - Scroll Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Fades out top and bottom cells in table view as they leave the screen
    NSArray *visibleCells = [gitHubTableView visibleCells];
    
    if (visibleCells != nil  &&  [visibleCells count] != 0) {       // Don't do anything for empty table view
        
        /* Get top and bottom cells */
        UITableViewCell *topCell = [visibleCells objectAtIndex:0];
        UITableViewCell *bottomCell = [visibleCells lastObject];
        
        /* Make sure other cells stay opaque */
        // Avoids issues with skipped method calls during rapid scrolling
        for (UITableViewCell *cell in visibleCells) {
            cell.contentView.alpha = 1.0;
        }
        
        /* Set necessary constants */
        NSInteger cellHeight = topCell.frame.size.height - 1;   // -1 To allow for typical separator line height
        NSInteger tableViewTopPosition = gitHubTableView.frame.origin.y;
        NSInteger tableViewBottomPosition = gitHubTableView.frame.origin.y + gitHubTableView.frame.size.height;
        
        /* Get content offset to set opacity */
        CGRect topCellPositionInTableView = [gitHubTableView rectForRowAtIndexPath:[gitHubTableView indexPathForCell:topCell]];
        CGRect bottomCellPositionInTableView = [gitHubTableView rectForRowAtIndexPath:[gitHubTableView indexPathForCell:bottomCell]];
        CGFloat topCellPosition = [gitHubTableView convertRect:topCellPositionInTableView toView:[gitHubTableView superview]].origin.y;
        CGFloat bottomCellPosition = ([gitHubTableView convertRect:bottomCellPositionInTableView toView:[gitHubTableView superview]].origin.y + cellHeight);
        
        /* Set opacity based on amount of cell that is outside of view */
        CGFloat modifier = 2.5;     /* Increases the speed of fading (1.0 for fully transparent when the cell is entirely off the screen,
                                     2.0 for fully transparent when the cell is half off the screen, etc) */
        CGFloat topCellOpacity = (1.0f - ((tableViewTopPosition - topCellPosition) / cellHeight) * modifier);
        CGFloat bottomCellOpacity = (1.0f - ((bottomCellPosition - tableViewBottomPosition) / cellHeight) * modifier);
        
        /* Set cell opacity */
        if (topCell) {
            topCell.contentView.alpha = topCellOpacity;
        }
        if (bottomCell) {
            bottomCell.contentView.alpha = bottomCellOpacity;
        }
    }
}

@end
