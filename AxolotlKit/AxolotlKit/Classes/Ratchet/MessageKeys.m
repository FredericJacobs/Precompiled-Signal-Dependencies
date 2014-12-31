//
//  TSMessageKeys.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 09/03/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import "MessageKeys.h"

static NSString* const kCoderMessageKeysCipherKey = @"kCoderMessageKeysCipherKey";
static NSString* const kCoderMessageKeysMacKey    = @"kCoderMessageKeysMacKey";
static NSString* const kCoderMessageKeysIVKey     = @"kCoderMessageKeysIVKey";
static NSString* const kCoderMessageKeysIndex     = @"kCoderMessageKeysIndex";


@implementation MessageKeys

+ (BOOL)supportsSecureCoding{
    return YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [self initWithCipherKey:[aDecoder decodeObjectOfClass:[NSData class] forKey:kCoderMessageKeysCipherKey]
                            macKey:[aDecoder decodeObjectOfClass:[NSData class] forKey:kCoderMessageKeysMacKey]
                                iv:[aDecoder decodeObjectOfClass:[NSData class] forKey:kCoderMessageKeysIVKey]
                             index:[aDecoder decodeIntForKey:kCoderMessageKeysIndex]];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.cipherKey forKey:kCoderMessageKeysCipherKey];
    [aCoder encodeObject:self.macKey forKey:kCoderMessageKeysMacKey];
    [aCoder encodeObject:self.iv forKey:kCoderMessageKeysIVKey];
    [aCoder encodeInt:self.index forKey:kCoderMessageKeysIndex];
}


- (instancetype)initWithCipherKey:(NSData*)cipherKey macKey:(NSData*)macKey iv:(NSData *)data index:(int)index{
    self = [super init];
    
    if (self) {
        _cipherKey = cipherKey;
        _macKey    = macKey;
        _iv        = data;
        _index     = index;
    }

    return self;
}

-(NSString*) debugDescription {
    return [NSString stringWithFormat:@"cipherKey: %@\n macKey %@\n",self.cipherKey,self.macKey];
}

@end
