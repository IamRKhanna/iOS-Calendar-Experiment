//
//  RKCalendarView.h
//  CalendarApp
//
//  Created by Rahul Khanna on 2/24/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RKCalendarViewDelegate;


@interface RKCalendarView : UIView

// Start and End date for the calendar
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

// Delegate
@property (nonatomic, weak) id<RKCalendarViewDelegate> delegate;

@property (nonatomic, assign) CGFloat rowHeight UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSDictionary *monthCoverLabelAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSDictionary *weekDayTitleAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *weekdayTitleViewBackgroundColor UI_APPEARANCE_SELECTOR;

// Methods
- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated;

- (CGFloat)heightToDisplayNumberOfRows:(NSUInteger)numberOfRows;
- (void)reload;

@end


@protocol RKCalendarViewDelegate <NSObject>

@optional
- (void)calendarView:(RKCalendarView *)calendarView didSelectDate:(NSDate *)date;
- (void)calenderViewWillBeginDragging:(RKCalendarView *)calendarView;

@end