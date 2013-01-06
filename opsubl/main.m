//
//  main.m
//  opsubl
//
//  Created by Declan Cook on 05/01/2013.
//  Copyright (c) 2013 Declan Cook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Finder.h"

NSString* getPathToFrontFinderWindow(){
    
    FinderApplication* finder = [SBApplication applicationWithBundleIdentifier:@"com.apple.Finder"];
    
    
    
    FinderFinderWindow* frontWindow =[[finder windows]  objectAtIndex:0];
    
    FinderItem* target =  [frontWindow.properties objectForKey:@"target"] ;
    
    
    NSURL* url =[NSURL URLWithString:target.URL];
    
    FSRef fsRef;
    Boolean isDir =NO;
    Boolean wasAliased;
    if (CFURLGetFSRef((CFURLRef)url, &fsRef)){
        if (FSResolveAliasFile (&fsRef, true /*resolveAliasChains*/,
                                &isDir, &wasAliased) == noErr && wasAliased){
            NSURL* newURL = (__bridge NSURL*)CFURLCreateFromFSRef(NULL, &fsRef);
            if(newURL!=nil)
                url = newURL;
        }
    }
    
    NSString* path = [url path];
    
    if(!isDir){
        path = [path stringByDeletingLastPathComponent];
    }
    
    return path;
}


int main(int argc, char *argv[])
{
    NSString* path;
	@try{
		path = getPathToFrontFinderWindow();
	}@catch(id ex){
		path =[@"~/Desktop" stringByExpandingTildeInPath];
	}
    
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:@"/Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl"];
    
    NSArray *args;
    args = [NSArray arrayWithObjects:@"-a",path, nil];
    [task setArguments:args];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    return 0;
}
