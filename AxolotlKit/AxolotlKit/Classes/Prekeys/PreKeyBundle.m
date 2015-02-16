//
//  AxolotlKeyFetch.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 21/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "PreKeyBundle.h"


static NSString* const kCoderPKBIdentityKey           = @"kCoderPKBIdentityKey";
static NSString* const kCoderPKBregistrationId        = @"kCoderPKBregistrationId";
static NSString* const kCoderPKBdeviceId              = @"kCoderPKBdeviceId";
static NSString* const kCoderPKBsignedPreKeyPublic    = @"kCoderPKBsignedPreKeyPublic";
static NSString* const kCoderPKBpreKeyPublic          = @"kCoderPKBpreKeyPublic";
static NSString* const kCoderPKBpreKeyId              = @"kCoderPKBpreKeyId";
static NSString* const kCoderPKBsignedPreKeyId        = @"kCoderPKBsignedPreKeyId";
static NSString* const kCoderPKBsignedPreKeySignature = @"kCoderPKBsignedPreKeySignature";

@implementation PreKeyBundle

- (instancetype)initWithRegistrationId:(int)registrationId
                              deviceId:(int)deviceId
                              preKeyId:(int)preKeyId
                          preKeyPublic:(NSData*)preKeyPublic
                    signedPreKeyPublic:(NSData*)signedPreKeyPublic
                        signedPreKeyId:(int)signedPreKeyId
                 signedPreKeySignature:(NSData*)signedPreKeySignature
                           identityKey:(NSData*)identityKey{
    
    self = [super init];
    
    if (self) {
        _identityKey           = identityKey;
        _registrationId        = registrationId;
        _deviceId              = deviceId;
        _preKeyPublic          = preKeyPublic;
        _preKeyId              = preKeyId;
        _signedPreKeyPublic    = signedPreKeyPublic;
        _signedPreKeyId        = signedPreKeyId;
        _signedPreKeySignature = signedPreKeySignature;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    int registrationId            = [aDecoder decodeIntForKey:kCoderPKBregistrationId];
    int deviceId                  = [aDecoder decodeIntForKey:kCoderPKBdeviceId];
    int preKeyId                  = [aDecoder decodeIntForKey:kCoderPKBpreKeyId];
    int signedPreKeyId            = [aDecoder decodeIntForKey:kCoderPKBsignedPreKeyId];
    
    NSData *preKeyPublic          = [aDecoder decodeObjectOfClass:[NSData class] forKey:kCoderPKBpreKeyPublic];
    NSData *signedPreKeyPublic    = [aDecoder decodeObjectOfClass:[NSData class] forKey:kCoderPKBsignedPreKeyPublic];
    NSData *signedPreKeySignature = [aDecoder decodeObjectOfClass:[NSData class] forKey:kCoderPKBsignedPreKeySignature];
    NSData *identityKey           = [aDecoder decodeObjectOfClass:[NSData class] forKey:kCoderPKBIdentityKey];
    
    
    self = [self initWithRegistrationId:registrationId
                               deviceId:deviceId
                               preKeyId:preKeyId
                           preKeyPublic:preKeyPublic
                     signedPreKeyPublic:signedPreKeyPublic
                         signedPreKeyId:signedPreKeyId
                  signedPreKeySignature:signedPreKeySignature
                            identityKey:identityKey];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:_registrationId forKey:kCoderPKBregistrationId];
    [aCoder encodeInt:_deviceId forKey:kCoderPKBdeviceId];
    [aCoder encodeInt:_preKeyId forKey:kCoderPKBpreKeyId];
    [aCoder encodeInt:_signedPreKeyId forKey:kCoderPKBsignedPreKeyId];
    
    [aCoder encodeObject:_preKeyPublic forKey:kCoderPKBpreKeyPublic];
    [aCoder encodeObject:_signedPreKeyPublic forKey:kCoderPKBsignedPreKeyPublic];
    [aCoder encodeObject:_signedPreKeySignature forKey:kCoderPKBsignedPreKeySignature];
    [aCoder encodeObject:_identityKey forKey:kCoderPKBIdentityKey];
}

+(BOOL)supportsSecureCoding{
    return YES;
}

@end
