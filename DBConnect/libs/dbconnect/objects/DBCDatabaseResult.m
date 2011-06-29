/**
 *
 * Copyright (c) 2011 Sergey Mamontov
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "DBCDatabaseResult.h"
#import "DBCConfiguration.h"
#import "DBCDatabaseRow.h"
#import "DBCMacro.h"

@implementation DBCDatabaseResult
@synthesize queryExecutionDuration;

#pragma mark DBCDatabaseResult instance creation/initialization

/**
 * Initiate and return DBCDatabaseResult instance
 * @parameters
 *      sqlite3_stmt *statement              - statement which used for query
 *      DBCDatabaseEncoding databaseEncoding - current encoding used for opened 
 *                                             database connection
 * @return autoreleased DBCDatabaseResult instance
 */
+ (id)resultWithPreparedStatement:(sqlite3_stmt*)statement encoding:(DBCDatabaseEncoding)databaseEncoding {
    return [[[[self class] alloc] initWidthPreparedSatetement:statement encoding:databaseEncoding] autorelease];
}

/**
 * Initiate and return DBCDatabaseResult instance
 * @parameters
 *      sqlite3_stmt *statement              - statement which used for query
 *      DBCDatabaseEncoding databaseEncoding - current encoding used for opened 
 *                                             database connection
 * @return DBCDatabaseResult instance
 */
- (id)initWidthPreparedSatetement:(sqlite3_stmt*)statement encoding:(DBCDatabaseEncoding)databaseEncoding {
    if ((self = [super init])) {
        [self setQueryExecutionDuration:-1.0f];
        dbEncoding = databaseEncoding;
        const char *querySQLC = sqlite3_sql(statement);
        if(querySQLC != NULL){
            NSStringEncoding enc = dbEncoding==DBCDatabaseEncodingUTF16?NSUTF16StringEncoding:NSUTF8StringEncoding;
            querySQL = [[NSString stringWithCString:querySQLC encoding:enc] copy];
        }
        int i, columnsCount = sqlite3_column_count(statement);
        rows = [[NSMutableArray alloc] init];
        colNames = [[NSMutableArray alloc] initWithCapacity:columnsCount];
        colTypes = [[NSMutableArray alloc] initWithCapacity:columnsCount];
        for (i = 0; i < columnsCount; i++) {
            const char *columnName = NULL;
            const char *columnType = NULL;
            if(databaseEncoding == DBCDatabaseEncodingUTF8) columnName = sqlite3_column_name(statement, i);
            else columnName = sqlite3_column_name16(statement, i);
            if (columnName != NULL) [colNames addObject:[[NSString stringWithCString:columnName encoding:NSUTF8StringEncoding] lowercaseString]];
            else [colNames addObject:[NSString stringWithFormat:@"%i", i]];
            columnType = sqlite3_column_decltype(statement, i);
            if(columnType != NULL) {
                NSString *columnTypeName = [[NSString stringWithCString:columnType encoding:NSUTF8StringEncoding] lowercaseString];
                if([columnTypeName isEqualToString:@"integer"] || [columnTypeName isEqualToString:@"int"] || [columnTypeName isEqualToString:@"number"]) 
                    [colTypes addObject:[NSNumber numberWithInt:SQLITE_INTEGER]];
                else if([columnTypeName isEqualToString:@"float"] || [columnTypeName isEqualToString:@"number"]) 
                    [colTypes addObject:[NSNumber numberWithInt:SQLITE_FLOAT]];
                else if([columnTypeName isEqualToString:@"text"]) [colTypes addObject:[NSNumber numberWithInt:SQLITE_TEXT]];
                else if([columnTypeName isEqualToString:@"blob"]) [colTypes addObject:[NSNumber numberWithInt:SQLITE_BLOB]];
                else [colTypes addObject:[NSNumber numberWithInt:SQLITE_NULL]];
            }
            else [colTypes addObject:[NSNumber numberWithInt:SQLITE_NULL]];
        }
    }
    return self;
}

#pragma mark DBCDatabaseResults setters/getters

/**
 * Retrieve count of result rows
 * @return result rows count
 */
- (int)count {
    return [rows count];
}

/**
 * Retrieve list of columns names
 * @return list of columns names
 */
- (NSArray*)columnNames {
    return colNames;
}

#pragma mark Result row management

/**
 * Create row instance from data stored in statement after step iteration
 * @parameters
 *      sqlite3_stmt *statement - statement which used for query
 */
- (void)addRowFromStatement:(sqlite3_stmt*)statement {
    [rows addObject:[DBCDatabaseRow rowWithStatement:statement dataStructureDelegate:self]];
}

/**
 * Retrieve row data instance from specific index
 * @parameters
 *      int rowIdx - target row index
 * @return row instance at specified index
 */
- (DBCDatabaseRow*)rowAtIndex:(int)rowIdx {
    if(rowIdx >= [rows count]) return nil;
    return [rows objectAtIndex:rowIdx];
}

#pragma mark Fast enumeration protocol support

/**
 * Support method for fast enumeration protocol
 * @parameters
 *      NSFastEnumerationState *state - Context information that is used in the 
 *                                      enumeration to, in addition to other 
 *                                      possibilities
 *      id *stackbuf                  - A C array of objects over which the 
 *                                      sender is to iterate
 *      NSUInteger len                - The maximum number of objects to return 
 *                                      in stackbuf
 * @return number of objects returned in stackbuf
 */
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
    return [rows countByEnumeratingWithState:state objects:stackbuf count:len];
}

#pragma mark Description for NSLog

/**
 * Return formated DBCDatabaseResults instance description
 * @return formated DBCDatabaseResults instance description
 */
- (NSString *)description {
    NSString *executionDuration = queryExecutionDuration==-1.0f?@"":[NSString stringWithFormat:@"Query execution done in %fs\n", queryExecutionDuration];
    return [NSString stringWithFormat:@"\nResult for: %@\n%@Found: %i records\nColumn names: %@\nResult rows: %@", querySQL, executionDuration, [self count], [colNames componentsJoinedByString:@" | "], rows];
}

#pragma mark DBCDatabaseResultStructure protocol support 

/**
 * Retrieve number of columns in response
 * @return number of columns in response
 */
- (int)columnsCount {
    return [colNames count];
}

/**
 * Retrieve database database encoding
 * @return database encoding
 */
- (DBCDatabaseEncoding)databaseEncoding {
    return dbEncoding;
}

/**
 * Retrieve name for column
 * @parameters
 *      int columnIdx - target column index
 * @return name of column at specified index
 */
- (NSString*)nameForColumnAtIndex:(int)columnIdx {
    if(columnIdx >= [colNames count]) return nil;
    return [colNames objectAtIndex:columnIdx];
}

/**
 * Retrieve column index
 * @parameters
 *      NSString *columnName - target column name
 * @return index of column with specified name
 */
- (int)indexForColumn:(NSString*)columnName {
    if(![colNames containsObject:columnName]){
        DBCDebugLogger(@"DBC:WARNING] There is no column with name '%@' in response", colNames);
        return -1;
    }
    return [colNames indexOfObject:columnName];
}

/**
 * Retrieve stringified column data type
 * @parameters
 *      NSString *columnName - target column name
 * @return stringified data type declared in table structure
 */
- (NSString*)stringifiedTypeForColumn:(NSString*)columnName {
    return DBCDatabaseDataTypeStringify([self typeForColumn:columnName]);
}

/**
 * Retrieve column data type
 * @parameters
 *      NSString *columnName - target column name
 * @return data type declared in table structure
 */
- (int)typeForColumn:(NSString*)columnName {
    int columnIdx = [self indexForColumn:columnName];
    if(columnIdx < 0) return -1;
    return [self typeForColumnAtIndex:columnIdx];
}

/**
 * Retrieve stringified column data type
 * @parameters
 *      int columnIdx - target column index
 * @return stringified data type declared in table structure
 */
- (NSString*)stringifiedTypeForColumnAtIndex:(int)columnIdx {
    return DBCDatabaseDataTypeStringify([self typeForColumnAtIndex:columnIdx]);
}

/**
 * Retrieve column data type
 * @parameters
 *      int columnIdx - target column index
 * @return data type declared in table structure
 */
- (int)typeForColumnAtIndex:(int)columnIdx {
    if(columnIdx >= [colTypes count]) return -1;
    return [[colTypes objectAtIndex:columnIdx] intValue];
}

#pragma mark DBCDatabaseResult memory management

/**
 * Deallocating result instance and release all retained memory
 */
- (void)dealloc {
    DBCReleaseObject(querySQL);
    DBCReleaseObject(rows);
    DBCReleaseObject(colNames);
    DBCReleaseObject(colTypes);
    [super dealloc];
}

@end
