#import "HTMLTagCleaner.h"

@implementation HTMLTagCleaner

- (NSString *)result
{
    return _currentResult;
}

- (BOOL)parseSucceeded
{
    return _parseSucceeded;
}

- (void)dealloc
{
    [_currentStack release];
    [_currentResult release];
    [super dealloc];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    [_currentResult release];
    _currentResult = [[NSMutableString alloc] init];
    [_currentStack release];
    _currentStack = [[NSMutableArray alloc] init];
    _parseSucceeded = YES;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue
{
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    NSString *currentTag = [_currentStack lastObject];
    if (![currentTag isEqualToString:@"script"] && ![currentTag isEqualToString:@"style"]) {
        NSString *cdataString = [[[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding] autorelease];
        [_currentResult appendString:cdataString];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSString *currentTag = [_currentStack lastObject];
    if (![currentTag isEqualToString:@"script"] && ![currentTag isEqualToString:@"style"]) {
        [_currentResult appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if ([[_currentStack lastObject] isEqualToString:elementName]) {
        [_currentStack removeLastObject];
    } else {
        DLog(@"warning: %@ is not last object in %@", elementName, _currentStack);
    }
    
    if ([elementName isEqualToString:@"br"]
        || [elementName isEqualToString:@"h1"]
        || [elementName isEqualToString:@"h2"]
        || [elementName isEqualToString:@"h3"]
        || [elementName isEqualToString:@"h4"])
    {
        [_currentResult appendString:@"\n"];
    }
    else if ([elementName isEqualToString:@"p"]) {
        [_currentResult appendString:@"\n\n"];
    }
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    [_currentStack addObject:elementName];
}

/*
- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{
}
*/

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    [parser abortParsing];
    _parseSucceeded = NO;
    DLog(@"parser encountered malformed document: %@", validationError);
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    DLog(@"parser encountered error: %@", parseError);
}

@end



@implementation NSString (HTMLTagCleaner)

- (NSString *)stringByStrippingHTMLTags
{
    NSString *wrappedString = nil;
    if ([[self substringToIndex:2] isEqualToString:@"<?"]) {
        wrappedString = self;
    } else {
        wrappedString = [NSString stringWithFormat:@"<root>%@</root>", self];
    }
    NSData *data = [wrappedString dataUsingEncoding:self.fastestEncoding];
    NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:data] autorelease];
    HTMLTagCleaner *cleaner = [[[HTMLTagCleaner alloc] init] autorelease];
    parser.delegate = cleaner;
    [parser parse];
    
    if (cleaner.parseSucceeded) {
        return cleaner.result;
    }
    return [self stringByStrippingRegexTags];
}

// from http://stackoverflow.com/a/4886998
- (NSString *)stringByStrippingRegexTags {
    NSRange r;
    NSString *s = [[self copy] autorelease];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

@end

