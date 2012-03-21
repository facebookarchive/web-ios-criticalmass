//
//  ViewController.h
//  CriticalMassTest
//
//  Created by caabernathy on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (retain, nonatomic) IBOutlet UILabel *welcomeLabel;

@property (retain, nonatomic) IBOutlet UILabel *gameLabel;

@property (retain, nonatomic) IBOutlet UIButton *playButton;




@property (retain, nonatomic) UIImageView *gameImageView;

@property (assign, nonatomic) NSUInteger score;

- (IBAction)playClicked:(id)sender;





@end
