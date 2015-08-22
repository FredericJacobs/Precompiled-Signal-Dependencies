//
//  LogSubmit.m
//  Signal
//
//  Created by Frederic Jacobs on 02/07/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import "Pastelog.h"
#include <sys/types.h>
#include <sys/sysctl.h>

static const NSUInteger ddLogLevel = DDLogLevelAll;

@interface Pastelog ()

@property (nonatomic)UIAlertView *reportAlertView;
@property (nonatomic)UIAlertView *loadingAlertView;
@property (nonatomic)UIAlertView *submitAlertView;
@property (nonatomic)NSMutableData *responseData;
@property (nonatomic, copy)successBlock block;
@property (nonatomic, copy)NSString *gistURL;


@end

@implementation Pastelog

+(void)reportErrorAndSubmitLogsWithAlertTitle:(NSString*)alertTitle alertBody:(NSString*)alertBody {
    [self reportErrorAndSubmitLogsWithAlertTitle:alertTitle alertBody:alertBody completionBlock:nil];
}

+(void)reportErrorAndSubmitLogsWithAlertTitle:(NSString*)alertTitle alertBody:(NSString*)alertBody completionBlock:(successBlock)block {
    Pastelog *sharedManager = [self sharedManager];
    sharedManager.block = block;
    sharedManager.reportAlertView = [[UIAlertView alloc] initWithTitle:alertTitle message:alertBody delegate:[self sharedManager] cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [sharedManager.reportAlertView show];
}

+(void)submitLogs {
    Pastelog *sharedManager = [self sharedManager];
    [self submitLogsWithCompletion:^(NSError *error, NSString *urlString) {
        if (!error) {
            sharedManager.gistURL = urlString;
            sharedManager.submitAlertView = [[UIAlertView alloc]initWithTitle:@"Submit Debug Log" message:@"Bugs can be reported by email or by copying the log in a GitHub Issue (advanced)." delegate:[self sharedManager] cancelButtonTitle:@"GitHub Issue" otherButtonTitles:@"Email", nil];
            [sharedManager.submitAlertView show];
        } else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed to submit debug log" message:@"The debug log could not be submitted. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}

+(void)submitLogsWithCompletion:(successBlock)block {
    [self submitLogsWithCompletion:(successBlock)block forFileLogger:[[DDFileLogger alloc] init]];
}

+(void)submitLogsWithCompletion:(successBlock)block forFileLogger:(DDFileLogger*)fileLogger {

    [self sharedManager].block = block;

    [self sharedManager].loadingAlertView =  [[UIAlertView alloc] initWithTitle:@"Sending debug log ..."
                                                                         message:nil delegate:self
                                                               cancelButtonTitle:nil
                                                               otherButtonTitles:nil];
    [[self sharedManager].loadingAlertView show];

    NSArray *fileNames = fileLogger.logFileManager.sortedLogFileNames;
    NSArray *filePaths = fileLogger.logFileManager.sortedLogFilePaths;

    NSMutableDictionary *gistFiles = [@{} mutableCopy];

    NSError *error;

    for (unsigned int i = 0; i < [filePaths count]; i++) {
        [gistFiles setObject:@{@"content":[NSString stringWithContentsOfFile:[filePaths objectAtIndex:i] encoding:NSUTF8StringEncoding error:&error]} forKey:[fileNames objectAtIndex:i]];
    }

    if (error) {
    }

    NSDictionary *gistDict = @{@"description":[self gistDescription], @"files":gistFiles};

    NSData *postData = [NSJSONSerialization dataWithJSONObject:gistDict options:0 error:nil];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:@"https://api.github.com/gists"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];

    [[self sharedManager] setResponseData:[NSMutableData data]];
    [[self sharedManager] setBlock:block];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];

    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:[self sharedManager]];

    [connection start];

}

+(Pastelog*)sharedManager {
    static Pastelog *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

-(instancetype)init {
    if (self = [super init]) {
        self.responseData = [NSMutableData data];
    }
    return self;
}

+(NSString*)gistDescription{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);

    NSString *gistDesc = [NSString stringWithFormat:@"iPhone Version: %@, iOS Version: %@", platform,[UIDevice currentDevice].systemVersion];

    return gistDesc;
}

#pragma mark Network delegates

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.loadingAlertView dismissWithClickedButtonIndex:0 animated:YES];

    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&error];
    if (!error) {
        self.block(nil, [dict objectForKey:@"html_url"]);
    } else{
        DDLogError(@"Error on debug response: %@", error);
        self.block(error, nil);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;

    if ( [httpResponse statusCode] != 201) {
        DDLogError(@"Failed to submit debug log: %@", httpResponse.debugDescription);
        [self.loadingAlertView dismissWithClickedButtonIndex:0 animated:YES];
        [connection cancel];
        self.block([NSError errorWithDomain:@"PastelogKit" code:10001 userInfo:@{}],nil);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.loadingAlertView dismissWithClickedButtonIndex:0 animated:YES];
    DDLogError(@"Uploading logs failed with error: %@", error);
    self.block(error,nil);
}

#pragma mark Alert View Delegates

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.reportAlertView) {
        if (buttonIndex == 0) {
            if (self.block) {
                [[self class] submitLogsWithCompletion:self.block];
            } else{
                [[self class] submitLogs];
            }

        } else{
            // User declined, nevermind.
        }
    } else if (alertView == self.submitAlertView) {
        if (buttonIndex == 0) {
            [self pasteBoardCopy:self.gistURL];
        } else{
            [self submitEmail:self.gistURL];
        }
    }
}

#pragma mark Logs submission

- (void)submitEmail:(NSString*)url {
    NSString *emailAddress = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"LOGS_EMAIL"];

    NSString *urlString = [NSString stringWithString: [[NSString stringWithFormat:@"mailto:%@?subject=iOS%%20Debug%%20Log&body=", emailAddress] stringByAppendingString:[[NSString stringWithFormat:@"Log URL: %@ \n Tell us about the issue: ", url]stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];

    [UIApplication.sharedApplication openURL: [NSURL URLWithString: urlString]];
}

- (void)pasteBoardCopy:(NSString*)url {
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:url];
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"LOGS_URL"]]];
}

@end
