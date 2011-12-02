//
//  AthleticsModule.h
//  Universitas
//
//  Created by Liu Mingxing on 12/2/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KGOModule.h"


@class AthleticsDataController;
@interface AthleticsModule : KGOModule {
    AthleticsDataController *_dataManager;
}
@property (nonatomic, retain)  AthleticsDataController *dataManager;

- (UIViewController *)modulePage:(NSString *)pageName params:(NSDictionary *)params;
@end
