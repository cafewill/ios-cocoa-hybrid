//
// NSString+Addtions.h
//

#import <Foundation/Foundation.h>

@interface NSString (UserAddtions)

- (BOOL) isEmpty;
- (BOOL) contains: (NSString*) text insensitive: (BOOL) needed;
- (NSString*) trim;
- (int) indexOf: (NSString*) text;
- (NSString*) urlencode;
+ (NSString*) urlencode: (NSString*) text;

@end
