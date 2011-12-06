//
//  AthleticsDataController.h
//  Universitas
//
//  Created by Liu Mingxing on 12/2/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KGORequestManager.h"
@interface AthleticsDataController : NSObject <KGORequestDelegate>{
    NSMutableSet *_searchRequests;
    NSMutableArray *_searchResults;
}

- (BOOL)requiresKurogoServer;

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) id searchDelegate;
@property (nonatomic, retain) ModuleTag *moduleTag;

- (void)fetchCategories;
@end
