//
//  FirstViewController.h
//  restfulBook
//
//  Created by XU, MINJIE on 8/29/14.
//  Copyright (c) 2014 uudaddy. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FirstViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *textField;

@property (nonatomic, strong) IBOutlet UITextView *textView;

-(IBAction)getAllBooks:(id)sender;

-(IBAction)getBookById:(id)sender;

-(IBAction)addBook:(id)sender;

-(IBAction)clear:(id)sender;

-(IBAction)removeBook:(id)sender;

-(IBAction)updateBook:(id)sender;

@end
