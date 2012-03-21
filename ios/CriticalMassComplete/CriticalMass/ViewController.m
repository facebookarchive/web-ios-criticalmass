/*
 * Copyright 2010 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ViewController.h"
#import "AppDelegate.h"

// An offset number for use when creating tags for the leader board
#define kLeaderBoardViewTagOffset   100

// Server endpoint for saving scores
static NSString *kBackEndServer = @"http://www.bitdecay.net/labs/criticalmasscomplete/server/savescore.php";

@implementation ViewController
@synthesize gameImageView;
@synthesize welcomeLabel;
@synthesize gameLabel;
@synthesize playButton;
@synthesize inviteButton;
@synthesize bragButton;
@synthesize logoutButton;
@synthesize leaderboardView;
@synthesize receivedData;
@synthesize scoresConnection;
@synthesize score;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [scoresConnection cancel];
    [scoresConnection release];
    [receivedData release];
    [gameLabel release];
    [playButton release];
    [welcomeLabel release];
    [logoutButton release];
    [gameImageView release];
    [leaderboardView release];
    [bragButton release];
    [inviteButton release];
    [super dealloc];
}

/*
 * This method creates the UI elements for the leader board:
 *  - The user's profile picture image view
 *  - The user's name label
 *  - The user's score label
 */
- (void) createLeaderboardDisplay {
    NSUInteger viewTag = kLeaderBoardViewTagOffset;
    int xOrigin = 20;
    int yOrigin = 10;
    // Only show at most 3 players on leader board
    for (NSUInteger i = 0; i < 3; i++) {
        // Image view to hold the user's profile picture
        UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, yOrigin, 50.0, 50.0)];
        [userImage setTag:viewTag];
        viewTag++;
        [self.leaderboardView addSubview:userImage];
        [userImage release];
        
        // Label to hold the user's name
        UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(xOrigin-10, yOrigin+60, 70.0, 14.0)];
        [userName setFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
        [userName setTextAlignment:UITextAlignmentCenter];
        [userName setBackgroundColor:[UIColor blackColor]];
        [userName setTextColor:[UIColor whiteColor]];
        [userName setLineBreakMode:UILineBreakModeClip];
        [userName setTag:viewTag];
        viewTag++;
        [self.leaderboardView addSubview:userName];
        [userName release];
        
        // Label to hold the user's score
        UILabel *userScore = [[UILabel alloc] initWithFrame:CGRectMake(xOrigin, yOrigin+75, 50.0, 14.0)];
        [userScore setFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
        [userScore setTextAlignment:UITextAlignmentCenter];
        [userScore setBackgroundColor:[UIColor blackColor]];
        [userScore setTextColor:[UIColor whiteColor]];
        [userScore setLineBreakMode:UILineBreakModeClip];
        [userScore setTag:viewTag];
        viewTag++;
        [self.leaderboardView addSubview:userScore];
        [userScore release];
        
        // Increment the x offset for the next player
        xOrigin += 96;
    }
}

/*
 * This method controls the visible state for the
 * game UI elements. It is called when the view
 * is first loaded or when the user is logged out.
 */
- (void) initGameUIState {
    [playButton setHidden:NO];
    [gameLabel setHidden:YES];
    [bragButton setHidden:YES];
    [inviteButton setHidden:YES];
    [leaderboardView setHidden:YES];
}

/*
 * This method is used to control the visibility of
 * the UI elements when the game starts or ends.
 */
- (void) gamePlayUIState:(BOOL) hide {
    [playButton setHidden:hide];
    [gameLabel setHidden:hide];
    [bragButton setHidden:hide];
    [inviteButton setHidden:hide];
    [leaderboardView setHidden:hide];
    [logoutButton setHidden:hide];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Create the leader board UI
    [self createLeaderboardDisplay];
    
    // Initialize the visibility of the game UI elements
    [self initGameUIState];
}

- (void)viewDidUnload
{
    [self setGameLabel:nil];
    [self setPlayButton:nil];
    [self setWelcomeLabel:nil];
    [self setLogoutButton:nil];
    [self setLeaderboardView:nil];
    [self setBragButton:nil];
    [self setInviteButton:nil];
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


#pragma mark - Game Play Methods
/*
 * This method posts the user's score
 */
- (void) sendScore {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    // Get the user ID information from the app delegate property
    // that holds user data returned from the /me Graph API call
    NSString *uid = [[delegate userData] objectForKey:@"id"];
    // Build up the request - <server>?score=<score>&uid=<uid>
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:
                                [NSURL URLWithString:
                                 [NSString stringWithFormat:@"%@?score=%d&uid=%@",
                                  kBackEndServer,
                                  self.score,uid]]];
    // Start the request
    scoresConnection =[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

/*
 * This method simulates the game play through a series of 
 * animated images.
 */
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
    // End the game after some time
    [self performSelector:@selector(endGame) withObject:nil afterDelay:8.0];
}

/*
 * This method starts the game
 */
- (void) startGame {
    // Set visibility for the game play UI
    [self gamePlayUIState:YES];
    
    // Reset the score
    self.score = 0;
    
    // Start the game play
    [self playGame];
}

/*
 * This method ends the game
 */
- (void) endGame {
    // Stop any animations
    if ([gameImageView isAnimating]) {
        [gameImageView stopAnimating];
    }
    // Set visibility for the game play UI
    [self gamePlayUIState:NO];
    
    // Set the score
    self.score = 120;
    
    // Display the score
    gameLabel.text = [NSString stringWithFormat:@"Score: %d", self.score];
    
    // Post the score to the server
    [self sendScore];
}

/*
 * Helper method to return the picture endpoint for a given Facebook
 * object. Useful for displaying a user's profile picture.
 */
- (UIImage *)imageForObject:(NSString *)objectID {
    // Get the object image
    NSString *url = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture",objectID];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    [url release];
    return image;
}

/*
 * This method updates the leader board from data returned
 * from the scores API call. This method is invoked from the
 * app delegate.
 */
- (void) updateLeaderboard:(NSArray *)data {
    if ([data count] > 0) {
        NSUInteger viewTag = kLeaderBoardViewTagOffset;
        // Loop through the returned data array, picking at most
        // 3 results.
        for (NSUInteger i=0; i<[data count] && i < 3; i++) {
            // Get the view corresponding to the profile picture
            UIImageView *playerImageView = (UIImageView *) [self.leaderboardView viewWithTag:viewTag];
            viewTag++;
            // Get the view corresponding to the user's name
            UILabel *playerInfoLabel = (UILabel *) [self.leaderboardView viewWithTag:viewTag];
            viewTag++;
            // Get the view corresponding to the user's score
            UILabel *playerScoreLabel = (UILabel *) [self.leaderboardView viewWithTag:viewTag];
            viewTag++;
            
            // Set the image for the profile picture view, from
            // the API result's "id" information
            playerImageView.image = [self imageForObject:
                                     [[[data objectAtIndex:i] objectForKey:@"user"] objectForKey:@"id"]];
            // Set the text for the user's name, from the API
            // result's "name" information
            playerInfoLabel.text = [NSString stringWithFormat:@"%@",
                                    [[[data objectAtIndex:i] objectForKey:@"user"] objectForKey:@"name"]];
            // Set the text for the user's score, from the API
            // result's "score" information
            playerScoreLabel.text = [NSString stringWithFormat:@"%@",
                                     [[data objectAtIndex:i] objectForKey:@"score"]];
        }
    }
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    receivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void) clearConnection {
    [receivedData release];
    receivedData = nil;
    [scoresConnection release];
    scoresConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString* responseString = [[[NSString alloc] initWithData:receivedData
                                                      encoding:NSUTF8StringEncoding]
                                autorelease];
    // Print out the response from the server call
    NSLog(@"Response from scores update: %@",responseString);
    [self clearConnection];
    
    // Make a call to get the game scores that will eventually 
    // update the leader board
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [delegate apiGraphScores];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Err message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    NSLog(@"Err code: %d", [error code]);
    [self clearConnection];
}

#pragma mark - Button Action Methods
/*
 * Action handler when the login/play button is tapped
 */
- (IBAction)playClicked:(id)sender {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if ([[delegate facebook] isSessionValid]) {
        [self startGame];
    } else {
        [delegate login];
    }
}

/*
 * Action handler when the logout button is tapped
 */
- (IBAction)logoutClicked:(id)sender {
    [self initGameUIState];
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [delegate logout];
}

/*
 * Action handler when the invite button is tapped
 */
- (IBAction)inviteClicked:(id)sender {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [delegate apiDialogRequestsToMany];
}

/*
 * Action handler when the brag button is tapped
 */
- (IBAction)bragClicked:(id)sender {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [delegate apiDialogFeedUser];
}



@end
