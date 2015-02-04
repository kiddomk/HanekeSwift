Pod::Spec.new do |s|
  s.name         = "HanekeSwift"
  s.version      = "0.8.1"
  s.summary      = "HanekeSwift is an extension of UIImageView for loading and displaying images asynchronously on iOS so that they do not lock up the UI."
  
  s.description  = "Haneke is a lightweight generic cache for iOS written in Swift. It's designed to be super-simple to use. Here's how you would initalize a JSON cache and fetch objects from a url:


Haneke provides a memory and LRU disk cache for UIImage, NSData, JSON, String or any other type that can be read or written as data.

Particularly, Haneke excels at working with images. It includes a zero-config image cache with automatic resizing. Everything is done in background, allowing for fast, responsive scrolling. Asking Haneke to load, resize, cache and display an appropriately sized image is as simple "

  s.homepage     = "https://github.com/Haneke/HanekeSwift"
  s.license      = { :type => 'zlib', :file => 'LICENCE.md' }
  s.author       = { "Haneke" => "https://github.com/Haneke/HanekeSwift" }
  s.source       = { :git => "https://github.com/kiddomk/HanekeSwift.git", :tag => "0.8.1" }

  s.platform     = :ios, '7.0'
  s.source_files = 'HanekeSwift'
  s.requires_arc = true
end
