//
//  UIViewControllerExtensions.swift
//  Pods
//
//  Created by Haizhen Lee on 15/12/11.
//
//

import UIKit

public extension UIViewController{
  
  public func bx_showURL(URL:NSURL,title:String?=nil){
   let vc = createWebAppViewController(URL)
    vc.title = title
    showViewController(vc, sender: self)
  }
}
