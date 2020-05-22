//
//  ImagePickerManager.swift
//  YayOrNay
//
//  Created by Ilay on 15/08/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import Foundation
import UIKit

public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?)
}

class ImagePicker: NSObject{

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?

    init(presentationController: UIViewController, delegate: ImagePickerDelegate){
        self.pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate

        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }

    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction?{
        guard UIImagePickerController.isSourceTypeAvailable(type) else { return nil}
        return UIAlertAction(title: title, style: .default, handler: { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        })
    }

    func present(from sourceView: UIView){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let action = self.action(for: .camera, title: NSLocalizedString("camera.option", comment: "camera")){
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: NSLocalizedString("photo.library.option", comment: "photos")){
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: nil))

        self.presentationController?.present(alertController, animated: true)
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?){
        controller.dismiss(animated: true, completion: nil)
        self.delegate?.didSelect(image: image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate{
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

extension ImagePicker: UINavigationControllerDelegate{

}
