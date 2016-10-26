//
//  DSDirectoryTableViewController.h
//  FileManagerTest
//
//  Created by Admin on 31.08.16.
//  Copyright © 2016 CS193p. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSDirectoryTableViewController : UITableViewController

- (id) initWithFolderPath:(NSString*) path;

@property (strong, nonatomic) NSString* path;

@end
