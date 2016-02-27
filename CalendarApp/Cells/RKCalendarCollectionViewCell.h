//
//  RKCalendarCollectionViewCell.h
//  CalendarApp
//
//  Created by Rahul Khanna on 2/24/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RKCalendarCollectionViewCell : UICollectionViewCell

+  (NSString *)reuseIdentifier;

@property (nonatomic, strong) UIColor *borderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *evenMonthBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *oddMonthBackgroundColor UI_APPEARANCE_SELECTOR;

// Text attributes
@property (nonatomic, strong) NSDictionary *dayLabelAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSDictionary *todayLabelAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSDictionary *monthLabelAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSDictionary *yearLabelAttributes UI_APPEARANCE_SELECTOR;

// Agenda indicator color
@property (nonatomic, strong) UIColor *todayAgendaIndicatorColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *agendaIndicatorColor UI_APPEARANCE_SELECTOR;

// Background view selector helper
@property (nonatomic, assign) CGFloat backgroundCoverWidthPadding UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat backgroundCoverHeightPadding UI_APPEARANCE_SELECTOR;

- (void)setDate:(NSDate *)date isSelected:(BOOL)isSelected;

- (void)updateDisplayForSelectedState:(BOOL)isSelected;

@end