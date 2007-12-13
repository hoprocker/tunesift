//
//  StringBox.m
//  TuneSift
//
//  Created by Malcolm McFarland on Mon Nov 01 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "StringBox.h"

char** strToRegEx(const char* instr);

@implementation StringBox

-(id)init {
	[super init];
	
	firstString = NULL;
	lastString = NULL;
	totalSizeBytes = 0;
	numStringsInSubset = numOfStrings = 0;
	
/*	indexmapper = (int*)malloc(kSongNumberCap*sizeof(int));
	strDirectAccess = (StringBoxUnit**)malloc(kSongNumberCap*sizeof(StringBoxUnit*));*/
	
//	strDirectAccess = (char**)malloc(sizeof(char*));
//	dirMapArray = [[NSArray alloc] init];
	
//	[dirMapArray retain];
	
	return self;
}

-(void)addString:(char*)str length:(int)len dbID:(int)dbid {
	StringBoxUnit*		newStringUnit;
//	NSData*				strPtr;
	
	newStringUnit = (StringBoxUnit*)malloc(sizeof(StringBoxUnit));
	
	newStringUnit->str = str;
	newStringUnit->len = len;
	newStringUnit->nextUnit = NULL;
	newStringUnit->dbID = dbid;
	
#ifdef _STRINGBOX_DEBUG_
	printf("\nstr: %slen: %i\ndbID: %i\n", newStringUnit->str, newStringUnit->len, newStringUnit->dbID);
#endif

	//totalSizeBytes += len;
	
#ifdef _STRINGBOX_DEBUG_
	if(sizeof(NSData*) != sizeof(char*))
		printf("NSString*: %ld  char: %ld\n", sizeof(StringBoxUnit*), sizeof(char*));
#endif
	
	if(firstString == NULL) {
		firstString = newStringUnit;
		lastString = firstString;
		indexmapper = (int*)malloc(sizeof(int));
		strDirectAccess = (StringBoxUnit**)malloc(sizeof(StringBoxUnit*));
	} else {
		lastString->nextUnit = newStringUnit;
		lastString = newStringUnit;
		indexmapper = (int*)realloc(indexmapper, (numOfStrings+1)*sizeof(int));
		if(!(strDirectAccess = (StringBoxUnit**)realloc(strDirectAccess, (numOfStrings+1)*sizeof(StringBoxUnit*)))) {
			fprintf(stderr, "StringBox::init : Couldn't realloc strDirectAccess\n");
			exit(-1);
		}
	}

#ifdef _STRINGBOX_DEBUG_
	printf("indexmapper[%i]\n\n", numOfStrings);
#endif

	indexmapper[numOfStrings] = numOfStrings;
	
/*	if(!(strDirectAccess = (char**)realloc(strDirectAccess, (numOfStrings)*sizeof(char*)))) {
		fprintf(stderr, "StringBox::init : Couldn't realloc strDirectAccess\n");
		exit(-1);
	}*/
	
//	[dirMapArray release];
	//dirMapArray = [dirMapArray arrayByAddingObject:[NSData dataWithBytesNoCopy:newStringUnit length:sizeof(StringBoxUnit*)]];
//	[dirMapArray retain];
//	strDirectAccess[numOfStrings] = (char*)malloc(sizeof(newStringUnit));
//	strDirectAccess[numOfStrings] = (char*)newStringUnit;

/*	strPtr = [NSData dataWithBytesNoCopy:newStringUnit length:sizeof(StringBoxUnit*)];
	[strPtr retain];
	strDirectAccess[numOfStrings] = (void*)strPtr;*/

	strDirectAccess[numOfStrings] = lastString;

	numStringsInSubset = ++numOfStrings;
}

-(int)getNumOfStrings {
	return numStringsInSubset;
}

-(unsigned long)getTotalSize {
	return totalSizeBytes;
}

-(int)mapSubsetToFull:(int)index {
	return indexmapper[index];
}

-(int) mapSubsetToDBID:(int)index {
	StringBoxUnitPtr	theBox;
	
//	theBox = (StringBoxUnit*)[[dirMapArray objectAtIndex:indexmapper[index]] bytes];
//	theBox = (StringBoxUnit*)[(NSData*) strDirectAccess[indexmapper[index]] bytes];
	theBox = (StringBoxUnit*)strDirectAccess[indexmapper[index]];
	
	return (int)theBox->dbID;
}

-(int)matchesForSubstring:(const char*)subStr {
	StringBoxUnitPtr	curBox;
	int					retVal, curSong, newIndex, numsubs, i;
	regex_t*			subRE;
	char**				parsedSubs;
	
	if(strlen(subStr) <= 0) {
//		[self resetSubsetMapper];
		return numOfStrings;
	}
	
	subRE = (regex_t*)malloc(sizeof(regex_t));
	
#ifdef _STRINGBOX_DEBUG_
	NSLog(@"SUBSTR: %s", subStr);
#endif
	
	parsedSubs = strToRegEx(subStr);
	
//	printf("sssss %i\n", sizeof(parsedSubs));
	
	numsubs = parsedSubs[0];  /* extract the number of strings from the first slot */
	
/*	for(i = 1; i <= numsubs; i++) 
		printf(" string %i: %s\n",i, parsedSubs[i]);*/
	
#ifdef _STRINGBOX_DEBUG_
	printf("parsedSub: %s\n", parsedSub);
#endif

	for(i = 1; i <= numsubs; i++) {
//		printf("i: %i\n", i);
		
		if(regcomp(subRE, parsedSubs[i], REG_NOSPEC & REG_NOSUB & REG_ICASE) != 0) {
			fprintf(stderr, "ERROR : Could not compile the RegEx.\n\n");
			return -1;
		}
		
		curSong = newIndex = 0;

		while(curSong < numStringsInSubset) {
	//		curBox = (StringBoxUnit*)[[dirMapArray objectAtIndex:indexmapper[curSong]] bytes];
	//		curBox = (StringBoxUnit*)[(NSData*)strDirectAccess[indexmapper[curSong]] bytes];
			curBox = (StringBoxUnit*)strDirectAccess[indexmapper[curSong]];
	#ifdef _STRINGBOX_DEBUG_   
			printf("indexmapper[%i] == %i,  str == %s\n", curSong, indexmapper[curSong], curBox->str);
	#endif
			if((retVal = regexec(subRE, curBox->str, 0, NULL, 0)) == 0) {
	#ifdef _STRINGBOX_DEBUG_   
				NSLog(@"FOUND ONE AT %i[%i]: %s", indexmapper[curSong], curSong, curBox->str);
	#endif
				indexmapper[newIndex] = indexmapper[curSong]; /* This uses newIndex, *then* increments, in one line! */
				newIndex++;
			} else if (retVal != REG_NOMATCH) {
				fprintf(stderr, "ERROR : Could not execute RegEx. \n\n");
				exit(-1);
			}
			
			curSong++;
		}
		
		numStringsInSubset = newIndex;
		regfree(subRE);
	}
	
	free(subRE);
	free(parsedSubs);
	
	return numStringsInSubset;
}

-(void) resetSubsetMapper {
	int i = 0;
	
#ifdef _STRINGBOX_DEBUG_   
	NSLog(@"Resetting mapper");
#endif
	
	for(i = 0; i< numOfStrings; i++)
		indexmapper[i] = i;
		
	numStringsInSubset = numOfStrings;
}


-(void) dealloc {
	StringBoxUnitPtr	nextBox, curBox;

	nextBox = firstString;
	curBox = nextBox;

	while(curBox != NULL) {
		nextBox = curBox->nextUnit;
		free(curBox->str);
		free(curBox);
		curBox = nextBox;
	}
}

-(NSString*) description {
	StringBoxUnitPtr	curBox;
	NSMutableString*	retStr = [NSMutableString stringWithCapacity:1000];
	
	curBox = firstString;
	
	while(curBox != NULL) {
		[retStr appendFormat:@"%s", curBox->str];
		curBox = curBox->nextUnit;
	}
	
	return (NSString*)retStr;
}
@end

char** strToRegEx(const char* instr) {
	char** allstrs;
	char* parseStr;
	int   parseInd, i, numstrs;
	
	parseStr = (char*)malloc(sizeof(char));
	parseInd = 0;
	
	allstrs = (char**)malloc(sizeof(char*));
	
	allstrs[0] = 0;		/* Store the number of strings in the first slot;probably not more than 2^32 */
	numstrs = 0;		/* This means that array accesses will be off by +1 */
	
//	printf("strlen: %i\n", strlen(instr));
	
	for(i = 0; i < strlen(instr); i++) {
		if(isalpha(instr[i])) {
			parseStr = (char*)realloc(parseStr, strlen(parseStr)+(4*sizeof(char)));
			parseStr[parseInd++] = '[';
			parseStr[parseInd++] = toupper(instr[i]);
			parseStr[parseInd++] = tolower(instr[i]);
			parseStr[parseInd++] = ']';
		} else if (isspace(instr[i])) {	
			if(parseStr[parseInd-1] != 0) {
				parseStr = (char*)realloc(parseStr, strlen(parseStr)+sizeof(char));
				parseStr[parseInd] = 0;
			}
			
			allstrs = (char**) realloc(allstrs, (numstrs+2)*sizeof(char*));
			allstrs[++numstrs] = parseStr;
			parseStr = (char*)malloc(sizeof(char));
			parseInd = 0;
			parseStr[0] = 0;
			allstrs[0] = numstrs;
		} else {
			parseStr = (char*)realloc(parseStr, strlen(parseStr)+(sizeof(char)));
			parseStr[parseInd++] = instr[i];
		}
	}
	
	if(parseStr[parseInd-1] != 0) {
		parseStr = (char*)realloc(parseStr, strlen(parseStr)+sizeof(char));
		parseStr[parseInd] = 0;
	}
	
	if(parseStr[0] != 0) {
		allstrs = (char**) realloc(allstrs, (numstrs+2)*sizeof(char*));
		allstrs[++numstrs] = parseStr;
	}
	
	allstrs = (char**) realloc(allstrs, (numstrs+2)*sizeof(char*));
	allstrs[numstrs+1] = 0;
	allstrs[0] = numstrs;
	
/*	for(i = 0; i < numstrs; i++) 
		printf(" inlalastring %i: %s\n",i, allstrs[i]);  */

//	printf("aasdfasfs %i\n", sizeof(allstrs));
	
	return allstrs;
}