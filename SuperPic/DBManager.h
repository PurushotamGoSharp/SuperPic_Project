//
//  DBManager.h
//  SimplicITy
//
//  Created by Vmoksha on 07/01/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class DBManager;

@protocol DBManagerDelegate <NSObject>

- (void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment;
@optional
- (void)DBMAnager:(DBManager *)manager savedSuccessfullyWithID:(NSInteger)lastID;

@end

@interface DBManager : NSObject

@property (weak, nonatomic) id<DBManagerDelegate> delegate;

- (instancetype)initWithFileName:(NSString *)dbFileName;

- (void)createTableForQuery:(NSString *)query;
- (void)dropTable:(NSString *)tableName;
- (void)saveDataToDBForQuery:(NSString *)query;
- (BOOL)getDataForQuery:(NSString *)query;

- (void)deleteRowForQuery:(NSString *)query;


@end
