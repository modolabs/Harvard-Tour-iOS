#import <Foundation/Foundation.h>

@interface NSString (HTMLTagCleaner)

- (NSString *)stringByStrippingHTMLTags; // slower. falls back to regex if document is not well-formed
- (NSString *)stringByStrippingRegexTags; // faster, not safe against <script> and other interesting tags

@end


@interface HTMLTagCleaner : NSObject <NSXMLParserDelegate>
{
    NSMutableString *_currentResult;
    NSMutableArray *_currentStack;
    BOOL _parseSucceeded;
}

- (NSString *)result;
- (BOOL)parseSucceeded;

@end
