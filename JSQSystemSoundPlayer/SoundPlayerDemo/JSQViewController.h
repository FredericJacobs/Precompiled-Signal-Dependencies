//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  The MIT License
//  Copyright (c) 2014 Jesse Squires
//  http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface JSQViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;

- (IBAction)playSystemSoundPressed:(UIButton *)sender;

- (IBAction)playAlertSoundPressed:(UIButton *)sender;

- (IBAction)playVibratePressed:(UIButton *)sender;

- (IBAction)playLongSoundPressed:(UIButton *)sender;

- (IBAction)stopPressed:(UIButton *)sender;

- (IBAction)toggleSwitch:(UISwitch *)sender;

@end
