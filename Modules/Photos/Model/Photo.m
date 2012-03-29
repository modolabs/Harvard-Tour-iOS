#import "Photo.h"
#import "Foundation+KGOAdditions.h"
#import "CoreDataManager.h"
#import "PhotoAlbum.h"
#import "KGOAppDelegate+ModuleAdditions.h"

NSString * const PhotoEntityName = @"Photo";

@implementation Photo

@dynamic identifier;
@dynamic title;
@dynamic thumbURL;
@dynamic thumbData;
@dynamic imageURL;
@dynamic imageData;
@dynamic caption;
@dynamic author;
@dynamic pubDate;
@dynamic sortOrder;
@dynamic album;

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

- (UIView *)iconView
{
    if (!self.thumbView) {
        self.thumbView = [[[MITThumbnailView alloc] initWithFrame:CGRectMake(0, 0, 72, 72)] autorelease];
        self.thumbView.imageURL = self.thumbURL;
        self.thumbView.imageData = self.thumbData;
        self.thumbView.delegate = self;
    }
    return self.thumbView;
}

- (BOOL)didGetSelected:(id)selector
{
    NSArray *photos = [self.album.photos sortedArrayUsingKey:@"sortOrder" ascending:YES];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self, @"photo", photos, @"photos", nil];
    return [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameDetail
                                  forModuleTag:self.moduleTag
                                        params:params];
}

#pragma mark -

+ (Photo *)photoWithDictionary:(NSDictionary *)dictionary
{
    Photo *photo = nil;
    NSString *identifier = [dictionary nonemptyStringForKey:@"id"];
    if (identifier) {
        photo = [Photo photoWithID:identifier canCreate:YES];
        [photo updateWithDictionary:dictionary];
    }
    return photo;
}

+ (Photo *)photoWithID:(NSString *)identifier canCreate:(BOOL)canCreate
{
    Photo *found = [[CoreDataManager sharedManager] uniqueObjectForEntity:PhotoEntityName
                                                                attribute:@"identifier"
                                                                    value:identifier];
    if (!found && canCreate) {
        found = [[CoreDataManager sharedManager] insertNewObjectForEntityForName:PhotoEntityName];
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
    NSString *author = [dictionary nonemptyStringForKey:@"author"];
    if (author) {
        self.imageURL = author;
    }
    NSNumber *pubDate = [dictionary numberForKey:@"published"];
    if (pubDate) {
        self.pubDate = [NSDate dateWithTimeIntervalSince1970:[pubDate doubleValue]];
    }
    NSString *caption = [dictionary stringForKey:@"description"];
    if (caption) {
        self.imageURL = caption;
    }

    // if the thumb/image url has changed somehow, also delete the associated image data
    NSString *thumbURL = [dictionary stringForKey:@"thumbnailUrl"];
    if (thumbURL && ![self.thumbURL isEqualToString:thumbURL]) {
        self.thumbURL = thumbURL;
        self.thumbData = nil;
    }
    NSString *imageURL = [dictionary stringForKey:@"imgUrl"];
    if (imageURL && ![self.imageURL isEqualToString:imageURL]) {
        self.imageURL = imageURL;
        self.imageData = nil;
    }

    NSString *albumID = [dictionary nonemptyStringForKey:@"albumId"];
    if (albumID) {
        PhotoAlbum *album = [PhotoAlbum albumWithID:albumID canCreate:NO];
        if (album) {
            self.album = album;
            self.album.lastUpdate = [NSDate date];
            if (self.sortOrder == nil) {
                self.sortOrder = [NSNumber numberWithInt:self.album.photos.count];
            }
        }
    }
}

- (NSString *)lastUpdateString
{
    return [NSString stringWithFormat:
            NSLocalizedString(@"PHOTOS_LAST_UPDATED_%@", @"Updated %@"),
            [self.pubDate agoString]];
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
    self.moduleTag = nil;
    
    [super dealloc];
}

#pragma mark - MITThumbnailDelegate

- (void)thumbnail:(MITThumbnailView *)thumbnail didLoadData:(NSData *)data
{
    if ([thumbnail.imageURL isEqualToString:self.imageURL]) { // this is not our thumbview
        self.imageData = data;
        [[CoreDataManager sharedManager] saveData];
    } else if ([thumbnail.imageURL isEqualToString:self.thumbURL]) { // this is our thumbview
        self.thumbData = data;
        [[CoreDataManager sharedManager] saveData];
    }
}

@end
