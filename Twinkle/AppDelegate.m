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
    IBOutlet NSTableView *_tableView;
    IBOutlet NSView *_detailContainer;
    IBOutlet NSTextField *_applicationLabel;
    IBOutlet NSColorWell *_colorWell;
    IBOutlet NSButton *_activeButton;
    IBOutlet NSImageView *_imageView;
    
    StartAtLoginController *_loginController;
    
    BOOL _isSharing;
    NSTimer *_timer;
    Blink1 *_blink;
    NSArray *_applications;
}
- (Blink1 *)blink;
- (void)fillApplications;
- (NSString *)supportPath;
- (NSDictionary *)applicationSettingsFromPath:(NSString *)applicationPath;
- (void)setApplicationData:(NSString *)applicationPath color:(NSColor *)color active:(BOOL)active;
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
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(applicationDidActivate:) name:NSWorkspaceDidActivateApplicationNotification object:nil];
    
    self.window.level = NSStatusWindowLevel;
    
    _isSharing = NO;
    
    _loginController = [StartAtLoginController new];
    [_loginController setBundle:[NSBundle bundleWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Library/LoginItems/TwinkleHelper.app"]]];
    _startAtLoginButton.state = [_loginController startAtLogin];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"first"]) {
        [self settings:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"first"];
    }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    [self settings:nil];
    return YES;
}

#pragma mark - Notifications

- (void)applicationWillTerminate:(NSNotification *)notification {
    [[self blink] fadeToRGBstr:@"#000000" atTime:0];
    [_timer invalidate];
}

- (void)didCloseSettingsWindow:(NSNotification *)notification {
    [[self blink] fadeToRGBstr:@"#000000" atTime:0];
    [_timer invalidate];
}

- (void)applicationDidActivate:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *path = ((NSRunningApplication *)userInfo[@"NSWorkspaceApplicationKey"]).bundleIdentifier;
    if ([self.window isVisible]) {
        [self fillApplications];
        for (NSInteger i = 0; i < _applications.count; i++) {
            NSRunningApplication *application = _applications[i];
            if ([application.bundleIdentifier isEqualToString:path]) {
                [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
                [_tableView scrollRowToVisible:i];
                break;
            }
        }
    } else {
        NSDictionary *dict = [self applicationSettingsFromPath:path];
        if (dict && [dict[@"active"] boolValue]) {
            [[self blink] fadeToRGBstr:dict[@"color"] atTime:0];
        } else {
            [[self blink] fadeToRGBstr:@"#000000" atTime:0];
        }
    }
}

#pragma mark - Table

- (int)numberOfRowsInTableView:(NSTableView *)tableView {
    return (int)_applications.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
    NSRunningApplication *application = [_applications objectAtIndex:row];
    if ([tableColumn.identifier isEqualToString:@"icon"]) {
        return application.icon;
    } else {
        return application.localizedName;
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    if (_tableView.selectedRow >= 0) {
        _detailContainer.alphaValue = 1.0f;

        NSRunningApplication *application = [_applications objectAtIndex:_tableView.selectedRow];
        _applicationLabel.stringValue = application.bundleIdentifier;
        _imageView.image = application.icon;
        NSDictionary *dict = [self applicationSettingsFromPath:application.bundleIdentifier];
        if (dict) {
            _activeButton.state = [[dict objectForKey:@"active"] boolValue] ? NSOnState : NSOffState;
            _colorWell.color = [Blink1 colorFromHexRGB:[dict objectForKey:@"color"]];
        } else {
            _activeButton.state = NSOffState;
            _colorWell.color = [Blink1 colorFromHexRGB:@"#000000"];
        }
    } else {
        _detailContainer.alphaValue = 0.0f;
    }
}

#pragma mark - Actions

- (IBAction)settings:(id)sender {
    [self fillApplications];
    _detailContainer.alphaValue = 0.0f;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(setBlinkText:) userInfo:nil repeats:YES];
    [_timer fire];
    
    [_window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)setBlinkText:(NSTimer *)timer {
    _label.stringValue = [NSString stringWithFormat:@"Total blinks connected: %li", [self blink].serialnums.count];
}

- (IBAction)toggleActive:(id)sender {
    NSRunningApplication *application = [_applications objectAtIndex:_tableView.selectedRow];
    [self setApplicationData:application.bundleIdentifier color:_colorWell.color active:_activeButton.state == NSOnState];
}

- (IBAction)setColor:(id)sender {
    NSRunningApplication *application = [_applications objectAtIndex:_tableView.selectedRow];
    [self setApplicationData:application.bundleIdentifier color:_colorWell.color active:_activeButton.state == NSOnState];
    //[[self blink] fadeToRGBstr:@"#ffffff" atTime:0];
    [[self blink] fadeToRGB:_colorWell.color atTime:0];
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

#pragma mark - Applications

- (void)fillApplications {
    _applications = [NSWorkspace sharedWorkspace].runningApplications;
    [_tableView reloadData];
}

#pragma mark - Plist

- (NSString *)supportPath {
    NSString *folder = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    folder = [folder stringByAppendingPathComponent:@"Twinkle"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:folder] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    return folder;
}

- (NSDictionary *)applicationSettingsFromPath:(NSString *)applicationPath {
    NSString *path = [[self supportPath] stringByAppendingPathComponent:@"Applications.plist"];
    return [[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:applicationPath];
}

- (void)setApplicationData:(NSString *)applicationPath color:(NSColor *)color active:(BOOL)active {
    NSString *path = [[self supportPath] stringByAppendingPathComponent:@"Applications.plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!dict) dict = [NSMutableDictionary dictionary];
    [dict set:@{ @"color": [Blink1 hexStringFromColor:color], @"active": @(active) } for:applicationPath];
    [dict writeToFile:path atomically:NO];
}

@end