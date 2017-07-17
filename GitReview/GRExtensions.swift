//
//  GRExtensions.swift
//  GitReview
//
//  Created by Whitney Foster on 7/16/17.
//  Copyright © 2017 Whitney Foster. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

extension UIImageView {
    func setImageWithCache(urlString: String?, placeholder: UIImage? = nil, options: KingfisherOptionsInfo? = [.transition(ImageTransition.fade(0.4)), .keepCurrentImageWhileLoading], completion: ((UIImage?) -> Void)?) {
        self.contentMode = .scaleAspectFit
        if urlString != nil, let url = URL(string: urlString!) {
            self.kf.indicatorType = IndicatorType.activity
            // ImageCache.default.isImageCached(forKey: urlString!).cached ? 0 : 0.4
            self.setImage(url: url, placeholder: placeholder, options: options, completion: completion)
        }
        else {
            self.setImage(url: nil, placeholder: placeholder, options: options, completion: completion)
        }
    }
    
    private func setImage(url: URL?, placeholder: UIImage?, options: KingfisherOptionsInfo?, completion: ((UIImage?) -> Void)?) {
        self.kf.setImage(with: url, placeholder: placeholder, options: options, progressBlock: { (receivedSize, totalSize) in }, completionHandler: { (image, error, cacheType, imageURL) in completion?(image) })
    }
    
    func resizeForWidth(_ width : CGFloat) {
        guard let image = self.image else {
            return
        }
        
        let height = image.size.height * width / image.size.width
        
        self.frame.size.height = height
        self.frame.size.width = width
        
    }
}

extension NSError {
    @discardableResult
    static func create(message: String) -> NSError {
        NSLog("Error: \(message)")
        return NSError(domain: Bundle.main.bundleIdentifier!, code: message.hash, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
    func createAlert() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: self.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        return alert
    }
}

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: self)
    }
}

extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        var date = formatter.date(from: self)
        if date == nil {
            formatter.dateFormat = "MM/dd"
            date = formatter.date(from: self)
        }
        return date
    }
}

extension NSMutableAttributedString {
    static func lineNumber(number: Int, color: UIColor) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: "\(number)", attributes: [
            NSForegroundColorAttributeName: color == UIColor.white ? UIColor.darkText : UIColor.white,
            NSBackgroundColorAttributeName: color])
    }
    
    static func lineOfFile(line: String) -> (NSMutableAttributedString, UIColor) {
        let line = line.isEmpty ? "\n" : line
        let backgroundColor = line.hasPrefix("-") ? UIColor.red : (line.hasPrefix("+") ? UIColor.green : UIColor.white)
        let paragraph = NSMutableParagraphStyle()
        paragraph.addTabStop(NSTextTab(textAlignment: .left, location: 100, options: [:]))
        paragraph.headIndent = 100
        return (NSMutableAttributedString(string: "\t\(line)", attributes: [
            NSBackgroundColorAttributeName: backgroundColor.withAlphaComponent(0.6),
            NSParagraphStyleAttributeName: paragraph]), backgroundColor)
    }
}


