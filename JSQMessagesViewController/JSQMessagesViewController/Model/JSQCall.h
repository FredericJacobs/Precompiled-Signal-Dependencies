//
//  JSQCall.h
//  JSQMessages
//
//  Created by Dylan Bourgeois on 20/11/14.
//

#import <Foundation/Foundation.h>

#import "JSQMessageData.h"

typedef enum : NSUInteger {
    kCallOutgoing = 1,
    kCallIncoming = 2,
    kCallMissed   = 3,
} CallStatus;


@interface JSQCall : NSObject <JSQMessageData, NSCoding, NSCopying>

/*
 * Returns the string Id of the user who initiated the call
 */
@property (copy, nonatomic, readonly) NSString *senderId;


/*
 * Returns the display name for user who initiated the call
 */
@property (copy, nonatomic, readonly) NSString *senderDisplayName;

/*
 * Returns date of the call
 */
@property (copy, nonatomic, readonly) NSDate *date;

/*
 * Returns the call status 
 * @see CallStatus
 */
@property (nonatomic) CallStatus status;

/*
 * Returns message type for adapter
 */
@property (nonatomic) TSMessageAdapterType messageType;


#pragma mark - Initialization 

- (instancetype)initWithCallerId:(NSString *)callerId
               callerDisplayName:(NSString *)callerDisplayName
                            date:(NSDate *)date
                          status:(CallStatus)status;

-(NSString*)text;
-(NSString*)dateText;

-(UIImage*)thumbnailImage;

@end
