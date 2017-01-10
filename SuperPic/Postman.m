//
//  Postman.m
//  EuLux
//
//  Created by Varghese Simon on 3/3/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "Postman.h"

@implementation Postman
{
    AFHTTPRequestOperationManager *manager;
}


- (id)init
{
    if (self = [super init])
    {
        [self initiate];
    }
    
    return self;
}

- (void)initiate
{
    manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [requestSerializer setValue:@"x-access-token" forHTTPHeaderField:@"x-access-token"];
//    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
      manager.requestSerializer = requestSerializer;
}

- (void)setTimeOutIntervel:(NSTimeInterval)timeOutIntervel
{
    _timeOutIntervel = timeOutIntervel;
    [manager.requestSerializer setTimeoutInterval:timeOutIntervel];
}

- (void)post:(NSString *)URLString withParameters:(NSString *)parameter
{
    NSLog(@"URl = %@ : parameters = %@", URLString,parameter);
    NSDictionary *parameterDict = [NSJSONSerialization JSONObjectWithData:[parameter dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    [manager POST:URLString
       parameters:parameterDict
          success:^(AFHTTPRequestOperation *operation, id responseObject){
              
              NSData *responseData = [operation responseData];
              [self.delegate postman:self gotSuccess:responseData forURL:URLString];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self.delegate postman:self gotFailure:error forURL:URLString];
              NSLog(@"ERROR %@",[operation responseString]);
              NSLog(@"Error %@", error);
              
          }];
}

- (AFHTTPRequestOperation *)post:(NSString *)URLString withParameters:(NSString *)parameter success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSLog(@"URl = %@ : parameters = %@", URLString,parameter);
    NSDictionary *parameterDict = [NSJSONSerialization JSONObjectWithData:[parameter dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    AFHTTPRequestOperation *operation = [manager POST:URLString
                                           parameters:parameterDict
                                              success:^(AFHTTPRequestOperation *operation, id responseObject){
                                                  
                                                  success(operation, responseObject);
                                              }
                                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                  
                                                  failure(operation, error);
                                                  
                                                  NSLog(@"ERROR %@",[operation responseString]);
                                                  NSLog(@"Error %@", error);
                                                  
                                              }];
    
    return operation;
    
}

- (AFHTTPRequestOperation *)delete:(NSString *)URLString withParameters:(NSString *)parameter success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSLog(@"URl = %@ : parameters = %@", URLString,parameter);
    NSDictionary *parameterDict = [NSJSONSerialization JSONObjectWithData:[parameter dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    AFHTTPRequestOperation *operation = [manager DELETE:URLString
                                           parameters:parameterDict
                                              success:^(AFHTTPRequestOperation *operation, id responseObject){
                                                  
                                                  success(operation, responseObject);
                                              }
                                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                  
                                                  failure(operation, error);
                                                  
                                                  NSLog(@"ERROR %@",[operation responseString]);
                                                  NSLog(@"Error %@", error);
                                                  
                                              }];
    
    return operation;
    
}

- (void)get:(NSString *)URLString
{
    NSLog(@"URl = %@ ", URLString);
    
    [manager GET:URLString
      parameters:Nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSData *responseData = [operation responseData];
             [self.delegate postman:self gotSuccess:responseData forURL:URLString] ;
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             [self.delegate postman:self gotFailure:error forURL:URLString];
             NSLog(@"ERROR Response %@",[operation responseString]);
             NSLog(@"Error %@", error);
         }];
    
}



- (void)setAuthenticationBlockForOperation:(AFHTTPRequestOperation *)operation
{
    [operation setWillSendRequestForAuthenticationChallengeBlock:^(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge) {
        
        NSLog(@"Authe type = %@", challenge.protectionSpace.authenticationMethod);
        NSString *certPath = [[NSBundle mainBundle] pathForResource:@"vmCert" ofType:@"p12"];
        NSData *certData = [[NSData alloc] initWithContentsOfFile:certPath];
        
        SecIdentityRef identity = NULL;
        SecCertificateRef certificate = NULL;
        
        [self identity:&identity
        andCertificate:&certificate
          forPKC12Data:certData
        withPassphrase:@"test"];
        
        NSURLCredential *credential = [NSURLCredential credentialWithIdentity:identity
                                                                 certificates:@[(__bridge id)certificate] persistence:NSURLCredentialPersistencePermanent];
        if (credential)
        {
            [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
        }else
        {
            NSLog(@"Error in credential");
        }
        
    }];
}

//- (NSURLCredential *)createCredential
//{
//    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"cert" ofType:@"p12"];
//    NSData *certData = [[NSData alloc] initWithContentsOfFile:certPath];
//
//    SecIdentityRef identity = NULL;
//    SecCertificateRef certificate = NULL;
//
//    [Postman identity:&identity
//       andCertificate:&certificate
//         forPKC12Data:certData
//       withPassphrase:@"test"];
//
//    NSURLCredential *cred = [NSURLCredential credentialWithIdentity:identity
//                                                       certificates:@[(__bridge id)certificate]
//                                                        persistence:NSURLCredentialPersistencePermanent];
//    return cred;
//}
//
- (void)identity:(SecIdentityRef *)identity andCertificate:(SecCertificateRef *)certificate forPKC12Data:(NSData *)certData withPassphrase:(NSString *)passphrase
{
    // bridge the import data to foundation objects
    CFStringRef importPassphrase = (__bridge CFStringRef)passphrase;
    CFDataRef importData = (__bridge CFDataRef)certData;
    
    // create dictionary of options for the PKCS12 import
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { importPassphrase };
    CFDictionaryRef importOptions = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    // create array to store our import results
    CFArrayRef importResults = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus pkcs12ImportStatus = errSecSuccess;
    pkcs12ImportStatus = SecPKCS12Import(importData, importOptions, &importResults);
    
    // check if import was successful
    if (pkcs12ImportStatus == errSecSuccess)
    {
        CFDictionaryRef identityAndTrust = CFArrayGetValueAtIndex (importResults, 0);
        
        // retrieve the identity from the certificate imported
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue (identityAndTrust, kSecImportItemIdentity);
        *identity = (SecIdentityRef)tempIdentity;
        
        // extract the certificate from the identity
        SecCertificateRef tempCertificate = NULL;
        OSStatus certificateStatus = errSecSuccess;
        certificateStatus = SecIdentityCopyCertificate (*identity, &tempCertificate);
        *certificate = (SecCertificateRef)tempCertificate;
    }else
    {
        NSLog(@"Status is %d", (int)pkcs12ImportStatus);
    }
    
    // clean up
    if (importOptions)
    {
        CFRelease(importOptions);
    }
}


@end
