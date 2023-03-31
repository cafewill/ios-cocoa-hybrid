//
//  Allo.h
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

#define CUBE @"cube"
#define CUBE_DEBUG YES

#define CUBE_SITE @"https://github.com/cafewill"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                 blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                alpha:1.0]

@interface Allo : NSObject

+ (void) i: (NSString*) format, ...;
+ (void) t: (NSString*) format, ...;

@end
