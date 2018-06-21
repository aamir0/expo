// Copyright © 2018 650 Industries. All rights reserved.

#import "EXScopedModuleRegistry.h"

#import "EXScopedModuleRegistryAdapter.h"
#import "EXPermissionsBinding.h"
#import "EXFileSystemBinding.h"
#import "EXSensorsManagerBinding.h"
#import "EXUnversioned.h"

#import "EXModuleRegistryBinding.h"

@implementation EXScopedModuleRegistryAdapter

- (NSArray<id<RCTBridgeModule>> *)extraModulesForBridge:(RCTBridge *)bridge andExperience:(NSString *)experienceId withScopedModulesArray:(NSArray<id<RCTBridgeModule>> *)scopedModulesArray withKernelServices:(NSDictionary *)kernelServices
{
  EXModuleRegistry *moduleRegistry = [self.moduleRegistryProvider moduleRegistryForExperienceId:experienceId];
  NSDictionary<Class, id> *scopedModulesDictionary = [self dictionaryFromScopedModulesArray:scopedModulesArray];

  EXFileSystemBinding *fileSystemBinding = [[EXFileSystemBinding alloc] initWithScopedModuleDelegate:kernelServices[EX_UNVERSIONED(@"EXFileSystemManager")]];
  [moduleRegistry registerInternalModule:fileSystemBinding];

  EXPermissionsBinding *permissionsBinding = [[EXPermissionsBinding alloc] initWithPermissions:scopedModulesDictionary[[EXPermissions class]]];
  [moduleRegistry registerInternalModule:permissionsBinding];

  EXSensorsManagerBinding *sensorsManagerBinding = [[EXSensorsManagerBinding alloc] initWithExperienceId:experienceId andKernelService:kernelServices[EX_UNVERSIONED(@"EXSensorManager")]];
  [moduleRegistry registerInternalModule:sensorsManagerBinding];

  NSArray<id<RCTBridgeModule>> *bridgeModules = [self extraModulesForModuleRegistry:moduleRegistry];
  return [bridgeModules arrayByAddingObject:[[EXModuleRegistryBinding alloc] initWithModuleRegistry:moduleRegistry]];
}

- (NSDictionary<Class, id> *)dictionaryFromScopedModulesArray:(NSArray<id<RCTBridgeModule>> *)scopedModulesArray
{
  NSMutableDictionary<Class, id> *scopedModulesDictionary = [NSMutableDictionary dictionaryWithCapacity:[scopedModulesArray count]];
  for (id<RCTBridgeModule> module in scopedModulesArray) {
    scopedModulesDictionary[(id<NSCopying>)[module class]] = module;
  }
  return scopedModulesDictionary;
}

@end