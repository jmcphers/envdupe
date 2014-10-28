#import "AppDelegate.h"

#include <string>

#include <stdlib.h>

@interface AppDelegate ()

@property (unsafe_unretained) IBOutlet NSTextView *myEnv;
@property (unsafe_unretained) IBOutlet NSTextView *childEnv;
@property (weak) IBOutlet NSTextField *myPath;
@property (weak) IBOutlet NSTextField *childPath;

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

NSString *execCommand(NSString *cmd, NSArray* args)
{
   NSTask* task = [[NSTask alloc] init];
   task.launchPath = cmd;
   if (args != nil) {
      task.arguments = args;
   }
   NSPipe* pipe = [[NSPipe alloc] init];
   [task setStandardOutput: pipe];
   [task launch];
   [task waitUntilExit];
   
   NSFileHandle* read = [pipe fileHandleForReading];
   NSData* dataRead = [read readDataToEndOfFile];
   NSString* stringRead = [[NSString alloc] initWithData:dataRead
                                                encoding:NSUTF8StringEncoding];
   return stringRead;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
   std::string path("/usr/share:");
   path.append(getenv("PATH"));
   setenv("PATH", path.c_str(), 1);

   NSString* myEnv = execCommand(@"/usr/bin/env", nil);
   [[_myEnv textStorage] replaceCharactersInRange: NSMakeRange(0, 0)
                                       withString: myEnv];
   
   NSString* childEnv = execCommand(@"/bin/sh",
                                    [NSArray arrayWithObjects: @"-c", @"/usr/bin/env", nil]);
   
   [[_childEnv textStorage] replaceCharactersInRange: NSMakeRange(0, 0)
                                          withString: childEnv];
   
   NSString* myPath = execCommand(@"/usr/bin/printenv",
                                 [NSArray arrayWithObjects: @"PATH", nil]);
   [_myPath setStringValue: myPath];

   NSString* childPath = execCommand(@"/bin/sh",
                                  [NSArray arrayWithObjects: @"-c", @"/usr/bin/printenv PATH", nil]);
   [_childPath setStringValue: childPath];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

@end
