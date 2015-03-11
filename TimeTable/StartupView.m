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
    [self becomeFirstResponder];
    
    AMTableClasses* classes = [AMTableClasses defaultTable];
    [classes ReadUserData];
//  [classes.classes removeAllObjects];
    if(classes.classes.count > 0)
    {
        ///Сразу к расписанию
        _GroupNumberField.hidden = _sliderBackground.hidden = _sliderSharp.hidden = true;
        UIStoryboard* mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewController* mainView = [mainSB instantiateViewControllerWithIdentifier:@"mainViewControllerId"];
        [self presentViewController:mainView animated:YES completion:nil];
    }
    
    
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
    _GroupNumberField.text = settings.currentGroup;
    
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    //[self.view addGestureRecognizer:tap];

    int screenWidth = self.view.frame.size.width;
    int screenHeight = _sliderBackground.frame.origin.y;
    CGPoint to = CGPointMake(screenWidth/2, screenHeight + 100);
    [self moveView:_spinner toPoint:to withDuration:0.2 andDelay:0];
    
    // Animation defenition
    _logoView.hidden = false;
    _GroupNumberField.alpha = 0;
    _sliderSharp.alpha = 0;
    _sliderSubgroup.alpha = 0;
    _sliderBackground.alpha = 0;
    _spinner.alpha = 0;
    CGPoint toValue =  CGPointMake(self.view.center.x, self.view.center.y-140);
    
    [self moveView:_logoView toPoint:toValue withDuration:1 andDelay:0];
    [self fadeView:_sliderBackground toValue:1 withDuration:1 andDelay:0.3];
    [self fadeView:_GroupNumberField toValue:1 withDuration:1 andDelay:0.5];
    
    [self moveView:_sliderSharp toPoint:CGPointMake(
                                _sliderBackground.center.x - _sliderBackground.frame.size.width/2 +
                                _sliderSharp.frame.size.width/2,
                                _sliderBackground.center.y)
                                withDuration:0.5 andDelay:0.3];
    [self fadeView:_sliderSharp toValue:1 withDuration:1 andDelay:0.3];

    
    CGPoint point = CGPointMake(_sliderSharp.center.x+25, _sliderSharp.center.y);
    [self moveView:_sliderSharp toPoint:point withDuration:0.5 andDelay:1];
    //[self fadeView:_GroupNumberField toValue:0.7 withDuration:0.5 andDelay:1];
    
    point.x -= 25;
    [self moveView:_sliderSharp toPoint:point withDuration:0.3 andDelay:1.41];
    [self fadeView:_GroupNumberField toValue:1 withDuration:0.3 andDelay:1.41];
    //~
    
}

//-------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

//-------------------------------------------------------------------------------------------------------------------
-(void)dismissKeyboard: (id) value {
    [_GroupNumberField resignFirstResponder];
}

- (void)keyboardWillShowNotification:(NSNotification *)aNotification
{
    int screenHeight = self.view.frame.size.height;
    int kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    int center = screenHeight - kbSize;
    int offset = abs(_sliderBackground.center.y - center) * 2;
    CGPoint to = CGPointMake(_content.center.x, _content.center.y - offset);
    [self moveView:_content toPoint:to withDuration:0.2 andDelay:0];
}

-(void)keyboardWillHideNotification:(NSNotification *)aNotification {
    int screenHeight = self.view.frame.size.height;
    int kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    int center = screenHeight - kbSize;
    int offset = abs(_sliderBackground.center.y - center) * 2;
    CGPoint to = CGPointMake(_content.center.x, _content.center.y + offset);
    [self moveView:_content toPoint:to withDuration:0.2 andDelay:0];
}

//-------------------------------------------------------------------------------------------------------------------
- (void)actionContinue
{
    [self dismissKeyboard: NULL];
     [_spinner startAnimating];
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(performContinueAction) object:NULL];
    [_thread start];
}

//-------------------------------------------------------------------------------------------------------------------
-(void) performContinueAction
{
    [self dismissKeyboard:NULL];
    [_spinner startAnimating];
    AMSettings *settings    = [AMSettings currentSettings];
    AMTableClasses* classes = [AMTableClasses defaultTable];

    if(classes.classes.count < 1 || ![_GroupNumberField.text isEqualToString:settings.currentGroup])
    {
        //__unused NSString *filePath = [DOCUMENTS stringByAppendingPathComponent:@"UserClasses.plist"];
        NSLog(@"[ReadUserData. AMTableClasses]: UserClasses not found. Start to download.");
        //NSLog(@"file path %@", filePath);
        BOOL result = [classes parse:_GroupNumberField.text];
         [_spinner stopAnimating];
        if(result == false)
        {
            _sliderSharp.userInteractionEnabled = YES;
            [self moveHome:_sliderSharp];
            [self fadeView:_GroupNumberField toValue:1 withDuration:0.3 andDelay:0];
            [self fadeView:_spinner toValue:0 withDuration:0.3 andDelay:0];
            return;
        }
        
        [self fadeView:_GroupNumberField toValue:0 withDuration:0.1 andDelay:0];
        [self fadeView:_subgroup1 toValue:1 withDuration:0.2 andDelay:0];
        [self fadeView:_subgroup2 toValue:1 withDuration:0.2 andDelay:0];
        [self fadeView:_subgroupMessage toValue:0.3 withDuration:1 andDelay:0.5];
        
        //далее на место шарпа ставим 1-2 и из феда к центральное положение
        [self fadeView:_sliderSubgroup toValue:1 withDuration:0.3 andDelay:0];
        [self moveView:_sliderSubgroup toPoint:_sliderBackground.center withDuration:0.3 andDelay:0];
        _sliderSharp.hidden = true;
    }
    
    [_spinner stopAnimating];
    settings.currentGroup = _GroupNumberField.text;
//    settings.subgroup     = _SubgroupControl.selectedSegmentIndex;
//    [self performSelectorOnMainThread:@selector(segue) withObject:NULL waitUntilDone: NO];
}

- (void) segue
{
    UIStoryboard* mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController* mainView = [mainSB instantiateViewControllerWithIdentifier:@"mainViewControllerId"];
    
    [self presentViewController:mainView animated:YES completion:nil];
}




#pragma mark Animations

- (void) moveView:(UIView*) view toPoint:(CGPoint) to withDuration:(CGFloat) duration andDelay:(CGFloat) delay
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelay:delay];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    view.center = to;
    [UIView commitAnimations];
}


- (void) fadeView:(UIView*) view toValue:(CGFloat) value withDuration:(CGFloat) duration andDelay:(CGFloat) delay
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelay:delay];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    view.alpha = value;
    [UIView commitAnimations];    
}


//640 × 1136
//425 × 236 - logo
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self dismissKeyboard:nil];
    NSLog(@"Begin");
}


//--------------------------------------------------------------------------------
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch* touch = [[touches allObjects] objectAtIndex:0];

    if(touch.view == _sliderSharp)
    {
        CGPoint touchPosition = [touch locationInView:self.view];
        touchPosition.y = _sliderSharp.center.y; //Убираем возможность перемешаться по у
        
        //Если мы слайдер находится в переделах формы, то идет перемешение
        if(touchPosition.x > _sliderBackground.center.x - _sliderBackground.frame.size.width/2 +_sliderSharp.frame.size.width/2 && touchPosition.x < _sliderBackground.center.x + _sliderBackground.frame.size.width/2 - _sliderSharp.frame.size.width/2)
                _sliderSharp.center = touchPosition;
        //иначе, если палец дальше середины то обрабатываем этот блок
        //если дальше середины, то если палец за слайдером то идет сдвиг в конец
        else if (touchPosition.x > _sliderBackground.center.x)
        {
            _sliderSharp.center = CGPointMake(MAX(_sliderSharp.center.x, _sliderBackground.center.x + _sliderBackground.frame.size.width/2 - _sliderSharp.frame.size.width/2), _sliderSharp.center.y);
            _GroupNumberField.alpha = 0;
        }
        else
        {
            _sliderSharp.center = CGPointMake(MIN(_sliderSharp.center.x, _sliderBackground.center.x - _sliderBackground.frame.size.width/2 + _sliderSharp.frame.size.width/2), _sliderSharp.center.y);
            _GroupNumberField.alpha = 1;
        }
        
        //Рассчитываем скаляр для уменьшения видимости номера группы
        CGFloat alphaScalar = _sliderBackground.center.x/touchPosition.x*15/ touchPosition.x;
        _GroupNumberField.alpha = alphaScalar;
        _spinner.hidden = false;
        _spinner.alpha = 1/(alphaScalar * 20);
    }
    //Если 2ой слайдер
    if(touch.view == _sliderSubgroup)
    {
        CGPoint touchPosition = [touch locationInView:self.view];
        touchPosition.y = _sliderSharp.center.y;
        if(touchPosition.x > _sliderBackground.center.x - _sliderBackground.frame.size.width/2 +_sliderSubgroup.frame.size.width/2 && touchPosition.x < _sliderBackground.center.x + _sliderBackground.frame.size.width/2 - _sliderSubgroup.frame.size.width/2)
                _sliderSubgroup.center = touchPosition;
        
        //иначе, если палец дальше середины то обрабатываем этот блок
        //если дальше середины, то если палец за слайдером то идет сдвиг в конец
        else if (touchPosition.x > _sliderBackground.center.x)
        {
            _sliderSubgroup.center = CGPointMake(MAX(_sliderSubgroup.center.x, _sliderBackground.center.x + _sliderBackground.frame.size.width/2 - _sliderSubgroup.frame.size.width/2), _sliderSubgroup.center.y);
        }
        else
        {
            _sliderSubgroup.center = CGPointMake(MIN(_sliderSubgroup.center.x, _sliderBackground.center.x - _sliderBackground.frame.size.width/2 + _sliderSubgroup.frame.size.width/2), _sliderSubgroup.center.y);
        }
        
        CGFloat alphaScalar = (_sliderBackground.center.x  - touchPosition.x) / _sliderBackground.center.x;
        if(alphaScalar < 0) alphaScalar = -alphaScalar;
        
        //n_spinner.hidden = false;
       // _spinner.alpha = alphaScalar * 2;
        _subgroup1.alpha = _subgroup2.alpha = 1/((alphaScalar)*50);
    }
}



//--------------------------------------------------------------------------------
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"End");
    UITouch* touch = [[touches allObjects] objectAtIndex:0];
    if(touch.view == _sliderSharp)
    {
       if(_sliderSharp.center.x > _sliderBackground.center.x + _sliderBackground.frame.size.width/2 - _sliderSharp.frame.size.width)
        {
            [self actionContinue];
            _sliderSharp.userInteractionEnabled = NO;
        }
       else
       {
           [self fadeView:_GroupNumberField toValue:1 withDuration:0.3 andDelay:0];
           [self fadeView:_spinner toValue:0 withDuration:0.2 andDelay:0];
           [self moveHome:_sliderSharp];
       }
    }
    else if(touch.view == _sliderSubgroup)
    {
        AMSettings *settings = [AMSettings currentSettings];
        if(_sliderSubgroup.center.x < _sliderBackground.center.x - _sliderBackground.frame.size.width/2 + _sliderSubgroup.frame.size.width)
            settings.subgroup = 1;
        if(_sliderSubgroup.center.x > _sliderBackground.center.x + _sliderBackground.frame.size.width/2 - _sliderSubgroup.frame.size.width)
            settings.subgroup = 2;

    
        [self moveHome:_sliderSubgroup];
        [_spinner startAnimating];
        [self fadeView:_sliderSubgroup toValue:0 withDuration:0.3 andDelay:0];
        [self fadeView:_sliderBackground toValue:0 withDuration:0.3 andDelay:0];
        [self moveView:_spinner toPoint:CGPointMake(_spinner.center.x, _spinner.center.y+ 15) withDuration:0 andDelay:0];
        
        _subgroup1.alpha = 1;
        _subgroup2.alpha = 1;
        [self moveHome:_sliderSubgroup];

        [self performSelectorOnMainThread:@selector(segue) withObject:NULL waitUntilDone: NO];
        return;
    }
}

//--------------------------------------------------------------------------------
- (void) moveHome:(UIView*) view
{
    if(view == _sliderSharp)
    {
        [self moveView:view toPoint:CGPointMake(_sliderBackground.center.x - _sliderBackground.frame.size.width/2 +                                                    view.frame.size.width/2, _sliderBackground.center.y) withDuration:0.3 andDelay:0];
    }
    else if(view == _sliderSubgroup)
    {
        [self moveView:view toPoint:_sliderBackground.center withDuration:0.3 andDelay:0];
    }
    
}


- (void) end:(UIView*) view
{
    [self fadeView:_GroupNumberField toValue:1 withDuration:0.3 andDelay:0];
    [self fadeView:_spinner toValue:0 withDuration:0.2 andDelay:0];
    [self moveHome:_sliderSharp];
}

@end
