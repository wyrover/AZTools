//
//  AZNavigationController.h
//  AZNavigation
//
//  Created by Alvin on 13-10-8.
//  Copyright (c) 2013 Alvin Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AZNavigationType){
    AZNavigationTransation,
    AZNavigationZoom
};

//static NSString *AZNavigationNotificationStartPanning = @"AZNavigationNotificationStartPanning";

@interface AZNavigationController : UINavigationController

@property (nonatomic, assign) BOOL canDragBack;
@property (nonatomic, assign) AZNavigationType navigationType;

@end
