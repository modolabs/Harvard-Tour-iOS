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
@interface AthleticsListController : UIViewController {
    
    IBOutlet KGOScrollingTabstrip *_navScrollView;
    IBOutlet UILabel *_loadingLabel;
    IBOutlet UILabel *_lastUpdateLabel;
    IBOutlet UIProgressView *_progressView;
    IBOutlet UITableView *_storyTable;

    IBOutlet AthleticsTableViewCell *_athleticsCell;
}

@end
