StoreCard (PrePaid) StoredValue iPad Application Demo
=========
This is a resource for developers and interested payment integrators to see how simple it is to get your iOS POS to integrate with Mercury StoreCard.

**iOS Simulator Note:** QR Code will not scan without building on an actual iPad device. If iOS simulating please make sure you use iPad2

##Step 1: Build Request with Key Value Pairs
  
Create a NSMutableDictionary and add all the Key Value Pairs.
  
```Objective-C
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:num forKey:@"InvoiceNo"]; //randoNum to avoid AP*
    [dictionary setObject:num forKey:@"RefNo"]; //randoNum to avoid AP*
    [dictionary setObject:@"StoreCard iOS Demo POS" forKey:@"Memo"];
    [dictionary setObject:[NSString stringWithFormat:@"%.2f", _total] forKey:@"Purchase"];
    [dictionary setObject:acct forKey:@"AcctNo"];
    [dictionary setObject:@"6453 Bistro iOS App" forKey:@"OperatorID"];
    [dictionary setObject:@"Bistro 6435 iOS Demo POS - StoreCard" forKey:@"Memo"];
    
    [self processTransactionWithDictionary:dictionary andResource:@"/PrePaid/Sale"];
```

##Step 1b: Add your choice of an image scanning SDK or use AVFoundation
  
```Objective-C
    

```


##Step 2: Process the Transaction

Process the transaction with an NSMutableURLRequest.

```Objective-C
    // Create a JSON POST
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
  
    // Add Authorization header
    NSString *credentials = [NSString stringWithFormat:@"%@:%@", self.merchantID, self.merchantPassword];
    NSString *base64Credentials = [self base64String:credentials];
    [request addValue:[@"Basic " stringByAppendingString:base64Credentials] forHTTPHeaderField:@"Authorization"];
    
    // Serialize NSDictionary to JSON data
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    
    // Add JSON data to request body
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    // Process request async
    [NSURLConnection connectionWithRequest:request delegate:self];
```
##Step 3: Parse the Response

Parse the Response using in the connection didReceiveData delegate.

Approved transactions will have a CmdStatus equal to "Approved".

```Objective-C
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    // Deserialize response from REST service
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

    if ([result objectForKey:@"CmdStatus"]
      && [[result objectForKey:@"CmdStatus"] isEqualToString:@"Approved"]) {
      
      // Approved logic here
      
    } else {
      
      // Declined logic here
      
    }
}
```

Contact a Developer Integration Analyst on the [Mercury Developer Portal](http://developer.mercurypay.com/solutions/mobiletablet-retail-json-objectivec/) for more information.

###© 2015 Mercury Payment Systems, LLC - all rights reserved.

Disclaimer:
This software and all specifications and documentation contained herein or provided to you hereunder (the "Software") are provided free of charge strictly on an "AS IS" basis. No representations or warranties are expressed or implied, including, but not limited to, warranties of suitability, quality, merchantability, or fitness for a particular purpose (irrespective of any course of dealing, custom or usage of trade), and all such warranties are expressly and specifically disclaimed. Mercury Payment Systems shall have no liability or responsibility to you nor any other person or entity with respect to any liability, loss, or damage, including lost profits whether foreseeable or not, or other obligation for any cause whatsoever, caused or alleged to be caused directly or indirectly by the Software. Use of the Software signifies agreement with this disclaimer notice.

![Analytics](https://ga-beacon.appspot.com/UA-60858025-15/StoreCard.ObjC/readme?pixel)
