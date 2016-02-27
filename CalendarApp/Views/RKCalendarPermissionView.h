//
//  RKCalendarPermissionView.h
//  CalendarApp
//
//  Created by Rahul Khanna on 2/17/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RKCalendarPermissionView : UIView

// Outlets
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UIButton *openSettingsButton;

- (void)setOpenSettingsButtonHidden:(BOOL)isHidden;

@end
