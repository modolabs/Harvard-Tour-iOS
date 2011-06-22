#import "KGOModule.h"

@class TourDataManager;

@interface TourModule : KGOModule {

}

+ (NSString *)fillOutTemplate:(NSString *)templateString 
                   withValues:(NSArray *)values forKeys:(NSArray *)keys;
+ (NSString *)htmlForPageTemplateFileName:(NSString *)pageTemplateFilename
                              welcomeText:(NSString *)welcomeText
                        topicDictionaries:(NSArray *)topicDicts;
@end

@interface TourModule (UINavigationBarModification)

- (void)setUpNavigationBar:(UINavigationBar *)navBar;
- (void)setUpNavBarTitle:(NSString *)title navItem:(UINavigationItem *)navItem;
- (void)updateNavBarTitle:(NSString *)title navItem:(UINavigationItem *)navItem;

@end
