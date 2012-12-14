//
//  AppDelegate.m
//  FastTwitter
//
//  Created by Jelle Vandebeeck on 20/09/12.
//  Copyright (c) 2012 Fousa. All rights reserved.
//

#import "AppDelegate.h"

#import "Blink1.h"

#import "StartAtLoginController.h"

@interface AppDelegate () <NSSharingServiceDelegate> {
    IBOutlet NSButton *_startAtLoginButton;
    IBOutlet NSTextField *_label;
    
    StartAtLoginController *_loginController;
    
    BOOL _isSharing;
    NSTimer *_timer;
    Blink1 *_blink;
}
- (Blink1 *)blink;
@end

@implementation AppDelegate

- (Blink1 *)blink {
    if (!_blink) {
        _blink = [Blink1 new];
    };
    [_blink enumerate];
    return _blink;
}

#pragma mark - Application flow

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCloseSettingsWindow:) name:NSWindowWillCloseNotification object:nil];
    
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

- (void)applicationWillTerminate:(NSNotification *)notification {
    [[self blink] fadeToRGBstr:@"#000000" atTime:0];
    [_timer invalidate];
}

- (void)didCloseSettingsWindow:(NSNotification *)notification {
    [[self blink] fadeToRGBstr:@"#000000" atTime:0];
    [_timer invalidate];
}

#pragma mark - Actions

- (IBAction)settings:(id)sender {
    [[self blink] fadeToRGBstr:@"#ffffff" atTime:0];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(setBlinkText:) userInfo:nil repeats:YES];
    [_timer fire];
    
    [_window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)setBlinkText:(NSTimer *)timer {
    _label.stringValue = [NSString stringWithFormat:@"Total blinks connected: %li", [self blink].serialnums.count];
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