//
//  GalleryViewController.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 19/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBtn;

- (IBAction)handleCamera:(id)sender;
- (IBAction)handleAdd:(id)sender;
- (IBAction)handleSave:(id)sender;

@property (nonatomic) UIImage *selectedImage;
@property (nonatomic) UIImagePickerController *imagePicker;

@end

