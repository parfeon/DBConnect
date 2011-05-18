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
#import "sqlite3lib_ext.h"

#define kSQLiteErrorDomain @"kSQLiteErrorDomain"
#define DBCAdditionalErrorInformation @"DBCAdditionalErrorInformation"

@interface DBCError : NSError {
    
}

+ (NSString*)errorDescriptionByCode:(int)errorCode;
+ (id)errorWithErrorCode:(NSInteger)code;
+ (id)errorWithErrorCode:(NSInteger)code forFilePath:(NSString*)filePath;
+ (id)errorWithErrorCode:(NSInteger)code forFilePath:(NSString*)filePath additionalInformation:(NSString*)additionalInformation;
- (id)initWithErrorCode:(NSInteger)code;
- (id)initWithErrorCode:(NSInteger)code forFilePath:(NSString*)filePath;
- (id)initWithErrorCode:(NSInteger)code forFilePath:(NSString*)filePath additionalInformation:(NSString*)additionalInformation;
@end
