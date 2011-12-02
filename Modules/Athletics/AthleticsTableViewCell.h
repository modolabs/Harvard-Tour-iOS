//
//  AthleticsTableViewCell.h
//  Universitas
//
//  Created by Liu Mingxing on 12/2/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KGOLabel.h"
#import "MITThumbnailView.h"
@interface AthleticsTableViewCell : UITableViewCell {
    
    IBOutlet MITThumbnailView *_thumbnailView;
    IBOutlet KGOLabel *_titleLabel;
    IBOutlet KGOLabel *_dekLabel;
}

@end
