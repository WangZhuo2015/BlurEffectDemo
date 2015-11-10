//
//  ViewController.swift
//  BlurEffectDemo
//
//  Created by 王卓 on 15/10/17.
//  Copyright © 2015年 BubbleTeam. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var backGroundImage: UIImageView!
    //保存的图片名
    let iconImageFileName="currentImage.png"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置圆角
        icon.layer.cornerRadius = icon.frame.width/2
        //设置遮盖额外部分,下面两句的意义及实现是相同的
         //icon.clipsToBounds = true
        icon.layer.masksToBounds = true

//        //创建模糊效果类实例,UIBlurEffectStyle的枚举值可以自己尝试一下不同的选择
//        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
//        //创建效果视图类实例
//        let EffertView = UIVisualEffectView(effect: blurEffect)
//        //设置模糊的透明程度
//        EffertView.alpha=0.8
//        //设置效果视图类实例的尺寸
//        EffertView.frame = self.view.bounds
//        //将模糊效果视图类实例放入背景中
//        backGroundImage.addSubview(EffertView)
        
        //为头像添加点击事件
        icon.userInteractionEnabled=true
        let userIconActionGR = UITapGestureRecognizer()
        userIconActionGR.addTarget(self, action: Selector("selectIcon"))
        icon.addGestureRecognizer(userIconActionGR)
        
        //读取用户头像
        let fullPath = ((NSHomeDirectory() as NSString) .stringByAppendingPathComponent("Documents") as NSString).stringByAppendingPathComponent(iconImageFileName)
        //可选绑定,若保存过用户头像则显示之
        if let savedImage = UIImage(contentsOfFile: fullPath){
            self.icon.image = savedImage
        }
        
    }
    //选择头像的函数
    func selectIcon(){
        let userIconAlert = UIAlertController(title: "请选择操作", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let chooseFromPhotoAlbum = UIAlertAction(title: "从相册选择", style: UIAlertActionStyle.Default, handler: funcChooseFromPhotoAlbum)
        userIconAlert.addAction(chooseFromPhotoAlbum)
        
        let chooseFromCamera = UIAlertAction(title: "拍照", style: UIAlertActionStyle.Default,handler:funcChooseFromCamera)
        userIconAlert.addAction(chooseFromCamera)
        
        let canelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel,handler: nil)
        userIconAlert.addAction(canelAction)
        
        self.presentViewController(userIconAlert, animated: true, completion: nil)
    }
    //从相册选择照片
    func funcChooseFromPhotoAlbum(avc:UIAlertAction) -> Void{
        let imagePicker = UIImagePickerController()
        //设置代理
        imagePicker.delegate = self
        //允许编辑
        imagePicker.allowsEditing = true
        //设置图片源
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        //模态弹出IamgePickerView
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    //拍摄照片
    func funcChooseFromCamera(avc:UIAlertAction) -> Void{
        let imagePicker = UIImagePickerController()
        //设置代理
        imagePicker.delegate = self
        //允许编辑
        imagePicker.allowsEditing=true
        //设置图片源
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        //模态弹出IamgePickerView
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //UIImagePicker回调方法
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //获取照片的原图
        //let image = (info as NSDictionary).objectForKey(UIImagePickerControllerOriginalImage)
        //获得编辑后的图片
        let image = (info as NSDictionary).objectForKey(UIImagePickerControllerEditedImage)
        //保存图片至沙盒
        self.saveImage(image as! UIImage, imageName: iconImageFileName)
        let fullPath = ((NSHomeDirectory() as NSString).stringByAppendingPathComponent("Documents") as NSString).stringByAppendingPathComponent(iconImageFileName)
        //存储后拿出更新头像
        let savedImage = UIImage(contentsOfFile: fullPath)
        self.icon.image=savedImage
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

//    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
//        //获取照片的原图
//        let image = (editingInfo! as NSDictionary).objectForKey(UIImagePickerControllerOriginalImage)
//        //保存图片至沙盒
//        self.saveImage(image as! UIImage, imageName: iconImageFileName)
//        let fullPath = ((NSHomeDirectory() as NSString).stringByAppendingPathComponent("Documents") as NSString).stringByAppendingPathComponent(iconImageFileName)
//        //存储后拿出更新头像
//        let savedImage = UIImage(contentsOfFile: fullPath)
//        self.icon.image=savedImage
//        picker.dismissViewControllerAnimated(true, completion: nil)
//    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - 保存图片至沙盒
    func saveImage(currentImage:UIImage,imageName:String){
        var imageData = NSData()
        imageData = UIImageJPEGRepresentation(currentImage, 0.5)!
        // 获取沙盒目录
        let fullPath = ((NSHomeDirectory() as NSString).stringByAppendingPathComponent("Documents") as NSString).stringByAppendingPathComponent(imageName)
        // 将图片写入文件
        imageData.writeToFile(fullPath, atomically: false)
    }
    
    // 改变图像的尺寸，方便上传服务器
    func scaleFromImage(image:UIImage,size:CGSize)->UIImage?{
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage;
    }
    
    //2.保持原来的长宽比，生成一个缩略图
    func thumbnailWithImageWithoutScale(image:UIImage?,size:CGSize)->UIImage?{
        let newImage:UIImage?
        guard image != nil else{
            return nil
        }
        let oldSize:CGSize = image!.size
        var rect = CGRect()
        if(size.width/size.height > oldSize.width/oldSize.height){
            rect.size.width = size.height*oldSize.width/oldSize.height
            rect.size.height = size.height
            rect.origin.x = (size.width - rect.size.width)/2
            rect.origin.y = 0
        }
        else{
            rect.size.width = size.width
            rect.size.height = size.width*oldSize.height/oldSize.width
            rect.origin.x = 0
            rect.origin.y = (size.height - rect.size.height)/2
        }
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        //透明背景
        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
        UIRectFill(CGRectMake(0, 0, size.width, size.height))
        image?.drawInRect(rect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndPDFContext()
        return newImage
    }
    
}

