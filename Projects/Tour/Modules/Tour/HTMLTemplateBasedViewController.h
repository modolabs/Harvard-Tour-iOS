//
//  HTMLTemplateBasedViewController.h
//  Tour
//

#import <Foundation/Foundation.h>

// Base class for views that have a web view that's filled out with a template.
// Make sure that you implement templateFilename and replacementsForStubs set 
// the webView in the nib of the inheriting class.

@interface HTMLTemplateBasedViewController : UIViewController {
    
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;

// The template file under resources/modules/tour.
- (NSString *)templateFilename;
// Keys: Stubs to replace in the template. Values: Strings to replace them.
- (NSDictionary *)replacementsForStubs;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
                title:(NSString *)title;

#pragma mark Formatting utils
+ (NSString *)fillOutTemplate:(NSString *)templateString 
         replacementsForStubs:(NSDictionary *)replacementsForStubs;
+ (NSString *)htmlForPageTemplateFileName:(NSString *)pageTemplateFilename
                     replacementsForStubs:(NSDictionary *)replacementsForStubs;
+ (NSString *)htmlForTopicSection:(NSArray *)topicDicts;
+ (NSString *)htmlForContactsSection:(NSArray *)contactDicts;

@end


@interface HTMLTemplateBasedViewController (Protected)

- (void)setUpWebViewLayout;

@end

