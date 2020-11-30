

Pod::Spec.new do |s|

s.name         = "KWImageBrowser"

s.version      = "1.0.0"

s.summary      = "iOS image browser / iOS 图片浏览器"

s.description  = <<-DESC
iOS 图片浏览器，功能强大，易于拓展，极致的性能优化和严格的内存控制让其运行更加的流畅和稳健。
DESC

s.homepage     = "https://github.com/yuekewei/KWImageBrowser"

s.license      = "MIT"

s.author       = { "岳克维" => "yuekewei@aliyun.com" }

s.platform     = :ios, "9.0"

s.ios.deployment_target = '9.0'

s.source       = { :git => "https://github.com/yuekewei/KWImageBrowser.git", :tag => "#{s.version}" }

s.requires_arc = true

s.source_files = 'KWImageBrowser/**/*.swift'

s.resources    = "KWImageBrowser/Resource/ImageBrowser.bundle"

s.ios.frameworks = 'Foundation', 'UIKit'

end
