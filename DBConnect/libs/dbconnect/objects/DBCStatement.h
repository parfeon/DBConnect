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

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBCStatement : NSObject {
    NSString                *sqlQuery;
    sqlite3_stmt            *statement;
}
@property (nonatomic, copy)NSString *sqlQuery;

#pragma mark DBCStatement instance initialization

/**
 * Initiate DBCStatement instance
 * @return initialized DBCStatement instance
 */
- (id)init;

/**
 * Initiate DBCStatement instance with SQL query request
 * @parameters
 *      NSString *sql - SQL query for statement
 * @return initialized DBCDatabaseStatement instance
 */
- (id)initWithSQLQuery:(NSString*)sql;

#pragma mark DBCStatement state manipulation

/**
 * Reset prepared statement to it's initial state
 */
- (void)reset;

/**
 * Close prepared statement and release it
 */
- (void)close;

#pragma mark DBCStatement getter/setter

/**
 * Set new prepared statement
 * @parameters
 *      sqlite3_stmt *newStatement - new statement to store
 */
- (void)setStatement:(sqlite3_stmt*)newStatement;

#pragma mark DBCStatement for NSLog

/**
 * Get stored statement
 * @return stored statement
 */
- (sqlite3_stmt*)statement;

#pragma mark DBCStatement memory management

/**
 * Deallocating DBCStatement instance and release all retained memory
 */
- (void)dealloc;

@end
