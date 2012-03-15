#import "PhotoAlbum.h"
#import "Photo.h"
#import "Foundation+KGOAdditions.h"
#import "CoreDataManager.h"
#import "KGOAppDelegate+ModuleAdditions.h"

NSString * const PhotoAlbumEntityName = @"PhotoAlbum";

@implementation PhotoAlbum

@dynamic identifier;
@dynamic lastUpdate;
@dynamic sortOrder;
@dynamic title;
@dynamic type;
@dynamic thumbURL;
@dynamic totalItems;
@dynamic thumbData;
@dynamic photos;

@synthesize moduleTag, thumbView;

#pragma mark KGOSearchResult

- (BOOL)isBookmarked
{
    return NO;
}

- (void)addBookmark
{
}

- (void)removeBookmark
{
}

- (NSString *)subtitle
{
    NSString *subtitle = nil;
    NSInteger count = [self.totalItems integerValue];
    if (count) {
        subtitle = [NSString stringWithFormat:@"%@\n%@", [self albumSize], [self lastUpdateString]];
    } else {
        subtitle = [self lastUpdateString];
    }
    return subtitle;
}

- (UIView *)iconView
{
    if (!self.thumbView) {
        self.thumbView = [[[MITThumbnailView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)] autorelease];
        self.thumbView.imageURL = self.thumbURL;
        self.thumbView.imageData = self.thumbData;
        self.thumbView.delegate = self;
    }
    return self.thumbView;
}

- (BOOL)didGetSelected:(id)selector
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self, @"album", nil];
    return [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameItemList
                                  forModuleTag:self.moduleTag
                                        params:params];
}

#pragma mark -

+ (PhotoAlbum *)albumWithDictionary:(NSDictionary *)dictionary
{
    PhotoAlbum *album = nil;
    NSString *identifier = [dictionary nonemptyStringForKey:@"id"];
    if (identifier) {
        album = [PhotoAlbum albumWithID:identifier canCreate:YES];
        [album updateWithDictionary:dictionary];
    }
    return album;
}

+ (PhotoAlbum *)albumWithID:(NSString *)identifier canCreate:(BOOL)canCreate
{
    PhotoAlbum *found = [[CoreDataManager sharedManager] uniqueObjectForEntity:PhotoAlbumEntityName
                                                            attribute:@"identifier"
                                                                value:identifier];
    if (!found && canCreate) {
        found = [[CoreDataManager sharedManager] insertNewObjectForEntityForName:PhotoAlbumEntityName];
        found.identifier = identifier;
    }
    
    return found;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    NSString *title = [dictionary nonemptyStringForKey:@"title"];
    if (title) {
        self.title = title;
    }
    NSString *thumbURL = [dictionary stringForKey:@"img"];
    if (thumbURL) {
        self.thumbURL = thumbURL;
    }
    NSString *type = [dictionary nonemptyStringForKey:@"type"];
    if (type) {
        self.type = type;
    }
    NSInteger count = [dictionary integerForKey:@"totalItems"];
    if (count) {
        self.totalItems = [NSNumber numberWithInt:count];
    }
}

- (NSString *)albumSize
{
    return [NSString stringWithFormat:
            NSLocalizedString(@"PHOTOS_%d_PHOTOS", @"%d photos"),
            [self.totalItems integerValue]];
}

- (NSString *)lastUpdateString
{
    if (self.lastUpdate) {
        return [NSString stringWithFormat:
                NSLocalizedString(@"PHOTOS_LAST_UPDATED_%@", @"Updated %@"),
                [self.lastUpdate agoString]];
    }
    return @"";
}

#pragma mark - cleanup

- (void)willTurnIntoFault
{
    [super willTurnIntoFault];

    self.thumbView.delegate = nil;
    self.thumbView = nil;
}

- (void)didSave
{
    [super didSave];

    if ([self isDeleted]) {
        self.thumbView.delegate = nil;
        self.thumbView = nil;
    }
}

- (void)dealloc
{
    self.thumbView.delegate = nil;
    self.thumbView = nil;

    [super dealloc];
}

#pragma mark - MITThumbnailDelegate

- (void)thumbnail:(MITThumbnailView *)thumbnail didLoadData:(NSData *)data
{
    if (thumbnail == self.thumbView) {
        self.thumbData = data;
        [[CoreDataManager sharedManager] saveData];
    }
}

@end
