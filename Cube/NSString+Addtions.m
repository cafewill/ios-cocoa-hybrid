//
// NSString+Addtions.m
//

#import "NSString+Addtions.h"

@implementation NSString (UserAddtions)

- (BOOL) contains: (NSString*) text insensitive: (BOOL) needed
{
    NSStringCompareOptions options = NSCaseInsensitiveSearch;
    if (needed) { options = -1; };
    NSRange range = [self rangeOfString: text options: options];
    return range.location != NSNotFound;
}

- (BOOL) isEmpty
{
    BOOL status = NO;
    if (1 > [[self trim] length]) status = YES;

    return status;
}

- (int) indexOf: (NSString*) text
{
    NSRange range = [self rangeOfString:text];
    if ( range.length > 0 ) {
        return (int) (range.location);
    } else {
        return -1;
    }
}

- (NSString*) trim
{
    return [self stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
}

- (NSString*) urlencode
{
    NSString* encoded = [self stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    encoded = [encoded stringByReplacingOccurrencesOfString: @":" withString:@"%3A"];
    encoded = [encoded stringByReplacingOccurrencesOfString: @"/" withString:@"%2F"];
    encoded = [encoded stringByReplacingOccurrencesOfString: @"?" withString:@"%3F"];
    encoded = [encoded stringByReplacingOccurrencesOfString: @"=" withString:@"%3D"];
    encoded = [encoded stringByReplacingOccurrencesOfString: @"&" withString:@"%26"];
    encoded = [encoded stringByReplacingOccurrencesOfString: @"#" withString:@"%23"];
    encoded = [encoded stringByReplacingOccurrencesOfString: @";" withString:@"%3B"];
    encoded = [encoded stringByReplacingOccurrencesOfString: @"@" withString:@"%40"];
    encoded = [encoded stringByReplacingOccurrencesOfString: @"$" withString:@"%24"];
    encoded = [encoded stringByReplacingOccurrencesOfString: @" " withString:@"+"];
    return (encoded);
}

+ (NSString*) urlencode: (NSString*) text
{
    NSString* encoded = [text stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    encoded = [encoded stringByReplacingOccurrencesOfString: @":" withString:@"%3A"];
    encoded = [encoded stringByReplacingOccurrencesOfString: @"/" withString:@"%2F"];
    encoded = [encoded stringByReplacingOccurrencesOfString: @"?" withString:@"%3F"];
    encoded = [encoded stringByReplacingOccurrencesOfString: @"=" withString:@"%3D"];
    encoded = [encoded stringByReplacingOccurrencesOfString: @"&" withString:@"%26"];
    encoded = [encoded stringByReplacingOccurrencesOfString: @"#" withString:@"%23"];
    encoded = [encoded stringByReplacingOccurrencesOfString: @";" withString:@"%3B"];
    encoded = [encoded stringByReplacingOccurrencesOfString: @"@" withString:@"%40"];
    encoded = [encoded stringByReplacingOccurrencesOfString: @"$" withString:@"%24"];
    encoded = [encoded stringByReplacingOccurrencesOfString: @" " withString:@"+"];
    return (encoded);
}

@end
