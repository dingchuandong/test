//
//  BHRoutingBuilder.m
//  Pods
//
//  Created by Chen Yihu on 6/15/15.
//
//

#import "BHRoutingBuilder.h"

@interface BHRoutingBuilder ()

@property (nonatomic, strong) NSMutableDictionary *params;
@property (nonatomic, strong) NSMutableArray *orderedParams;

@end

@implementation BHRoutingBuilder

- (instancetype)initWithPattern:(NSString *)pattern
{
    self = [super init];
    if ( self ) {
        _pattern = pattern;
    }
    return self;
}

- (BHRoutingKeyValueParamBlock)PARAM
{
    BHRoutingKeyValueParamBlock block = ^ BHRoutingBuilder * ( NSString *key, id format, ... )
    {
        if ( !self.params) {
            self.params = [NSMutableDictionary dictionary];
        }
        
        va_list args;
        va_start( args, format );
        NSString * value = [[NSString alloc] initWithFormat:format arguments:args];
        va_end( args );
        
        [self.params setValue:value forKey:key];
        return self;
    };
    
    return [block copy];
}

- (BHRoutingOrderedParamBlock)PARAMS
{
    BHRoutingKeyValueParamBlock block = ^ BHRoutingBuilder * ( NSString *key, id format, ... )
    {
        if ( !self.orderedParams) {
            self.orderedParams = [NSMutableArray array];
        }
        
        va_list args;
        va_start( args, format );
        NSString * value = [[NSString alloc] initWithFormat:format arguments:args];
        va_end( args );
        
        [self.orderedParams addObject:value];
        return self;
    };
    
    return [block copy];
}

- (NSString *)ROUTING
{
    if ( ![self params] && ![self orderedParams] ) {
        return _pattern;
    }
    
    // 1. find route params
    NSMutableArray *array = [[_pattern componentsSeparatedByString:@"/"] mutableCopy];
    [array enumerateObjectsUsingBlock:^(NSString *routeKey, NSUInteger idx, BOOL *stop) {
        if ( [routeKey hasPrefix:@":"] ) {
            NSString *key = [routeKey substringFromIndex:1];
            NSString *value = [self.params valueForKey:key];
            if ( value ) {
                [array replaceObjectAtIndex:idx withObject:value];
                [self.params setValue:nil forKey:key];
            }
        }
    }];
    
    // 2. find query params
    if ( [self.params count] ) {
        NSMutableArray *keyValuePairs = [NSMutableArray array];
        for ( NSString *eachKey in self.params ) {
            NSString *keyValuePair = [NSString stringWithFormat:@"%@=%@", eachKey, self.params[eachKey]];
            [keyValuePairs addObject:keyValuePair];
        }
        
        NSString *query = [keyValuePairs componentsJoinedByString:@"&"];
        if ( [query length] ) {
            query = [@"?" stringByAppendingString:query];
        }
        
        [array addObject:query];
    }

    return [array componentsJoinedByString:@"/"];
}


@end
