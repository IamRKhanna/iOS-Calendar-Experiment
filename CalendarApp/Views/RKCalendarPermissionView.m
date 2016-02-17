//
//  RKCalendarPermissionView.m
//  CalendarApp
//
//  Created by Rahul Khanna on 2/17/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import "RKCalendarPermissionView.h"

@interface RKCalendarPermissionView()
// Outlets
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UIButton *openSettingsButton;

// Action
- (IBAction)openSettingsButtonTapped:(id)sender;
@end

@implementation RKCalendarPermissionView

#pragma mark - Intialization
- (id)init {
	self = [super init];

    if (self) {
        
        NSString *currentClassName = NSStringFromClass([RKCalendarPermissionView class]);
        
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:currentClassName owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[RKCalendarPermissionView class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        
        [self basicInitialization];
	}
	
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
    
	if (self) {
        [self basicInitialization];
	}
	
    return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
        NSString *currentClassName = NSStringFromClass([RKCalendarPermissionView class]);
        
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:currentClassName owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[RKCalendarPermissionView class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];

        self.frame = frame;
        
        [self basicInitialization];

	}
	return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [self basicInitialization];
}

- (void) basicInitialization {
    self.messageLabel.adjustsFontSizeToFitWidth = YES;
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    self.messageLabel.text = [NSString stringWithFormat:@"In iPhone settings, tap %@ and turn on Calendar", appName];
}

#pragma mark - Button Click Handler
- (IBAction)openSettingsButtonTapped:(id)sender {
    NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:settingsURL];
}

@end
