//
//  SearchUsersTableView.m
//  Collages
//
//  Created by Ekaterina Belinskaya on 14/03/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import "SearchUsersTableView.h"
#import "UIImageView+AFNetworking.h"
#import "UserPhotosViewController.h"
#import "InstaEngine.h"
#import "InstaUser.h"
//#import <Accelerate/Accelerate.h>

@interface SearchUsersTableView ()

@property (nonatomic, strong) NSMutableArray *findedUsers;

//UI
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *usersTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityInducator;
@property (strong, nonatomic) UIBarButtonItem *btnBack;
@property (strong, nonatomic) InstaEngine *iEngine;

@end

@implementation SearchUsersTableView

//NSString *userID;
InstaUser *selectedUser;

- (void)viewDidLoad {
    [super viewDidLoad];
    _iEngine = [InstaEngine sharedInstance];
    
    // Do any additional setup after loading the view.
   [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getUsers:)
                                                 name:@"GotUserData"
                                               object:nil];
    
    _usersTableView.backgroundColor = [UIColor clearColor];
    
    NSString *buttonTitle = (_iEngine.isSignedIn)? @"Sign out" : @"Sign In";
    _btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:buttonTitle
                                style:UIBarButtonItemStyleDone
                                target:self
                                action:@selector(signInClicked:)];
    [self.navigationItem setRightBarButtonItem: _btnBack];
    [_activityInducator setHidden:YES];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _btnBack.title = (_iEngine.isSignedIn)? @"Sign out" : @"Sign In";
}


-(void)signInClicked:(UIBarButtonItem*)sender
{
    //sign out
    if (_iEngine.isSignedIn){
        [_iEngine forgetUser];
        _btnBack.title = @"Sign In";
    }
    //sign in
    else {
        [self performSegueWithIdentifier:@"signIn" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)getUsers:(NSNotification *)note {
    NSDictionary *theData = [note userInfo];
    //[self.activityIndicator setHidden: YES];
    if (theData != nil) {
        _findedUsers = [InstaEngine parseUsersWith:theData];
        [_usersTableView reloadData];
        [_activityInducator stopAnimating];
        [_activityInducator setHidden:YES];
    }
}

#pragma mark UITableView - DataSources
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_findedUsers count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView
                      dequeueReusableCellWithIdentifier:@"UserTableCell"];
    InstaUser *user =_findedUsers[indexPath.row];
    cell.textLabel.text = user.fullName;
    cell.imageView.image = [UIImage imageNamed:@"superman-logo"];
    cell.backgroundColor = [UIColor clearColor];
    NSURL *url = [[NSURL alloc] initWithString:user.pictureURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    __weak UITableViewCell *weakCell = cell;
    [cell.imageView setImageWithURLRequest:request
                          placeholderImage: nil//placeholderImage
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       weakCell.imageView.contentMode =UIViewContentModeScaleAspectFill;
                                       weakCell.imageView.clipsToBounds = YES;
                                       weakCell.imageView.image = image;//newImage;
                                       [weakCell setNeedsLayout];
                                       
                                   } failure:nil];
    
    return cell;
}

#pragma mark UITableView - Delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedUser = _findedUsers[indexPath.row];
    //userID = user.userId;
    [self performSegueWithIdentifier:@"showUsersPhotos" sender:self];
}

#pragma mark UISearchBar - Delegates

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [_searchBar resignFirstResponder];
    [_activityInducator setHidden:NO];
    [_activityInducator startAnimating];
    if (searchBar.text.length !=0){
        InstaEngine *engine = [[InstaEngine alloc] init];
        NSURL *url = [ engine getUsersSearchURLWith: searchBar.text];
        [_iEngine getDataWith:url sendNotification:@"GotUserData"];
    }
}

#pragma mark Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showUsersPhotos"]) {
        
        UserPhotosViewController *destView = segue.destinationViewController;
        destView.user = selectedUser;
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
