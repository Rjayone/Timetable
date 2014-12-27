//
//  StartupView.m
//  TimeTable
//
//  Created by Admin on 23.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import "StartupView.h"
#import "AMTableClasses.h"
#import "AMSettings.h"
#import "Utils.h"
#import "ViewController.h"
#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]


@implementation StartupView

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    AMTableClasses* classes = [AMTableClasses defaultTable];
    [classes ReadUserData];
    //[classes.classes removeAllObjects];
//    if(classes.classes.count > 0)
//    {
//        ///Сразу к расписанию
//        UIStoryboard* mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        ViewController* mainView = [mainSB instantiateViewControllerWithIdentifier:@"mainViewControllerId"];
//        [self presentViewController:mainView animated:NO completion:nil];
//    }
    
    [self.view addSubview:_spinner]; // spinner is not visible until started
    
    
    // Подписываемся на события клавиатуры
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(keyboardWillShowNotification:)
               name:UIKeyboardWillShowNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(keyboardWillHideNotification:)
               name:UIKeyboardWillHideNotification
             object:nil];
}

//-------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    AMSettings* settings = [AMSettings currentSettings];
    _SubgroupControl.selectedSegmentIndex = settings.subgroup;
    _GroupNumberField.text = settings.currentGroup;
    
    //устанавливаем закругленные края у кнопки
    _ContinueButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    _ContinueButton.layer.borderWidth = 1.0f;
    _ContinueButton.layer.cornerRadius = 7;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

//-------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

//-------------------------------------------------------------------------------------------------------------------
-(void)dismissKeyboard {
    [_GroupNumberField resignFirstResponder];
}

//-----------------------------------------------------------------------------------------------------------------------
- (IBAction)actionContinue:(UIButton *)sender
{
    [self dismissKeyboard];
     [_spinner startAnimating];
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(performContinueAction) object:NULL];
    [_thread start];
}

//-------------------------------------------------------------------------------------------------------------------
//Показываем клаву если начинается редактирование поля
- (IBAction)actionDidTouchInside:(UITextField*)sender
{
    //[sender becomeFirstResponder];
}

//------------------------------------------------------------------------------------------------------------------------
//Скрываем клавиатуру по нажатию Done
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    //[self actionContinue:nil];
    return YES;
}


- (void)scrollToTextField:(UITextField *)textField {
    [_scrollView setContentOffset:(CGPoint){0,
        CGRectGetHeight(textField.frame) + 17
    } animated:YES];
}

- (void)resetScrollView {
    [_scrollView setContentOffset:(CGPoint){0, 0}animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _GroupNumberField = textField;
    [self scrollToTextField:_GroupNumberField];
}

- (void)keyboardWillShowNotification:(NSNotification *)aNotification
{
    CGRect keyboardScreenRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height += CGRectGetHeight(keyboardScreenRect);
    self.scrollView.contentSize = contentSize;
    
    [self scrollToTextField:_GroupNumberField];
}

-(void)keyboardWillHideNotification:(NSNotification *)aNotification {
    CGRect keyboardScreenRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height -= CGRectGetHeight(keyboardScreenRect);
    self.scrollView.contentSize = contentSize;
    [self resetScrollView];
}


-(void) performContinueAction
{
    AMSettings *settings    = [AMSettings currentSettings];
    AMTableClasses* classes = [AMTableClasses defaultTable];
    [self dismissKeyboard];
    if(classes.classes.count < 1 || ![_GroupNumberField.text isEqualToString:settings.currentGroup])
    {
        //__unused NSString *filePath = [DOCUMENTS stringByAppendingPathComponent:@"UserClasses.plist"];
        NSLog(@"[ReadUserData. AMTableClasses]: UserClasses not found. Start to download.");
        //NSLog(@"file path %@", filePath);
        [_spinner startAnimating];
        __unused BOOL result = [classes parse:_GroupNumberField.text];
         [_spinner stopAnimating];
        if(result == false)
            return;
        
    }
    [_spinner stopAnimating];
    settings.currentGroup = _GroupNumberField.text;
    settings.subgroup     = _SubgroupControl.selectedSegmentIndex;
    [self performSelectorOnMainThread:@selector(segue) withObject:NULL waitUntilDone: NO];

    
}

-(void) startSpinner
{
    [_spinner startAnimating];
}

- (void) segue
{
    UIStoryboard* mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController* mainView = [mainSB instantiateViewControllerWithIdentifier:@"mainViewControllerId"];
    
    [self presentViewController:mainView animated:YES completion:nil];
}

@end
