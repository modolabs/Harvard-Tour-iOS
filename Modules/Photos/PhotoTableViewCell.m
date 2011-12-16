#import "PhotoTableViewCell.h"

@implementation PhotoTableViewCell

@synthesize titleLabel = _titleLabel, subtitleLabel = _subtitleLabel, thumbView = _thumbView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.titleLabel.textColor = [UIColor whiteColor];
        self.subtitleLabel.textColor = [UIColor whiteColor];
    } else {
        self.titleLabel.textColor = [UIColor blackColor];
        self.subtitleLabel.textColor = [UIColor darkGrayColor];
    }
}

- (void)dealloc
{
    [_titleLabel release];
    [_subtitleLabel release];
    [_thumbView release];
    [super dealloc];
}

@end
