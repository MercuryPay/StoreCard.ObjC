//
//  StoreCard.h
//  StoreCard iPad Demo
//
//  Created by Dan Ourada & Andrew Harris on 01/22/15.
//  Copyright (c) 2015 Mercury Payment Systems, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface StoreCard : UIViewController <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *lbltemsPurchased;
@property (strong, nonatomic) IBOutlet UILabel *lblTranType;
@property (strong, nonatomic) IBOutlet UILabel *lblKeyedSV;
@property (strong, nonatomic) IBOutlet UILabel *lblDollarAmount;
@property (strong, nonatomic) IBOutlet UIButton *btnCharge;
@property (strong, nonatomic) IBOutlet UIButton *btn1dollar;
@property (strong, nonatomic) IBOutlet UIButton *btn2dollar;
@property (strong, nonatomic) IBOutlet UIButton *btn5dollar;
@property (strong, nonatomic) IBOutlet UIButton *btn10dollar;
@property (strong, nonatomic) IBOutlet UIButton *btn20dollar;
@property (strong, nonatomic) IBOutlet UIButton *btn50dollar;

@property (weak, nonatomic) IBOutlet UIButton *btnScan;
@property (weak, nonatomic) IBOutlet UIButton *btnGiftSale;

@property (weak, nonatomic) IBOutlet UIView *viewPreview;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


- (IBAction)btn2dollar:(id)sender;
- (IBAction)btn5dollar:(id)sender;
- (IBAction)btn10dollar:(id)sender;
- (IBAction)btn20dollar:(id)sender;
- (IBAction)btn50dollar:(id)sender;
- (IBAction)btnClear:(id)sender;
- (IBAction)btnClearKeyPad:(id)sender;
- (IBAction)btnKeypadClick:(id)sender;
- (IBAction)startStopReading:(id)sender;

@end
