//
//  HPComboxPopover.h
//  HPComboxPopover
//
//  Created by Hervé PEROTEAU on 07/09/13.
//  Copyright (c) 2013 Hervé PEROTEAU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class HPComboxPopover;

@protocol HPComboxPopoverDelegate <NSObject>

- (void)didCancel:(HPComboxPopover *)sender;
- (void)didSelectedItem:(id)item sender:(HPComboxPopover *)sender;

@end

@interface HPComboxPopover : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, weak) id<HPComboxPopoverDelegate> delegate;
@property (nonatomic, assign) NSInteger idxSelectedItem;

- (void)presentInParentViewController:(UIViewController *)parentViewController;
- (void)dismissFromParentViewController;

@end
