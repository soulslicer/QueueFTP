//
//  QueueFTP.m
//  nwTest
//
//  Created by Yaadhav Raaj on 22/10/12.
//  Copyright (c) 2012 Yaadhav Raaj. All rights reserved.
//

#import "QueueFTP.h"

@implementation QueueFTPSettings
@synthesize phpPath,ftpPath,username,password;

-(id)init:(NSString*)_phpPath:(NSString*)_ftpPath:(NSString*)_username:(NSString*)_password{
    
    phpPath=_phpPath;
    ftpPath=_ftpPath;
    username=_username;
    password=_password;
    
    return self;
}

@end


@implementation QueueFTP
@synthesize networkQueue,delegate;

-(id)init:(QueueFTPSettings*)_queueFTPSettings{
    
    currIdx=0;
    currentFile=[[NSMutableArray alloc]init];
    settings=_queueFTPSettings;
    
    // Stop anything already in the queue before removing it
	[[self networkQueue] cancelAllOperations];
	
	// Creating a new queue each time we use it means we don't have to worry about clearing delegates or resetting progress tracking
	[self setNetworkQueue:[ASINetworkQueue queue]];
	[[self networkQueue] setDelegate:self];
	[[self networkQueue] setRequestDidFinishSelector:@selector(requestFinished:)];
	[[self networkQueue] setRequestDidFailSelector:@selector(requestFailed:)];
	[[self networkQueue] setQueueDidFinishSelector:@selector(queueFinished:)];
    [[self networkQueue] setRequestDidStartSelector:@selector(requestStarted:)];
    
    [self networkQueue].delegate = self;
    [[self networkQueue] setShowAccurateProgress:YES];
    
    return self;
}

-(NSString*)getLastString:(NSString*)fullPath{
    NSArray* X=[fullPath componentsSeparatedByString:@"/"];
    NSString* actualFileName=[X lastObject];
    return actualFileName;
}

-(void)addFile:(NSString*)filePath:(NSString*)ftpPath{
    
    NSURL* url=[[NSURL alloc]initWithString:settings.phpPath];
    ASIFormDataRequest* request=[[ASIFormDataRequest alloc]initWithURL:url];
    
    [request setRequestMethod:@"POST"];
    [request setPostValue:settings.ftpPath forKey:@"server"];
    [request setPostValue:settings.username forKey:@"user"];
    [request setPostValue:settings.password forKey:@"password"];
    [request setPostValue:ftpPath forKey:@"pathserver"];
    [request setFile:filePath forKey:@"userfile"];
    
    [request setUploadProgressDelegate:self];
    [request setShowAccurateProgress:YES];
    
    request.showAccurateProgress=YES;
    request.timeOutSeconds = 500;
    [request setShouldStreamPostDataFromDisk:YES];
    request.responseEncoding=NSUTF8StringEncoding;
    
    [[self networkQueue] addOperation:request];
    [currentFile addObject:[self getLastString:filePath]];
}

-(void)beginExecution{
    [[self networkQueue] go];
}

-(void)cancelAllOperations{
    [[self networkQueue] cancelAllOperations];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    //You could release the queue here
	if ([[self networkQueue] requestsCount] == 0) {
		[self setNetworkQueue:nil];
	}
    
    //Handle 404 Error
    if(request.responseStatusCode==404){
        [[self delegate]fileUploadResponse:NO :404 :@"PHP path not found"];
        return;
    }
    
    //Handle 500 Error
    if(request.responseStatusCode==500){
        [[self delegate]fileUploadResponse:NO :500 :@"Server rejected response"];
        return;
    }
    
    //Connection Success 200
    if(request.responseStatusCode==200){
        
        NSString* response=[request responseString];
        //NSLog(response);
        
        //FTP Path Wrong
        if (!([response rangeOfString:@"getaddrinfo failed"].location == NSNotFound)) {
            [[self delegate]fileUploadResponse:NO :101 :@"FTP Server Wrong"];
            return;
        }
        
        //Authentication Wrong
        if (!([response rangeOfString:@"Login authentication failed"].location == NSNotFound)) {
            [[self delegate]fileUploadResponse:NO :102 :@"Wrong username or password"];
            return;
        }
        
        //Bad FTP Path
        if (!([response rangeOfString:@"No such file or directory"].location == NSNotFound)) {
            
            NSString* fileName=[self getLastString:response];
            NSString* string=[NSString stringWithFormat:@"FTP Directory not found: %@",fileName];
            [[self delegate]fileUploadResponse:NO :103 :string];
            return;
        }
        
        //Interrupted upload
        if (!([response rangeOfString:@"FTP upload has encountered an error"].location == NSNotFound)) {
            NSString* fileName=[self getLastString:response];
            NSString* string=[NSString stringWithFormat:@"Upload Interrupted Error: %@",fileName];
            [[self delegate]fileUploadResponse:NO :104 :string];
            return;
        }
        
        //No Issue Success
        if (!([response rangeOfString:@"Success!"].location == NSNotFound)) {
            [[self delegate]fileUploadResponse:YES :100 :[self getLastString:response]];
        }
    }

}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	// You could release the queue here if you wanted
	if ([[self networkQueue] requestsCount] == 0) {
		[self setNetworkQueue:nil];
	}
	
	//... Handle failure
	NSLog(@"Request failed");
}


- (void)queueFinished:(ASINetworkQueue *)queue
{
	if ([[self networkQueue] requestsCount] == 0) {
		[self setNetworkQueue:nil];
	}

    [[self delegate]allFilesUploaded];
}

- (void)requestStarted:(ASIFormDataRequest *)request{
    NSLog(@"Upload for %@ started",[currentFile objectAtIndex:currIdx]);
    currIdx++;
}

- (void)setProgress:(float)progress
{
    [[self delegate]progress:progress];
}

- (void)setDelegate:(id <QueueFTPDelegate>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;
    }
}


@end

