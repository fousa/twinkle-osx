//
//  AppDelegate.m
//  EggyHelper
//
//  Created by Jelle Vandebeeck on 24/09/12.
//  Copyright (c) 2012 Fousa. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *appPath = [[[[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
    NSString *binaryPath = [[NSBundle bundleWithPath:appPath] executablePath];
    [[NSWorkspace sharedWorkspace] launchApplication:binaryPath];
    [NSApp terminate:nil];
}

@end
