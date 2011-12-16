#import "PhotoAlbum.h"
#import "Photo.h"
#import "Foundation+KGOAdditions.h"
#import "CoreDataManager.h"

NSString * const PhotoAlbumEntityName = @"PhotoAlbum";

@implementation PhotoAlbum

@dynamic identifier;
@dynamic title;
@dynamic type;
@dynamic thumbURL;
@dynamic totalItems;
@dynamic thumbData;
@dynamic photos;

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

#pragma mark - MITThumbnailDelegate

- (void)thumbnail:(MITThumbnailView *)thumbnail didLoadData:(NSData *)data
{
    if ([thumbnail.imageURL isEqualToString:self.thumbURL]) {
        self.thumbData = data;
        [[CoreDataManager sharedManager] saveData];
    }
}

@end
