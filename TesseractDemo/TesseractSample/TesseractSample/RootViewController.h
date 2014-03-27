//
//  ViewController.h
//  TesseractSample
//
//  Created by Loïs Di Qual on 08/10/12.
//  Copyright (c) 2012 Loïs Di Qual. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
 uint32_t *pixels;
}
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButt;
@property (weak, nonatomic) IBOutlet UIButton *photoGallary;
-(IBAction)takePhoto:(id)sender;
- (IBAction)selectPhoto:(id)sender;
-(BOOL)checkDeviceCapability:(NSInteger)sourceType;
-(void)recognizedText:(UIImage *)image;
-(UIImage *)fixOrientation:(UIImage *)image;
-(UIImage *) gs_convert_image :(UIImage *) src_img;

//////
-(UIImage *)resizeImage:(UIImage *)image;
- (UIImage *) toGrayscale:(UIImage*)img;
@end
