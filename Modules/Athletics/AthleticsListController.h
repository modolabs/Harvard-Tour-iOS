//
//  AthleticsListController.h
//  Universitas
//
//  Created by Liu Mingxing on 12/2/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KGOTabbedViewController.h"
#import "AthleticsTableViewCell.h"
#import "KGOSearchBar.h"
#import "AthleticsDataController.h"
#import "KGOSearchDisplayController.h"
@interface AthleticsListController : KGOTabbedViewController <KGOSearchBarDelegate,AthleticsDataDelegate,UITableViewDelegate,UITableViewDataSource> {
    UIView *_contentView;
    
    UILabel *_loadingLabel;
    UILabel *_lastUpdateLabel;
    UIProgressView *_progressView;
    UITableView *_storyTable;
    UIView *_activityView;
    
    UILabel *_sepratorLine;
    
    IBOutlet AthleticsTableViewCell *_athletcisCell;
    
    NSString *activeCategoryId;
    
    NSInteger _topNewsTabIndex;
    NSInteger _menTabIndex;
    NSInteger _womenTabIndex;
    NSInteger _mySportsTabIndex;
    
}

@property (nonatomic, retain) AthleticsDataController *dataManager;
@property (nonatomic, retain) NSArray *federatedSearchResults;
@property (nonatomic, retain) NSString *federatedSearchTerms;
@property (nonatomic, retain) NSArray *stories;
@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) NSString *activeCategoryId;

- (void)setStatusText:(NSString *)text;
@end
