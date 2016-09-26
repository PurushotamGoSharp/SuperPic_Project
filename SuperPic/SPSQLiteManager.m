//
//  SPSQLiteManager.m
//  SuperPic
//
//  Created by Syed Hyder Zubair on 01/05/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "SPSQLiteManager.h"
#import "AppDelegate.h"
#import <sqlite3.h>

@implementation SPSQLiteManager

@synthesize imageName, imageURL, userName;
@synthesize status, rowId;

static sqlite3 *database = nil;
static sqlite3_stmt *addStatement = nil;

- (id)init {
    if ((self = [super init])) {
        AppDelegate *appDelegateTemp = [[UIApplication sharedApplication] delegate];
        
        if (sqlite3_open([[appDelegateTemp databasePath] UTF8String], &database) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
    }
    return self;
}

-(void)InsertRecords:(NSMutableString *)txt{
    
    
}

// ("ImageName" TEXT, "ImageURL" TEXT, "Status" INTEGER, "UserName" TEXT, "Date" DATETIME DEFAULT CURRENT_DATE)
- (void)addImageInfoRecord {
//    NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"SuperPic.sqlite"];
//    const char *dbpath = [dbPath UTF8String];
    AppDelegate *appDelegateTemp = [[UIApplication sharedApplication] delegate];
    const char *dbpath = [[appDelegateTemp databasePath] UTF8String];
    sqlite3 *superPicDB;
    
    sqlite3_stmt    *statement;
//    imageURL = @"kURL";
//    imageName = @"kName";
//    NSLog(@"%@",dbPath);
    if (sqlite3_open(dbpath, &superPicDB) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO CareImage (ImageCode, ImageName, ImageURL, Status, UserName) VALUES (\"%@\", \"%@\", \"%@\", \"%ld\", \"%@\")",self.imageCode, imageName, imageURL, (long)status, userName];
        
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(superPicDB, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            sqlite3_bind_text(statement, 1, [imageName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [imageName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 3, (int)status);
            sqlite3_bind_text(statement, 4, [imageName UTF8String], -1, SQLITE_TRANSIENT);
        } else {
            NSLog(@"error");
            printf( "could not prepare statemnt: %s\n", sqlite3_errmsg(superPicDB) );
        }
        sqlite3_finalize(statement);
        sqlite3_close(superPicDB);
    }
    else {
        NSLog(@"Sqlite != ok");
    }
    /*
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//    
//        NSString *todaysDate = [dateFormatter stringFromDate:[NSDate date]];
    
    if (addStatement == nil) {
        const char *sqlQuery = "INSERT INTO CareImage(ImageName, ImageURL, Status, UserName) Values(?, ?, ?, ?)";
        if(sqlite3_prepare_v2(database, sqlQuery, -1, &addStatement, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
    }
    sqlite3_bind_text(addStatement, 1, [imageName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(addStatement, 2, [imageURL UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(addStatement, 3, (int)status);
    sqlite3_bind_text(addStatement, 4, [userName UTF8String], -1, SQLITE_TRANSIENT);
    
    if(SQLITE_DONE != sqlite3_step(addStatement))
        NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
    else
        //SQLite provides a method to get the last primary key inserted by using sqlite3_last_insert_rowid
        rowId = (int)sqlite3_last_insert_rowid(database);
    // NSUInteger
    //Reset the add statement.
    sqlite3_reset(addStatement);
     */
    /*
    
//    sqlite3_bind_text(addStatement, 4, [todaysDate UTF8String], -1, SQLITE_TRANSIENT);
     
     Are you sure you want to execute the following statement(s):
     
     INSERT INTO "main"."CareImage" ("ImageName","ImageURL","Status","UserName") VALUES (?1,?2,?3,?4)
     Parameters:
     param 1 (text): Syed
     param 2 (text): lion
     param 3 (integer): 1
     param 4 (text): Syed
     
    
    AppDelegate *appDelegateTemp = [[UIApplication sharedApplication] delegate];
    [appDelegateTemp databasePath];
    const char *dbpath = [[appDelegateTemp databasePath] UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into CareImage(ImageName, ImageURL, Status, UserName, Date) Values(\"%@, \"%@, \"%d, \"%@, \"%@)",@"Rose", @"rose.jpg", (int)status, userName, todaysDate];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &addStatement, NULL);
        if (sqlite3_step(addStatement) == SQLITE_DONE)
        {
            NSLog(@"Successfully added");
        }
        else {
            NSLog(@"Failed added");
        }
        //Reset the add statement.
        sqlite3_reset(addStatement);
    }
     */
}

+ (void) finalizeStatements
{
    if(database) sqlite3_close(database);
    if(addStatement) sqlite3_finalize(addStatement);
}

/*
 AppDelegate *appDelegateTemp = [[UIApplication sharedApplication] delegate];
 [appDelegateTemp databasePath];
 const char *dbpath = [[appDelegateTemp databasePath] UTF8String];
 if (sqlite3_open(dbpath, &database) == SQLITE_OK)
 {
 NSString *insertSQL = [NSString stringWithFormat:@"insert into CareImage(ImageName, ImageURL, Status, UserName, Date) Values(\"%@, \"%@, \"%d, \"%@, \"%@)",imageName, imageURL, (int)status, userName, [NSDate date]];
 const char *insert_stmt = [insertSQL UTF8String];
 sqlite3_prepare_v2(database, insert_stmt,-1, &addStatement, NULL);
 if (sqlite3_step(addStatement) == SQLITE_DONE)
 {
 
 }
 else {
 
 }
 //Reset the add statement.
 sqlite3_reset(addStatement);
 }
 */

- (BOOL)findImage:(NSString *)imgName {
    BOOL tempFindImage = NO;
    AppDelegate *appDelegateTemp = [[UIApplication sharedApplication] delegate];
    
    const char *dbpath = [[appDelegateTemp databasePath] UTF8String];
    sqlite3_stmt    *statement;
    __typeof(self) __weak weakSelf = self;
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT ImageCode, Status FROM CareImage WHERE ImageName=\"%@\"", imgName];
        
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                char * str1 = (char *)sqlite3_column_text(statement, 0);
                if (str1) {
                    weakSelf.imageCode = [NSString stringWithUTF8String:str1];
                }
                else {
                    weakSelf.imageCode = @"";
                }
                weakSelf.status = sqlite3_column_int(statement, 1);
                
                NSLog(@"Match found");
                tempFindImage = YES;
                
            } else {
                NSLog(@"Match not found");
                tempFindImage = NO;
            }
            sqlite3_finalize(statement);
        }
        else {
            tempFindImage = NO;
        }
        sqlite3_close(database);
    }
    else {
        tempFindImage = NO;
    }
    return tempFindImage;
}

@end
