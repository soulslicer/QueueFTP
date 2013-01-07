# QueueFTP

The easiest way to upload large files from iOS to a server.

There exists many solutions to upload large files (more than 50mb), however, I noticed that many of them were synchronous, slow and very difficult to use.

QueueFTP makes use of the [ASIHTTPRequest](http://allseeing-i.com/ASIHTTPRequest/) framework and uses a mix of PHP, FormRequest and NetworkQueue. Simply add as many files as you like, and beginExecution.

## Usage

1. Start my adding the following dependancy frameworks (CFNetwork) (SystemConfiguration) (MobileCoreServices) (Security) (libz.dylib) to your project
2. Add ASIHTTPRequest framework by hitting other and selecting the framework attached above
3. Drag QueueFTP.h and QueueFTP.m files into your project
4. Add the PHP script to your server
4. Start using! That easy!

## Example Usage

``` objective-c

QueueFTP* ftp;
QueueFTPSettings* ftpSettings;

ftpSettings=[[QueueFTPSettings alloc]init:@"phplink" :@"ftplink" :@"username" :@"password"];
ftp=[[QueueFTP alloc]init:ftpSettings];
[ftp setDelegate:self];
[ftp addFile:@"file1" :@"ftppath"];
[ftp addFile:@"file2" :@"ftppath"];
[ftp beginExecution];

```

## Delegate Functions

``` objective-c

//When a file is uploaded or failed, this function is called with the particular response code and string
-(void) fileUploadResponse:(BOOL)success:(int)responseCode:(NSString*)responseString{}

//When all files have been uploaded this is called
-(void) allFilesUploaded{}

//Exact progress of file being uploaded (currently does not support which file it is)
-(void) progress:(float)progress{}

```

## Errors

Error    | Description
---------- | ----------- 
404 | PHP path not found   
500 | Server rejected response (possibly from too many retries)
101 | Unable to connect to FTP Server
102 | Wrong username or password
103 | Wrong FTP Location/Path
104 | Upload interrupted/failed
100 | Upload Success!

## Notes

* I have packaged ASIHTTPRequest into an easy to use framework which you can simply add it to your ARC or non-ARC program
* New settings can be easily added as I have seperated the queueSettings from queueFTP. Also this ensures security
* Due to limitations of ASINetworkQueue, I am unable to match the progress to a particular file in the queue
* An example Project has been uploaded but without the FTP Parameters
* Use the PHP script provided as it works in tandem with QueueFTP to handle the errors in uploads etc.
* Tested to be working on iOS 5.1 and PHP Pear server

LICENSE
-------

Copyright (C) 2012 by Raaj

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.