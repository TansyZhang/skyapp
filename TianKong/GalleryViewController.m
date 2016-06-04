//
//  GalleryViewController.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 19/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "GalleryViewController.h"
#import "MySingleton.h"

const int PIC_MAX_LENGTH = 600;

@interface GalleryViewController ()

@end

@implementation GalleryViewController

@synthesize imagePicker;
@synthesize selectedImage;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageView.image = nil;
    self.selectedImage = nil;
    self.saveBtn.enabled = false;
    if (self.imagePicker == nil){
        [self performSelector:@selector(preparePicker) withObject:nil afterDelay:0.3];
    }
}

- (void)preparePicker {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationCurrentContext; // For Full Screen - UIModalPresentationFullScreen
    picker.allowsEditing = YES;
    self.imagePicker = picker;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)handleCamera:(id)sender {
    NSLog(@"handleCamera");
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    });
    
}

- (IBAction)handleAdd:(id)sender {
    NSLog(@"handleAdd");
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    });
    
}

- (IBAction)handleSave:(id)sender {
    NSLog(@"handleSave");
    
    //Also put file into disk
    /*
    NSData *imageData = UIImagePNGRepresentation(selectedImage);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSDate *currentTime = [NSDate date];
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",currentTime]];
    */
    MySingleton* singleton = [MySingleton getInstance];
    singleton.globalImageData = UIImagePNGRepresentation(selectedImage);
    
    //tell Gallery get the image and close this popup
    [self performSelector:@selector(noticeDismiss) withObject:nil afterDelay:0.1];

}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // Code here to work with media
    
    [self dismissViewControllerAnimated:YES completion:nil];
    self.selectedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    self.selectedImage = [self scaleImage:self.selectedImage toResolution:PIC_MAX_LENGTH];         //600 set in storyboard
    self.imageView = [[UIImageView alloc]initWithImage:self.selectedImage];
    [self.view addSubview:self.imageView];
    [self.imageView setCenter:CGPointMake(PIC_MAX_LENGTH/2, PIC_MAX_LENGTH/2)];                    //600/2 set in storyboard
    if (selectedImage == nil){
        self.saveBtn.enabled = false;
    }else{
        //button on
        self.saveBtn.enabled = true;
    }

}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//to scale images without changing aspect ratio
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize {
    
    float width = newSize.width;
    float height = newSize.height;
    
    UIGraphicsBeginImageContext(newSize);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    float widthRatio = image.size.width / width;
    float heightRatio = image.size.height / height;
    float divisor = widthRatio > heightRatio ? widthRatio : heightRatio;
    
    width = image.size.width / divisor;
    height = image.size.height / divisor;
    
    rect.size.width  = width;
    rect.size.height = height;
    
    //indent in case of width or height difference
    float offset = (width - height) / 2;
    if (offset > 0) {
        rect.origin.y = offset;
    }
    else {
        rect.origin.x = -offset;
    }
    
    [image drawInRect: rect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return smallImage;
    
}

- (UIImage *)scaleImage:(UIImage*)image toResolution:(int)resolution {
    NSLog(@"5");
    
    CGImageRef imgRef = [image CGImage];
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    //if already at the minimum resolution, return the orginal image, otherwise scale
    if (width <= resolution && height <= resolution) {
        return image;
        
    } else {
        CGFloat ratio = width/height;
        
        if (ratio > 1) {
            bounds.size.width = resolution;
            bounds.size.height = bounds.size.width / ratio;
        } else {
            bounds.size.height = resolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    [image drawInRect:CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height)];
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"6");
    
    return imageCopy;
}


-(void)noticeDismiss{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GalleryViewControllerDismissed"
                                                        object:nil
                                                      userInfo:nil];
}

@end
