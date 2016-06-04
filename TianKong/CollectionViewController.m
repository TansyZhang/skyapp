//
//  CollectionViewController.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 12/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "CollectionViewController.h"
#import "MySingleton.h"

const int MAX_NUMBER_OF_COLLECTION = 8;

@interface CollectionViewController ()

@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //get singleton
    MySingleton* singleton = [MySingleton getInstance];
    
    //localication
    NSString* backText = NSLocalizedStringFromTableInBundle(@"Back", nil, singleton.globalLocaleBundle, nil);
    self.backBtn.title = [NSString stringWithFormat:@"< %@ %@", singleton.globalUserName, backText];
    
    //set background image
    //NSString* imageName= NSLocalizedStringFromTableInBundle(@"mainViewBG", nil, singleton.globalLocaleBundle, nil);
    //self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    //self.backgroundView.alpha = 0.1f;
    [self.view sendSubviewToBack:self.backgroundView];
    
    [self showCollections];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleBack:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NoteViewControllerDismissed"
                                                        object:nil
                                                      userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showCollections{
    for(int i =0; i < MAX_NUMBER_OF_COLLECTION; i++){
        // create button object
        
        //-------------------------------------------------------------------------------------//
        //-----------------------------------------localization--------------------------------//
        //-------------------------------------------------------------------------------------//
        //MySingleton* singleton = [MySingleton getInstance];
        //NSString* editText = NSLocalizedStringFromTableInBundle(@"editText", nil, singleton.globalLocaleBundle, nil);
        //-------------------------------------------------------------------------------------//
        //-----------------------------------------localization--------------------------------//
        //-------------------------------------------------------------------------------------//
        
        UIButton * button =[UIButton buttonWithType:UIButtonTypeSystem];
        button.enabled=NO;
        
        //set button size
        [button sizeToFit];
        CGRect buttonFrame =button.frame;
        buttonFrame.size=CGSizeMake(200, 250);
        button.frame=buttonFrame;
        
        //set background image
        [button setBackgroundImage:[UIImage imageNamed:@"scissor_black.png"] forState:UIControlStateNormal];
        
        // set button center
        button.center=CGPointMake(140+250*(i%4),240+320*(i/4));
        
        //set number label size and location
        UILabel * numLabel = [[UILabel alloc] init]; //(x,y,w,h)
        [numLabel sizeToFit];
        CGRect labelFrame = numLabel.frame;
        labelFrame.size=CGSizeMake(200, 30);
        numLabel.frame = labelFrame;
        numLabel.center=CGPointMake(140+250*(i%4),100+320*(i/4));
        
        //set number label feature
        numLabel.backgroundColor = [UIColor clearColor];
        numLabel.textAlignment = NSTextAlignmentRight;
        numLabel.textColor=[UIColor blackColor];
        numLabel.text = [NSString stringWithFormat:@"%@ %d", @"NO. ", i+1];
        
        
        //set name label size and location
        UILabel * nameLabel = [[UILabel alloc] init]; //(x,y,w,h)
        [nameLabel sizeToFit];
        CGRect nameFrame = nameLabel.frame;
        nameFrame.size=CGSizeMake(200, 30);
        nameLabel.frame = nameFrame;
        nameLabel.center=CGPointMake(140+250*(i%4),380+320*(i/4));
        
        //set name label feature
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.textColor=[UIColor blackColor];
        nameLabel.text = [NSString stringWithFormat:@"%@ %d", @"NAME", i+1];
        nameLabel.alpha = 0.0f;
        
        
        //hard-code for demo
        if(i==7){
            [button setBackgroundImage:[UIImage imageNamed:@"scissor.png"] forState:UIControlStateNormal];
            nameLabel.text = @"Scissor";
            nameLabel.alpha = 1;
        }
        
        //add objects to UIView
        [self.view addSubview:numLabel];
        [self.view addSubview:nameLabel];
        [self.view addSubview:button];
    }

}

@end
