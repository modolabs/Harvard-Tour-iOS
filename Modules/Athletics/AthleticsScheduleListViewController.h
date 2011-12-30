//
//  AthleticsScheduleListViewController.h
//  Universitas
//
//  Created by Liu Mingxing on 12/30/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AthleticsDataController.h"
#import "KGOTableViewController.h"
@interface AthleticsScheduleListViewController : KGOTableViewController <AthleticsDataDelegate>{
    IBOutlet UITableView *_scheduleListView;
    
    
}
@property (nonatomic, retain) AthleticsDataController *dataManager;
@property (nonatomic, retain) NSArray *schedules;
@end
