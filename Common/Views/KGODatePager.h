#import <UIKit/UIKit.h>
#import "DatePickerViewController.h"

@class KGODatePager;

@protocol KGODatePagerDelegate

- (void)pager:(KGODatePager *)pager didSelectDate:(NSDate *)date;

@end


@interface KGODatePager : UIView <DatePickerViewControllerDelegate> {
    
    NSDate *_date;
    NSDate *_displayDate;
    NSDateFormatter *_dateFormatter;
    NSCalendarUnit _incrementUnit;
    
    IBOutlet UIButton *nextButton;
    IBOutlet UIButton *prevButton;
    IBOutlet UIButton *dateButton;
    IBOutlet UIButton *calendarButton;
    IBOutlet UIImageView *dropShadow;
}

- (IBAction)buttonPressed:(id)sender;

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDate *displayDate;

@property (nonatomic) NSCalendarUnit incrementUnit;
@property (nonatomic, assign) id<KGODatePagerDelegate> delegate;
@property (nonatomic, assign) UIViewController *contentsController;

@end
