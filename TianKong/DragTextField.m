//
//  DragTextField.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 4/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DragTextField.h"
#import "UIView-Transform.h"
#import "MySingleton.h"

const int KEYBOARD_Y_POS = 250;
const int TF_SUGGESTED_POS_BY_KEYBOARD = 200;

@implementation DragTextField

- (id)initWithFrame:(CGRect)frame inputStr:(NSString *)myStr andLink:(NSString*)myLink andTitle:(NSString*)myTitle
{
    //min size
    self = [super initWithFrame:frame];
    
    if (self) {
        //reset share menu
        UIMenuController * menu = [UIMenuController sharedMenuController];
        NSMutableArray *options = [NSMutableArray array];
        [menu setMenuItems:options];
        
        //setup textLabel
        title = [[NSString alloc] initWithFormat:@"%@", myTitle];
        link = [[NSString alloc] initWithFormat:@"%@", myLink];
        
        // Reset geometry to identities
        self.transform = CGAffineTransformIdentity;
        tx = 0.0f; ty = 0.0f; scale = 1.0f;	theta = 0.0f;
        
        self.text = myStr;
        
        [self refreshFrame];
        
        [self viewDefaultSetting];
        
        //testing
        [self showDetail];
        
        //keyboard init
        movedUp = false;
    
        return self;
        
    }
    return self;
    
}

- (id)initWithFrame:(CGRect)frame inputStr:(NSString *)myStr andFrame:(CGRect)rect andBounds:(CGRect)myBounds andLink:(NSString*)myLink andTitle:(NSString*)myTitle andScale:(CGFloat)myScale andTheta:(CGFloat)myTheta
{
    self = [super initWithFrame:frame];
    
    if (self) {
        //reset share menu
        UIMenuController * menu = [UIMenuController sharedMenuController];
        NSMutableArray *options = [NSMutableArray array];
        [menu setMenuItems:options];
        
        //setup textLabel
        title = [[NSString alloc] initWithFormat:@"%@", myTitle];
        link = [[NSString alloc] initWithFormat:@"%@", myLink];
        
        // Reset geometry to identities
        self.transform = CGAffineTransformIdentity;
        tx = 0.0f; ty = 0.0f; scale = 1.0f;	theta = 0.0f;
        
        self.text = myStr;
        
        [self refreshFrame];
        
        [self viewDefaultSetting];
        
        //testing
        [self showDetail];
        
        //keyboard init
        movedUp = false;
        
        return self;
    }
    return self;
}


- (void) refreshFrame{
    NSLog(@"refreshFrame here");
}


- (void) viewDefaultSetting{
    //keyboard init
    self.delegate = self;
    
    //TextField Setting here
    self.borderStyle = UITextBorderStyleRoundedRect;
    self.font = [UIFont systemFontOfSize:50];
    self.adjustsFontSizeToFitWidth = true;
    MySingleton* singleton = [MySingleton getInstance];
    NSString* askInputText = NSLocalizedStringFromTableInBundle(@"askInputText", nil, singleton.globalLocaleBundle, nil);
    self.placeholder = askInputText;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.returnKeyType = UIReturnKeyDone;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textAlignment = NSTextAlignmentCenter;
    
    //change border color
    self.layer.cornerRadius=8.0f;
    self.layer.masksToBounds=YES;
    self.layer.borderColor=[[UIColor blackColor]CGColor];
    self.layer.borderWidth= 1.0f;
    
    // Initialization code
    self.userInteractionEnabled = YES;
    
    // Add gesture recognizer suite
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    UITapGestureRecognizer *doubletapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubletapGesture.numberOfTapsRequired = 1;
    doubletapGesture.numberOfTapsRequired = 2;
    //UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    //self.gestureRecognizers = @[pan, doubletapGesture, longPressGesture];
    self.gestureRecognizers = @[pan, doubletapGesture];
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) recognizer.delegate = self;
    
    //init selecting dash border
    /*
    dashBorder = [CAShapeLayer layer];
    dashBorder.strokeColor = [UIColor colorWithRed:67/255.0f green:37/255.0f blue:83/255.0f alpha:1].CGColor;
    dashBorder.fillColor = nil;
    dashBorder.lineDashPattern = @[@4, @2];
    */
    
    //init
    status = @"normal";
    [self.layer addSublayer:dashBorder];
    [self offHighLight];
    [self refreshBorder];
    
    //btn always on top
    [self toLayerTop];
}

//disable magnifying glass
-(void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    //Prevent zooming but not panning
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
    {
        gestureRecognizer.enabled = NO;
    }
    [super addGestureRecognizer:gestureRecognizer];
    return;
}


- (NSString *) getLINK{
    return link;
}
- (NSString *) getTITLE{
    return title;
}

- (CGFloat) getSCALE{
    return scale;
}

- (CGFloat) getTHETA{
    return theta;
}

- (NSString *) getSTR{
    return self.text;
}

- (NSString *) getSTATUS{
    return status;
}


-(void) restoreOriginal
{
    NSLog(@"Restore");
    [self offHighLight];
    status = @"normal";
}

- (void) refreshBorder{
    //refresh border
    /*
    dashBorder.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    dashBorder.frame = self.bounds;
    */
}

- (void) onHighLight{
    [self refreshBorder];
    //on border
    //dashBorder.hidden = false;
}

- (void) offHighLight{
    //dashBorder.hidden = true;
}

//Gesture touch for selection (drag and resize)
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchBegan");
    if ([status isEqual: @"normal"]){
        //btn always on top
        [self toLayerTop];
        
        NSLog(@"touchBegan");
        int numOfFingers = (int)[[event allTouches]count];
        if (numOfFingers==1){
            [self performSelector:@selector(noticeOnSelected) withObject:nil];
            status = @"readyForDrag";
            [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
            [self onHighLight];
            
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
     NSLog(@"touchEnd");
}

//Gesture for drag
- (void) handlePan: (UIPanGestureRecognizer *) recognizer
{
    NSLog (@"handlePan = %@", status );
    if ([status isEqual: @"readyForDrag"]){
        
        [self onHighLight];
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
        
        CGPoint translation = [recognizer translationInView:self.superview];
        CGPoint newPT = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
        
        //only move if center does not exceed containView
        if (CGRectContainsPoint(self.superview.frame, newPT)){
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                                 recognizer.view.center.y + translation.y);
            
            [recognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
        }
        
        [self performSelector:@selector(noticeDragging) withObject:nil afterDelay:0.001];
        
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            NSLog(@"End Pan");
            [self restoreOriginal];
            [self performSelector:@selector(cancelAllViewSelections) withObject:nil];
        }
    }
}

//Gesture update
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

//Gesture for tab, shows menu
- (void)handleDoubleTapGesture:(UITapGestureRecognizer*)tapPress {
    NSLog(@"handleDoubleTapGesture - status = %@", status);
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    if ([status isEqual: @"readyForDrag"]){
        //btn always on top
        [self toLayerTop];
        
        [self performSelector:@selector(cancelAllViewSelections) withObject:nil];
        status = @"normal";
    }
    
    if ([status isEqual: @"normal"]){
        //if it is originally in readyForDrag
        //[self performSelector:@selector(cancelAllViewSelections) withObject:nil];
        status = @"inMenu";
        [self becomeFirstResponder];
    }
}

- (void) showMenu {
    NSLog(@"showMenu - status = %@", status);
    MySingleton* singleton = [MySingleton getInstance];
    NSString* linkText = NSLocalizedStringFromTableInBundle(@"linkText", nil, singleton.globalLocaleBundle, nil);
    NSString* deleteText = NSLocalizedStringFromTableInBundle(@"deleteText", nil, singleton.globalLocaleBundle, nil);
    
    UIMenuController * menu = [UIMenuController sharedMenuController];
    NSMutableArray *options = [NSMutableArray array];
    UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:linkText action:@selector(openLink)];
    if (![link  isEqual: @"noCallLink"])
        [options addObject:item2];
    
    //delete
    UIMenuItem *item4 = [[UIMenuItem alloc] initWithTitle:deleteText action:@selector(delete)];
    [options addObject:item4];
    [menu setMenuItems:options];
    
    //if menu not yet appears
    if ([self canBecomeFirstResponder]){
        [menu setTargetRect:self.frame inView:self.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}


/*
- (void)handleLongPressGesture:(UILongPressGestureRecognizer*)longPress {
    if (longPress.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Long press Ended .................");
    }
    else {
        NSLog(@"Long press detected .....................status = %@", status);
        if ([status isEqual: @"normal"]){
            //btn always on top
            [self toLayerTop];
            
            NSLog(@"handleLongPressGesture status %@=", status);
            [self performSelector:@selector(noticeOnSelected) withObject:nil];
            [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
            [self onHighLight];
            status = @"readyForDrag";   //must after notice on selected
        }
    }
}
*/

//For share menu
/*
- (BOOL)canBecomeFirstResponder {
    return YES;
}
*/

//For share menu
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL result = NO;
    if(@selector(delete) == action || @selector(openLink) == action) {
        result = YES;
    }
    return result;
}


//For share menu - it is called when the menu is open.
- (BOOL)becomeFirstResponder
{
    NSLog(@"becomeFirstResponder");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignFirstResponder) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    return [super becomeFirstResponder];
}

//For share menu - it is called when the menu is closed.
- (BOOL)resignFirstResponder
{
    NSLog(@"resignFirstResponder status = %@",status);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    // custom cleanup code here (e.g. deselection)
    if ([status isEqual: @"inMenu"]){
        NSLog(@"resignFirstResponder - In menu");
        status = @"typing";
        //[self restoreOriginal];
    }else if ([status isEqual: @"typing"]){
        status = @"canClose";
        //reset share menu
        UIMenuController * menu = [UIMenuController sharedMenuController];
        NSMutableArray *options = [NSMutableArray array];
        [menu setMenuItems:options];
    }
    
    return [super resignFirstResponder];
}

-(void) openLink
{
    //[self.delegate callPopOverWebViewControllerByDragLabel:self];
    [self restoreOriginal];
    [self performSelector:@selector(cancelAllViewSelections) withObject:nil];
    
}

-(void) toLayerTop
{
    [self.superview bringSubviewToFront:self];
}

-(void) delete
{
    NSLog(@"delete");
    [self performSelector:@selector(cancelAllViewSelections) withObject:nil];
    self.hidden = YES;
    [self performSelector:@selector(noticeRemove) withObject:nil afterDelay:0.001];
}

//for testing
-(void) showDetail{
    NSLog(@"My DTF frame: %@", NSStringFromCGRect(self.frame));
    NSLog(@"My DTF bounds: %@", NSStringFromCGRect(self.bounds));
}


-(void)noticeRemove{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewRemoved"   //ViewRemoved
                                                        object:self
                                                      userInfo:nil];
}

-(void)noticeOnSelected{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noticeOnSelectedFromObj"    //ReadyForResize
                                                        object:self
                                                      userInfo:nil];
}

-(void)noticeDragging{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noticeDraggingFromObj" //RefreshControlBtnPosition
                                                        object:self
                                                      userInfo:nil];
}

-(void)cancelAllViewSelections{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelAllViewSelections" //NotTouched
                                                        object:self
                                                      userInfo:nil];
}


//not work after becomefirstresponder
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldBeginEditing");
    if ([status isEqual: @"inMenu"]){
        if (self.frame.origin.y >= KEYBOARD_Y_POS && !movedUp){
            originalY = self.frame.origin.y;
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3]; // if you want to slide up the view
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
            CGRect rect = self.frame;
            rect.origin.y = TF_SUGGESTED_POS_BY_KEYBOARD;
            self.frame = rect;
            [UIView commitAnimations];
            movedUp = true;
            
            NSLog(@"textFieldShouldBeginEditing - originalY = %d", originalY);
        }else if (self.frame.origin.y < KEYBOARD_Y_POS && !movedUp){
            NSLog(@"SHOW NOT SHOW - originalY = %d", originalY);
            
            originalY = self.frame.origin.y;
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3]; // if you want to slide up the view
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
            CGRect rect = self.frame;
            rect.origin.y = self.frame.origin.y+0.001;
            self.frame = rect;
            [UIView commitAnimations];
            movedUp = true;
            
            NSLog(@"textFieldShouldBeginEditing - originalY = %d", originalY);
        }
        
        return YES;
    }
    return NO;
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // set up the second animation here
    NSLog(@"animationDidStop");
    
    //delay sec to show menu
    [self showMenu];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");

}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing = status = %@ movedUp =%d",status, movedUp);
    
    if ([status isEqual: @"normal"] || [status isEqual: @"canClose"]){
        if (movedUp){
            NSLog(@"textFieldShouldEndEditing- movedUp - original Y = %d",originalY);
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3]; // if you want to go back original place
            CGRect rect = self.frame;
            rect.origin.y = originalY;
            self.frame = rect;
            [UIView commitAnimations];
            movedUp = false;
        }
        status = @"normal";
        NSLog(@"textFieldShouldEndEditing(END-YES) = status = %@ movedUp =%d",status, movedUp);
        return YES;
    }
    NSLog(@"textFieldShouldEndEditing(END-NO) = status = %@ movedUp =%d",status, movedUp);
    return NO;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldDidEndEditing");

}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSLog(@"textField");
    NSLog(@"textField status = %@",status);
    NSLog(@"range.length = %lu",(unsigned long)range.length);
    NSLog(@"range.location = %lu",(unsigned long)range.location);
    NSLog(@"textField.text.length = %lu",(unsigned long)textField.text.length);
    [self showDetail];
    if(textField.text.length >= MAX_TF_CHAR && range.length == 0){
        return NO;
    }
    
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    NSLog(@"textFieldShouldClear");
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn");
    status = @"canClose";
    [self endEditing:YES];
    [self resignFirstResponder];
    
    return YES;
}



@end
