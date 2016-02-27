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
#import "RKInterfaceConstants.h"
#import "RKCalendarPermissionView.h"

// Calendar View File Imports
#import "RKCalendarView.h"

// Agenda Table View File imports
#import "RKAgendaTableViewCell.h"
#import "RKAgendaTableViewSectionHeaderView.h"

// Degrees to radians
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

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

@interface RKCalendarViewController() <UITableViewDataSource, UITableViewDelegate, RKCalendarViewDelegate>

// Helper Variables
@property (nonatomic, strong) RKCalendarDataManager *calendarManager;
@property (nonatomic, assign) BOOL isAgendaScrolledByCalendarView;

// Menu View
@property (nonatomic, strong) IBOutlet UIView *menuView;
@property (nonatomic, strong) IBOutlet UILabel *menuMonthLabel;

// Agenda Table View
@property (nonatomic, strong) IBOutlet UITableView *agendaTableView;
@property (nonatomic, strong) RKAgendaTableViewCell *sizingCell;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *agendaTableViewHeightConstraint;
@property (nonatomic, assign) RKAgendaTableViewScrollDirection agendTableViewScrollDirection;

// Calendar View
@property (nonatomic, strong) IBOutlet RKCalendarView *calendarView;


// Today button
@property (nonatomic, strong) IBOutlet UIButton *todayButton;

// Permission Access View
@property (nonatomic, strong) RKCalendarPermissionView *permissionView;

// Actions
- (IBAction)todayButtonPressed:(id)sender;

@end

@implementation RKCalendarViewController

#pragma mark - View Loading methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Generic initialization
    [self basicInitialization];
    
    // Table view initialization
    [self setupAgendaTableView];
    
    // Anothe calendar view initialization
    [self setupCalendarView];
    
    // Today button initialization
    [self setupTodayButton];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateAgendaTableViewHeightWithExpansion:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.calendarView reload];
    
    [self.calendarView scrollToDate:[NSDate date] animated:YES];
}

#pragma mark - Helper Methods
- (void) basicInitialization {
    // Get an instance of Data manager for reference
    _calendarManager = [RKCalendarDataManager sharedInstance];
    
    // Initiate permission view and hide it for now
    self.permissionView = [[RKCalendarPermissionView alloc] init];
    self.permissionView.hidden = YES;
    [self.view addSubview:self.permissionView];
    
    // Add notification observers
    [self addNotificationObservers];
}

#pragma mark - Notification Observers

- (void)addNotificationObservers {
    // Add an observer to receive Calendar changes made in the background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(calendarManagerDidUpdateData:)
                                                 name:RKCalendarDataManagerDidUpdateEventsNotification
                                               object:nil];

    // Add an observer to received calendar access permission change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(calendarAccessPermissionDidChange:)
                                                 name:RKCalendarDataManagerAccessPermissionDidChangeNotification
                                               object:nil];
}

- (void)removeNotificatonObservers {
    
    // Remove observer for calendar changes
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:RKCalendarDataManagerDidUpdateEventsNotification
                                                  object:nil];
    
    // Remove observer for calendar permission
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:RKCalendarDataManagerAccessPermissionDidChangeNotification
                                                  object:nil];
    
}

- (void)calendarManagerDidUpdateData:(NSNotification *)notification {
    
    // Update Agenda View
    [self.agendaTableView reloadData];
    
    // Update Calendar View
    [self.calendarView reload];
}

- (void)calendarAccessPermissionDidChange:(NSNotification *)notification {
    BOOL hasCalendarPermission = [(NSNumber *)notification.object boolValue];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (hasCalendarPermission) {
            if (self.calendarManager.isDummyEventsData) {
                // Enable Agenda table view
                self.agendaTableView.alpha = 0.3;
                [self.agendaTableView setUserInteractionEnabled:NO];
                
                // Show permission view in the context of dummy data information
                [self.permissionView setOpenSettingsButtonHidden:YES];
                
                self.permissionView.titleLabel.text = @"No events found";
                self.permissionView.messageLabel.text = @"Why don't you cal up a couple of mates and create an event to meet up.";
                
                // Set permission view frame and show it
                self.permissionView.frame = CGRectMake(self.agendaTableView.frame.origin.x + 40.0f, self.agendaTableView.frame.origin.y + self.agendaTableView.frame.size.height/2 - self.permissionView.frame.size.height/2, self.agendaTableView.frame.size.width - 80.0f, 100.0f);
                self.permissionView.layer.borderWidth = 0.5f;
                self.permissionView.layer.borderColor = [UIColor blackColor].CGColor;
                self.permissionView.layer.cornerRadius = 5.0f;
                self.permissionView.hidden = NO;
            }
            else {
                // Enable Agenda table view
                self.agendaTableView.alpha = 1.0;
                [self.agendaTableView setUserInteractionEnabled:YES];

                // Hide permission view
                self.permissionView.hidden = YES;
            }
        }
        else {
            // Tone down the alpha for agenda table view & disable interaction
            self.agendaTableView.alpha = 0.5;
            [self.agendaTableView setUserInteractionEnabled:NO];
            
            
            // Set permission view frame and show it
            [self.permissionView setOpenSettingsButtonHidden:NO];
            self.permissionView.frame = CGRectMake(self.agendaTableView.frame.origin.x + 20.0f, self.agendaTableView.frame.origin.y + self.agendaTableView.frame.size.height/2 - self.permissionView.frame.size.height/2, self.agendaTableView.frame.size.width - 40.0f, 150.0f);
            self.permissionView.layer.borderWidth = 0.0f;
            self.permissionView.layer.cornerRadius = 5.0f;
            self.permissionView.hidden = NO;
        }
    });
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

#pragma mark - MENU VIEW
#pragma mark Month Label Display Helper
- (void) updateMonthLabelForMenuViewForDate:(NSDate *)date {
    self.menuMonthLabel.text = [date monthYearString];
}

#pragma mark - CALENDAR VIEW

#pragma mark Calendar View Setup
- (void)setupCalendarView {
    self.calendarView.delegate = self;
    
    self.calendarView.startDate = [self.calendarManager startDateForCalendarView];
    self.calendarView.endDate = [self.calendarManager endDateForCalendarView];
    
    [RKCalendarView appearance].rowHeight = RK_CALENDAR_VIEW_ROW_HEIGHT;
}

#pragma mark Calendar View Delegate

-(void)calendarView:(RKCalendarView *)calendarView didSelectDate:(NSDate *)date {
    // Scroll agenda view to nearest event on the selected date
    [self scrollAgendaTableViewToDate:date];
    
    // Update month label on top menu
    [self updateMonthLabelForMenuViewForDate:date];
}

- (void)calenderViewWillBeginDragging:(RKCalendarView *)calendarView {
    [UIView animateWithDuration:0.3f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self updateAgendaTableViewHeightWithExpansion:NO];
                     }
                     completion:nil];
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
    
    // Ensure separators do not have left margin
    if([self.agendaTableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        self.agendaTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    
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
    return RK_AGENDA_VIEW_ROW_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    RKAgendaTableViewSectionHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[RKAgendaTableViewSectionHeaderView reuseIdentifier]];
    
    view.sectionDate = [self.calendarManager.sortedEventsDaysArray objectAtIndex:section];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return RK_AGENDA_VIEW_SECTION_HEIGHT;
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Get date for seletced section
    NSDate *selectedAgendaDate = [self.calendarManager.sortedEventsDaysArray objectAtIndex:indexPath.section];
    
    // Scroll to selected section date in calendar view
    [self scrollCalendarViewToDate:selectedAgendaDate];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // Update table view with animation
    [UIView animateWithDuration:0.3f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self updateAgendaTableViewHeightWithExpansion:YES];
                     }
                     completion:nil];
    
    // Display Today button
    [self setTodayButtonHidden:NO animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[self.agendaTableView class]] && !self.isAgendaScrolledByCalendarView) {
        
        [self updateTodayButtonDisplay];
        
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
    if ([scrollView isKindOfClass:[self.agendaTableView class]] && !self.isAgendaScrolledByCalendarView) {
        [self scrollCalendarViewToDate:[self.calendarManager.sortedEventsDaysArray objectAtIndex:0]];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // Safety Code: Ensure date selected on calendar view is the date for the header on top of visible content
    if ([scrollView isKindOfClass:[self.agendaTableView class]] && !self.isAgendaScrolledByCalendarView) {
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
    if(self.calendarManager.accessToCalendarGranted) {
        // Check if there are any events on given day
        NSUInteger sectionIndex = [self.calendarManager sectionIndexForEventNearestToDate:date];
        
        NSIndexPath *indexPathForSection = [NSIndexPath indexPathForRow:0
                                                              inSection:sectionIndex];

        if (indexPathForSection) {
            self.isAgendaScrolledByCalendarView = YES;
            self.agendTableViewScrollDirection = RKAgendaTableViewScrollDirectionNone;
            
            [self.agendaTableView scrollToRowAtIndexPath:indexPathForSection
                                        atScrollPosition:UITableViewScrollPositionTop
                                                animated:YES];
            self.isAgendaScrolledByCalendarView = NO;
        }
    }
}

- (void)scrollCalendarViewToDate:(NSDate *)date {
    // Update month year label
    [self updateMonthLabelForMenuViewForDate:date];
    
    // Scroll to selected date
    [self.calendarView scrollToDate:date animated:YES];
}

- (void)updateAgendaTableViewHeightWithExpansion:(BOOL)shouldExpandAgendaView {
    NSUInteger numberOfRows = 4;
    if (shouldExpandAgendaView) {
        numberOfRows = 2;
    }
    
    [self updateAgendaTableViewHeightToDiplayNumberOfRowsofCalendarView:numberOfRows];
}

-(void)updateAgendaTableViewHeightToDiplayNumberOfRowsofCalendarView:(NSUInteger)numberOfRows {
    // Set Table View height constraint
    self.agendaTableViewHeightConstraint.constant = self.view.frame.size.height - (self.menuView.frame.origin.y + self.menuView.frame.size.height) - ([self.calendarView heightToDisplayNumberOfRows:numberOfRows]);
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}


#pragma mark - TODAY BUTTON

#pragma mark Setup Button

- (void)setupTodayButton {
    [self setTodayButtonHidden:YES animated:NO];
}

#pragma mark Update Button Display
-(void)updateTodayButtonDisplay {
    CGFloat relaxedRotationLimit = 80.0f;
    CGFloat maximumDegreeRotationForButton = 90.0f;
    
    // Get today button
    NSUInteger todaySectionIndex = [self.calendarManager sectionIndexForEventNearestToDate:[NSDate date]];
    
    CGRect rect = [self.agendaTableView rectForSection:todaySectionIndex];
    CGFloat yOrigin = rect.origin.y;
    
    CGFloat yDifference = self.agendaTableView.contentOffset.y - yOrigin;
    CGFloat degreeRotation;

    if (ABS(yDifference) <= relaxedRotationLimit) {
        yDifference = yDifference/10;
    }
    else {
        if (yDifference >= 0) {
            degreeRotation = relaxedRotationLimit/10 + (yDifference - relaxedRotationLimit)/40;
        }
        else {
            degreeRotation = -relaxedRotationLimit/10 - (ABS(yDifference)-relaxedRotationLimit)/40;
        }
    }
    
    
    if (degreeRotation > maximumDegreeRotationForButton) {
        degreeRotation = maximumDegreeRotationForButton;
    }
    else if(degreeRotation < -maximumDegreeRotationForButton){
        degreeRotation = -maximumDegreeRotationForButton;
    }
    
    
    self.todayButton.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degreeRotation));
}

- (void)setTodayButtonHidden:(BOOL)hidden animated:(BOOL)animated {
    if (animated) {
        [UIView transitionWithView:self.todayButton
                          duration:0.4
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
        
        self.todayButton.hidden = hidden;
    }
    else {
        self.todayButton.hidden = hidden;
    }
}


#pragma mark Today Button Action
- (IBAction)todayButtonPressed:(id)sender {
    [self scrollAgendaTableViewToDate:[NSDate date]];
    [self scrollCalendarViewToDate:[NSDate date]];
}
@end
