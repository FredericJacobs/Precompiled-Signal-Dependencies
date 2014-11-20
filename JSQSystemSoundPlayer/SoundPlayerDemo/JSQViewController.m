//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  The MIT License
//  Copyright (c) 2014 Jesse Squires
//  http://opensource.org/licenses/MIT
//

#import "JSQViewController.h"
#import "JSQSystemSoundPlayer.h"

@implementation JSQViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.soundSwitch.on = [JSQSystemSoundPlayer sharedPlayer].on;
}

- (IBAction)playSystemSoundPressed:(UIButton *)sender
{
    JSQSystemSoundPlayer *sharedPlayer = [JSQSystemSoundPlayer sharedPlayer];
    
    [sharedPlayer playSoundWithFilename:@"Basso"
                          fileExtension:kJSQSystemSoundTypeAIF
                             completion:^{
                                 NSLog(@"Sound finished playing. Executing completion block...");
                                 
                                 [sharedPlayer playAlertSoundWithFilename:@"Funk"
                                                            fileExtension:kJSQSystemSoundTypeAIFF];
                             }];
}

- (IBAction)playAlertSoundPressed:(UIButton *)sender
{
    [[JSQSystemSoundPlayer sharedPlayer] playAlertSoundWithFilename:@"Funk"
                                                      fileExtension:kJSQSystemSoundTypeAIFF];
}

- (IBAction)playVibratePressed:(UIButton *)sender
{
    [[JSQSystemSoundPlayer sharedPlayer] playVibrateSound];
}

- (IBAction)playLongSoundPressed:(UIButton *)sender
{
    NSLog(@"Playing long sound...");
    [[JSQSystemSoundPlayer sharedPlayer] playSoundWithFilename:@"BalladPiano"
                                                 fileExtension:kJSQSystemSoundTypeCAF
                                                    completion:^{
                                                        NSLog(@"Long sound complete!");
                                                    }];
}

- (IBAction)stopPressed:(UIButton *)sender
{
    [[JSQSystemSoundPlayer sharedPlayer] stopAllSounds];
    
    //  Stop playing specific sound
    //  [[JSQSystemSoundPlayer sharedPlayer] stopSoundWithFilename:@"BalladPiano"];
}

- (IBAction)toggleSwitch:(UISwitch *)sender
{
    [[JSQSystemSoundPlayer sharedPlayer] toggleSoundPlayerOn:sender.on];
}

@end
