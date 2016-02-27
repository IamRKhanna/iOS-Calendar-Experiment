//
//  RKCalendarMonthCoverScrollView.m
//  CalendarApp
//
//  Created by Rahul Khanna on 2/27/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import "RKCalendarMonthCoverScrollView.h"
#import "RKCalendarDataHelper.h"

@interface RKCalendarMonthCoverScrollView()

@property (nonatomic, copy) NSDate *firstDate;
@property (nonatomic, copy) NSDate *lastDate;

@end

@implementation RKCalendarMonthCoverScrollView

- (void)updateWithFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate calendar:(NSCalendar *)calendar rowHeight:(CGFloat)rowHeight
{
    if ([RKCalendarDataHelper isdate:firstDate sameAsDate:self.firstDate] && [RKCalendarDataHelper isdate:lastDate sameAsDate:self.lastDate]) {
        return;
    }
    self.firstDate = firstDate;
    self.lastDate = lastDate;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    monthFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSDateComponents *today = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
    
    for (NSDate *date = [RKCalendarDataHelper monthFirstDate:firstDate]; [date compare:lastDate] < 0; date = [RKCalendarDataHelper dateByAddingYears:0 months:1 days:0 toDate:date]) {
        NSInteger dayDiff = [RKCalendarDataHelper daysBetweenDate:firstDate andDate:date];
        if (dayDiff < 0) {
            continue;
        }
        
        NSDateComponents *components = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];
        
        UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), rowHeight * 3)];
        monthLabel.backgroundColor = [UIColor clearColor];
        monthLabel.lineBreakMode = NSLineBreakByWordWrapping;
        monthLabel.numberOfLines = 0;
        monthLabel.textAlignment = NSTextAlignmentCenter;
        NSString *labelText;
        if (today.year == components.year) {
            monthFormatter.dateFormat = @"MMMM";
            labelText = [monthFormatter stringFromDate:date];
        } else {
            monthFormatter.dateFormat = @"MMMM y";
            labelText = [monthFormatter stringFromDate:date];
        }
        
        monthLabel.attributedText = [[NSAttributedString alloc] initWithString:labelText attributes:self.textAttributes];;
        monthLabel.center = CGPointMake(CGRectGetMidX(self.bounds), ceilf(rowHeight * (dayDiff / 7 + 2))+rowHeight/2);
        monthLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:monthLabel];
    }
}


@end
