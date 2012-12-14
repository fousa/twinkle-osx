//
//  CommonMacros.h
//  Makro
//
//  Created by Piet Jaspers on 27/01/11.
//  Copyright 2011 10to1. Some Rights Reserved.
//

/*
 * How to use this file:
 *  1. Find your .pch file
 *  2. Import this file
 *  3. Make sure to import this file after UIKit and Foundation
 *  4. Use the functions in your app.
 *
 */

// Some handy logging macros

#ifdef CONFIGURATION_DEBUG
#define DLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#define ALog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__]
#else
#define DLog(...) do { } while (0)
#ifndef NS_BLOCK_ASSERTIONS
#define NS_BLOCK_ASSERTIONS
#endif
#define ALog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#endif

#define ZAssert(condition, ...) do { if (!(condition)) { ALog(__VA_ARGS__); }} while(0)

// Blatantly picked up from: http://blog.wilshipley.com/2005/10/pimp-my-code-interlude-free-code.html
static inline BOOL IsEmpty(id thing) {
    return thing == nil
	|| ([thing isEqual:[NSNull null]]) // addition for things like coredata
	|| ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
	|| ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}


// A check to see if we're running on an iPad.
// Blatantly picked up from: http://cocoawithlove.com/2010/07/tips-tricks-for-conditional-ios3-ios32.html
static inline BOOL IsIPad() {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
		return YES;
	} else
#endif
    {
       	return NO;
    }
}

static inline void dispatch_delayed(NSTimeInterval time, dispatch_block_t block) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), dispatch_get_main_queue(), block);
}