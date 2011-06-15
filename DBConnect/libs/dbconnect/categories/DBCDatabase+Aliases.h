//
//  DBCDatabase+Aliases.h
//  DBConnect
//
//  Created by Sergey Mamontov on 6/11/11.
//  Copyright 2011 Tattooed Orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBCDatabase.h"

@interface DBCDatabase (DBCDatabase_Aliases)

#pragma mark SQLite database misc

- (BOOL)attachDatabase:(NSString*)dbFilePath databaseAttachName:(NSString*)dbAttachName;
- (BOOL)detachDatabase:(NSString*)attachedDatabaseName;
- (BOOL)setDatabaseEncoding:(DBCDatabaseEncoding)encoding;
- (DBCDatabaseEncoding)databaseEncoding;
- (BOOL)setUseCaseSensitiveLike:(BOOL)use;
- (BOOL)useCaseSensitiveLike;

#pragma mark DDL and DML methods

- (BOOL)dropTable:(NSString*)tableName inDatabase:(NSString*)databaseName;
- (BOOL)dropAllTablesInDatabase:(NSString*)databaseName;

#pragma mark Database information

- (int)tablesCount;
- (int)tablesCountInDatabase:(NSString*)databaseName;
- (NSArray*)tablesList;
- (NSArray*)tablesListForDatabase:(NSString*)databaseName;
- (NSArray*)tableInformation:(NSString*)tableName;
- (NSArray*)tableInformation:(NSString*)tableName forDatabase:(NSString*)databaseName;
- (NSArray*)databasesList;
- (NSArray*)indicesList:(NSString*)databaseName forTable:(NSString*)tableName;
- (NSArray*)indexedColumnsList:(NSString*)databaseName index:(NSString*)indexName;

@end
