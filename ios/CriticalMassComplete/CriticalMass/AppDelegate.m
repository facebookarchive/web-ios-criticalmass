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

#import "AppDelegate.h"

#import "ViewController.h"

// Your Facebook APP Id must be set before running this example
// See http://developers.facebook.com/apps
// Also, your application must bind to the fb[app_id]:// URL
// scheme (substitue [app_id] for your real Facebook app id).
static NSString *kAppId = @"343598042347842";

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize facebook;
@synthesize userData;

- (void)dealloc
{
    [userData release];
    [facebook release];
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    // Initialize Facebook
    facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:self];
    
    // Check and retrieve authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    // After retrieving any authorization data, make an additional
    // check to see if it is still valid.
    if ([facebook isSessionValid]) {
        // Show logged in state
        [self fbDidLogin];
    } else {
        // Show logged out state
        [self fbDidLogout];
    }
    
    
    return YES;
}

// Add for Facebook SSO support (pre 4.2)
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url]; 
}

// Add for Facebook SSO support (4.2+)
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url]; 
}

#pragma mark - Facebook Graph API 
/*
 * Graph API: Get the user's basic information, picking the name field.
 */
- (void)apiGraphMe {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"name",  @"fields",
                                   nil];
    [facebook requestWithGraphPath:@"me" andParams:params andDelegate:self];
}

/*
 * Graph API: Get the scores for the user and friends
 */
- (void)apiGraphScores {
    [facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/scores",kAppId]
                       andDelegate:self];
}

#pragma mark - FBRequestDelegate Methods
/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    if ([result isKindOfClass:[NSArray class]] && ([result count] > 0)) {
        result = [result objectAtIndex:0];
    }
    if ([result objectForKey:@"name"]) {
        // Personal information API return callback
        userData = [[NSMutableDictionary alloc] initWithDictionary:result copyItems:YES];
        self.viewController.welcomeLabel.text = [NSString stringWithFormat:@"Welcome %@", [result objectForKey:@"name"]];
    } else if ([result objectForKey:@"data"]) {
        [self.viewController updateLeaderboard:[result objectForKey:@"data"]];
    }
}

#pragma mark - Facebook User Authorization
/*
 * This method calls the Facebook API to authorize the user
 */
- (void) login {
    // Permissions to request
    NSArray *perms = [[NSArray alloc] initWithObjects:
                      @"publish_actions", 
                      @"email", 
                      nil];
    [facebook authorize:perms];
    [perms release];
}

/*
 * This method calls the Facebook to log out the user
 */
- (void) logout {
    [facebook logout];
}

#pragma mark - FBSessionDelegate Methods
/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
    self.viewController.welcomeLabel.text = @"Welcome ...";
    [self.viewController.playButton setTitle:@"Play" forState:UIControlStateNormal];
    [self.viewController.logoutButton setHidden:NO];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    // Personalize
    [self apiGraphMe];
    
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
    self.viewController.welcomeLabel.text = @"Welcome to Critical Mass";
    [self.viewController.playButton setTitle:@"Login to Play" forState:UIControlStateNormal];
    [self.viewController.logoutButton setHidden:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

/**
 * Called when the user canceled the authorization dialog.
 */
- (void)fbDidNotLogin:(BOOL)cancelled {
}

/**
 * Called when the access token has been extended
 */
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

/**
 * Called when the session is found to be invalid during an API call
 */
- (void)fbSessionInvalidated {
}

#pragma mark - Facebook Dialogs
/**
 * A helper function for parsing URL parameters.
 */
- (NSDictionary*)parseURLParams:(NSString *)query {
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	for (NSString *pair in pairs) {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
		NSString *val =
        [[kv objectAtIndex:1]
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
		[params setObject:val forKey:[kv objectAtIndex:0]];
	}
    return params;
}

/*
 * Dialog: Requests - enable multi-friend selector on all friends
 */
- (void)apiDialogRequestsToMany {
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"Check out Critical Mass!",  @"message",
                                   nil];
    
    [facebook dialog:@"apprequests"
           andParams:params
         andDelegate:self];
}

/*
 * Dialog: Feed for the user
 */
- (void)apiDialogFeedUser {
    // Dialog parameters
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"I just did something awesome in Critical Mass!", @"caption",
                                   @"http://www.bitdecay.net/labs/criticalmasscomplete/", @"link",
                                   @"http://www.bitdecay.net/labs/criticalmasscomplete/criticalmass.png", @"picture",
                                   nil];
    
    [facebook dialog:@"feed"
           andParams:params
         andDelegate:self];
    
}

#pragma mark - FBDialogDelegate Methods

/**
 * Called when a UIServer Dialog successfully return. Using this callback
 * instead of dialogDidComplete: to properly handle successful shares/sends
 * that return ID data back.
 */
- (void)dialogCompleteWithUrl:(NSURL *)url {
    if (![url query]) {
        NSLog(@"User canceled dialog or there was an error");
        return;
    }
    
    NSDictionary *params = [self parseURLParams:[url query]];
    if ([params objectForKey:@"request"]) {
        // Successful requests are returned in the form:
        // request=1001316103543&to[0]=100003086810435&to[1]=100001482211095
        NSLog(@"Request ID: %@", [params objectForKey:@"request"]);
    } else if ([params valueForKey:@"post_id"]) {
        // Successful feed posts will return a post_id parameter
        NSLog(@"Feed post ID: %@", [params valueForKey:@"post_id"]);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Attempt to extend the access token when the app is activated
    [facebook extendAccessTokenIfNeeded];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
