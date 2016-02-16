//
//  RKCalendarViewController.m
//  CalendarApp
//
//  Created by Rahul Khanna on 2/12/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import "RKCalendarViewController.h"
#import "RKCalendarDataManager.h"
#import "RKCalendarDataHelper.h"
#import "UIColor+HexString.h"
#import "NSDate+RKCalendarHelper.h"

// Calendar View File Imports
#import "GLCalendarView.h"
#import "GLCalendarDayCell.h"

// Agenda Table View File imports
#import "RKAgendaTableViewCell.h"
#import "RKAgendaTableViewSectionHeaderView.h"

/**
 *  Enum to determine the direction of Agenda View scrolling
 */
typedef NS_ENUM(NSUInteger, RKAgendaTableViewScrollDirection) {
    /**
     *  No Direction
     */
    RKAgendaTableViewScrollDirectionNone = 0,
    /**
     *  Direction upwards. When vertical velocity is less than 0
     */
    RKAgendaTableViewScrollDirectionUp,
    /**
     *  Direction downwards. When vertical velocity is greater than 0
     */
    RKAgendaTableViewScrollDirectionDown
};

@interface RKCalendarViewController() <UITableViewDataSource, UITableViewDelegate, GLCalendarViewDelegate>

// Helper Variables
@property (nonatomic, weak) RKCalendarDataManager *calendarManager;

// Menu View
@property (nonatomic, weak) IBOutlet UIView *menuView;

// Agenda Table View
@property (nonatomic, weak) IBOutlet UITableView *agendaTableView;
@property (nonatomic, strong) RKAgendaTableViewCell *sizingCell;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (nonatomic, assign) RKAgendaTableViewScrollDirection agendTableViewScrollDirection;

// Calendar View
@property (nonatomic, weak) IBOutlet GLCalendarView *calendarView;


@end

@implementation RKCalendarViewController

#pragma mark - View Loading methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Generic initialization
    [self basicInitialization];
    
    // Table view initialization
    [self setupAgendaTableView];
    
    // Calendar view initialization
    [self setupCalendarView];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.calendarView reload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.calendarView scrollToDate:[NSDate date] animated:YES];
}

#pragma mark - Helper Methods
- (void) basicInitialization {
    // Get an instance of Data manager for reference
    _calendarManager = [RKCalendarDataManager sharedInstance];
}

#pragma mark - Notification Observers

- (void)addNotificationObservers {
    // Add an observer to receive Calendar changes made in the background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(calendarManagerDidUpdateData:)
                                                 name:RKCalendarDataManagerDidUpdateEventsNotification
                                               object:nil];
}

- (void)removeNotificatonObservers {
    
    // Remove observer for calendar changes
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:RKCalendarDataManagerDidUpdateEventsNotification
                                                  object:nil];
    
}

- (void)calendarManagerDidUpdateData:(NSNotification *)notification {
    
    // Update Table View
    [self.agendaTableView reloadData];
}



#pragma mark - Key Value Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isEventsDataReady"]) {
        BOOL isDataReady = [[(NSNumber *)change valueForKey:NSKeyValueChangeNewKey] boolValue];
        if (isDataReady) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.agendaTableView reloadData];
                [self scrollAgendaTableViewToDate:[NSDate date]];
            });
            [self.calendarManager removeObserver:self
                                      forKeyPath:@"isEventsDataReady"];
        }
    }
}

#pragma mark - CALENDAR VIEW

#pragma mark Calendar View Setup
- (void)setupCalendarView {
    self.calendarView.firstDate = [self.calendarManager startDateForCalendarView];
    self.calendarView.lastDate = [self.calendarManager endDateForCalendarView];
    self.calendarView.scrollDecelartionRate = UIScrollViewDecelerationRateNormal;
    self.calendarView.delegate = self;
    
    // Create calendar range for today
    GLCalendarDateRange *todayRange = [self calendarRangeForDate:[NSDate date]];
    self.calendarView.ranges = [@[todayRange] mutableCopy];
    
    // Attributes for calendar view
    [GLCalendarView appearance].rowHeight = 45.0f;
    [GLCalendarView appearance].padding = 0.0f;
    
    [GLCalendarDayCell appearance].dayLabelAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:[UIColor colorFromHexString:@"#9B9B9B"]};
    [GLCalendarDayCell appearance].todayLabelAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:[UIColor colorFromHexString:@"#9B9B9B"]};
    [GLCalendarDayCell appearance].todayBackgroundColor = [UIColor colorFromHexString:@"#0073C6"];
    [GLCalendarDayCell appearance].monthLabelAttributes = @{NSForegroundColorAttributeName:[UIColor colorFromHexString:@"#9B9B9B"]};
    [GLCalendarDayCell appearance].yearLabelAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:7], NSForegroundColorAttributeName:[UIColor colorFromHexString:@"#9B9B9B"]};
    [GLCalendarDayCell appearance].agendaIndicatorColor = [UIColor colorFromHexString:@"#E6E6E6"];
    [GLCalendarDayCell appearance].todayAgendaIndicatorColor = [UIColor blueColor];
}

- (GLCalendarDateRange *)calendarRangeForDate:(NSDate *)date {
    GLCalendarDateRange *range = [GLCalendarDateRange rangeWithBeginDate:date endDate:date];
    range.editable = NO;
    range.backgroundColor = [UIColor colorFromHexString:@"#0073C6"];
    
    return range;
}

#pragma mark Calendar View Delegate
- (BOOL)calenderView:(GLCalendarView *)calendarView canAddRangeWithBeginDate:(NSDate *)beginDate {
    return YES;
}

- (GLCalendarDateRange *)calenderView:(GLCalendarView *)calendarView rangeToAddWithBeginDate:(NSDate *)beginDate {
    // Our range is only one date long so begin and end date shall be same
    GLCalendarDateRange *range = [GLCalendarDateRange rangeWithBeginDate:beginDate endDate:beginDate];
    range.editable = NO;
    range.backgroundColor = [UIColor colorFromHexString:@"#0073C6"];

    [self scrollAgendaTableViewToDate:beginDate];
    
    return range;
}


#pragma mark - AGENDA TABLE VIEW

#pragma mark Table View Setup

- (void)setupAgendaTableView {
    
    // Register Nibs for Table view cells and header views
    [self.agendaTableView registerNib:[UINib nibWithNibName:NSStringFromClass([RKAgendaTableViewCell class])
                                                     bundle:[NSBundle mainBundle]]
               forCellReuseIdentifier:[RKAgendaTableViewCell reuseIdentifier]];
    
    [self.agendaTableView registerClass:[RKAgendaTableViewSectionHeaderView class]
     forHeaderFooterViewReuseIdentifier:[RKAgendaTableViewSectionHeaderView reuseIdentifier]];
    
    // Setup KVO
    [self setupAgendaTableViewKVO];
    
    // Create sizing cell to be used to determine height for each cell
    if (!self.sizingCell) {
        self.sizingCell = [[RKAgendaTableViewCell alloc] init];
        self.sizingCell.hidden = YES;
    }
}

- (void)setupAgendaTableViewKVO {
    [self.calendarManager addObserver:self
                           forKeyPath:@"isEventsDataReady"
                              options:NSKeyValueObservingOptionNew
                              context:nil];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.calendarManager.accessToCalendarGranted && self.calendarManager.isEventsDataReady) {
        return self.calendarManager.sortedEventsDaysArray.count;
    }
    else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *eventsArray = [self.calendarManager.eventsDictionary objectForKey:[self.calendarManager.sortedEventsDaysArray objectAtIndex:section]];
    
    if (eventsArray) {
        return eventsArray.count;
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RKAgendaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[RKAgendaTableViewCell reuseIdentifier]];
    NSArray<EKEvent *> *eventsArray = [self.calendarManager.eventsDictionary objectForKey:[self.calendarManager.sortedEventsDaysArray objectAtIndex:indexPath.section]];
    
    cell.event = [eventsArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    RKAgendaTableViewSectionHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[RKAgendaTableViewSectionHeaderView reuseIdentifier]];
    
    view.sectionDate = [self.calendarManager.sortedEventsDaysArray objectAtIndex:section];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0f;
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Get date for seletced section
    NSDate *selectedAgendaDate = [self.calendarManager.sortedEventsDaysArray objectAtIndex:indexPath.section];
    
    // Scroll to selected section date in calendar view
    [self scrollCalendarViewToDate:selectedAgendaDate];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[self.agendaTableView class]]) {
        CGFloat yVelocity = [scrollView.panGestureRecognizer velocityInView:scrollView].y;

        if (self.agendaTableView.contentOffset.y < 0) {
            // Scroll view is bouncing. No need to check for direction
            self.agendTableViewScrollDirection = RKAgendaTableViewScrollDirectionNone;
        }
        else {
            if (yVelocity < 0) {
                // Table view scrolling upwards
                self.agendTableViewScrollDirection = RKAgendaTableViewScrollDirectionUp;
            } else if (yVelocity > 0) {
                // Table view scrolling downwards
                self.agendTableViewScrollDirection = RKAgendaTableViewScrollDirectionDown;
            }
        }
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    // Safety Code: Ensure top event date is selected on calendar view if scrolled to top
    if ([scrollView isKindOfClass:[self.agendaTableView class]]) {
        [self scrollCalendarViewToDate:[self.calendarManager.sortedEventsDaysArray objectAtIndex:0]];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // Safety Code: Ensure date selected on calendar view is the date for the header on top of visible content
    if ([scrollView isKindOfClass:[self.agendaTableView class]]) {
        UITableViewCell *cell = [[(UITableView *)scrollView visibleCells] objectAtIndex:0];
        NSIndexPath *indexPath = [(UITableView *)scrollView indexPathForCell:cell];
        [self scrollCalendarViewToDate:[self.calendarManager.sortedEventsDaysArray objectAtIndex:indexPath.section]];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    // Just so that calendar does not scroll to dates when scrolling upwards
    if (self.agendTableViewScrollDirection == RKAgendaTableViewScrollDirectionDown) {
        [self scrollCalendarViewToDate:[self.calendarManager.sortedEventsDaysArray objectAtIndex:section]];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    // Just so that calendar does not scroll to dates when scrolling downwards
    if(self.agendTableViewScrollDirection == RKAgendaTableViewScrollDirectionUp) {
         [self scrollCalendarViewToDate:[self.calendarManager.sortedEventsDaysArray objectAtIndex:section+1]];
    }
}

#pragma mark Utility Methods
- (void)scrollAgendaTableViewToDate:(NSDate *)date {
    
    // Check if there are any events on given day
    NSUInteger index = [self.calendarManager indexForEventNearestToDate:date];
    
    NSIndexPath *indexPathForSection = [NSIndexPath indexPathForRow:0
                                                          inSection:index];
    
    [self.agendaTableView scrollToRowAtIndexPath:indexPathForSection
                                atScrollPosition:UITableViewScrollPositionTop
                                        animated:YES];
}

- (void)scrollCalendarViewToDate:(NSDate *)date {
    // Create a date range for this date and add set it to range for calendar view
    GLCalendarDateRange *dateRange = [self calendarRangeForDate:date];
    [self.calendarView addRange:dateRange];

    // Scroll to selected date
    [self.calendarView scrollToDate:date animated:YES];
}

@end
