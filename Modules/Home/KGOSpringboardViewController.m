#import "KGOSpringboardViewController.h"
#import "KGOAppDelegate+ModuleAdditions.h"
#import "KGOModule.h"
#import "KGOSearchBar.h"
#import "KGOSearchDisplayController.h"
#import "UIKit+KGOAdditions.h"
#import "SpringboardIcon.h"
#import "KGOHomeScreenWidget.h"

@implementation KGOSpringboardViewController

#pragma mark -

- (void)loadView {
    [super loadView];
    
    CGFloat minY = [self minimumAvailableY];
    CGRect frame = CGRectMake(0, minY,
                              CGRectGetWidth(self.view.bounds),
                              CGRectGetHeight(self.view.bounds) - minY);
    _scrollView = [[UIScrollView alloc] initWithFrame:frame];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.contentSize = self.view.bounds.size;
    [self.view addSubview:_scrollView];
    
    if (!primaryGrid) {
        primaryGrid = [[[IconGrid alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)] autorelease];
        primaryGrid.padding = [self moduleListMargins];
        primaryGrid.spacing = [self moduleListSpacing];
        primaryGrid.icons = [self iconsForPrimaryModules:YES];
        primaryGrid.delegate = self;
    }
    
    if (!secondGrid) {
        secondGrid = [[[IconGrid alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(primaryGrid.frame),
                                                                 self.view.bounds.size.width, 1)] autorelease];
        secondGrid.padding = [self secondaryModuleListMargins];
        secondGrid.spacing = [self secondaryModuleListSpacing];
        secondGrid.icons = [self iconsForPrimaryModules:NO];
    }
    
    [_scrollView addSubview:primaryGrid];
    [_scrollView addSubview:secondGrid];
}

- (void)showAnnouncementBanner
{
    [_scrollView addSubview:self.banner];
    [super showAnnouncementBanner];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self iconGridFrameDidChange:secondGrid];
}

- (void)refreshHeights
{
    
    CGFloat minY = [self minimumAvailableY];
    if (CGRectGetMinY(_scrollView.frame) != minY) {
        _scrollView.frame = CGRectMake(0, minY,
                                       CGRectGetWidth(self.view.bounds),
                                       CGRectGetHeight(self.view.bounds) - minY);
    }
    
    CGFloat primaryGridY = self.banner != nil ? CGRectGetMaxY(self.banner.frame) : 0;
    if (CGRectGetMinY(primaryGrid.frame) != primaryGridY) {
        primaryGrid.frame = CGRectMake(0, primaryGridY,
                                       CGRectGetWidth(primaryGrid.frame),
                                       CGRectGetHeight(primaryGrid.frame));
    }
    
    CGFloat secondGridY = CGRectGetMaxY(primaryGrid.frame);
    if (CGRectGetMinY(secondGrid.frame) != secondGridY) {
        secondGrid.frame = CGRectMake(0, secondGridY,
                                      CGRectGetWidth(secondGrid.frame),
                                      CGRectGetHeight(secondGrid.frame));
    }
    
    CGFloat scrollHeight = [self minimumAvailableY] + CGRectGetMaxY(secondGrid.frame);
    if (scrollHeight != _scrollView.contentSize.height) {
        _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, scrollHeight);
    }
    
    [_scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void)refreshModules
{
    [super refreshModules];
    
    [self refreshHeights];
    
    primaryGrid.icons = [self iconsForPrimaryModules:YES];
    secondGrid.icons = [self iconsForPrimaryModules:NO];
    
    [primaryGrid setNeedsLayout];
    [secondGrid setNeedsLayout];
}

- (void)iconGridFrameDidChange:(IconGrid *)iconGrid
{
    [self refreshHeights];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_scrollView release];
    [super dealloc];
}

@end



