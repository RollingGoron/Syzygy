//
//  SyzygyCore.h
//  SyzygyCore
//
//  Created by Dave DeLong on 12/31/17.
//  Copyright © 2017 Syzygy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#import <SyzygyCore/SyzygyConditionals.h>

#import <SyzygyCore/Objective-C.h>
#import <SyzygyCore/Entitlements.h>

#if BUILDING_FOR_DESKTOP
#import <SyzygyCore/IOKit.h>
#endif
