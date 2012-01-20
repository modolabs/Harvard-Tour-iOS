#import "AthleticsSportDetailViewController.h"
#import "KGOAppDelegate+ModuleAdditions.h"
#import "UIKit+KGOAdditions.h"
#import <QuartzCore/QuartzCore.h>
#import "AthleticsModel.h"
#import "CoreDataManager.h"
#import "Foundation+KGOAdditions.h"
#import "KGOHTMLTemplate.h"
#import "AthleticsListController.h"
#import "KGOShareButtonController.h"
#import "KGOToolbar.h"
#import "AthleticsDataController.h"
@interface AthleticsSportDetailViewController (Private) 

- (void)displayCurrentStory;
- (UIButton *)toolbarCloseButton;

@end

@implementation AthleticsSportDetailViewController

@synthesize story, stories, storyView, multiplePages, category;
@synthesize dataManager;

- (void)viewDidLoad {
    self.navigationItem.title = @"Sport";
    
    [super viewDidLoad];
	
    self.view.opaque = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGRect storyViewFrame  = self.view.bounds;
	storyView = [[UIWebView alloc] initWithFrame:storyViewFrame];
	[self.view addSubview: storyView];
	storyView.delegate = self;
    
    if (self.stories.count > 0) {
        multiplePages = YES;
    }
    KGOToolbar *alternateToolbar = nil;
    if (multiplePages) {
        storyPager = [[KGODetailPager alloc] initWithPagerController:self delegate:self];
        
        UIBarButtonItem * segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView: storyPager];
        if(alternateToolbar) {
            alternateToolbar.items = [alternateToolbar.items arrayByAddingObject:segmentBarItem];
        } else {
            self.navigationItem.rightBarButtonItem = segmentBarItem;
        }
        
        [segmentBarItem release];
        
        [storyPager selectPageAtSection:initialIndexPath.section row:initialIndexPath.row];
    } 
}


- (void) setInitialIndexPath:(NSIndexPath *)theInitialIndexPath  {
    initialIndexPath = [theInitialIndexPath retain];
}

# pragma KGODetailPagerController methods
- (NSInteger)numberOfSections:(KGODetailPager *)pager {
    return 1;
}

- (NSInteger)pager:(KGODetailPager *)pager numberOfPagesInSection:(NSInteger)section {
    return self.stories.count;
}

- (id<KGOSearchResult>)pager:(KGODetailPager *)pager contentForPageAtIndexPath:(NSIndexPath *)indexPath {
    return [self.stories objectAtIndex:indexPath.row];
}

# pragma 
- (void)pager:(KGODetailPager*)pager showContentForPage:(id<KGOSearchResult>)content {
    if(self.story == content) {
        // story already being shown
        return;
    }
    
    self.story = (AthleticsStory *)content;
    [self displayCurrentStory];
}

- (void)displayCurrentStory {
    NSURL *url = [NSURL URLWithString:story.link];
    if (url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [storyView loadRequest:request];
    }
    // mark story as read
    self.story.read = [NSNumber numberWithBool:YES];
    [[CoreDataManager sharedManager] saveDataWithTemporaryMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[storyView release];
    self.story = nil;
    self.stories = nil;
    self.category = nil;
    [initialIndexPath release];
    [super dealloc];
}

@end
