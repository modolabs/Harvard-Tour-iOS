
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import "KGOModule.h"

@class TourDataManager;

@interface TourModule : KGOModule {

}

@end

@interface TourModule (UINavigationBarModification)

- (void)setUpNavigationBar:(UINavigationBar *)navBar;
- (void)setUpNavBarTitle:(NSString *)title navItem:(UINavigationItem *)navItem;
- (void)updateNavBarTitle:(NSString *)title navItem:(UINavigationItem *)navItem;
- (void)updateNavBarTitleColor:(UIColor *)color 
                       navItem:(UINavigationItem *)navItem;
+ (UIBarButtonItem *)customToolbarButtonWithImageNamed:(NSString *)imageName 
                                     pressedImageNamed:(NSString *)pressedImageName
                                                target:(id)target 
                                                action:(SEL)action;
@end
