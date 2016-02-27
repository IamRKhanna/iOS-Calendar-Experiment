//
//  RKCalendarCollectionViewCell.m
//  CalendarApp
//
//  Created by Rahul Khanna on 2/24/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import "RKCalendarCollectionViewCell.h"
#import "UIColor+HexString.h"
#import "RKCalendarDataHelper.h"
#import "RKCalendarDataManager.h"
#import "BackgroundCoverView.h"

@interface RKCalendarCollectionViewCell()

@property (nonatomic, weak) IBOutlet BackgroundCoverView *backgroundCoverView;
@property (nonatomic, weak) IBOutlet UILabel *monthLabel;
@property (nonatomic, weak) IBOutlet UILabel *dayLabel;
@property (nonatomic, weak) IBOutlet UILabel *yearLabel;
@property (nonatomic, weak) IBOutlet UIView *agendaIndicatorView;

// Constraints
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *monthLabelTopSpaceToContainerConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *dayLabelVerticalCenterAlignConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *dayLabelBottomSpaceToContainerConstraint;

// Border properties
@property (nonatomic, weak) IBOutlet UIView *topBorderView;
@property (nonatomic, weak) IBOutlet UIView *bottomBorderView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topBorderViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomBorderViewHeightConstraint;

// Date Modal for this cell
@property (nonatomic, strong) NSDate *date;

@end

@implementation RKCalendarCollectionViewCell

#pragma mark - Initialization
- (instancetype)init {
	self = [super init];

    if (self) {
        NSString *currentClassName = NSStringFromClass([self class]);
        
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:currentClassName owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[self class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        
        [self basicInitialization];
	}
	
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
    if (self) {
        NSString *currentClassName = NSStringFromClass([self class]);
        
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:currentClassName owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[self class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        
        self.frame = frame;
        
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

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    [self basicInitialization];
}

- (void) basicInitialization {
    // Load Appearance
    [self loadAppearance];
    
    // Update UI
    [self updateUI];
}

- (void)loadAppearance {
    RKCalendarCollectionViewCell *cellAppearance = [[self class] appearance];
    
    self.borderColor = cellAppearance.borderColor ?: [UIColor colorFromHexString:@"#E3E3E3"];
    self.evenMonthBackgroundColor = cellAppearance.evenMonthBackgroundColor ?: [UIColor colorFromHexString:@"#f8f8f8"];
    self.oddMonthBackgroundColor = cellAppearance.oddMonthBackgroundColor ?: [UIColor whiteColor];
    
    self.dayLabelAttributes = cellAppearance.dayLabelAttributes ?: @{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:[UIColor colorFromHexString:@"#9B9B9B"]};
    self.todayLabelAttributes = cellAppearance.dayLabelAttributes ?:  @{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:[UIColor blueColor]};
    self.monthLabelAttributes = cellAppearance.monthLabelAttributes ?: @{NSFontAttributeName:[UIFont systemFontOfSize:8], NSForegroundColorAttributeName:[UIColor colorFromHexString:@"#9B9B9B"]};
    self.yearLabelAttributes = cellAppearance.yearLabelAttributes ?: @{NSFontAttributeName:[UIFont systemFontOfSize:8], NSForegroundColorAttributeName:[UIColor colorFromHexString:@"#9B9B9B"]};
    
    self.backgroundCoverView.heightPadding = cellAppearance.backgroundCoverHeightPadding ?: 10.0f;
    
    // Appearance settings for Agenda Indicator view
    self.agendaIndicatorView.layer.cornerRadius = self.agendaIndicatorView.frame.size.width/2;
    self.todayAgendaIndicatorColor = cellAppearance.todayAgendaIndicatorColor ?: [UIColor blueColor];
    self.agendaIndicatorColor = cellAppearance.agendaIndicatorColor ?: [UIColor colorFromHexString:@"#E6E6E6"];
}

- (void)updateUI {
    
    // Setup Borders
    self.topBorderViewHeightConstraint.constant = 0.25;
    self.bottomBorderViewHeightConstraint.constant = 0.25;
    self.topBorderView.backgroundColor = self.borderColor;
    self.bottomBorderView.backgroundColor = self.borderColor;
}

#pragma mark - Getter/Setter
-(void)setDate:(NSDate *)date {
    _date = date;

    [self updateDateInfoUI];
}

- (void)setDate:(NSDate *)date isSelected:(BOOL)isSelected {
    // Set date
    self.date = date;
    
    // Set selected state
    [self updateDisplayForSelectedState:isSelected];
}

#pragma mark - Display Handlers

- (void)updateDisplayForSelectedState:(BOOL)isSelected {
    if (isSelected) {
        [self updateSelectedStateInfoUI];
    } else {
        [self updateDateInfoUI];
    }
}

- (void)updateDateInfoUI {
    
    NSDateComponents *components = [[RKCalendarDataHelper calendar] components:NSCalendarUnitYear|NSCalendarUnitDay|NSCalendarUnitMonth fromDate:self.date];
    NSInteger year = components.year;
    NSInteger day = components.day;
    NSInteger month = components.month;
    
    // month background color
    if (month % 2 == 0) {
        self.backgroundCoverView.backgroundColor = self.evenMonthBackgroundColor;
    } else {
        self.backgroundCoverView.backgroundColor = self.oddMonthBackgroundColor;
    }
    self.backgroundCoverView.fillColor = [UIColor colorWithCGColor:self.backgroundCoverView.backgroundColor.CGColor];
    [self.backgroundCoverView setNeedsDisplay];
    
    // Set day label text
    BOOL isToday = [[RKCalendarDataHelper calendar] isDateInToday:self.date];
    [self setDayLabelText:[NSString stringWithFormat:@"%ld", day] isToday:isToday];
    
    // Set month/today text
    if (day == 1) {
        [self setMonthLabelText:[self monthText:month]];
    } else {
        [self setMonthLabelText:@""];
    }
    
    // Set year text
    if ([RKCalendarDataHelper isYearThisYear:year] || day != 1 || isToday) {
        [self setYearLabelText:@""];
        
        if (day == 1) {
            [self setShouldDisplaceLabelsForFirstDayCell:YES];
        }
    } else {
        [self setYearLabelText:[NSString stringWithFormat:@"%ld", year]];
    }
    
    // Agenda indicator view
    if ([[RKCalendarDataManager sharedInstance] doesEventExistForDate:self.date] && day != 1 && [RKCalendarDataManager sharedInstance].isDummyEventsData == NO) {
        self.agendaIndicatorView.hidden = NO;
        if (isToday) {
            self.agendaIndicatorView.backgroundColor = self.todayAgendaIndicatorColor;
        } else {
            self.agendaIndicatorView.backgroundColor = self.agendaIndicatorColor;
        }
    } else {
        self.agendaIndicatorView.hidden = YES;
    }
}

- (void)setMonthLabelText:(NSString *)text {
    self.monthLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:self.monthLabelAttributes];
}

- (void)setDayLabelText:(NSString *)text isToday:(BOOL)isToday {
    if (isToday) {
        self.dayLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:self.todayLabelAttributes];
    } else {
        self.dayLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:self.dayLabelAttributes];
    }
}

- (void)setYearLabelText:(NSString *)text {
    self.yearLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:self.yearLabelAttributes];
}

- (void)updateSelectedStateInfoUI {
    self.backgroundCoverView.fillColor = [UIColor colorFromHexString:@"#0073C6"];
    [self.backgroundCoverView setNeedsDisplay];
    
    self.dayLabel.attributedText = [self updatedAttributedStringForSelectedAttributedString:self.dayLabel.attributedText];
    [self setMonthLabelText:@""];
    [self setYearLabelText:@""];
    
    NSDateComponents *components = [[RKCalendarDataHelper calendar] components:NSCalendarUnitYear|NSCalendarUnitDay|NSCalendarUnitMonth fromDate:self.date];
    NSInteger year = components.year;
    NSInteger day = components.day;
    
    if ([RKCalendarDataHelper isYearThisYear:year] && day == 1) {
        [self setShouldDisplaceLabelsForFirstDayCell:NO];
    }
    
    self.agendaIndicatorView.hidden = YES;
}

- (NSAttributedString *)updatedAttributedStringForSelectedAttributedString:(NSAttributedString *)attributedString {
    NSMutableAttributedString *selectedAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    [selectedAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attributedString.length)];

    return (NSAttributedString *)selectedAttributedString;
}

- (void)setShouldDisplaceLabelsForFirstDayCell:(BOOL)shouldDisplace {
    [self.dayLabelVerticalCenterAlignConstraint setActive:!shouldDisplace];
    [self.dayLabelBottomSpaceToContainerConstraint setActive:shouldDisplace];
    
    if (shouldDisplace) {
        self.monthLabelTopSpaceToContainerConstraint.constant = 9.0f;
        self.dayLabelBottomSpaceToContainerConstraint.constant = 5.0f;
    } else {
        self.monthLabelTopSpaceToContainerConstraint.constant = 2.0f;
    }
    
    [self layoutIfNeeded];
}

#pragma mark - Reuse Identifier
+  (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

-(void)prepareForReuse {
    [self setShouldDisplaceLabelsForFirstDayCell:NO];
}

#pragma mark - Helper Methods
static NSArray *_rkCalendarCollectionViewCellMonthStringArray;
- (NSString *)monthText:(NSInteger)month {
    if (!_rkCalendarCollectionViewCellMonthStringArray) {
        _rkCalendarCollectionViewCellMonthStringArray = @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"];
    }
    return [_rkCalendarCollectionViewCellMonthStringArray objectAtIndex:(month - 1)];
}
@end