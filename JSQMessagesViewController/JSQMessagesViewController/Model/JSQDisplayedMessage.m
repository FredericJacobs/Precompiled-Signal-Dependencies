//
//  JSQDisplayedMessage.m
//  JSQMessages
//
//  Created by Dylan Bourgeois on 29/11/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "JSQDisplayedMessage.h"

@implementation JSQDisplayedMessage

-(id)init
{
    NSAssert(NO,@"%s is not a valid initializer for %@. Use %@ instead", __PRETTY_FUNCTION__, [self class], NSStringFromSelector(@selector(initWithSenderId:senderDisplayName:date:)));
    return nil;
}

-(instancetype)initWithSenderId:(NSString*)senderId
              senderDisplayName:(NSString*)senderDisplayName
                           date:(NSDate*)date
{
    self = [super init];
    
    if (self) {
        _senderId = [senderId copy];
        _senderDisplayName = [senderDisplayName copy];
        _date = [date copy];
    }
    
    return self;
}

- (NSUInteger)messageHash {
    return self.date.hash ^ self.senderId.hash;
}

@end
