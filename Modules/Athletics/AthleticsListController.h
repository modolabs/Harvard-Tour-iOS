//
//  AthleticsListController.h
//  Universitas
//
//  Created by Liu Mingxing on 12/2/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KGOScrollingTabstrip.h"
#import "AthleticsTableViewCell.h"
#import "KGOSearchBar.h"
#import "KGOTableViewController.h"
#import "AthleticsDataController.h"
#import "KGOSearchDisplayController.h"
@interface AthleticsListController : KGOTableViewController <KGOScrollingTabstripDelegate,KGOSearchBarDelegate,AthleticsDataDelegate>{
    
    IBOutlet KGOScrollingTabstrip *_navScrollView;
    IBOutlet UILabel *_loadingLabel;
    IBOutlet UILabel *_lastUpdateLabel;
    IBOutlet UIProgressView *_progressView;
    IBOutlet UITableView *_storyTable;
    IBOutlet UIView *_activityView;
    IBOutlet AthleticsTableViewCell *_athletcisCell;
    
    NSString *activeCategoryId;
    
    BOOL showingBookmarks;
}

@property (nonatomic, retain) AthleticsDataController *dataManager;
@property (nonatomic, retain) NSArray *federatedSearchResults;
@property (nonatomic, retain) NSString *federatedSearchTerms;
@property (nonatomic, retain) NSArray *stories;
@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain)  NSString *activeCategoryId;

- (void)setupNavScrollButtons;
- (void)setStatusText:(NSString *)text;
@end
