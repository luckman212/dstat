#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import <SystemConfiguration/SystemConfiguration.h>

NSString *appName;

void printUsage() {
    const char *appNameCStr = [appName UTF8String];
    printf("Usage: %s <type>\n", appNameCStr);
    printf("    -s, --sleep    check display sleep status\n");
    printf("    -l, --lock     check screen lock status\n\n");
    printf("The program does not output anything—it exits with a status code:\n");
    printf("    0 (true)       display is sleeping or locked\n");
    printf("    1 (false)      display is NOT sleeping or locked\n");
    printf("    2              invalid commandline argument\n");
    printf("    3              error querying display status\n");
    printf("    4              no login session (cannot operate in this condition)\n");
}

int checkSleepStatus() {
    CGDirectDisplayID mainDisplayID = CGMainDisplayID();
    BOOL isAsleep = CGDisplayIsAsleep(mainDisplayID);
    return (isAsleep ? 0 : 1);
}

int checkLockStatus() {
    CFDictionaryRef dictRef = CGSessionCopyCurrentDictionary();
    if (dictRef) {
        NSDictionary *dict = CFBridgingRelease(dictRef);
        NSString *locked = dict[@"CGSSessionScreenIsLocked"];
        BOOL isLocked = [locked boolValue];
        return (isLocked ? 0 : 1);
    } else {
        fprintf(stderr, "error: unable to get session dictionary\n");
        return(3);
    }
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        appName = [[NSProcessInfo processInfo] processName];
        NSString *userName;
        uid_t userID;
        gid_t groupID;
        userName = CFBridgingRelease(SCDynamicStoreCopyConsoleUser(NULL, &userID, &groupID));
        if (!userName || [userName isEqualToString:@"loginwindow"]) {
            exit(4);
        }
        if (argc > 1) {
            NSString *argument = [NSString stringWithUTF8String:argv[1]];
            const char *argCStr = [argument UTF8String];
            if ([argument isEqualToString:@"--sleep"] || [argument isEqualToString:@"-s"]) {
                exit(checkSleepStatus());
            } else if ([argument isEqualToString:@"--lock"] || [argument isEqualToString:@"-l"]) {
                exit(checkLockStatus());
            } else if ([argument isEqualToString:@"--help"] || [argument isEqualToString:@"-h"]) {
                printUsage();
                exit(2);
            } else {
                fprintf(stderr, "invalid arg: %s\n", argCStr);
                printUsage();
                exit(2);
            }
        } else {
            printUsage();
            exit(2);
        }
    }
    return 0;
}
