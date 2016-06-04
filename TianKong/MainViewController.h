//
//  MainViewController.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 10/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UIPopoverControllerDelegate>

//Storyboard declared objects
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *logoutBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *collectionBtn;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *containerView;


//Storyboard Click Action
- (IBAction)handleLogout:(id)sender;
- (IBAction)handleAdd:(id)sender;
- (IBAction)handleRefresh:(id)sender;

//Instance Objects
@property (nonatomic, assign) NSInteger noteCount;
@property (nonatomic, assign) NSArray* noteArray;
@property (nonatomic, retain) NSMutableArray* noteButtonsArray;
@property (nonatomic, retain) UIPopoverController *poc;
@property (nonatomic, assign) CGRect currentClickedRect; //for locating popover controller location
@property (nonatomic, weak) UIMenuController *menu;


-(void)didDismissCollectionViewController;



@end
