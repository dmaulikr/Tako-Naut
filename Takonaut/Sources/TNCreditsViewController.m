//
//  TNCreditsViewController.m
//  Tako-Naut
//
//  Created by mugx on 25/04/16.
//  Copyright (c) 2014 mugx. All rights reserved.
//

#import "TNCreditsViewController.h"
#import "TNConstants.h"
#import "TNMacros.h"
#import "TNAppDelegate.h"
#import <MXAudioManager/MXAudioManager.h>

@interface TNCreditsViewController ()
@property IBOutlet UILabel *versionLabel;
@property IBOutlet UIImageView *logoIconImage;
@property IBOutlet UIButton *sendFeedbackButton;
@property IBOutlet UIButton *backButton;
@end

@implementation TNCreditsViewController

+ (instancetype)create
{
  TNCreditsViewController *aboutViewController = [[TNCreditsViewController alloc] initWithNibName:nil bundle:nil];
  return aboutViewController;
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  self.versionLabel.text = [NSString stringWithFormat:@"v%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
  self.sendFeedbackButton.layer.borderColor = MAGENTA_COLOR.CGColor;
  self.sendFeedbackButton.layer.borderWidth = 2.0;
  self.logoIconImage.layer.shadowOffset = CGSizeMake(2, 2);
  self.logoIconImage.layer.shadowColor = [MAGENTA_COLOR colorWithAlphaComponent:0.4].CGColor;
  self.backButton.layer.borderColor = MAGENTA_COLOR.CGColor;
  self.backButton.layer.borderWidth = 2.0;
}

#pragma mark - Actions

- (IBAction)backTouched
{
  [[MXAudioManager sharedInstance] play:STSelectItem];
  [[TNAppDelegate sharedInstance] selectScreen:STMenu];
}

- (IBAction)sendFeedbackTouched
{
  if ([MFMailComposeViewController canSendMail])
  {
    MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
    [emailController setMailComposeDelegate:self];
 		[emailController setToRecipients:[NSArray arrayWithObject:FEEDBACK_EMAIL]];
    [emailController setMessageBody:@"" isHTML:false];
 		[emailController setSubject:@"Feedback Tako-Naut"];
    [emailController setTitle:@"Feedback"];
    
    [self presentViewController:emailController animated:YES completion:nil];
  }
  else
  {
    UIAlertView *gameOverAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Cannot send the email" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [gameOverAlert show];
  }
}

#pragma mark - MFMailComposeViewController Stuff

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
  switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Mail saved: you saved the email message in the Drafts folder");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send the next time the user connects to email");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Mail failed: the email message was nog saved or queued, possibly due to an error");
			break;
		default:
			NSLog(@"Mail not sent");
			break;
	}

  [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
