//
//  PoqAsyncImageView.swift
//  Haneke
//
//  Created by Jun Seki on 05/02/2015.
//  Copyright (c) 2015 Haneke. All rights reserved.
//

import UIKit
import Haneke

class PoqAsyncImageView: UIImageView {
    
    var spinnerView:MMMaterialDesignSpinner?
    let cache = Shared.imageCache
    var fetcher : NetworkFetcher<UIImage>?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupProgressView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProgressView()
    }
    
    func setupProgressView()
    {
        var imageWidth = fminf(Float(self.bounds.size.width), Float(self.bounds.size.height));
        var progressViewWidth = CGFloat(imageWidth/3);
        var frame = CGRectMake(0, 0, progressViewWidth, progressViewWidth);
        spinnerView = MMMaterialDesignSpinner(frame: frame)
        spinnerView?.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        spinnerView?.lineWidth = 1.5;
        // Set the tint color of the spinner
        spinnerView?.tintColor = UIColor.redColor()
        self.addSubview(spinnerView!)
    
    }
    
    func getImageFromURL(URL:NSURL){
        spinnerView?.startAnimating()
        
        self.hnk_setImageFromURL(URL)

        fetcher = NetworkFetcher<UIImage>(URL: URL)
        cache.fetch(fetcher: fetcher!).onSuccess { image in
           
            self.spinnerView?.stopAnimating()
            //animation
            let duration : NSTimeInterval = 0.1
            UIView.transitionWithView(self, duration: duration, options: .TransitionCrossDissolve, animations: {
                self.image = image
    
                }, completion: nil)
        }
    }
    
    func prepareForReuse(){
        if let existingFetcher=fetcher{
            existingFetcher.cancelFetch()
        }
        
    }
}