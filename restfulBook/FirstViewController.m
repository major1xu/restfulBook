//
//  FirstViewController.m
//  restfulBook
//
//  Created by XU, MINJIE on 8/29/14.
//  Copyright (c) 2014 uudaddy. All rights reserved.
//

#import "FirstViewController.h"

static NSString * const BaseURLString = @"http://interview.locationlabs.com/book";

@interface FirstViewController ()

@end



@implementation FirstViewController

@synthesize textField = _textField;
@synthesize textView = _textView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Get Book";
}

- (void)get_book_request:(NSString *)string
{
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        self.title = @"Book Retrieved";
        _textView.text = [[NSString alloc] initWithFormat:@"Response JSON: %@", (NSDictionary *)responseObject];
        
        // capture 404 book can not found
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        NSHTTPURLResponse *response = (NSHTTPURLResponse *)operation.response;
        int statuscode = response.statusCode;
        NSLog(@"\n============== ERROR ====\n%@; statusCode=%i",error.userInfo, statuscode);
        // 4
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Book"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    [operation start];
}

- (IBAction)getAllBooks:(id)sender
{
    [self clear:nil];

    NSString *string = [NSString stringWithFormat:@"%@", BaseURLString];
    
    [self get_book_request:string];
}

-(IBAction)getBookById:(id)sender
{
    [self clear:nil];

    // validate the book ID text field
    if (_textField.text == NULL || _textField.text.length==0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Book ID required"
                                                            message:@"Please input the book ID"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        [_textField resignFirstResponder];
    
        int bookId = [_textField.text intValue];
    
        NSString *string = [NSString stringWithFormat:@"%@/%i", BaseURLString, bookId];
    
        [self get_book_request:string];
    }
}

// TBD: the book is hard coded for now
-(IBAction)addBook:(id)sender
{
    // 1
    NSURL *baseURL = [NSURL URLWithString:BaseURLString];
    NSDictionary *parameters = @{@"title": @"One Flew Over the Cuckoo's Nest",
                                 @"author": @"Ken Kesey",
                                 @"read": @false};
    
    // 2
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:@"/book" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        self.title = @"Book added";
        _textView.text = [[NSString alloc] initWithFormat:@"Response JSON: %@", (NSDictionary *)responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"\n============== ERROR ====\n%@",error.userInfo);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error adding book"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
        [alertView show];
    }];
}

- (void)setupForRemoveAndUpdateBook:(AFHTTPSessionManager **)manager_p bookIdString_p:(NSString **)bookIdString_p
{
    NSURL *baseURL = [NSURL URLWithString:BaseURLString];
    
    [_textField resignFirstResponder];
    
    int bookId = [_textField.text intValue];
    
    *bookIdString_p = [NSString stringWithFormat:@"/book/%i", bookId];
    
    *manager_p = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    (*manager_p).requestSerializer = [AFJSONRequestSerializer serializer];
    (*manager_p).responseSerializer = [AFJSONResponseSerializer serializer];
}

- (void)remove_book
{
    NSString *bookIdString;
    AFHTTPSessionManager *manager;
    [self setupForRemoveAndUpdateBook:&manager bookIdString_p:&bookIdString];
    
    [manager DELETE:bookIdString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.title = @"Book deleted";
        _textView.text = [[NSString alloc] initWithFormat:@"Response JSON: %@", (NSDictionary *)responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"\n============== ERROR ====\n%@",error.userInfo);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error deleting book"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
}

-(IBAction)removeBook:(id)sender
{
    [self clear:nil];

    if (_textField.text == NULL || _textField.text.length==0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Book ID required"
                                                            message:@"Please input the book ID"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else {
        [self remove_book];
    }
}

- (void)update_book
{
    NSString *bookIdString;
    AFHTTPSessionManager *manager;
    [self setupForRemoveAndUpdateBook:&manager bookIdString_p:&bookIdString];
    
    NSDictionary *parameters = @{@"read": @true};
    
    [manager PUT:bookIdString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        self.title = @"Book updated";
        _textView.text = [[NSString alloc] initWithFormat:@"Response JSON: %@", (NSDictionary *)responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"\n============== ERROR ====\n%@",error.userInfo);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error updating book"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
}

-(IBAction)updateBook:(id)sender
{
    [self clear:nil];

    if (_textField.text == NULL || _textField.text.length==0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Book ID required"
                                                            message:@"Please input the book ID"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else {
        [self update_book];
    }
}

-(IBAction)clear:(id)sender
{
     _textView.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
