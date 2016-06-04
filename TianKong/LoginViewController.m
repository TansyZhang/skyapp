//
//  ViewController.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 9/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "LoginViewController.h"
#import "MySingleton.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize passInput;
@synthesize nameInput;
@synthesize langSelect;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //notification called when main view dismiss
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissMainViewController)
                                                 name:@"MainViewControllerDismissed"
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleLoginClick:(id)sender {
    NSLog(@"handleLoginClick");
    MySingleton* singleton = [MySingleton getInstance];
    
    //-----------------------------------------------------------------------------
    //----------------------------------FOR REAL START-----------------------------
    //-----------------------------------------------------------------------------
    
    bool loginStatus = [self jsonLogin];
    
    //-----------------------------------------------------------------------------
    //----------------------------------FOR REAL END-------------------------------
    //-----------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------
    //----------------------------------FOR TESTING START--------------------------
    //-----------------------------------------------------------------------------

    //-----------------------------------------------------------------------------
    //----------------------------------FOR TESTING END----------------------------
    //-----------------------------------------------------------------------------
  
    
    if (loginStatus){
        //store global values
     
        
        singleton.globalLang = [[NSNumber alloc] initWithInt:(int)langSelect.selectedSegmentIndex]; //store Language
        
        //changel lang, by path to LocaleBundle. All localized strings can be referred to Localizable.string file.
        if (singleton.globalLang.integerValue == 0){
            NSString *path = [[NSBundle mainBundle] pathForResource:@"zh-Hant" ofType:@"lproj"];
            if (path) {
                singleton.globalLocaleBundle = [NSBundle bundleWithPath:path];
            }
           
        }else if (singleton.globalLang.integerValue == 1){
            NSString *path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
            if (path) {
                singleton.globalLocaleBundle = [NSBundle bundleWithPath:path];
            }
           
        }
        
        //Segue
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    }
    
    
}

//notification called when main view dismiss
-(void)didDismissMainViewController {
    self.nameInput.text = @"";
    self.passInput.text = @"";
    MySingleton* singleton = [MySingleton getInstance];
    singleton.globalLang = 0;
    singleton.globalUserType = @"";
    singleton.globalUserName = @"";
    singleton.globalUserID = @"";
}

//login
- (bool)jsonLogin {
    NSInteger success = 0;
    @try {
        if([self.nameInput.text isEqualToString:@""] || [self.passInput.text isEqualToString:@""] ) {
            
            [self alertStatus:@"請輸入帳戶及密碼 (Please enter Account and Password)" :@"登入失敗 (Sign in Failed)" :0];
            
        } else {
            NSString *post =[[NSString alloc] initWithFormat:@"account=%@&password=%@",self.nameInput.text,self.passInput.text];
            NSLog(@"PostData: %@",post);
            
            NSURL *url=[NSURL URLWithString:@"http://lesofts.com/tk/jsonLogin.php"];
            
            NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            
            //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
            
            NSError *error = [[NSError alloc] init];
            NSHTTPURLResponse *response = nil;
            NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            NSLog(@"Response code: %ld", (long)[response statusCode]);
            
            if ([response statusCode] >= 200 && [response statusCode] < 300)
            {
                NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
                NSLog(@"Response ==> %@", responseData);
                
                NSError *error = nil;
                NSDictionary *jsonData = [NSJSONSerialization
                                          JSONObjectWithData:urlData
                                          options:NSJSONReadingMutableContainers
                                          error:&error];
                
                success = [jsonData[@"success"] integerValue];
                NSLog(@"Success: %ld",(long)success);
                
                if(success == 1)
                {
                    NSString *success_msg = (NSString *) jsonData[@"success_message"];
                    NSString *user_id = (NSString *) jsonData[@"user_id"];
                    NSString *user_type = (NSString *) jsonData[@"user_type"];
                    NSString *user_name = (NSString *) jsonData[@"user_name"];
                    NSLog(@"Login SUCCESS");
                    NSLog(@"success_message = %@", success_msg);
                    NSLog(@"user_id = %@", user_id);
                    NSLog(@"user_type = %@", user_type);
                    NSLog(@"user_name = %@", user_name);
                    
                    MySingleton* singleton = [MySingleton getInstance];
                    singleton.globalUserType = user_type;
                    singleton.globalUserName = user_name;
                    singleton.globalUserID = user_id;
                    
                } else {
                    NSString *error_msg = (NSString *) jsonData[@"error_message"];
                    [self alertStatus:error_msg :@"登入失敗 (Sign in Failed)" :0];
                }
                
            } else {
                //no internet connection
                [self alertStatus:@"連接失敗 (Connection Failed)" :@"登入失敗 (Sign in Failed)" :0];
            }
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [self alertStatus:@"登入失敗 (Sign in Failed)" :@"錯誤 (Error)" :0];
    }
    if (success) {
        return true;
    }else{
        return false;
    }
}

//general alert method
- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}

@end
