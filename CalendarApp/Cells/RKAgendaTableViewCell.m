//
//  RKAgendaTableViewCell.m
//  CalendarApp
//
//  Created by Rahul Khanna on 2/12/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import "RKAgendaTableViewCell.h"
#import "NSDate+RKCalendarHelper.h"
#import "RKCalendarDataHelper.h"

@interface RKAgendaTableViewCell()

@property (nonatomic, strong) IBOutlet UILabel *dayTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventDurationLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventLocationLabel;

@end

@implementation RKAgendaTableViewCell
#pragma mark - Initialization
- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        NSString *currentClassName = NSStringFromClass([RKAgendaTableViewCell class]);
        
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:currentClassName owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[RKAgendaTableViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        
        // Custom initialization
        [self basicInitialization];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        NSString *currentClassName = NSStringFromClass([RKAgendaTableViewCell class]);
        
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:currentClassName owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[RKAgendaTableViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Custom initialization
        [self basicInitialization];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    [self basicInitialization];
}

- (void) basicInitialization {
    
}

#pragma mark - Identifier
+ (NSString *)reuseIdentifier {
    return NSStringFromClass([RKAgendaTableViewCell class]);
}

#pragma mark - Accessor Methods
- (void)setEvent:(EKEvent *)event {
    _event = event;
    [self configureDisplayInfo];
}

#pragma mark - Configurator
- (void)configureDisplayInfo {
    if (self.event) {
        // Configure time display
        [self configureEventTimingDisplay];
        
        // Configure event information display
        [self configureEventInfoDisplay];
    }
}

- (void)configureEventTimingDisplay {
    // Check if event is an all day event
    if (self.event.isAllDay) {
        self.dayTimeLabel.text = @"ALL DAY";
        self.eventDurationLabel.text = @"";
    } else {
        // Find the date components of the event
        self.dayTimeLabel.text = [self.event.startDate amPmTimeStampString];
        self.eventDurationLabel.text = [RKCalendarDataHelper stringForTimeDifferenceBetweenStartDate:self.event.startDate
                                                                                          andEndDate:self.event.endDate];
    }
}

- (void)configureEventInfoDisplay {
    self.eventTitleLabel.text = self.event.title;
    self.eventLocationLabel.text = self.event.location;
}
@end
