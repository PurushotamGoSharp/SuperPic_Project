//
//  DBManager.m
//  SimplicITy
//
//  Created by Vmoksha on 07/01/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "DBManager.h"
#import <sqlite3.h>

@implementation DBManager
{
    NSString *databasePath;
    sqlite3 *database;
    //    sqlite3_stmt *statement ;
}

- (id)initWithFileName:(NSString *)dbFileName
{
    if (self = [super init])
    {
        NSString *docsDir;
        NSArray *dirPaths;
        
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = dirPaths[0];
        databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:dbFileName]];
        
        NSLog(@"Data Base Path %@",databasePath);
    }
    
    return self;
}

- (void)createTableForQuery:(NSString *)query
{
    NSLog(@"Data Base Path %@",databasePath);
    NSFileManager *filemgr = [NSFileManager defaultManager];
    const char *dbpath = [databasePath UTF8String];
    if (![filemgr fileExistsAtPath: databasePath ])
    {
        if (sqlite3_open(dbpath, &database)== SQLITE_OK)
        {
            sqlite3_close(database);
        }
    }
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        char *errMsg;
        const char *sql_stmt = [query UTF8String];
        
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
        {
            
            NSLog(@"Failed to create table");
        }
        sqlite3_close(database);
    }
    else {
        NSLog(@"Failed to open/create database");
    }
}




- (void)dropTable:(NSString *)tableName
{
    const char *dbPath = [databasePath UTF8String];
    
    if (sqlite3_open(dbPath, &database) == SQLITE_OK)
    {
        NSString *deleQry = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", tableName];
        const char *sqlStmt = [deleQry UTF8String];
        
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(database, sqlStmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"Table %@ is droped", tableName);
            }else
            {
                NSLog(@"Table %@ is not able to dropped", tableName);
            }
        }else
        {
            NSLog(@"Statement for droping is failed to be prepared");
        }
        
        sqlite3_close(database);
    }
}


- (void)deleteRowForQuery:(NSString *)query
{
    const char *dbPath = [databasePath UTF8String];
    if (sqlite3_open(dbPath, &database) == SQLITE_OK)
    {
        const char *sqlStmt = [query UTF8String];
        sqlite3_stmt *statement;
        
        sqlite3_prepare_v2(database, sqlStmt, -1, & statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"Deleted Sucessfully");
        } else
        {
            NSLog(@"Not Deleted");
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
}


- (void)saveDataToDBForQuery:(NSString *)query
{
    
    const char *dbPath = [databasePath UTF8String];
    
    if (sqlite3_open(dbPath, &database) == SQLITE_OK)
    {
        const char *insert_stmt = [query UTF8String];
        
        sqlite3_stmt *statement;
        
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"saved Sucessfully");
            
            NSInteger lastInsertId = (NSInteger)sqlite3_last_insert_rowid(database);
            
            if ([self.delegate respondsToSelector:@selector(DBMAnager:savedSuccessfullyWithID:)])
            {
                [self.delegate DBMAnager:self savedSuccessfullyWithID:lastInsertId];
            }
        }
        else
        {
            NSLog(@"Not saved ");
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
}

- (BOOL)getDataForQuery:(NSString *)query
{
    const char *dbPath = [databasePath UTF8String];
    
    if (sqlite3_open(dbPath, &database) == SQLITE_OK)
    {
        const char *insert_stmt = [query UTF8String];
        
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            [self.delegate DBManager:self gotSqliteStatment:statement];
            sqlite3_finalize(statement);
        }else
        {
            return NO;
        }
     
        sqlite3_close(database);
    }else
    {
        return NO;
    }
    
    return YES;
}

@end
