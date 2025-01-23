//
//  SwiftZSTD_macOS.h
//  SwiftZSTD_macOS
//
//  Created by Anatoli on 12/20/16.
//
//

#if __has_include(<UIKit/UIKit.h>)
    #import <UIKit/UIKit.h>
#else
    #import <Cocoa/Cocoa.h>
#endif

//! Project version number for SwiftZSTD_macOS.
FOUNDATION_EXPORT double SwiftZSTDVersionNumber;

//! Project version string for SwiftZSTD_macOS.
FOUNDATION_EXPORT const unsigned char SwiftZSTDVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SwiftZSTD_macOS/PublicHeader.h>

#import <zstdlib/zstd.h>
#import <zstdlib/zdict.h>

#import "../../StreamHelpers.h"


