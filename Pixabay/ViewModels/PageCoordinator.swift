//
//  PageViewModel.swift
//  Pixabay
//
//  Created by Nour on 31/05/2018.
//  Copyright © 2018 Nour Saffaf. All rights reserved.
//

import Foundation
import UIKit

public enum Pages: String {
    case Editor = "editor"
    case Search = "search"
    case Category = "category"
    
    static let all = [Editor, Search, Category]
    
    static func rawValueFrom(hashValue: Int) ->  String? {
        if hashValue < 0 || hashValue >= all.count { return nil }
        for page in Pages.all {
            if page.hashValue == hashValue {
                print(page.rawValue)
                return page.rawValue
            }
        }
        return nil
    }
    
    static func pageFrom(hashValue: Int) -> Pages? {
        
        if hashValue < 0 || hashValue >= all.count { return nil }
        for page in Pages.all {
            if page.hashValue == hashValue {
                return page
            }
        }
        return nil
    }
    
    static func pageViewModel(rawValue: String) -> ViewModel.Type {
        if rawValue == Pages.Editor.rawValue {
            return CategoryViewModel.self
        } else if rawValue == Pages.Category.rawValue {
            return CollectionViewModel.self
        }
        
        return CategoryViewModel.self
    }
}

final class PageCoordinator: NSObject, UIPageViewControllerDelegate,  UIPageViewControllerDataSource {
    var pageViewController: UIPageViewController!
    var currentPageId: Int = 1
    
    init(pageViewController: UIPageViewController ){
        
        self.pageViewController = pageViewController
       
        let firstPage = pageViewController.storyboard?.instantiateViewController(withIdentifier: Pages.Search.rawValue)
        pageViewController.setViewControllers([firstPage!], direction: .forward, animated: false, completion: nil)
       
    }
    
    deinit {
        print("dies?")
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let nextIdentifier = viewControllerNextTo(identifier: viewController.restorationIdentifier, nextId: -) {
            return pageViewController.storyboard?.instantiateViewController(with: nextIdentifier, delegate: self)

        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        if let nextViewController = pendingViewControllers.first {
            currentPageId = indexOfViewControllerWith(nextViewController.restorationIdentifier)
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        (pageViewController as? PixaPageViewController)?.pageControl.currentPage = currentPageId
      
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let nextIdentifier = viewControllerNextTo(identifier: viewController.restorationIdentifier, nextId: +) {
            return pageViewController.storyboard?.instantiateViewController(with: nextIdentifier, delegate: self)
            
           // return viewController
        }
        
        return nil
    }
    
    func indexOfViewControllerWith(_ identifier: String?) -> Int {
        
        if identifier == nil { return NSNotFound }
        
        for page in Pages.all {
            if page.rawValue == identifier {
                return page.hashValue
            }
        }
        
        return NSNotFound
    }
    /*
    func viewControllerNextTo(identifier: String?, nextId:(Int, Int)-> Int) -> String?  {
        
        let indexOfVisibleViewController = self.indexOfViewControllerWith(identifier)
        
        if  indexOfVisibleViewController < 0  || indexOfVisibleViewController == NSNotFound
        { return nil }
        
        return Pages.rawValueFrom(hashValue: nextId(indexOfVisibleViewController, 1))
    }
    */
    func viewControllerNextTo(identifier: String?, nextId:(Int, Int)-> Int) -> Pages?  {
        
        let indexOfVisibleViewController = self.indexOfViewControllerWith(identifier)
        
        if  indexOfVisibleViewController < 0  || indexOfVisibleViewController == NSNotFound
        { return nil }
        
        return Pages.pageFrom(hashValue: nextId(indexOfVisibleViewController, 1))
    }
    
    
}

extension PageCoordinator: CategoryDelegate {
    func didSelect(_ category: PhotosCategory) {
        print("hello delegate?")
        let navigationController = pageViewController.storyboard?.instantiateNavigatorViewController(for: category)
       self.pageViewController.present(navigationController!, animated: true, completion: nil)
        
    }
    
    
}

extension UIStoryboard {
    
    func instantiateViewController(with pageIdentifier: Pages, delegate: PixaDelegate?) -> UIViewController {
        
        switch pageIdentifier {
        case Pages.Category:
            return instantiatePixaGategoryViewController(with: delegate)
        case Pages.Editor:
              return instantiatePixaEditorViewController()
        case Pages.Search:
            return instantiateSearchViewController()
        }

    }
    
    func instantiatePixaGategoryViewController(with delegate: PixaDelegate?) -> PixaGategoriesViewController{
         let viewController =  instantiateViewController(withIdentifier: "category") as! PixaGategoriesViewController
        viewController.viewModel = CategoryViewModel()
        viewController.viewModel.collectionSize =  viewController.collectionView?.bounds.size
        viewController.delegate = delegate as? CategoryDelegate
        return viewController
    }
    
    func instantiatePixaEditorViewController() -> PixaEditorViewController{
        let viewController =  instantiateViewController(withIdentifier: "photos") as! PixaEditorViewController
        viewController.viewModel.collectionView = viewController.collectionView
        viewController.viewModel.model = EditorCollectionModel()
        viewController.viewModel.model.data = nil
        viewController.viewModel.requestParameters = viewController.viewModel.model.parameters
        
        return viewController
    }
    
    func instantiateSearchViewController() -> PixaPageViewController {
          let viewController =  instantiateViewController(withIdentifier: "search") as! PixaPageViewController
        
        return viewController
    }
    
    func instantiateNavigatorViewController(for category: PhotosCategory)-> PixalCategoryPhotosViewController {
         let viewController = instantiateViewController(withIdentifier: "category_collection") as! PixalCategoryPhotosViewController
        
        viewController.viewModel.collectionView = viewController.collectionView
        viewController.viewModel.model = CategoryCollectionModel()
        viewController.viewModel.model.data = category
        viewController.viewModel.requestParameters = viewController.viewModel.model.parameters
        
        return viewController
    }
}