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


@interface DBCDatabaseIndexInfo : NSObject {
    int         idxSeqNumber;
    NSString    *idxName;
    BOOL        idxUnique;
}
@property (nonatomic, readonly, getter = numberInSequence)int idxSeqNumber;
@property (nonatomic, readonly, getter = name)NSString *idxName;
@property (nonatomic, readonly, getter = isUnique)BOOL idxUnique;

#pragma mark DBCDatabaseIndexInfo instance initialization

/**
 * Initiate DBCDatabaseIndexInfo instance
 * @parameters
 *      int sequenceNumber  - index sequence number in list of other indices
 *      NSString* indexName - index name
 *      BOOL isUnique       - unique
 * @return autoreleased DBCDatabaseIndexInfo instance
 */
+ (id)indexInfoWithSequence:(int)sequenceNumber name:(NSString*)indexName unique:(BOOL)isUnique;

/**
 * Initiate DBCDatabaseIndexInfo instance
 * @parameters
 *      int sequenceNumber  - index sequence number in list of other indices
 *      NSString* indexName - index name
 *      BOOL isUnique       - unique
 * @return DBCDatabaseIndexInfo instance
 */
- (id)initIndexInfoWithSequence:(int)sequenceNumber name:(NSString*)indexName unique:(BOOL)isUnique;

#pragma mark DBCDatabaseIndexInfo for NSLog

/**
 * Get formatted index description
 * @return formatted index description
 */
- (NSString*)description;

#pragma mark DBCDatabaseIndexInfo memory management

/**
 * Deallocate index information and release all retained memory
 */
- (void)dealloc;

@end
