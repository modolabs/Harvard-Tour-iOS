#import <UIKit/UIKit.h>
#import "KGOModule.h"
#import "IconGrid.h"
#import "KGORequestManager.h"
#import "KGOTableViewController.h"

typedef enum {
    LinksDisplayTypeList,
    LinksDisplayTypeSpringboard
} LinksDisplayType;

@interface LinksTableViewController : KGOTableViewController <KGORequestDelegate, IconGridDelegate>{
    
    ModuleTag *moduleTag;
    
    NSArray * linksArray;
    
    NSString * description;
    
    NSString * descriptionFooter;
    
    LinksDisplayType displayType;
    
    UIView * loadingView;
    UIActivityIndicatorView * loadingIndicator;
    
    UIView * headerView;
    UIView * footerView;
    
    // views for SpringBoard
    IconGrid *iconGrid;
    UIScrollView *scrollView;
    UILabel *descriptionLabel;
    UILabel *descriptionFooterLabel;
    
}

@property (nonatomic, retain) KGORequest *request;
@property (nonatomic, retain) UIView * loadingView;
@property (nonatomic, retain) UIActivityIndicatorView * loadingIndicator;

- (id)initWithModuleTag: (ModuleTag *) moduleTag;
- (void) addLoadingView;
- (void) removeLoadingView;
- (UIView *)viewForTableHeader;
- (UIView *)viewForTableFooter;
@end
