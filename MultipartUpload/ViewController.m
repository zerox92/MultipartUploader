//
//  ViewController.m
//  MultipartUpload
//
//  Created by Zeeshan Anjum on 28/12/2017.
//  Copyright © 2017 Zeeshan Anjum. All rights reserved.
//

#import "ViewController.h"
#import "MPApiClient.h"
#import <SVProgressHUD.h>
#import "UIImage+Compression.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *pickImageButton;
@property (strong, nonatomic) UIImage *imageToUpload;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pickImageButtonTapped:(id)sender {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.navigationBar.translucent = NO;
    controller.delegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:controller animated:YES completion:nil];
    });
}

- (IBAction)uploadButtonTapped:(id)sender {
    if (self.imageToUpload) {
        NSString *path = [self saveImage:self.imageToUpload];
        [SVProgressHUD showProgress:0.01f];
        [[MPApiClient sharedClient] uploadMediaWithMediaPath:path withProgressCompletionHandler:^(NSProgress *progress) {
            [SVProgressHUD showProgress:progress.fractionCompleted];
        } andCompletionHandler:^(NSURLResponse *response, id result, NSError *error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    
                    NSString *title = (error) ? @"Error" : @"Success";
                    NSString *message = (error) ? error.localizedDescription : @"Uploaded successfully";
                    [self showAlertConrollerWithTitle:title andMessage:message];
                });
            });
        }];
    } else {
        [self showAlertConrollerWithTitle:@"Sabr oyee" andMessage:@"Kakay image tho daaal ;-)"];
    }
}

- (NSString *)saveImage:(UIImage*)image {
    
    if (!image) {
        return nil;
    }
    
    NSData *pngData = UIImageJPEGRepresentation(image, 0.5);
    
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    path =  [path stringByAppendingPathComponent:[NSString stringWithFormat:@"image%@.jpeg", @"ZEESHAN"]];
    [pngData writeToFile:path atomically:YES];
    
    return path;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];

    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageView setImage:originalImage];
        });
        
        UIImage *compressedImage = [UIImage compressedImageUsingImage:originalImage];
        self.imageToUpload = compressedImage;
        
    }
    
}

- (void)showAlertConrollerWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                         message:message
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
