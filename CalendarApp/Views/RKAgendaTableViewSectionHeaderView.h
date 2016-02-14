//
//  RKAgendaTableViewSectionHeaderView.h
//  CalendarApp
//
//  Created by Rahul Khanna on 2/12/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RKAgendaTableViewSectionHeaderView : UITableViewHeaderFooterView

+ (NSString *)reuseIdentifier;

@property (nonatomic, strong) NSDate *sectionDate;

@property (nonatomic, strong) IBOutlet UILabel *dateLabel;

@end
