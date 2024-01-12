#import "NSURLSessionTask+Sentry.h"


@implementation
NSURLSessionTask (Sentry)

- (nullable NSString *)sentry_graphQLOperationDetails
{
    if (!self.originalRequest.HTTPBody) { return nil; }
    // Get a string of the request body
    NSString *requestBodyString = [[NSString alloc] initWithData:self.originalRequest.HTTPBody encoding:NSUTF8StringEncoding];
    if (!requestBodyString) { return nil; }

    // Extract the graphql mutation/query name using regex
    NSString *regex = @"(mutation|query)\\s+(\\w+)";
    NSError *regexError = nil;
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:&regexError];
    if (regexError) { return nil; }  // Check if regex failed to compile

    NSTextCheckingResult *match = [regularExpression firstMatchInString:requestBodyString options:0 range:NSMakeRange(0, requestBodyString.length)];
    if (!match) { return nil; }

    // Extract the graphql operation name from the regex match
    if (match.numberOfRanges < 3) { return nil; }
    NSRange operationTypeRange = [match rangeAtIndex:1];
    NSRange operationNameRange = [match rangeAtIndex:2];
    NSString *operationType = [requestBodyString substringWithRange:operationTypeRange];
    NSString *operationName = [requestBodyString substringWithRange:operationNameRange];
    return (operationType && operationName) ? [NSString stringWithFormat:@"%@ %@", operationType, operationName] : nil;
}

@end
