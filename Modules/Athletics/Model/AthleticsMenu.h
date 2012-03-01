#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AthleticsCategory;

@interface AthleticsMenu : NSManagedObject

@property (nonatomic, retain) NSString * sportTitle;
@property (nonatomic, retain) NSSet *categories;
@end

@interface AthleticsMenu (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(AthleticsCategory *)value;
- (void)removeCategoriesObject:(AthleticsCategory *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

@end
