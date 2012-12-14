//
//  AppDelegate.m
//  FastTwitter
//
//  Created by Jelle Vandebeeck on 20/09/12.
//  Copyright (c) 2012 Fousa. All rights reserved.
//

#import "AppDelegate.h"

#import "StartAtLoginController.h"

@interface AppDelegate () <NSSharingServiceDelegate> {
    IBOutlet NSButton *_startAtLoginButton;
    
    StartAtLoginController *_loginController;
    
    BOOL _isSharing;
}
@end

@implementation AppDelegate

#pragma mark - Application flow

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _isSharing = NO;
    
    _loginController = [StartAtLoginController new];
    [_loginController setBundle:[NSBundle bundleWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Library/LoginItems/TwinkleHelper.app"]]];
    _startAtLoginButton.state = [_loginController startAtLogin];
    
    [self settings:nil];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    [self settings:nil];
    return YES;
}

#pragma mark - Actions

- (IBAction)settings:(id)sender {
    [_window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
    
}

- (IBAction)toggleStartAtLogin:(id)sender {
    if ([_startAtLoginButton state]) {
        if (![_loginController startAtLogin]) {
            [_loginController setStartAtLogin: YES];
        
            if (![_loginController startAtLogin]) { // Error checking if you want
                NSLog(@"Register error");
            }
        }
    } else {
        if ([_loginController startAtLogin]) {
            [_loginController setStartAtLogin:NO];
        
            if ([_loginController startAtLogin]) { // Error checking if you want
                NSLog(@"Error");
            }
        }
    }

    _startAtLoginButton.state = [_loginController startAtLogin];
}

@end