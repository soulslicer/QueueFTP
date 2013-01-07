//
//  QueueFTP.h
//  nwTest
//
//  Created by Yaadhav Raaj on 22/10/12.
//  Copyright (c) 2012 Yaadhav Raaj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ASIHTTPRequest/ASINetworkQueue.h>
#import <ASIHTTPRequest/ASIFormDataRequest.h>

/************************************************************************
 * QueueFTPSettings Class
 
 This class does the following:
 
 1. A slightly more abstracte secure way to add settings
 2. Currently contains FTP Parameters
 ************************************************************************/

@interface QueueFTPSettings : NSObject{
    
    NSString* phpPath;
    NSString* ftpPath;
    NSString* username;
    NSString* password;
    
}

@property(nonatomic,strong)NSString* phpPath;
@property(nonatomic,strong)NSString* ftpPath;
@property(nonatomic,strong)NSString* username;
@property(nonatomic,strong)NSString* password;

-(id)init:(NSString*)_phpPath:(NSString*)_ftpPath:(NSString*)_username:(NSString*)_password;

@end

/************************************************************************
 * QueueFTPDelegate Protocol
 
 This protocol does the following:
 
 1. Function calls that can be used to check progress of upload
 2. More calls can be added here
 ************************************************************************/

@protocol QueueFTPDelegate<NSObject>
@required
-(void) fileUploadResponse:(BOOL)success:(int)responseCode:(NSString*)responseString;
-(void) allFilesUploaded;
-(void) progress:(float)progress;
@end

/************************************************************************
 * QueueFTP Class
 
 This class does the following:
 
 1. Allows adding of files
 2. Once files have been added, calling beginExecution starts upload
 3. All uploads may be cancelled by calling cancelAllOperations
 4. Contains it's own instance of NetworkQueue, so more functions
    may be added accordingly
 5. Needs to be initialized with queueFTPSettings
 6. Runs asynchronously
 7. Reads responses from PHP Script to generate errors/responses
 8. Currently upload progress cannot be linked to the particular file
    due to limitations of ASINetworkQueue
 ************************************************************************/

@interface QueueFTP : NSObject<QueueFTPDelegate>{
    
    QueueFTPSettings* settings;
    ASINetworkQueue *networkQueue;
    id<QueueFTPDelegate>delegate;
    
    int currIdx;
    NSMutableArray* currentFile;
}

@property (nonatomic,strong) ASINetworkQueue *networkQueue;
@property (nonatomic, strong) IBOutlet id <QueueFTPDelegate> delegate;

-(id)init:(QueueFTPSettings*)_queueFTPSettings;
-(void)beginExecution;
-(void)cancelAllOperations;
-(void)addFile:(NSString*)filePath:(NSString*)ftpPath;
-(void)setDelegate:(id <QueueFTPDelegate>)aDelegate;


@end


