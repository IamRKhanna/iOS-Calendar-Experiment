//
//  GLCalendarDateCell.m
//  GLPeriodCalendar
//
//  Created by ltebean on 15-4-16.
//  Copyright (c) 2015 glow. All rights reserved.
//

#import "GLCalendarDayCell.h"
#import "GLCalendarDayCellBackgroundCover.h"
#import "GLCalendarDateRange.h"
#import "GLDateUtils.h"
#import "GLCalendarView.h"
#import "GLCalendarDayCell.h"
#import "RKCalendarDataManager.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface GLCalendarDayCell()
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;

@property (weak, nonatomic) IBOutlet GLCalendarDayCellBackgroundCover *backgroundCover;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundCoverLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundCoverRight;

@property (nonatomic) CELL_POSITION position;
@property (nonatomic) ENLARGE_POINT enlargePoint;
@property (nonatomic) BOOL inEdit;
@property (nonatomic) CGFloat containerPadding;

// Custom View to show whether the date has an agenda
@property (weak, nonatomic) IBOutlet UIView *agendaIndicatorView;

@end

@implementation GLCalendarDayCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self reloadAppearance];
}

- (void)reloadAppearance
{
    GLCalendarDayCell *appearance = [[self class] appearance];
    self.evenMonthBackgroundColor = appearance.evenMonthBackgroundColor ?: UIColorFromRGB(0xf8f8f8);
    self.oddMonthBackgroundColor = appearance.oddMonthBackgroundColor ?: [UIColor whiteColor];
    self.dayLabelAttributes = appearance.dayLabelAttributes ?: @{NSFontAttributeName:[UIFont systemFontOfSize:20]};
    self.futureDayLabelAttributes = appearance.futureDayLabelAttributes ?: self.dayLabelAttributes;
    self.monthLabelAttributes = appearance.monthLabelAttributes ?: @{NSFontAttributeName:[UIFont systemFontOfSize:8]};
    self.yearLabelAttributes = appearance.yearLabelAttributes ?: @{NSFontAttributeName:[UIFont systemFontOfSize:8]};
    self.todayLabelAttributes = appearance.todayLabelAttributes ?: @{NSFontAttributeName:[UIFont boldSystemFontOfSize:22]};
    
    self.backgroundCover.paddingTop = appearance.editCoverPadding ?: 2;
    self.backgroundCover.borderWidth = appearance.editCoverBorderWidth ?: 2;
    self.backgroundCover.strokeColor = appearance.editCoverBorderColor ?: [UIColor darkGrayColor];
    
    self.backgroundCover.pointSize = appearance.editCoverPointSize ?: 14;
    self.backgroundCover.pointScale = appearance.editCoverPointScale ?: 1.3;
    
    RANGE_DISPLAY_MODE mode = appearance.rangeDisplayMode ?: RANGE_DISPLAY_MODE_SINGLE;
    self.backgroundCover.continuousRangeDisplay = mode == RANGE_DISPLAY_MODE_CONTINUOUS ? YES : NO;
    
    self.todayBackgroundColor = appearance.todayBackgroundColor ?: self.backgroundCover.strokeColor;
    self.containerPadding = [GLCalendarView appearance].padding;
    
    self.agendaIndicatorView.layer.cornerRadius = self.agendaIndicatorView.frame.size.width/2;
    self.agendaIndicatorView.backgroundColor = appearance.agendaIndicatorColor ?: self.backgroundCover.strokeColor;
}

- (void)setDate:(NSDate *)date range:(GLCalendarDateRange *)range cellPosition:(CELL_POSITION)cellPosition enlargePoint:(ENLARGE_POINT)enlargePoint
{
    _date = [date copy];
    _range = range;
    if (range) {
        self.inEdit = range.inEdit;
    } else {
        self.inEdit = NO;
    }
    self.position = cellPosition;
    self.enlargePoint = enlargePoint;
    [self updateUI];
}

- (void)updateUI
{
//    NSLog(@"update ui: %@ %d", [GLDateUtils descriptionForDate:self.date], _enlargePoint);

    NSDateComponents *components = [[GLDateUtils calendar] components:NSCalendarUnitYear|NSCalendarUnitDay|NSCalendarUnitMonth fromDate:self.date];
    NSInteger year = components.year;
    NSInteger day = components.day;
    NSInteger month = components.month;

    // month background color
    if (month % 2 == 0) {
        self.backgroundCover.backgroundColor = self.evenMonthBackgroundColor;
    } else {
        self.backgroundCover.backgroundColor = self.oddMonthBackgroundColor;
    }
    
    // adjust background position
    if (self.position == POSITION_LEFT_EDGE) {
        self.backgroundCoverRight.constant = 0;
        self.backgroundCoverLeft.constant = -self.containerPadding;
        self.backgroundCover.paddingLeft = self.containerPadding;
        self.backgroundCover.paddingRight = 0;
    } else if (self.position == POSITION_RIGHT_EDGE){
        self.backgroundCoverRight.constant = -self.containerPadding;
        self.backgroundCoverLeft.constant = 0;
        self.backgroundCover.paddingLeft = 0;
        self.backgroundCover.paddingRight = self.containerPadding;
    } else {
        self.backgroundCoverRight.constant = 0;
        self.backgroundCoverLeft.constant = 0;
        self.backgroundCover.paddingLeft = 0;
        self.backgroundCover.paddingRight = 0;
    }
        
    // day label and month label
    if ([self isToday]) {
        // Uncomment below code if you want to see the Today label on top of today cell like month start cell
//        self.monthLabel.textColor = [UIColor whiteColor];
//        [self setMonthLabelText:@"Today"];
        self.monthLabel.textColor = [UIColor blackColor];
        [self setMonthLabelText:@""];
        self.yearLabel.textColor = [UIColor blackColor];
        [self setYearLabelText:@""];
        self.dayLabel.textColor = [UIColor whiteColor];
        [self setTodayLabelText:[NSString stringWithFormat:@"%ld", (long)day]];
        self.backgroundCover.isToday = YES;
        self.backgroundCover.fillColor = self.todayBackgroundColor;
        
        self.agendaIndicatorView.backgroundColor = self.todayBackgroundColor;
        if ([[RKCalendarDataManager sharedInstance] doesEventExistForDate:self.date]) {
            self.agendaIndicatorView.hidden = NO;
        } else {
            self.agendaIndicatorView.hidden = YES;
        }
    } else if (day == 1) {
        self.monthLabel.textColor = [UIColor redColor];
        [self setMonthLabelText:[self monthText:month]];
        
        // Check if year is not current year
        NSDateComponents *components = [[GLDateUtils calendar] components:NSCalendarUnitYear fromDate:[NSDate date]];
        NSInteger thisYear = components.year;
        if(year != thisYear) {
            self.yearLabel.textColor = [UIColor blackColor];
            [self setYearLabelText:[NSString stringWithFormat:@"%ld", (long)year]];
        }
        else {
            self.yearLabel.textColor = [UIColor blackColor];
            [self setYearLabelText:@""];
        }
        
        self.dayLabel.textColor = [UIColor redColor];
        [self setDayLabelText:[NSString stringWithFormat:@"%ld", (long)day]];
        self.backgroundCover.isToday = NO;
        self.agendaIndicatorView.backgroundColor = self.todayBackgroundColor;
        
        self.agendaIndicatorView.hidden = YES;
    } else {
        self.monthLabel.textColor = [UIColor blackColor];
        [self setMonthLabelText:@""];
        self.yearLabel.textColor = [UIColor blackColor];
        [self setYearLabelText:@""];
        self.dayLabel.textColor = [UIColor blackColor];
        [self setDayLabelText:[NSString stringWithFormat:@"%ld", (long)day]];
        self.backgroundCover.isToday = NO;

        self.agendaIndicatorView.backgroundColor = self.agendaIndicatorColor;
        if ([[RKCalendarDataManager sharedInstance] doesEventExistForDate:self.date]) {
            self.agendaIndicatorView.hidden = NO;
        } else {
            self.agendaIndicatorView.hidden = YES;
        }
        
    }
    
    if ([self isFuture]) {
        [self setFutureDayLabelText:[NSString stringWithFormat:@"%ld", (long)day]];
    }
    
    // background cover
    if (self.range) {
        // configure look when in range
        self.backgroundCover.fillColor = self.range.backgroundColor ?: [UIColor clearColor];
        self.backgroundCover.backgroundImage = self.range.backgroundImage ?: nil;
        UIColor *textColor = self.range.textColor ?: [UIColor whiteColor];
        self.monthLabel.textColor = textColor;
        self.dayLabel.textColor = textColor;
        
        // check position in range
        BOOL isBeginDate = [GLDateUtils date:self.date isSameDayAsDate:self.range.beginDate];
        BOOL isEndDate = [GLDateUtils date:self.date isSameDayAsDate:self.range.endDate];
        
        if (isBeginDate && isEndDate) {
            self.backgroundCover.rangePosition = RANGE_POSITION_SINGLE;
            [self.superview bringSubviewToFront:self];
        } else if (isBeginDate) {
            self.backgroundCover.rangePosition = RANGE_POSITION_BEGIN;
            [self.superview bringSubviewToFront:self];
        } else if (isEndDate) {
            self.backgroundCover.rangePosition = RANGE_POSITION_END;
            [self.superview bringSubviewToFront:self];
        } else {
            self.backgroundCover.rangePosition = RANGE_POSITION_MIDDLE;
        }
    } else {
        self.backgroundCover.rangePosition = RANGE_POSITION_NONE;
        [self.superview sendSubviewToBack:self];
    }
    
    self.backgroundCover.inEdit = self.inEdit;
    
    if (self.enlargePoint == ENLARGE_BEGIN_POINT) {
        [self.backgroundCover enlargeBeginPoint:YES];
        [self.backgroundCover enlargeEndPoint:NO];
    } else if (self.enlargePoint == ENLARGE_END_POINT) {
        [self.backgroundCover enlargeBeginPoint:NO];
        [self.backgroundCover enlargeEndPoint:YES];
    } else {
        [self.backgroundCover enlargeBeginPoint:NO];
        [self.backgroundCover enlargeEndPoint:NO];
    }
}

- (void)setDayLabelText:(NSString *)text
{
    self.dayLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:self.dayLabelAttributes];
}

- (void)setFutureDayLabelText:(NSString *)text
{
    self.dayLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:self.futureDayLabelAttributes];
}


- (void)setTodayLabelText:(NSString *)text
{
    self.dayLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:self.todayLabelAttributes];
}

- (void)setMonthLabelText:(NSString *)text
{
    self.monthLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:self.monthLabelAttributes];
}

- (void)setYearLabelText:(NSString *)text
{
    self.yearLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:self.yearLabelAttributes];
}


- (BOOL)isToday
{
    return [GLDateUtils date:self.date isSameDayAsDate:[NSDate date]];
}

- (BOOL)isFuture
{
    return [self.date compare:[NSDate date]] == NSOrderedDescending;
}

static NSArray *months;
- (NSString *)monthText:(NSInteger)month {
    if (!months) {
        months = @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"];
    }
    return [months objectAtIndex:(month - 1)];
}

@end
