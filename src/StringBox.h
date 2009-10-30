//
//  StringBox.h
//  TuneSift
//
//  Created by Malcolm McFarland on Mon Nov 01 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#include <regex.h>

typedef struct {
	char*				str;
	int					len;
	int					dbID;
	void*				nextUnit;
} StringBoxUnit;

typedef StringBoxUnit *StringBoxUnitPtr;

@interface StringBox : NSObject {
	unsigned long			totalSizeBytes;
	int				numOfStrings, numStringsInSubset;
	StringBoxUnitPtr	firstString;
	StringBoxUnitPtr	lastString;
	StringBoxUnit**   strDirectAccess;
	int*			indexmapper, *indexToDBID;
	NSArray*		dirMapArray;
}

-(void)addString:(char*)str length:(int)len dbID:(int)dbid;
-(int)getNumOfStrings;
-(unsigned long)getTotalSize;
-(int)mapSubsetToFull:(int)index;
-(int) mapSubsetToDBID:(int)index;
-(int)matchesForSubstring:(const char*)subStr;
-(void) resetSubsetMapper;
-(NSString*) description;

@end
