//
//  SceneDelegate.m
//

#import "SceneDelegate.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void) scene : (UIScene *)scene willConnectToSession : (UISceneSession *) session  options : (UISceneConnectionOptions *) connectionOptions {
    [Allo i : @"scene / willConnectToSession / options %@", [[self class] description]];
}


- (void) sceneDidDisconnect : (UIScene *) scene {
    [Allo i : @"sceneDidDisconnect %@", [[self class] description]];
}


- (void) sceneDidBecomeActive : (UIScene *) scene {
    [Allo i : @"sceneDidBecomeActive %@", [[self class] description]];
}


- (void) sceneWillResignActive : (UIScene *) scene {
    [Allo i : @"sceneWillResignActive %@", [[self class] description]];
}


- (void) sceneWillEnterForeground : (UIScene *) scene {
    [Allo i : @"sceneWillEnterForeground %@", [[self class] description]];
}


- (void) sceneDidEnterBackground : (UIScene *) scene {
    [Allo i : @"sceneDidEnterBackground %@", [[self class] description]];
}


@end
