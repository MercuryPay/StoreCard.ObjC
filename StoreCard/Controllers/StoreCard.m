//
//  StoreCard.m
//  StoreCard iPad Demo
//
//  Created by Dan Ourada & Andrew Harris on 01/22/15.
//  Copyright (c) 2015 Mercury Payment Systems, LLC. All rights reserved.
//

#import "StoreCard.h"
#import "AppDelegate.h"

@interface StoreCard ()
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) BOOL isReading;

-(BOOL)startReading;
-(void)stopReading;

@property double total;
@property int itemCount;

@property NSString *url;
@property NSString *merchantID;
@property NSString *merchantPassword;
@property NSString *tranType;
@property NSString *tranCode;

@end

@implementation StoreCard

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _total = 0;
    _itemCount = 0;
    [self updateSale];
    
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap)];
    [_lblKeyedSV addGestureRecognizer:tapGesture];
    [_lblKeyedSV setBackgroundColor: [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0]];

    // Configure settings to target processing platform
    
    // CERT
    self.url = @"https://w1.mercurycert.net/PaymentsAPI";
    self.merchantID = @"003503902913105";
    self.merchantPassword = @"xyz";
    
    // Initially make the captureSession object nil.
    _captureSession = nil;
    
    // Set the initial value of the flag to NO.
    _isReading = NO;
    
    self.activityIndicator.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)labelTap {
    if (_lblKeyedSV > 0) {
        _lblKeyedSV.enabled = NO;
        [self sendTransaction:_lblKeyedSV.text];
        _lblKeyedSV.text = @"processing...";
        [_lblKeyedSV setFont:[UIFont systemFontOfSize:18]];
    }
    else {
        _lblKeyedSV.enabled = NO;
        [self sendTransaction:_lblKeyedSV.text];
        _lblKeyedSV.text = @"Enter Gift Card Number";
    }
}

- (void)sendTransaction:(NSString *)acct {
    
    NSString *min = @"00001";
    NSString *max = @"10000";
    
    int randNum = arc4random() % ([max intValue] - [min intValue]) + [min intValue];
    NSString *num = [NSString stringWithFormat:@"%d", randNum];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:num forKey:@"InvoiceNo"]; //randoNum to avoid AP*
    [dictionary setObject:num forKey:@"RefNo"]; //randoNum to avoid AP*
    [dictionary setObject:@"iOS Demo POS - StoreCard" forKey:@"Memo"];
    [dictionary setObject:[NSString stringWithFormat:@"%.2f", _total] forKey:@"Purchase"];
    [dictionary setObject:acct forKey:@"AcctNo"];
    [dictionary setObject:@"6453 Bistro iOS App" forKey:@"OperatorID"];
    [dictionary setObject:@"Bistro 6435 iOS Demo POS - StoreCard" forKey:@"Memo"];
    
    [self processTransactionWithDictionary:dictionary andResource:@"/PrePaid/Sale"];
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    [self updateSale];

}


- (IBAction)btnClear:(id)sender {
    NSString *label = ((UIButton*)sender).titleLabel.text;
    if ([label isEqualToString:@"Clear"]){
        _total = 0;
        _itemCount =0;
    }
    [self updateSale];
}

- (IBAction)btnClearKeyPad:(id)sender {
    NSString *label = ((UIButton*)sender).titleLabel.text;
    if ([label isEqualToString:@"Clear"]){
        _total = 0;
        _itemCount =0;
        _lblKeyedSV.text = @"";
        [_lblKeyedSV setFont:[UIFont systemFontOfSize:62]];

    }
    [self updateSale];
}

#pragma mark - IBAction method implementation

- (IBAction)startStopReading:(id)sender {
    if (!_isReading) {
        // This is the case where the app should read a QR code when the start button is tapped.
        if ([self startReading]) {
            // If the startReading methods returns YES and the capture session is successfully
            // running, then change the start button title and the status message.
        }
    }
    else{
        // In this case the app is currently reading a QR code and it should stop doing so.
        [self stopReading];
    }
    
    // Set to the flag the exact opposite value of the one that currently has.
    _isReading = !_isReading;
}

#pragma mark - Private method implementation

- (BOOL)startReading {
    NSError *error;
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        // If any error occurs, simply log the description of it and don't continue any more.
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    // Initialize the captureSession object.
    _captureSession = [[AVCaptureSession alloc] init];
    // Set the input device on the capture session.
    [_captureSession addInput:input];
    
    
    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    // Start video capture.
    [_captureSession startRunning];
    
    return YES;
}

-(void)stopReading {
    // Stop video capture and make the capture session object nil.
    [_captureSession stopRunning];
    _captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    [_videoPreviewLayer removeFromSuperlayer];
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        // Get the metadata object.
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            // If the found metadata is equal to the QR code metadata then update the status label's text,
            // stop reading and change the bar button item's title and the flag's value.
            // Everything is done on the main thread.
            [self performSelectorOnMainThread:@selector(sendTransaction:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            
            _isReading = NO;
            
        }
    }
}

- (IBAction)btn1dollar:(id)sender {
    _total = _total + 1.00;
    _itemCount++;
    [self updateSale];
}

- (IBAction)btn2dollar:(id)sender {
    _total = _total + 2.00;
    _itemCount++;
    [self updateSale];
}

- (IBAction)btn5dollar:(id)sender {
    _total = _total + 5.00;
    _itemCount++;
    [self updateSale];
}

- (IBAction)btn10dollar:(id)sender {
    _total = _total + 10.00;
    _itemCount++;
    [self updateSale];
}

- (IBAction)btn20dollar:(id)sender {
    _total = _total + 20.00;
    _itemCount++;
    [self updateSale];
}

- (IBAction)btn50dollar:(id)sender {
    _total = _total + 50.00;
    _itemCount++;
    [self updateSale];
}

- (IBAction)btnKeypadClick:(id)sender {
    NSString *label = ((UIButton*)sender).titleLabel.text;
    _lblKeyedSV.text = [_lblKeyedSV.text stringByAppendingFormat:@"%@", label];
}

- (void)updateSale {
    if (_itemCount > 0) {
        _lbltemsPurchased.text = [NSString stringWithFormat:@"Sale (%d Items)", _itemCount];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        _lblDollarAmount.text = [formatter stringFromNumber:[NSNumber numberWithDouble:_total]];
        _lblTranType.text = @"PrePaid";
        _btnGiftSale.enabled = NO;
        [_btnGiftSale setBackgroundColor: [UIColor colorWithRed:102.0/255.0 green:204.0/255.0 blue:255.0/255.0 alpha:0.5]];
    }
    else {
        _lbltemsPurchased.text = @"No Sale (0)";
        _lblDollarAmount.text = @"$0.00";
        _lblTranType.text = @"";
        _btnGiftSale.enabled = NO;
        [_btnGiftSale setBackgroundColor: [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0]];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    _total = 0;
    _itemCount =0;
    _lblKeyedSV.text = @"";
    [_lblKeyedSV setFont:[UIFont systemFontOfSize:62]];
    [self updateSale];
}

- (void) processTransactionWithDictionary:(NSDictionary *)dictionary andResource:(NSString *) resource {
    
    // Create a JSON POST
    NSString *urlResource = [NSString stringWithFormat:@"%@%@", self.url, resource];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlResource]];
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
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"88430189141" forKey:@"MerchantID"];
    [dictionary setObject:@"605011..." forKey:@"AcctNo"];
    [dictionary setObject:@"PrePaid" forKey:@"TranType"];
    [dictionary setObject:@"Offline" forKey:@"RefNo"];
    [dictionary setObject:@"Approved" forKey:@"CmdStatus"];
    [dictionary setObject:@"111111" forKey:@"AuthCode"];
    [dictionary setObject:[NSString stringWithFormat:@"%.2f", _total] forKey:@"Authorize"];
    [dictionary setObject:@"Offline" forKey:@"ResponseOrigin"];
    [dictionary setObject:@"Offline Success" forKey:@"TextResponse"];
    [dictionary setObject:@"Sale" forKey:@"TranCode"];
    [dictionary setObject:@"111111" forKey:@"InvoiceNo"];
    [dictionary setObject:@"6453 Bistro iOS App" forKey:@"OperatorID"];
    [dictionary setObject:[NSString stringWithFormat:@"%.2f", _total] forKey:@"Purchase"];
    [dictionary setObject:@"Offline" forKey:@"Balance"];
    [dictionary setObject:@"Offline" forKey:@"DSIXReturnCode"];
    [dictionary setObject:@"Bistro 6435 iOS Demo POS - StoreCard - Offline" forKey:@"Memo"];
    
    [self showReceipt: dictionary];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Deserialize response from REST service
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    [self showReceipt: dictionary];
}

- (void)showReceipt: (NSDictionary *)dictionary {
    NSMutableString *message = [NSMutableString new];
    for (NSString *key in [dictionary allKeys])
    {
        [message appendFormat:@"%@: %@;\n", key, [dictionary objectForKey:key]];
    }
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"JSON RESTful\n Payments API\n ------\n RESPONSE\n -----\n Stored Value\n ------\n"
                                                   message: message
                                                  delegate: self
                                         cancelButtonTitle: nil
                                         otherButtonTitles:@"OK",nil];
    
    [alert show];
    self.activityIndicator.hidden = YES;
}

// Base64 function taken from http://calebmadrigal.com/string-to-base64-string-in-objective-c/
- (NSString *)base64String:(NSString *)str {
    NSData *theData = [str dataUsingEncoding: NSASCIIStringEncoding];
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
