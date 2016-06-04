//
//  DragLabel.m
//  getituseit
//
//  Created by Leo Yeung on 30/6/14.
//
//

#import <UIKit/UIKit.h>
#import "DragLabel.h"
#import "UIView-Transform.h"
#import "MySingleton.h"

const int MAX_LABEL_WIDTH = 390;

@implementation DragLabel

- (id)initWithFrame:(CGRect)frame inputStr:(NSAttributedString *)myStr andLink:(NSString*)myLink andTitle:(NSString*)myTitle
{
    //min size
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        //setup textLabel
        title = [[NSString alloc] initWithFormat:@"%@", myTitle];
        link = [[NSString alloc] initWithFormat:@"%@", myLink];
        
        // Reset geometry to identities
        self.transform = CGAffineTransformIdentity;
        tx = 0.0f; ty = 0.0f; scale = 1.0f;	theta = 0.0f;
        
        self.attributedText = myStr;
        
        [self refreshFrame];
        
        [self viewDefaultSetting];
        
        //testing
        [self showDetail];
        
        return self;
        
    }
    return self;

}

- (id)initWithFrame:(CGRect)frame inputStr:(NSAttributedString *)myStr andFrame:(CGRect)rect andBounds:(CGRect)myBounds andLink:(NSString*)myLink andTitle:(NSString*)myTitle andScale:(CGFloat)myScale andTheta:(CGFloat)myTheta
{
    self = [super initWithFrame:myBounds];
    //self = [super initWithFrame:rect];
    
    if (self) {
        //setup textLabel
        title = [[NSString alloc] initWithFormat:@"%@", myTitle];
        link = [[NSString alloc] initWithFormat:@"%@", myLink];
        
        // Reset geometry to identities
        self.transform = CGAffineTransformIdentity;
        tx = 0.0f; ty = 0.0f; scale = 1.0f;	theta = 0.0f;
        
        self.attributedText = myStr;
        
        // transform view to original place
        self.frame = CGRectMake(rect.origin.x, rect.origin.y, self.frame.size.width, self.frame.size.height);
        //self.frame = rect;
        
        //gesture setup
        [self viewDefaultSetting];
        
        //testing
        [self showDetail];
        
        return self;
    }
    return self;
}

- (void) refreshFrame{
    //min width and max width
    NSLog(@"refreshFrame - self.frame.size.width = %f", self.frame.size.width);
    [self sizeToFit];
    if (self.frame.size.width < R_LENGTH){
        [self sizeToFitFixedWidth:R_LENGTH];
    }else if (self.frame.size.width > MAX_LABEL_WIDTH){
        [self sizeToFitFixedWidth:MAX_LABEL_WIDTH];
    }else{
        [self sizeToFitFixedWidth:self.frame.size.width];
    }
}


- (void)sizeToFitFixedWidth:(CGFloat)fixedWidth
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, 0);
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.numberOfLines = 0;
    [self sizeToFit];
    
    //ensure the height is not too small
    if (self.frame.size.height <R_LENGTH){
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, R_LENGTH);
    }else{
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, self.frame.size.height);
    }
    
}

- (void) viewDefaultSetting{
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.numberOfLines = 0;
    
    // Initialization code
    self.userInteractionEnabled = YES;
    
    // Add gesture recognizer suite
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    self.gestureRecognizers = @[pan, tapGesture];
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) recognizer.delegate = self;
    
    //init selecting dash border
    dashBorder = [CAShapeLayer layer];
    dashBorder.strokeColor = [UIColor colorWithRed:67/255.0f green:37/255.0f blue:83/255.0f alpha:1].CGColor;
    dashBorder.fillColor = nil;
    dashBorder.lineDashPattern = @[@4, @2];
    
    //init
    status = @"normal";
    [self.layer addSublayer:dashBorder];
    [self offHighLight];
    [self refreshBorder];
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

- (NSAttributedString *) getAttStr{
    return self.attributedText;
}

- (void)updateText:(NSMutableAttributedString *)mutStr{
    self.attributedText = mutStr;
    self.userInteractionEnabled = YES;
}

-(void) restoreOriginal
{
    NSLog(@"Restore");
    [self offHighLight];
    status = @"normal";
}

- (void) refreshBorder{
    //refresh border
    dashBorder.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    dashBorder.frame = self.bounds;
}

- (void) onHighLight{
    [self refreshBorder];
    //on border
    dashBorder.hidden = false;
}

- (void) offHighLight{
    dashBorder.hidden = true;
}

//Gesture touch for selection (drag and resize)
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([status isEqual: @"normal"]){
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

//Gesture for drag
- (void) handlePan: (UIPanGestureRecognizer *) recognizer
{
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
- (void)handleTapGesture:(UITapGestureRecognizer*)tapPress {
    NSLog(@"handleTapGesture");
    MySingleton* singleton = [MySingleton getInstance];
    NSString* editText = NSLocalizedStringFromTableInBundle(@"editText", nil, singleton.globalLocaleBundle, nil);
    NSString* linkText = NSLocalizedStringFromTableInBundle(@"linkText", nil, singleton.globalLocaleBundle, nil);
    NSString* topText = NSLocalizedStringFromTableInBundle(@"topText", nil, singleton.globalLocaleBundle, nil);
    NSString* upText = NSLocalizedStringFromTableInBundle(@"upText", nil, singleton.globalLocaleBundle, nil);
    NSString* downText = NSLocalizedStringFromTableInBundle(@"downText", nil, singleton.globalLocaleBundle, nil);
    NSString* bottomText = NSLocalizedStringFromTableInBundle(@"bottomText", nil, singleton.globalLocaleBundle, nil);
    NSString* deleteText = NSLocalizedStringFromTableInBundle(@"deleteText", nil, singleton.globalLocaleBundle, nil);

    if ([status isEqual: @"normal"] || [status isEqual: @"readyForDrag"]){
        //if it is originally in readyForDrag
        [self performSelector:@selector(cancelAllViewSelections) withObject:nil];
        
        status = @"inMenu";
        [self onHighLight];
        
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        NSMutableArray *options = [NSMutableArray array];
        UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:editText action:@selector(edit)];
        [options addObject:item1];
        UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:linkText action:@selector(openLink)];
        if (![link  isEqual: @"noCallLink"])
            [options addObject:item2];
        
        //layering
        UIMenuItem *itemLayerTop = [[UIMenuItem alloc] initWithTitle:topText action:@selector(toLayerTop)];
        UIMenuItem *itemLayerUp = [[UIMenuItem alloc] initWithTitle:upText action:@selector(toLayerUp)];
        UIMenuItem *itemLayerDown = [[UIMenuItem alloc] initWithTitle:downText action:@selector(toLayerDown)];
        UIMenuItem *itemLayerBottom = [[UIMenuItem alloc] initWithTitle:bottomText action:@selector(toLayerBottom)];
        [options addObject:itemLayerTop];
        [options addObject:itemLayerUp];
        [options addObject:itemLayerDown];
        [options addObject:itemLayerBottom];
        
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
    
}

//For share menu
- (BOOL)canBecomeFirstResponder {
    return YES;
}

//For share menu
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL result = NO;
    if(@selector(edit) == action || @selector(delete) == action || @selector(openLink) == action || @selector(toLayerTop) == action || @selector(toLayerUp) == action || @selector(toLayerDown) == action || @selector(toLayerBottom) == action) {
        result = YES;
    }
    return result;
}


//For share menu - it is called when the menu is open.
- (BOOL)becomeFirstResponder
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignFirstResponder) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    return [super becomeFirstResponder];
}

//For share menu - it is called when the menu is closed.
- (BOOL)resignFirstResponder
{
    NSLog(@"resignFirstResponder");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    // custom cleanup code here (e.g. deselection)
    if ([status isEqual: @"inMenu"]){
        [self restoreOriginal];
    }
    return [super resignFirstResponder];
}

-(void) edit
{
    NSLog(@"edit");
    [self restoreOriginal];
    [self performSelector:@selector(cancelAllViewSelections) withObject:nil];
    [self performSelector:@selector(callEditTextViewController) withObject:nil afterDelay:0.001];
}


-(void) openLink
{
    //[self.delegate callPopOverWebViewControllerByDragLabel:self];
    [self restoreOriginal];
    [self performSelector:@selector(cancelAllViewSelections) withObject:nil];
    [self performSelector:@selector(callWebViewController) withObject:self afterDelay:0.001];
    
}

-(void) toLayerTop
{
    [self.superview bringSubviewToFront:self];
    [self restoreOriginal];
    [self performSelector:@selector(cancelAllViewSelections) withObject:nil];
}

-(void) toLayerUp
{
    [self.superview insertSubview:self atIndex:[self.superview.subviews indexOfObject:self]+1];
    [self restoreOriginal];
    [self performSelector:@selector(cancelAllViewSelections) withObject:nil];
}

-(void) toLayerDown
{
    [self.superview insertSubview:self atIndex:[self.superview.subviews indexOfObject:self]-1];
    [self restoreOriginal];
    [self performSelector:@selector(cancelAllViewSelections) withObject:nil];
}

-(void) toLayerBottom
{
    [self.superview sendSubviewToBack:self];
    [self restoreOriginal];
    [self performSelector:@selector(cancelAllViewSelections) withObject:nil];
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
    NSLog(@"My view frame: %@", NSStringFromCGRect(self.frame));
    NSLog(@"My view bounds: %@", NSStringFromCGRect(self.bounds));
}

//post notifications
-(void)callEditTextViewController{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"callEditTextViewController"   //callEditTextViewController
                                                        object:self
                                                      userInfo:nil];
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

-(void)callWebViewController{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"callWebViewController" //NotTouched
                                                        object:self
                                                      userInfo:nil];
}



@end
