//
//  TNHighScoresViewController.m
//  Tako-Naut
//
//  Created by mugx on 25/04/16.
//  Copyright (c) 2016 mugx. All rights reserved.
//

#import "TNHighScoresViewController.h"
#import "TNConstants.h"
#import "TNAppDelegate.h"
#import "MXToolBox.h"
#import "TNMacros.h"
#import <MXAudioManager/MXAudioManager.h>

@interface TNHighScoresViewController ()
@property IBOutlet UITableView *tableView;
@property IBOutlet UIButton *backButton;
@end

@implementation TNHighScoresViewController

+ (instancetype)create
{
  TNHighScoresViewController *highScoresViewController = [[TNHighScoresViewController alloc] initWithNibName:nil bundle:nil];
  return highScoresViewController;
}

- (BOOL)prefersStatusBarHidden
{
  return YES;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.tableView.layer.borderColor = MAGENTA_COLOR.CGColor;
  self.tableView.layer.borderWidth = 2.0;
  self.backButton.layer.borderColor = MAGENTA_COLOR.CGColor;
  self.backButton.layer.borderWidth = 2.0;
}

#pragma mark - Actions

- (IBAction)backTouched
{
  [[MXAudioManager sharedInstance] play:STSelectItem];
  [[TNAppDelegate sharedInstance] selectScreen:STMenu];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
  unsigned long count = [self getHighScores].count;
  if (count < 10)
  {
    count = 10;
  }
  return count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
  UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
  cell.backgroundColor = [UIColor clearColor];
  cell.textLabel.textColor = WHITE_COLOR;
  cell.textLabel.backgroundColor = [UIColor clearColor];
  cell.textLabel.font = [UIFont fontWithName:FONT_FAMILY size:16];
  cell.detailTextLabel.textColor = WHITE_COLOR;
  cell.detailTextLabel.font = [UIFont fontWithName:FONT_FAMILY size:16];
  cell.detailTextLabel.backgroundColor = [UIColor clearColor];

  NSArray *highScores = [self getHighScores];
  if (highScores && indexPath.row <= highScores.count - 1)
  {
    int64_t score = [[highScores objectAtIndex:indexPath.row] longLongValue];
    cell.textLabel.text = LOCALIZE(@"takonaut.game.score");
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lld", score];
  }
  else
  {
    cell.textLabel.text = LOCALIZE(@"takonaut.game.score");
    cell.detailTextLabel.text = @"xxx";
  }
  return cell;
}

#pragma mark - Private Functions

- (NSArray*)getHighScores
{
  return [[NSUserDefaults standardUserDefaults] arrayForKey:SAVE_KEY_HIGH_SCORES];
}

@end