//
//  ViewController.m
//  CriticalMassTest
//
//  Created by caabernathy on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"


@implementation ViewController
@synthesize welcomeLabel;
@synthesize gameLabel;
@synthesize playButton;
@synthesize gameImageView;
@synthesize score;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void) initGameUIState {
    [playButton setHidden:NO];
    [gameLabel setHidden:YES];
}

- (void) gamePlayUIState:(BOOL) hide {
    [playButton setHidden:hide];
    [gameLabel setHidden:hide];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self initGameUIState];
}

- (void)viewDidUnload
{
    [self setGameLabel:nil];
    [self setPlayButton:nil];
    [self setWelcomeLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) playGame {
    NSArray * imageArray  = [[NSArray alloc] initWithObjects:
                             [UIImage imageNamed:@"criticalmass_1.png"],
                             [UIImage imageNamed:@"criticalmass_2.png"],
                             [UIImage imageNamed:@"criticalmass_3.png"],
                             [UIImage imageNamed:@"criticalmass_4.png"],
                             [UIImage imageNamed:@"criticalmass_5.png"],
                             [UIImage imageNamed:@"criticalmass_6.png"],
                             [UIImage imageNamed:@"criticalmass_7.png"],
                             [UIImage imageNamed:@"criticalmass_8.png"],
                             [UIImage imageNamed:@"criticalmass_9.png"],
                             [UIImage imageNamed:@"criticalmass_10.png"],
                             [UIImage imageNamed:@"criticalmass_11.png"],
                             [UIImage imageNamed:@"criticalmass_12.png"],
                             [UIImage imageNamed:@"criticalmass_13.png"],
                             [UIImage imageNamed:@"criticalmass_14.png"],
                             [UIImage imageNamed:@"criticalmass_15.png"],
                             nil];
	gameImageView = [[UIImageView alloc] initWithFrame:
                             CGRectMake(0, 50, 320, 314)];
	gameImageView.animationImages = imageArray;
	gameImageView.animationDuration = 20;
    gameImageView.animationRepeatCount = 1;
	gameImageView.contentMode = UIViewContentModeBottomLeft;
	[self.view addSubview:gameImageView];
	[gameImageView startAnimating];
    [self performSelector:@selector(endGame) withObject:nil afterDelay:8.0];
}

- (void) endGame {
    if ([gameImageView isAnimating]) {
        [gameImageView stopAnimating];
    }
    [self gamePlayUIState:NO];

    self.score = 100;
    gameLabel.text = [NSString stringWithFormat:@"Score: %d", self.score];
}

- (void)dealloc {
    [gameImageView release];
    [gameLabel release];
    [playButton release];
    [welcomeLabel release];
    [super dealloc];
}

- (void) startGame {
    self.score = 0;
    [self gamePlayUIState:YES];
    [self playGame];
}

- (IBAction)playClicked:(id)sender {
    [self startGame];
}



@end
