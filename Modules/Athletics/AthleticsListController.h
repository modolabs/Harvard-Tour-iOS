//
//  AthleticsListController.h
//  Universitas
//
//  Created by Liu Mingxing on 12/2/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KGOTabbedControl.h"
#import "AthleticsTableViewCell.h"
#import "KGOSearchBar.h"
#import "KGOTableViewController.h"
#import "AthleticsDataController.h"
#import "KGOSearchDisplayController.h"
@interface AthleticsListController : KGOTableViewController <KGOTabbedControlDelegate,KGOSearchBarDelegate,AthleticsDataDelegate> {
    
    IBOutlet KGOTabbedControl *_navTabbedView;
    IBOutlet UILabel *_loadingLabel;
    IBOutlet UILabel *_lastUpdateLabel;
    IBOutlet UIProgressView *_progressView;
    IBOutlet UITableView *_storyTable;
    IBOutlet UIView *_activityView;
    IBOutlet AthleticsTableViewCell *_athletcisCell;
    
    NSString *activeCategoryId;
    
    BOOL showingBookmarks;
    BOOL showingMenuCategories;
}

@property (nonatomic, retain) AthleticsDataController *dataManager;
@property (nonatomic, retain) NSArray *federatedSearchResults;
@property (nonatomic, retain) NSString *federatedSearchTerms;
@property (nonatomic, retain) NSArray *stories;
@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) NSString *activeCategoryId;

- (void)setupNavTabbedButtons;
- (void)setStatusText:(NSString *)text;
- (void)switchToCategory:(NSString *)category;
@end
