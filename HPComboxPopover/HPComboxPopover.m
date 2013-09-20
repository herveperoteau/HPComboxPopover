//
//  HPComboxPopover.m
//  HPComboxPopover
//
//  Created by Hervé PEROTEAU on 07/09/13.
//  Copyright (c) 2013 Hervé PEROTEAU. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HPComboxPopoverGradientView.h"
#import "HPComboxPopover.h"

@interface HPComboxPopover ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIView *backgroundView;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UIPickerView *picker;

- (IBAction)close:(id)sender;
- (IBAction)valid:(id)sender;

@end

@implementation HPComboxPopover {
    
    HPComboxPopoverGradientView *gradientView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.backgroundView.layer.borderWidth = 3.0f;
    self.backgroundView.layer.cornerRadius = 10.0f;
	
    self.titleLabel.text = self.title;
    self.titleLabel.textColor = (self.colorText!=nil?self.colorText:[UIColor whiteColor]);
    self.titleLabel.font = (self.font!=nil?self.font:[UIFont systemFontOfSize:21]);
 
    if (self.colorCombox) {
        
        self.backgroundView.backgroundColor = self.colorCombox;
        self.picker.backgroundColor = self.colorCombox;
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)layoutForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGRect rect = self.closeButton.frame;
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        rect.origin = CGPointMake(28, 87);
    } else {
        rect.origin = CGPointMake(108, 7);
    }
    self.closeButton.frame = rect;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"%@.willRotateToInterfaceOrientation ...", self.class);
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self layoutForInterfaceOrientation:toInterfaceOrientation];
}

- (IBAction)close:(id)sender
{
    [self.delegate didCancel:self];
}

- (IBAction)valid:(id)sender {
    
    NSInteger row = [self.picker selectedRowInComponent:0];
    
    if (row == -1) {
        
        [self.delegate didCancel:self];
        return;
    }

    self.idxSelectedItem = row;
    
    [self.delegate didSelectedItem:self.items[row] sender:self];
}

- (void)presentInParentViewController:(UIViewController *)parentViewController
{
//    Bidouille ici pour la rendre completement modale sur tout le view controller
//    Sinon si je clique sur le menu, les boutons sont actfs !!!
//    Mais cette version bug en orientation Landscape, donc a utiliser uniquement
//    dans une application en Portrait !!!
    
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    
    gradientView = [[HPComboxPopoverGradientView alloc] initWithFrame:keyWindow.bounds];
    //[parentViewController.view addSubview:gradientView];
    [keyWindow addSubview:gradientView];
    
    self.view.frame = parentViewController.view.bounds;
	[self layoutForInterfaceOrientation:parentViewController.interfaceOrientation];
    [gradientView addSubview:self.view];
//    [parentViewController.view addSubview:self.view];
    [parentViewController addChildViewController:self];
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    bounceAnimation.duration = 0.4;
    bounceAnimation.delegate = self;
    
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.7f],
                              [NSNumber numberWithFloat:1.2f],
                              [NSNumber numberWithFloat:0.9f],
                              [NSNumber numberWithFloat:1.0f],
                              nil];
    
    bounceAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:0.0f],
                                [NSNumber numberWithFloat:0.334f],
                                [NSNumber numberWithFloat:0.666f],
                                [NSNumber numberWithFloat:1.0f],
                                nil];
    
    bounceAnimation.timingFunctions = [NSArray arrayWithObjects:
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       nil];
    
    [self.view.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    fadeAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    fadeAnimation.duration = 0.1;
    [gradientView.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self didMoveToParentViewController:self.parentViewController];
    
    if (self.idxSelectedItem >= 0) {
    
        //NSLog(@"selectRow %d", self.idxSelectedItem);
    
        [self.picker reloadAllComponents];
        [self.picker selectRow:self.idxSelectedItem inComponent:0 animated:YES];
    }

}

- (void)dismissFromParentViewController
{
    [self willMoveToParentViewController:nil];
    
    [UIView animateWithDuration:0.4 animations:^ {
        
        CGRect rect = self.view.bounds;
        rect.origin.y += rect.size.height;
        self.view.frame = rect;
        gradientView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        [self.view removeFromSuperview];
        [gradientView removeFromSuperview];
        [self removeFromParentViewController];
        
    }];
}

#pragma mark - UIPickerViewDataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return self.items.count;
}


#pragma mark - UIPickerViewDelegate

//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    
//    return [self.items[row] description];
//}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    
    UIView *customPickerView = view;
    
    UILabel *pickerViewLabel;
    
    if (customPickerView==nil) {
        
        CGRect frame = CGRectMake(0.0, 0.0, self.picker.frame.size.width, 50.0);
        customPickerView = [[UIView alloc] initWithFrame: frame];
        
        pickerViewLabel = [[UILabel alloc] initWithFrame:frame];
        [pickerViewLabel setTag:1];
        [pickerViewLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerViewLabel setBackgroundColor:[UIColor clearColor]];
        [pickerViewLabel setTextColor:(self.colorText!=nil?self.colorText:[UIColor whiteColor])];
        [pickerViewLabel setFont:(self.font!=nil?self.font:[UIFont systemFontOfSize:21])];
        [customPickerView addSubview:pickerViewLabel];
    }
    else{
        
        for (UIView *view in customPickerView.subviews) {
            
            if (view.tag == 1) {
                
                pickerViewLabel = (UILabel *)view;
                break;
            }
        }
    }
    
    [pickerViewLabel setText:[self.items[row] description]];
    
    return customPickerView;
}




@end
