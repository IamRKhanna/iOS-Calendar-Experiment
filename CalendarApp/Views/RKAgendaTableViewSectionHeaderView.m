//
//  RKAgendaTableViewSectionHeaderView.m
//  CalendarApp
//
//  Created by Rahul Khanna on 2/12/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import "RKAgendaTableViewSectionHeaderView.h"
#import "NSDate+RKCalendarHelper.h"
#import "UIColor+HexString.h"


@interface RKAgendaTableViewSectionHeaderView()

@end


@implementation RKAgendaTableViewSectionHeaderView

#pragma mark - Initialization
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    if (self) {
        NSString *currentClassName = NSStringFromClass([RKAgendaTableViewSectionHeaderView class]);
        
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:currentClassName owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[RKAgendaTableViewSectionHeaderView class]]) {
            return nil;
        }
        
        UIView *nibView = [arrayOfViews firstObject];
        
        UIView *contentView = self.contentView;
        CGSize contentViewSize = contentView.frame.size;
        
        nibView.frame = CGRectMake(0, 0, contentViewSize.width, contentViewSize.height);

        // Since the view extracted from XIB file is a UIView subclass, we should add it as a subview to the content view
        [contentView addSubview:nibView];
        
        // Basic Initialization
        [self basicInitialization];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self basicInitialization];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self basicInitialization];
    }
    
    return self;
}

/**
 *  Common method for initialization
 */
- (void)basicInitialization {
    
    self.backgroundColor = [UIColor colorFromHexString:@"#F8F8F8"];
    
    // Apply Auto Resizing Mask On Content View
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
}

#pragma mark - Identifier
+ (NSString *)reuseIdentifier {
    return NSStringFromClass([RKAgendaTableViewSectionHeaderView class]);
}

#pragma mark - Accessors

-(void)setSectionDate:(NSDate *)sectionDate {
    _sectionDate = sectionDate;
    
    [self configureDateLabelDisplay];
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    self.contentView.backgroundColor = backgroundColor;
}

#pragma mark - Helper
- (void)configureDateLabelDisplay {
    if (self.sectionDate) {
        
        // Display date info
        if ([self.sectionDate isToday]) {
            NSString *dateString = [NSString stringWithFormat:@"TODAY • %@", [self.sectionDate weekdayMonthDayString]];
            self.dateLabel.text = [dateString uppercaseString];
            self.dateLabel.textColor = [UIColor blueColor];
        }
        else if([self.sectionDate isTomorrow]) {
            NSString *dateString = [NSString stringWithFormat:@"TOMORROW • %@", [self.sectionDate weekdayMonthDayString]];
            self.dateLabel.text = [dateString uppercaseString];
            self.dateLabel.textColor = [UIColor colorFromHexString:@"#A0A0A0"];
        }
        else if ([self.sectionDate isYesterday]) {
            NSString *dateString = [NSString stringWithFormat:@"YESTERDAY • %@", [self.sectionDate weekdayMonthDayString]];
            self.dateLabel.text = [dateString uppercaseString];
            self.dateLabel.textColor = [UIColor colorFromHexString:@"#A0A0A0"];
        }
        else {
            self.dateLabel.text = [[self.sectionDate weekdayMonthDayString] uppercaseString];
            self.dateLabel.textColor = [UIColor colorFromHexString:@"#A0A0A0"];
        }
    }
}

@end
