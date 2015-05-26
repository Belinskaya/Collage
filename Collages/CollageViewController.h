//
//  ViewController.h
//  Collages
//
//  Created by Ekaterina Belinskaya on 12/03/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButtonsViewController.h"
#import "ChangingBordersViewController.h"

@interface CollageViewController : UIViewController< UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout,
     UIPopoverPresentationControllerDelegate, ButtonsDelegate, BordersDelegate,UIDocumentInteractionControllerDelegate, UIScrollViewDelegate>


@end

