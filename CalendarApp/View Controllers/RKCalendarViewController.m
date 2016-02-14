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


@interface RKCalendarViewController() <UITableViewDataSource, UITableViewDelegate>

// Helper Variables
@property (nonatomic, weak) RKCalendarDataManager *calendarManager;

// Menu View
@property (nonatomic, strong) IBOutlet UIView *menuView;

// Agenda Table View
@property (nonatomic, strong) IBOutlet UITableView *agendaTableView;
@property (nonatomic, strong) RKAgendaTableViewCell *sizingCell;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

// Calendar View
@property (nonatomic, strong) IBOutlet GLCalendarView *calendarView;


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
    
    [GLCalendarView appearance].rowHeight = 45.0f;
    [GLCalendarView appearance].padding = 0.0f;
    
    [GLCalendarDayCell appearance].dayLabelAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:[UIColor colorFromHexString:@"#9B9B9B"]};
    [GLCalendarDayCell appearance].todayLabelAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15]};
    [GLCalendarDayCell appearance].todayBackgroundColor = [UIColor colorFromHexString:@"#0073C6"];
    [GLCalendarDayCell appearance].monthLabelAttributes = @{NSForegroundColorAttributeName:[UIColor colorFromHexString:@"#9B9B9B"]};
    [GLCalendarDayCell appearance].yearLabelAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:7], NSForegroundColorAttributeName:[UIColor colorFromHexString:@"#9B9B9B"]};
    [GLCalendarDayCell appearance].agendaIndicatorColor = [UIColor colorFromHexString:@"#E6E6E6"];
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
    view.backgroundColor = [UIColor colorFromHexString:@"#F8F8F8"];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0f;
}

#pragma Utility Methods
- (void)scrollAgendaTableViewToDate:(NSDate *)date {
    // Find weekday info without timestamp
    NSDate *scrollDay = [RKCalendarDataHelper dateAtBeginningOfDayForDate:date];
    
    // Check if there are any events on given day
    if ([self.calendarManager doesEventExistForDate:date]) {
        NSIndexPath *indexPathForSection = [NSIndexPath indexPathForRow:0
                                                              inSection:[self.calendarManager.sortedEventsDaysArray indexOfObject:scrollDay]];
        
        [self.agendaTableView scrollToRowAtIndexPath:indexPathForSection
                                    atScrollPosition:UITableViewScrollPositionTop
                                            animated:YES];
    }
    else {
        // TODO: Find next event after this date
        
    }
}

@end
