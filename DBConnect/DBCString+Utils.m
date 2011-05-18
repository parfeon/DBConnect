//
//  DBCString+Utils.m
//  DBCOnnect
//
//  Created by Sergey Mamontov on 5/9/11.
//  Copyright 2011 Tattooed Orange. All rights reserved.
//

#import "DBCString+Utils.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (DBCString_Utils)

/**
 * Return MD5 hash from string
 * @return generated MD5 hash
 */
- (NSString*)md5 {
    const char *cStr = [self UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

/**
 * Returns trimmed string
 * @return string with trimmed leading and ending whitespaces
 */
- (NSString*)trimmedString {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
