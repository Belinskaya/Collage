//
//  ViewController.m
//  Collages
//
//  Created by Ekaterina Belinskaya on 12/03/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import "CollageViewController.h"
#import "Collage.h"
#import "ImageCollectionViewCell.h"
#import "SearchUsersTableView.h"
#import "InstaPhoto.h"
#import "InstaEngine.h"
#import "UIImageView+AFNetworking.h"
#import "InstagramActivity.h"


@interface CollageViewController ()
//Collection Views
@property (weak, nonatomic) IBOutlet UICollectionView *selectedPhotoCV;
@property (weak, nonatomic) IBOutlet UICollectionView *modesCV;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionnButton;

//Collages
@property (strong, nonatomic) Collage *collage;
@property (weak, nonatomic) IBOutlet UIView *collageFrame;


//Other properties
@property BOOL isFreeForm;
@property (weak, nonatomic) UIImageView *movingImage;
@property (strong, nonatomic) UIImageView *movingCell;
@property (strong, nonatomic) NSMutableArray *templates;
@property (nonatomic, strong) UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionBarButton;
@property (strong, nonatomic) UIBarButtonItem *moreButton;
@property (strong, nonatomic) ButtonsViewController *btnController;
@property (strong, nonatomic) ChangingBordersViewController *changingBorderController;
@property (strong, nonatomic) InstaEngine *iEngine;
@property (retain)UIDocumentInteractionController *documentController;

@end

@implementation CollageViewController

#pragma mark Variables
NSInteger photoIndex;
NSInteger selectedPhotoCount;
NSInteger borderWidth;
float borderConer;


- (void)viewDidLoad {
    [super viewDidLoad];
     _iEngine = [InstaEngine sharedInstance];
    // Do any additional setup after loading the view, typically from a nib.
    
    _isFreeForm = YES;
    borderWidth = 3;
    borderConer = 0;
    
    UIColor *collectionViewColor = [UIColor colorWithRed:52.0f/255.0f green:73.0f/255.0f blue:94.0f/255.0f alpha:1.0f];
    UIColor *mainBackgroundColor = [UIColor colorWithRed:103.0f/255.0f green:128.0f/255.0f blue:159.0f/255.0f alpha:1.0f];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [_selectedPhotoCV setCollectionViewLayout:flowLayout];
    //add Long Press Recognizer
    UILongPressGestureRecognizer *lpgr= [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .1; //seconds
    lpgr.delegate = self;
    [_selectedPhotoCV addGestureRecognizer: lpgr];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createNewImage:)];
    tap.numberOfTapsRequired = 2;
    [_collageFrame addGestureRecognizer:tap];
    [_collageFrame addSubview:_movingImage];

    
    UICollectionViewFlowLayout *flowLayoutForModes = [[UICollectionViewFlowLayout alloc] init];
    [flowLayoutForModes  setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [_modesCV setCollectionViewLayout:flowLayoutForModes];

    self.view.backgroundColor = mainBackgroundColor;
    
    _modesCV.backgroundColor = collectionViewColor;
    _selectedPhotoCV.backgroundColor = collectionViewColor;
    
    
    _collageFrame.backgroundColor = mainBackgroundColor ;//[UIColor whiteColor];//lightGrayColor
    _collageFrame.layer.borderColor = [UIColor whiteColor].CGColor;
    _collageFrame.layer.borderWidth = 1.0f;
    
    _collage = [Collage sharedInstance];
    selectedPhotoCount = [_collage.selectedPhotos count];
    
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"collage_templates" ofType:@"txt"];
    
    //création d'un string avec le contenu du JSON
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    NSAssert(myJSON, @"File collage_templates.txt couldn't be read!");
    
    NSData *data = [myJSON dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *dict =[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    _templates =[[NSMutableArray alloc] initWithCapacity:4];
    
    for (NSDictionary *i in [[dict objectForKey:@"collage_templates"] objectForKey:@"templates"]) {
        [_templates addObject:i];
    }
    //[self.navigationItem setLeftBarButtonItems:<#(NSArray *)#>]
    
    self.navigationItem.leftItemsSupplementBackButton = YES;
    _moreButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"More.tiff"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(showPopover:)];
    self.navigationItem.rightBarButtonItems = @[ _addButton, _moreButton];
    
    
    //-----upper line
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake( 0, _selectedPhotoCV.frame.origin.y + _selectedPhotoCV.frame.size.height )];
    [path addLineToPoint:CGPointMake( self.view.frame.size.width, _selectedPhotoCV.frame.origin.y + _selectedPhotoCV.frame.size.height)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor grayColor] CGColor];
    shapeLayer.lineWidth = 1.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.view.layer addSublayer:shapeLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
    for (NSInteger i = selectedPhotoCount; i < [_collage.selectedPhotos count]; i++) {
        [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [_selectedPhotoCV insertItemsAtIndexPaths:arrayWithIndexPaths];
    selectedPhotoCount =[_collage.selectedPhotos count];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //------lower liner
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    [path2 moveToPoint:CGPointMake( 0, _modesCV.frame.origin.y)];
    [path2 addLineToPoint:CGPointMake( self.view.frame.size.width, _modesCV.frame.origin.y )];
    CAShapeLayer *shapeLayer2 = [CAShapeLayer layer];
    shapeLayer2.path = [path2 CGPath];
    shapeLayer2.strokeColor = [[UIColor grayColor] CGColor];
    shapeLayer2.lineWidth = 1.0;
    shapeLayer2.fillColor = [[UIColor clearColor] CGColor];
    [self.view.layer addSublayer:shapeLayer2];
}

-(void)showPopover:(UIBarButtonItem*)sender{
    if(!_btnController){
        _btnController = [[ButtonsViewController alloc] init];
        _btnController.delegate = self;
    }
    if (_popover == nil) {
        _btnController.modalPresentationStyle = UIModalPresentationPopover;
        UIPopoverPresentationController *pc = [ _btnController popoverPresentationController];
        pc.barButtonItem = sender;
        pc.permittedArrowDirections = UIPopoverArrowDirectionAny;
        pc.delegate = self;
        [self presentViewController: _btnController animated:YES completion:nil];
    } else {
        //The color picker popover is showing. Hide it.
        [_popover dismissPopoverAnimated:YES];
        _popover = nil;
    }
    
}


- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

-(void)showBordersPopover:(id)sender{
    [self dismissViewControllerAnimated:NO completion:nil];
    _popover = nil;
    if(!_changingBorderController){
        _changingBorderController = [[ChangingBordersViewController alloc] init];
        _changingBorderController.delegate = self;
    }
    if (_popover == nil) {
        _changingBorderController.modalPresentationStyle = UIModalPresentationPopover;
        UIPopoverPresentationController *pc = [ _changingBorderController popoverPresentationController];
        pc.barButtonItem = _moreButton;
        pc.permittedArrowDirections = UIPopoverArrowDirectionAny;
        pc.delegate = self;
        [self presentViewController: _changingBorderController animated:NO completion:nil];
    } else {
        //The color picker popover is showing. Hide it.
        [_popover dismissPopoverAnimated:YES];
        _popover = nil;
    }
}

-(void)changeBordersWidth:(UISlider *)sender{
    for (id i in _collageFrame.subviews) {
        if( [i isKindOfClass:[UIScrollView class]]){
            UIScrollView *scroll= i;
            scroll.layer.borderWidth = sender.value;
        }
    }
    borderWidth = sender.value;
}

-(void) changeConerRadius:(UISlider *)sender{
    for (id i in _collageFrame.subviews) {
        if( [i isKindOfClass:[UIScrollView class]]){
            UIScrollView *scroll= i;
            float maxRadius = scroll.frame.size.height/2;
            borderConer = sender.value*maxRadius/100;
            scroll.layer.cornerRadius = borderConer;
        }
    }
}

#pragma mark Gesture Recognizer Selectors

-(void)createNewImage:(UITapGestureRecognizer *) gesture{
    if (_isFreeForm){
        CGPoint locationPointInCollageView = [gesture locationInView:_collageFrame];
        float width = (_collageFrame.bounds.size.width - 5)/2;
        CGRect frame = CGRectMake(locationPointInCollageView.x, locationPointInCollageView.y, width, width);
        UIImageView *newImage = [[UIImageView alloc] initWithFrame:frame];
        newImage.layer.borderWidth = 5.0f;
        newImage.layer.borderColor = [UIColor whiteColor].CGColor;
        [newImage setUserInteractionEnabled:YES];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveImageInCollage:)];
        pan.delegate = self;
        [newImage addGestureRecognizer:pan];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bringSubviewToFront:)];
        tap.delegate = self;
        [newImage addGestureRecognizer: tap];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseFromLibrary:)];
        doubleTap.numberOfTapsRequired = 2;
        [newImage addGestureRecognizer:doubleTap];
        [_collageFrame addSubview:newImage];
        newImage.center = locationPointInCollageView;
        _movingImage = newImage;
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Select image from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"From library",@"From camera",  nil] ;
        
        [action showInView:self.view];
    }
}

-(void) handleLongPress:(UILongPressGestureRecognizer *)longRecognizer{
    //позиция в collectionView
    CGPoint locationPointInCollection = [longRecognizer locationInView:_selectedPhotoCV];
    //позиция на экране
    CGPoint locationPointInView = [longRecognizer locationInView:self.view];
    
    if (longRecognizer.state == UIGestureRecognizerStateBegan) {
        
        NSIndexPath *indexPathOfMovingCell = [_selectedPhotoCV indexPathForItemAtPoint:locationPointInCollection];
        photoIndex = indexPathOfMovingCell.row;
        
        NSDictionary *photoDict = [_collage.selectedPhotos objectAtIndex:indexPathOfMovingCell.row];
        UIImage *image = [photoDict objectForKey:@"smallImage"];
        CGRect frame = CGRectMake(locationPointInView.x, locationPointInView.y, 150.0f, 150.0f);
        _movingCell = [[UIImageView alloc] initWithFrame:frame];
        _movingCell.image = image;
        [_movingCell setCenter:locationPointInView];
        _movingCell.layer.borderWidth = 5.0f;
        _movingCell.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.view addSubview:_movingCell];
        
    }
    
    if (longRecognizer.state == UIGestureRecognizerStateChanged) {
        [_movingCell setCenter:locationPointInView];
    }
    
    if (longRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect frameRelativeToParentCollageFrame = [_collageFrame convertRect:_collageFrame.bounds
                                                                           toView:self.view];
        if (CGRectContainsPoint( frameRelativeToParentCollageFrame, _movingCell.center)){
            if (_isFreeForm){
                CGPoint originInCollageView = [_collageFrame convertPoint:_movingCell.center fromView:self.view];
                float width = (_collageFrame.bounds.size.width - 5)/2;
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
                [self holdInContainer:imgView];
                [self tuneImageView:imgView withCenterPont: originInCollageView];
                [_collageFrame addSubview:imgView];
                [_collageFrame bringSubviewToFront:imgView];
                //[self.movingCell removeFromSuperview];
            } else{
                NSInteger s_i = 0;
                for (id i in _collageFrame.subviews){
                    if( [i isKindOfClass:[UIScrollView class]]){
                        UIScrollView *tmpScroll = (UIScrollView *)i;
                        CGRect frameRelativeToParent= [tmpScroll convertRect: tmpScroll.bounds
                                                                                           toView:self.view];
                        NSInteger img_i = 0;
                        
                        if (CGRectContainsPoint( frameRelativeToParent, _movingCell.center)){
                            for (id y in tmpScroll.subviews){
                                if( [y isKindOfClass:[UIImageView class]]){
                                    UIImageView *imgView = y;
                                    if (imgView.tag!=0){
                                        [self holdInContainer:imgView];
                                        [_movingCell removeFromSuperview];
                                    }
                                    img_i+=1;
                                }
                            }
                        }
                        s_i+=1;
                        
                    }
                }
            }
        }
        else{
            [_movingCell removeFromSuperview];
        }
    }
}

-(void)bringSubviewToFront:(UITapGestureRecognizer *) gesture{
    CGPoint locationPointInView = [gesture locationInView:_collageFrame];
    for (UIView *i in _collageFrame.subviews){
        if([i isKindOfClass:[UIImageView class]]){
            UIImageView *img = (UIImageView*)i;
            CGRect frameRelativeToParent = [img convertRect:img.bounds
                                                     toView:_collageFrame];
            if (CGRectContainsPoint( frameRelativeToParent , locationPointInView)){
                _movingImage = (UIImageView*)i;
                [_collageFrame bringSubviewToFront:_movingImage];
            }
        }
    }
}

-(void) moveImageInCollage: (UIPanGestureRecognizer *) gesture{
    CGPoint locationPointInView = [gesture locationInView: _collageFrame];
    CGPoint locationPointInSuperView = [gesture locationInView:self.view];
    if (gesture.state ==  UIGestureRecognizerStateBegan){
        for (UIView *i in _collageFrame.subviews){
            if([i isKindOfClass:[UIImageView class]]){
                UIImageView *img = (UIImageView*)i;
                CGRect frameRelativeToParent = [img convertRect:img.bounds
                                                         toView:_collageFrame];
                if (CGRectContainsPoint( frameRelativeToParent , locationPointInView)){
                    _movingImage = (UIImageView*)i;
                    [_collageFrame bringSubviewToFront:_movingImage];
                }
            }
        }
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGRect frameRelativeToParent = [_movingImage convertRect:_movingImage.bounds
                                                              toView:_collageFrame];
        if (CGRectContainsPoint( frameRelativeToParent , locationPointInView)){
            _movingImage.center =locationPointInView;
        }
    }
    if(gesture.state == UIGestureRecognizerStateEnded){
        CGRect frameRelativeToParent = [_collageFrame convertRect:_collageFrame.bounds
                                                               toView:self.view];
        if (! CGRectContainsPoint( frameRelativeToParent , locationPointInSuperView)){
            [_movingImage removeFromSuperview];
            [_collage.collagePhotos removeObjectAtIndex:_movingImage.tag];
        }
    }
}

-(void)showActionSheet{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Select image from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"From library",@"From camera", @"From Instagram", nil] ;
    
    [action showInView:self.view];
}

-(void)chooseFromLibrary:(UITapGestureRecognizer *) gesture{
    [self showActionSheet];
}

#pragma mark - ActionSheet delegates

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            {UIImagePickerController *pickerView = [[UIImagePickerController alloc] init];
                pickerView.allowsEditing = YES;
                pickerView.delegate = self;
                [pickerView setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                [self presentViewController:pickerView animated:YES completion:nil];
                break;
            }
        case 1:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *pickerView =[[UIImagePickerController alloc]init];
                pickerView.allowsEditing = YES;
                pickerView.delegate = self;
                pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:pickerView animated:YES completion:nil];
                //[self presentModalViewController:pickerView animated:true];
            }
            break;
        }
        case 2:
            if (_iEngine.isSignedIn){
            [self performSegueWithIdentifier:@"openSearch" sender:self];
            } else {
                [self performSegueWithIdentifier:@"SignIn" sender:self];
            }
            break;
        default:
            break;
    }
    // [self performSegueWithIdentifier:@"searchResultsSegue" sender:self];
}

#pragma mark - PickerDelegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage * img = [info valueForKey:UIImagePickerControllerEditedImage];
    _movingImage.image = img;
    [_collage.collagePhotos addObject:img];
    NSDictionary *photoDictionary = @{@"info": [NSNull null], @"smallImage": img};
    [_collage.selectedPhotos addObject:photoDictionary];
}

#pragma mark UICollectionView - sources

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if (view == _selectedPhotoCV) {
        return [_collage.selectedPhotos count];
    } else if (view == _modesCV){
        return [_templates count]+1;
    } else return 0;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    if (cv == _modesCV){
        [cell.imageView setHidden:YES];
        UIView *freeForm = [[UIView alloc] initWithFrame:cell.bounds];
        freeForm.backgroundColor = [UIColor clearColor];
        freeForm.layer.borderWidth = 2.0f;
        freeForm.layer.borderColor = [UIColor whiteColor].CGColor;
        if (indexPath.row == 0) {
            [cell addSubview:freeForm];
        } else {
            NSDictionary *dict = [_templates objectAtIndex: indexPath.row-1];
            NSArray *templ_array = [dict objectForKey:@"small_template"];
            UIBezierPath *path = [UIBezierPath bezierPath];
            for (NSDictionary *d in templ_array) {
                [path moveToPoint:CGPointMake( [[d objectForKey:@"start_x"] floatValue], [[d objectForKey:@"start_y"] floatValue])];
                [path addLineToPoint:CGPointMake( [[d objectForKey:@"end_x"] floatValue], [[d objectForKey:@"end_y"] floatValue])];
            }
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = [path CGPath];
            shapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
            shapeLayer.lineWidth = 2.0;
            shapeLayer.fillColor = [[UIColor clearColor] CGColor];
            [freeForm.layer addSublayer:shapeLayer];
            [cell addSubview:freeForm];
        }
    } else {
        NSDictionary *photoDict = [_collage.selectedPhotos objectAtIndex:indexPath.row];
        UIImage *image = [photoDict objectForKey:@"smallImage"];
        cell.imageView.image = image;
    }
    return cell;
}



#pragma mark UICollectionView - delegates
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell =  [collectionView cellForItemAtIndexPath:indexPath];
    if (collectionView == _modesCV){
        if (indexPath.row == 0 ){
            _isFreeForm = YES;
            [self deleteScrolls];
            [self reesteblishImageViews];
        } else
        {
            _isFreeForm=NO;
            [self deleteScrolls];
            [self deleteUIImageView];
            [self addScrollsWithIndex:indexPath.row];
        }
        cell.layer.borderWidth = 2.0f;
        cell.layer.borderColor = self.navigationController.navigationBar.tintColor.CGColor;
    }
    
}
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell =  [collectionView cellForItemAtIndexPath:indexPath];
    if (collectionView == _modesCV){
        if (indexPath.row == 0 ){
            _isFreeForm = NO;
        } else
        {
            _isFreeForm=YES;
        }
        cell.layer.borderWidth = 0.0f;
    }
}

#pragma mark UICollectionView - layouts
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _selectedPhotoCV) {
        return CGSizeMake(100.0f, 100.0f);
    } else return CGSizeMake(40.0f, 40.0f);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (collectionView == _modesCV) { return 30.0f; }
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (collectionView == _modesCV){
        NSInteger cellCount = [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:section];
        NSIndexPath *index = [[NSIndexPath alloc] initWithIndex:0];
        CGSize size = [self collectionView:_modesCV
                                    layout:collectionViewLayout
                    sizeForItemAtIndexPath: index];
        CGFloat cellWidth = size.width;
        CGFloat totalCellWidth = cellWidth*cellCount +(((UICollectionViewFlowLayout*)collectionViewLayout).minimumInteritemSpacing * (cellCount - 1));
        CGFloat contentWidth = collectionView.frame.size.width-collectionView.contentInset.left-collectionView.contentInset.right;
        if( totalCellWidth<contentWidth )
        {
            CGFloat padding = (contentWidth - totalCellWidth) / 2.0;
            return UIEdgeInsetsMake(0, padding, 0, padding);
        }
    }
    return UIEdgeInsetsMake(0,5,0,5);  // top, left, bottom, right
}

#pragma mark Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"openSearch"]) {
        
        SearchUsersTableView *destView = segue.destinationViewController;
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.0);
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        destView.background= image;
    }
}
#pragma mark Utilities

-(void)addScrollsWithIndex: (NSInteger) index{
    NSDictionary *dict = [_templates objectAtIndex: index-1];
    NSArray *templ_array = [dict objectForKey:@"scrolls"];
    int i =0;
    for (NSDictionary *d in templ_array) {
        float x = [[d objectForKey:@"x"] floatValue];
        float y = [[d objectForKey:@"y"] floatValue];
        float width = [[d objectForKey:@"width"] floatValue];
        float height = [[d objectForKey:@"height"] floatValue];
        CGRect frame = CGRectMake(x, y, width, height);
        
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:frame];
        scroll.backgroundColor = [UIColor clearColor];
        [_collageFrame addSubview:scroll];
        [self tuneScroll:scroll withContentSize:CGSizeMake(width, height) withScrollIndex:i];
        i+=1;
    }
    
}

-(void) deleteScrolls{
    for (id i in _collageFrame.subviews){
        if( [i isKindOfClass:[UIScrollView class]]){
            [i removeFromSuperview];
        }
    }
}

-(void)reesteblishImageViews{
    float x = 75.0f;
    float y = 75.0f;
    float offset = _collageFrame.bounds.size.width/ [_collage.collagePhotos count];
    for (UIImage *img in _collage.collagePhotos){
        float width = (_collageFrame.bounds.size.width - 5)/2;
        UIImageView *newImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        newImageView.image = img;
        [self tuneImageView:newImageView withCenterPont:CGPointMake(x, y)];
        [_collageFrame addSubview:newImageView];
        [_collageFrame bringSubviewToFront:newImageView];
        x += offset;
        y += offset;
    }
}

-(void) deleteUIImageView{
    for (id i in _collageFrame.subviews){
        if( [i isKindOfClass:[UIImageView class]]){
            [i removeFromSuperview];
        }
    }
}

-(void)tuneScroll: (UIScrollView *)scroll withContentSize: (CGSize) size withScrollIndex: (NSInteger) index
{
    float biggestSide = (size.height>size.width)? size.height : size.width;
    scroll.contentSize = CGSizeMake(biggestSide, biggestSide);
    CGRect frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), scroll.contentSize};
    UIImageView *imView = [[UIImageView alloc] initWithFrame: frame];
    //UIScrollView by default contains 2 UIImageViews as subviews for scroll indicators.
    //so we need tag for mark ours
    imView.tag=101;
    //in case wrong array index
    @try {
        imView.image = [_collage.collagePhotos objectAtIndex:index];
    }
    @catch (NSException *exception) {
        //do nothing
    }
    scroll.layer.borderWidth = borderWidth;
    scroll.layer.borderColor = [UIColor whiteColor].CGColor;
    [scroll addSubview:imView];
}

-(void) tuneImageView: (UIImageView *)imageView withCenterPont: (CGPoint) centerPont{

    imageView.center = centerPont;
    [imageView setUserInteractionEnabled:YES];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveImageInCollage:)];
    pan.delegate = self;
    [imageView addGestureRecognizer:pan];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bringSubviewToFront:)];
    tap.delegate = self;
    [imageView addGestureRecognizer: tap];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseFromLibrary:)];
    doubleTap.numberOfTapsRequired = 2;
    [imageView addGestureRecognizer:doubleTap];
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.borderWidth = 5.0f;


}


-(void) holdInContainer: (UIImageView *) container{
    container.alpha = 0.0;
    container.image = _movingCell.image;
    
    //download big imgage's version
    NSDictionary *photoDict = _collage.selectedPhotos[photoIndex];
    id photo = [photoDict objectForKey:@"info"];
    if (photo != [NSNull null]){
        NSURLRequest *request = [NSURLRequest requestWithURL:[photo getStandartResolutionURL]];
        __weak UIImageView *iView = container;
        [iView setImageWithURLRequest:request
                     placeholderImage:nil
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  iView.image = image;
                                  iView.tag = [_collage.collagePhotos count];
                                  [_collage.collagePhotos addObject:image];
                                  [UIView animateWithDuration:1.0f
                                                   animations:^{
                                                       container.alpha = 1.0f;
                                                   }
                                                   completion:nil];
                              }
                              failure:nil];
        //animate disappearance of moving cell
        CGPoint centerPoint = _movingCell.center;
        [UIView animateWithDuration: 0.5f
                         animations:^{CGRect frame = _movingCell.frame;
                             frame.size.width -= frame.size.width - 1.0f;
                             frame.size.height -= frame.size.height -  1.0f;
                             _movingCell.frame = frame;
                             _movingCell.center = centerPoint;}
                         completion:^(BOOL finished){[_movingCell removeFromSuperview]; }];
    } else{
        CGPoint centerPoint = _movingCell.center;
        [UIView animateWithDuration: 0.5f
                         animations:^{ container.alpha = 1.0f;
                             CGRect frame = _movingCell.frame;
                             frame.size.width -= frame.size.width - 1.0f;
                             frame.size.height -= frame.size.height -  1.0f;
                             _movingCell.frame = frame;
                             _movingCell.center = centerPoint;}
                         completion:^(BOOL finished){[_movingCell removeFromSuperview]; }];
    }
}

-(UIImage *) makeImage{
    UIGraphicsBeginImageContextWithOptions(_collageFrame.bounds.size, NO, 0.0);
    [_collageFrame.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark IBActions
- (IBAction)addPhotos:(id)sender {
    [self showActionSheet];
}

- (IBAction)chooseAction:(id)sender {
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    
    [sharingItems addObject:[self makeImage]];
    InstagramActivity *instaActivity = [[InstagramActivity alloc] init];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:[NSArray arrayWithObject:instaActivity]];
    NSArray *excludeActivities = @[
                                   UIActivityTypePostToWeibo,
                                   UIActivityTypePrint,
                                   UIActivityTypeCopyToPasteboard,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToVimeo,
                                   UIActivityTypePostToTencentWeibo];
    
    activityController.excludedActivityTypes = excludeActivities;
    UIActivityViewControllerCompletionWithItemsHandler compl = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        if ([activityType isEqualToString:@"Instagram"]){
            NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            // *.igo is exclusive to instagram
            NSString *saveImagePath = [documentDirectory stringByAppendingPathComponent:@"Image.igo"];
            NSLog(@"saveImagePath  %@", saveImagePath);
            NSData *imageData = UIImagePNGRepresentation([sharingItems objectAtIndex:0]);
            [imageData writeToFile:saveImagePath atomically:YES];
            
            NSURL *instagramURL = [NSURL URLWithString:@"instagram://camera"];
            if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
                _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:saveImagePath]];
                _documentController.UTI = @"com.instagram.photo";
                //_documentController.annotation = [NSDictionary dictionaryWithObject:@"my caption" forKey:@"InstagramCaption"];
                [_documentController presentOpenInMenuFromBarButtonItem:_actionBarButton animated:YES];
            }

        }
    };
    [self presentViewController:activityController animated:YES completion:nil];
    [activityController setCompletionWithItemsHandler: compl];
}


@end
