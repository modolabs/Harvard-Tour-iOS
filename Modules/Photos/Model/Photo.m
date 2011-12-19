#import "Photo.h"
#import "Foundation+KGOAdditions.h"
#import "CoreDataManager.h"
#import "PhotoAlbum.h"

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
    NSString *imageURL = [dictionary stringForKey:@"imageUrl"];
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

#pragma mark - MITThumbnailDelegate

- (void)thumbnail:(MITThumbnailView *)thumbnail didLoadData:(NSData *)data
{
    if ([thumbnail.imageURL isEqualToString:self.imageURL]) {
        self.imageData = data;
        [[CoreDataManager sharedManager] saveData];
    } else if ([thumbnail.imageURL isEqualToString:self.thumbURL]) {
        self.thumbData = data;
        [[CoreDataManager sharedManager] saveData];
    }
}

@end
