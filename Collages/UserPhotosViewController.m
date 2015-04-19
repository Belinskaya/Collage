//
//  UserPhotosViewController.m
//  Collages
//
//  Created by Ekaterina Belinskaya on 14/03/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import "UserPhotosViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ImageCollectionViewCell.h"
#import "InstaEngine.h"
#import "Collage.h"
#import "InstaPhoto.h"


@interface UserPhotosViewController ()
//IB
@property (weak, nonatomic) IBOutlet UICollectionView *selectedPhotosCV;
@property (weak, nonatomic) IBOutlet UICollectionView *userPhotosCollectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

//other property
@property (strong, nonatomic) UIBarButtonItem *btnBack;

@property (nonatomic, strong) Collage *collage;
@property (nonatomic, strong) NSMutableArray *usersPhotos;
@property (nonatomic, strong) InstaEngine *iEngine;

@end

@implementation UserPhotosViewController

NSInteger photoCount = 200;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIColor *collectionViewColor = [UIColor colorWithRed:52.0f/255.0f green:73.0f/255.0f blue:94.0f/255.0f alpha:1.0f];
    UIColor *mainBackgroundColor = [UIColor colorWithRed:103.0f/255.0f green:128.0f/255.0f blue:159.0f/255.0f alpha:1.0f];
    
    self.selectedPhotosCV.backgroundColor = collectionViewColor;
    self.view.backgroundColor = mainBackgroundColor ;
    
    _userPhotosCollectionView.backgroundColor = [UIColor clearColor];
    
    _iEngine = [InstaEngine sharedInstance];
    
    _collage = [Collage sharedInstance];
    
    _usersPhotos = [[NSMutableArray alloc] initWithCapacity:1];
    
    _userPhotosCollectionView.allowsMultipleSelection = YES;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getPhotos:)
                                                 name:@"GotPhotoData"
                                               object:nil];
    NSURL *url = [_iEngine getPhotoSearchURLWith:_userID];
    [_iEngine  getDataWith:url sendNotification:@"GotPhotoData"];
    
    NSString *buttonTitle =  @"Done";
    _btnBack = [[UIBarButtonItem alloc]
                    initWithTitle:buttonTitle
                    style:UIBarButtonItemStyleDone
                    target:self
                    action:@selector(returnToCollage:)];
    [self.navigationItem setRightBarButtonItem: _btnBack];
    
    [_activityIndicator startAnimating];
    [_activityIndicator setHidden:NO];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getPhotos:(NSNotification *)note {
    NSDictionary *theData = [note userInfo];
    
    [_activityIndicator stopAnimating];
    [_activityIndicator setHidden:YES];
    //[self.activityIndicator setHidden:YES];
    if (theData != nil) {
        NSString *nextURL = [[theData objectForKey:@"pagination"] objectForKey:@"next_url"];
        NSMutableArray *ar = [theData objectForKey:@"data"];
        //update collectionvew
        [_userPhotosCollectionView performBatchUpdates:^{
            NSInteger resultsSize = [_usersPhotos count];
            NSMutableArray *newPhotos =[InstaEngine parsePhotos: ar ];
            [_usersPhotos addObjectsFromArray: newPhotos];
            NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
            for (NSInteger i = resultsSize; i < resultsSize + newPhotos.count; i++) {
                [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            [_userPhotosCollectionView insertItemsAtIndexPaths:arrayWithIndexPaths];
        }
                                      completion:nil];
        if ([_usersPhotos count]<photoCount && [nextURL length] != 0) {
            NSURL *url = [[NSURL alloc] initWithString:nextURL];
            [_iEngine getDataWith:url sendNotification:@"GotPhotoData"];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No photos!"
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark UICollectionView - sources
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if (view == _selectedPhotosCV) {
        return [_collage.selectedPhotos count];
    } else if (view == _userPhotosCollectionView){
        return [_usersPhotos count];
    } else return 1;
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //(expression) ? (if true) : (if false);
    NSString *cellIdentifier = (cv == _selectedPhotosCV)?  @"selectedPhoto" : @"UserPhoto";
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    return cell;
}

-(void) collectionView:(UICollectionView *)collectionView willDisplayCell:(ImageCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == _userPhotosCollectionView) {
        cell.layer.borderWidth = 4.0f;
        if (cell.selected){
            cell.layer.borderColor = self.navigationController.navigationBar.tintColor.CGColor;
        } else {
            cell.layer.borderColor = [UIColor clearColor].CGColor;
        }
        InstaPhoto *photo = _usersPhotos[indexPath.row];
        NSURL *url = [photo getThumbnailURL];
     
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
     
        __weak ImageCollectionViewCell *weakCell = cell;
        [weakCell.imageView setImageWithURLRequest:request
                                  placeholderImage: nil
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               weakCell.imageView.contentMode =UIViewContentModeScaleAspectFill;
                                               weakCell.imageView.clipsToBounds = YES;
                                               weakCell.image = image;//newImage;
                                               [weakCell setNeedsLayout];
     
                                           } failure:nil];
     
     } else{
         NSDictionary *photoDict = [_collage.selectedPhotos objectAtIndex:indexPath.row];
         UIImage *image = [photoDict objectForKey:@"smallImage"];
         cell.image = image;
     }

}

#pragma mark Utilities

-(void) returnToCollage: (UIBarButtonItem*)sender{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark UICollectionView - delegates
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageCollectionViewCell *cell =  (ImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (collectionView == _userPhotosCollectionView){
        cell.layer.borderColor = [UIColor whiteColor].CGColor;
        InstaPhoto *photo = _usersPhotos[indexPath.row];
        NSDictionary *photoDictionary = @{@"info": photo, @"smallImage": cell.imageView.image};
        NSInteger index = [_collage.selectedPhotos count];
        NSArray *arrayWithIndexPaths = @[[NSIndexPath indexPathForRow:index inSection:0]];
        [_collage.selectedPhotos addObject:photoDictionary];
        [_selectedPhotosCV insertItemsAtIndexPaths:arrayWithIndexPaths];
    }
    
}
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageCollectionViewCell *cell =  (ImageCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    if (collectionView == _userPhotosCollectionView) {
        cell.layer.borderColor = [UIColor clearColor].CGColor;
        ImageCollectionViewCell *cell =  (ImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        InstaPhoto *photo = _usersPhotos[indexPath.row];
        NSDictionary *photoDictionary = @{@"info": photo, @"smallImage": cell.imageView.image};
        NSInteger index = [_collage.selectedPhotos indexOfObject:photoDictionary];
        NSArray *arrayWithIndexPaths = @[[NSIndexPath indexPathForRow:index inSection:0]];
        [_collage.selectedPhotos removeObject:photoDictionary];
        [_selectedPhotosCV deleteItemsAtIndexPaths:arrayWithIndexPaths];
    }
}

#pragma mark UICollectionView - layouts
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _selectedPhotosCV) {
        return CGSizeMake(50.0f, 50.0f);
    }
    float collectionViewWidth = _userPhotosCollectionView.bounds.size.width -20;
    CGSize mElementSize = CGSizeMake(collectionViewWidth*0.33, collectionViewWidth*0.33);
    return mElementSize;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    /*if (collectionView == self.modesCV){
        NSInteger cellCount = [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:section];
        CGFloat cellWidth = ((UICollectionViewFlowLayout*)collectionViewLayout).itemSize.width+((UICollectionViewFlowLayout*)collectionViewLayout).minimumInteritemSpacing;
        CGFloat totalCellWidth = cellWidth*cellCount;
        CGFloat contentWidth = collectionView.frame.size.width-collectionView.contentInset.left-collectionView.contentInset.right;
        if( totalCellWidth<contentWidth )
        {
            CGFloat padding = (contentWidth - totalCellWidth) / 2.0;
            return UIEdgeInsetsMake(0, padding, 0, padding);
        }
    }*/
    return UIEdgeInsetsMake(5,5,0,5);  // top, left, bottom, right
}

@end
