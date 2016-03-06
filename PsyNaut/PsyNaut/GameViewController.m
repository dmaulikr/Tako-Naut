//
//  GameViewController.m
//  PsyNaut
//
//  Created by mugx on 22/02/16.
//  Copyright (c) 2016 mugx. All rights reserved.
//

#import "GameViewController.h"
#import "UIImage+sprite.h"

#define SPRITE_SIZE 32

@interface GameViewController()
@property(nonatomic,strong) UIImageView *player;
@end

@implementation GameViewController

+ (instancetype)create
{
  return [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self animateBrain];
}

- (void)animateBrain
{
  UIImage *spriteSheet = [UIImage imageNamed:@"ZBrain_Walk_LefttoRight"];
  NSArray *arrayWithSprites = [spriteSheet spritesWithSpriteSheetImage:spriteSheet spriteSize:CGSizeMake(64, 64)];
  self.player = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 16, self.view.frame.size.height/2 - 16, SPRITE_SIZE, SPRITE_SIZE)];
  [self.player setAnimationImages:arrayWithSprites];
  self.player.animationDuration = 1.0f;
  self.player.animationRepeatCount = 0;
  [self.player startAnimating];
  [self.view addSubview:self.player];
}

@end
