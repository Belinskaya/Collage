//
//  AlbumContentsViewController.m
//  Collages
//
//  Created by Ekaterina Belinskaya on 22/05/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import "AlbumContentsViewController.h"
#import "ALAsset+ALAssetCategory.h"
#import "ImageCollectionViewCell.h"
#import "InstaEngine.h"
#import "Collage.h"
#import "InstaPhoto.h"

@interface AlbumContentsViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *selectedPhotosCV;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;
@property (strong, nonatomic) NSMutableArray *photos;
@property (nonatomic, strong) InstaEngine *iEngine;
@property (nonatomic, strong) Collage *collage;

@end

@implementation AlbumContentsViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    _iEngine = [InstaEngine sharedInstance];
    _collage = [Collage sharedInstance];
    
    if (self.photos == nil) {
        _photos = [[NSMutableArray alloc] init];
    } else{
        [self.photos removeAllObjects];
    }
    if (self.assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    if (self.groups == nil) {
        _groups = [[NSMutableArray alloc] init];
    } else {
        [self.groups removeAllObjects];
    }
    
    self.photosCollectionView.allowsMultipleSelection = YES;
    //get photos from library
    
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        NSLog(@"%@", errorMessage);
    };
    
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
    
        if ([group numberOfAssets] > 0)
        {
            [self.groups addObject:group];
            ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (result) {
                    [self.photos addObject:result];
                }
            };
            [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
            
        }
        
    };
    
    // enumerate only photos
    NSUInteger groupTypes =  ALAssetsGroupSavedPhotos;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];

}

-(void) viewDidAppear:(BOOL)animated{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    //self.assets = [tmpAssets sortedArrayUsingDescriptors:@[sort]];
    NSMutableArray *tmp=[self.photos copy];
    self.photos = (NSMutableArray *)[tmp sortedArrayUsingDescriptors:@[sort]];
    [super viewDidAppear:animated];
    [_photosCollectionView reloadData];
}

#pragma mark UICollectionView - sources
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if (view == _selectedPhotosCV) {
        return [_collage.selectedPhotos count];
    } else if (view == _photosCollectionView){
        return [_photos count];
    } else return 1;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = (cv == _selectedPhotosCV)?  @"selectedPhoto" : @"photoCell";
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cv== _photosCollectionView){
        ALAsset *assetPhoto = [_photos objectAtIndex:indexPath.row];
        CGImageRef thumbnailImageRef = [assetPhoto thumbnail];
        UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
        
        cell.imageView.image = thumbnail;
        cell.imageView.clipsToBounds = YES;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        if (cell.selected) {
            [cell.selectedImageView setHidden:NO];
        } else{
            [cell.selectedImageView setHidden:YES];
        }
    }
    else{
        
        NSDictionary *photoDict = [_collage.selectedPhotos objectAtIndex:indexPath.row];
        id i = [photoDict objectForKey:@"smallImage"];
        if ([i isKindOfClass:[NSData class]]) {
            cell.image = [UIImage imageWithData:(NSData *) i];
        } else {
            cell.image = (UIImage *) i;
        }
    }
    return cell;
}

#pragma mark UICollectionView - layouts
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _selectedPhotosCV) {
        return CGSizeMake(50.0f, 50.0f);
    }
    float collectionViewWidth = _photosCollectionView.bounds.size.width -20;
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
    return UIEdgeInsetsMake(5,5,0,5);  // top, left, bottom, right
}

#pragma mark UICollectionView - delegates
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageCollectionViewCell *cell =  (ImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (collectionView == _photosCollectionView){
        //get photo by index
        ALAsset *assetPhoto = [_photos objectAtIndex:indexPath.row];
        ALAssetRepresentation *assetRepresentation = [assetPhoto defaultRepresentation];
        
        Byte *buffer = (Byte*)malloc(assetRepresentation.size);
        NSUInteger buffered = [assetRepresentation getBytes:buffer fromOffset:0.0 length: assetRepresentation.size error:nil];
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        //save photo
        NSDictionary *photoDictionary = @{@"info": [NSNull null], @"smallImage": data};
        NSInteger index = [_collage.selectedPhotos count];
        NSArray *arrayWithIndexPaths = @[[NSIndexPath indexPathForRow:index inSection:0]];
        [_collage.selectedPhotos addObject:photoDictionary];
        [_selectedPhotosCV insertItemsAtIndexPaths:arrayWithIndexPaths];
        [cell.selectedImageView setHidden:NO];
    }
    
}
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageCollectionViewCell *cell =  (ImageCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    if (collectionView == _photosCollectionView) {
        [cell.selectedImageView setHidden:YES];
        
        ALAsset *assetPhoto = [_photos objectAtIndex:indexPath.row];
        ALAssetRepresentation *assetRepresentation = [assetPhoto defaultRepresentation];
        
        Byte *buffer = (Byte*)malloc(assetRepresentation.size);
        NSUInteger buffered = [assetRepresentation getBytes:buffer fromOffset:0.0 length: assetRepresentation.size error:nil];
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        
        NSDictionary *photoDictionary = @{@"info": [NSNull null], @"smallImage": data};
        NSInteger index = [_collage.selectedPhotos indexOfObject:photoDictionary];
        NSLog(@"Index %lu", index);
        NSArray *arrayWithIndexPaths = @[[NSIndexPath indexPathForRow:index inSection:0]];
        [_collage.selectedPhotos removeObject:photoDictionary];
        [_selectedPhotosCV deleteItemsAtIndexPaths:arrayWithIndexPaths];
    }
}


@end
