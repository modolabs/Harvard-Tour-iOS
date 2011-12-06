//
//  AthleticsDataController.m
//  Universitas
//
//  Created by Liu Mingxing on 12/2/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import "AthleticsDataController.h"

@implementation AthleticsDataController
@synthesize delegate;
@synthesize searchDelegate;
@synthesize moduleTag;

- (BOOL)requiresKurogoServer {
    return YES;
}

#pragma mark - KGORequestDelegate
- (void)requestWillTerminate:(KGORequest *)request {
    
}

- (void)request:(KGORequest *)request didFailWithError:(NSError *)error {
    
}

- (void)request:(KGORequest *)request didHandleResult:(NSInteger)returnValue {
    
}

- (void)request:(KGORequest *)request didReceiveResult:(id)result {
    
}

- (void)request:(KGORequest *)request didMakeProgress:(CGFloat)progress {
    
}

- (void)requestDidReceiveResponse:(KGORequest *)request {
    
}

- (void)requestResponseUnchanged:(KGORequest *)request {
    
}

#pragma mark - Serach

- (void)fetchCategories
{

}

- (void)dealloc {
    self.moduleTag = nil;

    [super dealloc];
}
@end
