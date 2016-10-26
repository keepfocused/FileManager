//
//  DSDirectoryTableViewController.m
//  FileManagerTest
//
//  Created by Admin on 31.08.16.
//  Copyright © 2016 CS193p. All rights reserved.
//

#import "DSDirectoryTableViewController.h"

@interface DSDirectoryTableViewController () <UIActionSheetDelegate,UIAlertViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic) NSArray* contents;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIBarButtonItem* addButton;
@property (strong, nonatomic) NSIndexPath* indexPathForInsert;
@property (assign, nonatomic) NSInteger index;


@end

@implementation DSDirectoryTableViewController

- (id) initWithFolderPath:(NSString *)path
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.path = path;
    }
    return self;
}

- (void) setPath:(NSString *)path
{

    _path = path;
    
    NSError* error = nil;
    
    self.contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }

    [self.tableView reloadData];
    
    self.navigationItem.title = [self.path lastPathComponent];
    
}

#pragma mark view Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [self.path lastPathComponent];
    
    if (!self.path) {
        self.path = @"/Users/Danil/Documents/TestDirectory";
    }
    
    

    
    UIBarButtonItem* edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                          target:self
                                                                          action:@selector(actionEdit:)];

    
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(actionCreateDirectory:)];
    self.addButton = addButton;
    
    
    self.navigationItem.rightBarButtonItem = edit;
    
    self.index = [self.contents count];
    
}

- (void) viewWillAppear:(BOOL)animated
{
   
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"path = %@", self.path);
    NSLog(@"view controllers on stack = %ld", (unsigned long)[self.navigationController.viewControllers count]);
    NSLog(@"index on stack %ld", (unsigned long)[self.navigationController.viewControllers indexOfObject:self]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) isDirectoryAtIndexPath:(NSIndexPath*) indexPath
{
    NSString* fileName = [self.contents objectAtIndex:indexPath.row];
    
    NSString* filePath = [self.path stringByAppendingPathComponent:fileName];
    
    BOOL isDirectory = NO;
    
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    
    return isDirectory;
}

#pragma mark - Actions

- (void) actionBackToRoot:(UIBarButtonItem*) sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) actionEdit:(UIBarButtonItem*) sender {
    
    BOOL isEditing = self.tableView.editing;
    
    [self.tableView setEditing:!isEditing animated:YES];
    
    UIBarButtonSystemItem item = UIBarButtonSystemItemEdit;
    
    
    
    if (self.tableView.editing) {
        item = UIBarButtonSystemItemDone;
        self.navigationItem.leftBarButtonItem = self.addButton;
    }
    
    else if (!self.tableView.editing) {
        self.navigationItem.leftBarButtonItem = nil;
    }

    
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:item
                                                                                target:self
                                                                                action:@selector(actionEdit:)];
    [self.navigationItem setRightBarButtonItem:editButton animated:YES];
}

- (void) actionCreateDirectory:(UIBarButtonItem*) sender
{
    
    
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"set folder name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].keyboardAppearance = UIKeyboardAppearanceDark;
    [alertView textFieldAtIndex:0].delegate = self;
    [alertView show];
    
    NSLog(@"index = %ld",(long)self.index);
}

- (void) createFolderWithName:(NSString*)folderName
{
        NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString* fileName = folderName;
    NSString* filePath = [self.path stringByAppendingPathComponent:fileName];



    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:nil];
        NSLog(@"folder created");
    } else {
        NSLog(@"folder exists");
    }

    NSError* error = nil;

    NSArray* tempArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:&error];

    self.contents = tempArray;

    NSLog(@"contents count = %ld",[self.contents count]);

    NSInteger newSectionIndex = 0;
    
    self.index ++;
    
    [self.tableView reloadData];
}

- (unsigned long long)sizeOfFolder:(NSString *)folderPath {
    
    unsigned long long int result = 0;
    
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    
    for (NSString *fileSystemItem in array) {
        BOOL directory = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:[folderPath stringByAppendingPathComponent:fileSystemItem] isDirectory:&directory];
        if (!directory) {
            result += [[[[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileSystemItem] error:nil] objectForKey:NSFileSize] unsignedIntegerValue];
        }
        else {
            result += [self sizeOfFolder:[folderPath stringByAppendingPathComponent:fileSystemItem]];
        }
    }
    
    return result;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
        UITextField *textfild = [alertView textFieldAtIndex:0];
        
        [self createFolderWithName:textfild.text];

}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contents count] ;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        self.indexPathForInsert = indexPath;
    }
    

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
        NSString* fileName = [self.contents objectAtIndex:indexPath.row];
        NSString *filePath = [self.path stringByAppendingPathComponent:fileName];
    
    cell.textLabel.text = fileName;
    
        if ([self isDirectoryAtIndexPath:indexPath]) {
            
            cell.imageView.image = [UIImage imageNamed:@"folder2.png"];
            NSString *folderSizeStr = [NSByteCountFormatter stringFromByteCount:[self sizeOfFolder:filePath] countStyle:NSByteCountFormatterCountStyleFile];
            cell.detailTextLabel.text = folderSizeStr;
        } else {
            
            cell.imageView.image = [UIImage imageNamed:@"file.png"];
            
            NSDictionary *data = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            cell.detailTextLabel.text = [NSByteCountFormatter stringFromByteCount:[data fileSize] countStyle:NSByteCountFormatterCountStyleFile];
        }
    
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.54 green:0.54 blue:0.54 alpha:1.000];
    
        return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        

        
        NSMutableArray* tempArray = [NSMutableArray arrayWithArray:self.contents];

        
        NSFileManager* fileManager = [NSFileManager defaultManager];
        
        NSString* fileName = [self.contents objectAtIndex:indexPath.row];
        
        NSString* filePath = [self.path stringByAppendingPathComponent:fileName];
        
        NSError* error = nil;
        
        if (![fileManager removeItemAtPath:filePath error:&error]) {
            
            NSLog(@"[Error] %@ (%@)",error,filePath);
        }
        
        [tempArray removeObject:[tempArray objectAtIndex:indexPath.row]];
        self.contents = tempArray;
        
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [tableView endUpdates];
    }
    
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
        
        NSString* fileName = [self.contents objectAtIndex:indexPath.row];
        
        NSString* path = [self.path stringByAppendingPathComponent:fileName];
        
        DSDirectoryTableViewController* vc = [[DSDirectoryTableViewController alloc] initWithFolderPath:path];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - NSFileManagerDelegate

- (BOOL)fileManager:(NSFileManager *)fileManager shouldRemoveItemAtPath:(NSString *)path {
    return YES;
}




@end
