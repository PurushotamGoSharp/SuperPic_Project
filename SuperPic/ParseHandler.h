
#import <AVFoundation/AVFoundation.h>

typedef enum {
    ParseResponseServerError=0,
    ParseResponseSuccess,
    ParseResponseLoginError,
    ParseResponseSignUpError,
    ParseResponseNetworkError,
    ParseResponseSMSSendError,
    ParseResponseUserAlreadyLoggedIn,
}ParseResponseCode;

typedef enum {
    ParseRequestNone = 0,
    ParseRequestSignUp,
    ParseRequestSignUpCheck,
    ParseRequestSignIn,
    ParseRequestSignInCheck,
    ParseRequestFriendRequest,
    ParseRequestFriendAccept,
}ParseRequest;

@protocol ParseHandlerDelegate <NSObject>

- (void)completedParseReuest:(ParseResponseCode)response error:(NSString*)error;

@optional
- (void)analyzeResult;

@end



@interface ParseHandler : NSObject
{
    id<ParseHandlerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, unsafe_unretained) id<ParseHandlerDelegate> delegate;
@property ParseResponseCode parseResponsecode;
@property ParseRequest      parseRequest;

+ (ParseHandler*)sharedInstance;

- (void) initialize;
- (void) sendFriendRequest:(NSString*)willfriendname;
- (void) acceptFriendRequest:(NSString*)willfriendname;
- (void) shareNotification:(NSMutableArray *)shareUsers count:(int)count;
- (BOOL) isNumbericalText:( NSString*)text; //double &value


@end