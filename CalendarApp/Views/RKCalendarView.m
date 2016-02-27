//
//  RKCalendarView.m
//  CalendarApp
//
//  Created by Rahul Khanna on 2/24/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import "RKCalendarView.h"
#import "RKCalendarDataHelper.h"
#import "RKCalendarMonthCoverScrollView.h"

// Collection View
#import "RKCalendarCollectionViewCell.h"

@interface RKCalendarView() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) IBOutlet UIView *weekDayTitleView;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet RKCalendarMonthCoverScrollView *monthCoverScrollView;

@property (nonatomic, strong) NSDate *calendarViewStartDate;
@property (nonatomic, strong) NSDate *calendarViewEndDate;

@property (nonatomic, strong) NSIndexPath *currentSelectedIndexPath;

@end

@implementation RKCalendarView

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

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];

    if (self) {
        
        UIView *view = [[[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
        view.frame = self.bounds;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:view];
        
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

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self basicInitialization];
}

- (void)basicInitialization {
    
    [self loadAppearance];
    
    // Setup month cover scroll view
    self.monthCoverScrollView.hidden = YES;

    // Setup Collection View
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([RKCalendarCollectionViewCell class])
                                                    bundle:nil]
          forCellWithReuseIdentifier:[RKCalendarCollectionViewCell reuseIdentifier]];
    
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    [self setupWeekDayTitle];
}

- (void)loadAppearance {
    RKCalendarView *appearance = [[self class] appearance];
    
    self.rowHeight = appearance.rowHeight ?: 45.0f;
    self.monthCoverLabelAttributes = appearance.monthCoverLabelAttributes ?: @{NSFontAttributeName:[UIFont systemFontOfSize:18]};
    self.weekDayTitleAttributes = appearance.weekDayTitleAttributes ?: @{NSFontAttributeName:[UIFont systemFontOfSize:8], NSForegroundColorAttributeName:[UIColor grayColor]};
    self.weekdayTitleViewBackgroundColor = appearance.weekdayTitleViewBackgroundColor ?: nil;
}

#pragma mark - Getter/Setter

-(void)setStartDate:(NSDate *)startDate {
    _startDate = startDate;
    
    self.calendarViewStartDate = [RKCalendarDataHelper weekFirstDate:_startDate];
}

-(void)setEndDate:(NSDate *)endDate {
    _endDate = endDate;
    
    self.calendarViewEndDate = [RKCalendarDataHelper weekLastDate:_endDate];
}

#pragma mark - Weekday Title View Setup
- (void)setupWeekDayTitle {
    if (self.weekdayTitleViewBackgroundColor) {
        self.weekDayTitleView.backgroundColor = self.weekdayTitleViewBackgroundColor;
    }
    
    [self.weekDayTitleView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat width = self.frame.size.width/7;
    CGFloat centerY = self.weekDayTitleView.frame.size.height / 2;
   
    NSArray *titles = @[@"S", @"M", @"T", @"W", @"T", @"F", @"S"];
    for (int i = 0; i < titles.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 20)];
        label.textAlignment = NSTextAlignmentCenter;
        label.attributedText = [[NSAttributedString alloc] initWithString:titles[i] attributes:self.weekDayTitleAttributes];
        label.center = CGPointMake(i * width + width / 2, centerY);
        [self.weekDayTitleView addSubview:label];
    }
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [RKCalendarDataHelper daysBetweenDate:self.calendarViewStartDate
                                         andDate:self.calendarViewEndDate] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RKCalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[RKCalendarCollectionViewCell reuseIdentifier]
                                                                                   forIndexPath:indexPath];
    
    // Set the date for the cell
    [cell setDate:[self dateForCellAtIndexPath:indexPath] isSelected:[self.currentSelectedIndexPath isEqual:indexPath]];
    
    return cell;
}

- (NSDate *)dateForCellAtIndexPath:(NSIndexPath *)indexPath {
    return [RKCalendarDataHelper dateByAddingYears:0 months:0 days:indexPath.item toDate:self.calendarViewStartDate];
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date {
    NSInteger index = [RKCalendarDataHelper daysBetweenDate:self.calendarViewStartDate andDate:date];
    return [NSIndexPath indexPathForRow:index inSection:0];
}

#pragma mark - UICollectionViewDelegate
#pragma mark Flow layout delegates
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.frame.size.width/7;
    return CGSizeMake(width, self.rowHeight);
}

#pragma mark Collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *selectedDate = [self dateForCellAtIndexPath:indexPath];
    
    if ([RKCalendarDataHelper daysBetweenDate:self.startDate andDate:selectedDate] >= 0 &&
        [RKCalendarDataHelper daysBetweenDate:selectedDate andDate:self.endDate] >= 0) {
        
        [self scrollToDate:selectedDate animated:YES];
        
        if ([self.delegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
            [self.delegate calendarView:self didSelectDate:selectedDate];
        }
    }
}

# pragma mark UIScrollView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.monthCoverScrollView.contentSize = self.collectionView.contentSize;
    self.monthCoverScrollView.hidden = NO;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.monthCoverScrollView.alpha = 1;
        self.collectionView.alpha = 0.4;
    } completion:^(BOOL finished) {
        
    }];
    
    if ([self.delegate respondsToSelector:@selector(calenderViewWillBeginDragging:)]) {
        [self.delegate calenderViewWillBeginDragging:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // update month cover
    self.monthCoverScrollView.contentOffset = self.collectionView.contentOffset;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint currentContentOffset = self.collectionView.contentOffset;
    
    [self.collectionView setContentOffset:CGPointMake(currentContentOffset.x, floorf(currentContentOffset.y/self.rowHeight)*self.rowHeight) animated:YES];
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState  animations:^{
        self.monthCoverScrollView.alpha = 0;
        self.collectionView.alpha = 1;
    } completion:nil];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (!decelerate) {
        [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState  animations:^{
            self.monthCoverScrollView.alpha = 0;
            self.collectionView.alpha = 1;
        } completion:nil];
    }
}

#pragma mark - Helper

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated {
    NSInteger item = [RKCalendarDataHelper daysBetweenDate:self.calendarViewStartDate
                                                   andDate:date];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
    
    UICollectionViewLayoutAttributes *layoutAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGPoint currentContentOffset = self.collectionView.contentOffset;
    
    // Need to move the selected cell in the second row from the top as per design
    CGFloat requiredOffset = (layoutAttributes.frame.origin.y - currentContentOffset.y) - self.rowHeight;
    
    NSLog(@"%ld, %ld, %@", (long)currentContentOffset.y, (long)(currentContentOffset.y+requiredOffset+self.collectionView.frame.size.height), NSStringFromCGSize(self.collectionView.contentSize));
    if (currentContentOffset.y+requiredOffset >= 0 && currentContentOffset.y+requiredOffset+self.collectionView.frame.size.height <= self.collectionView.contentSize.height) {
        [self.collectionView setContentOffset:CGPointMake(currentContentOffset.x, currentContentOffset.y+requiredOffset) animated:animated];
    }
    
    [self updateSelectionStateForDate:date];
}

- (void)updateSelectionStateForDate:(NSDate *)date {
    
    NSIndexPath *oldIndexPath = self.currentSelectedIndexPath;
    self.currentSelectedIndexPath = [self indexPathForDate:date];
    
    if (![self.currentSelectedIndexPath isEqual:oldIndexPath]) {
        NSMutableArray *indexesToReload;
        RKCalendarCollectionViewCell *cell;
        cell = (RKCalendarCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.currentSelectedIndexPath];
        if (cell) {
            [cell updateDisplayForSelectedState:YES];
        }
        else {
            indexesToReload = [NSMutableArray arrayWithObject:self.currentSelectedIndexPath];
        }
        
        if (oldIndexPath) {
            cell = (RKCalendarCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:oldIndexPath];
            if (cell) {
                [cell updateDisplayForSelectedState:NO];
            }
            else {
                if (indexesToReload) {
                    [indexesToReload addObject:oldIndexPath];
                }
            }
        }
        if (indexesToReload) {
            [self.collectionView reloadItemsAtIndexPaths:indexesToReload];
        }
    }
}

- (CGFloat)heightToDisplayNumberOfRows:(NSUInteger)numberOfRows {
    return self.weekDayTitleView.frame.size.height + (numberOfRows * self.rowHeight);
}

- (void)reload {
    self.monthCoverScrollView.textAttributes = self.monthCoverLabelAttributes;
    [self.monthCoverScrollView updateWithFirstDate:self.calendarViewStartDate
                                          lastDate:self.calendarViewEndDate
                                          calendar:[RKCalendarDataHelper calendar]
                                         rowHeight:self.rowHeight];
    
    [self.collectionView reloadData];
}

@end