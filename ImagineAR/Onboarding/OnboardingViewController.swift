//
//  OnboardingViewController.swift
//  ImagineAR
//
//  Created by Karim Amanov on 27/10/2019.
//  Copyright © 2019 Karim Amanov. All rights reserved.
//

import UIKit

private class OnboardingView: UIView, UIScrollViewDelegate {
    private let scrollView: UIScrollView
    private let pageControl: UIPageControl
    
    init(frame: CGRect, pageViews: [UIView]) {
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = .gray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = pageViews.count
        super.init(frame: frame)
        
        scrollView.delegate = self
        
        addSubview(scrollView)
        scrollView.addSubview(pageControl)
        pageControl.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: scrollView.frameLayoutGuide.bottomAnchor, constant: -180).isActive = true

        
        addConstraints([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        scrollView.showsHorizontalScrollIndicator = false
        let containerView = UIView()
        containerView.backgroundColor = .green
        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)
        scrollView.addConstraints([
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
        ])
        containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, multiplier: 3).isActive = true
        //containerView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, multiplier: 1).isActive = true

        var lastPage: UIView?
        for page in pageViews {
            page.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(page)
            page.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
            page.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20).isActive = true
            if let last = lastPage {
                page.leftAnchor.constraint(equalTo: last.rightAnchor).isActive = true
            } else {
                page.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            }
            page.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            //page.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -40).isActive = true
            //page.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true

            lastPage = page
        }

    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let page = Int(round(scrollView.contentOffset.x / pageWidth))
        pageControl.currentPage = page
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ImageInfoView: UIView {
    let imageView: UIImageView
    let label: UILabel?
    init(image: UIImage, text: NSAttributedString? = nil) {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        if let t = text {
            label = UILabel()
            label?.translatesAutoresizingMaskIntoConstraints = false
            label?.backgroundColor = .clear
            label?.attributedText = t
            label?.textAlignment = .center
            label?.numberOfLines = 0
            
        } else {
            label = nil
        }
        super.init(frame: .zero)
        
        addSubview(imageView)
        
        if let label = self.label {
            addSubview(label)
            label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            label.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -20).isActive = true
        } else {
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -70).isActive = true
        }
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class OnboardingViewController: UIViewController {
    var onClose: (() -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear

        let views = [
            ImageInfoView(image: UIImage(named: "onboarding")!,
                          text: NSAttributedString(string: "Hello!", attributes: [.font: UIFont(name: "DINAlternate-Bold", size: 50.0)!])),
            ImageInfoView(image: UIImage(named: "onboarding2")!,
            text: NSAttributedString(string: "LOOK PINS AROUND YOU.\nCREATE ART.\nGIVE FEEDBACK.", attributes: [.font: UIFont(name: "DINAlternate-Bold", size: 15.0)!])),
            ImageInfoView(image: UIImage(named: "start_button")!)
        ]
        
        views[2].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCloseFunc)))

        let onboarding = OnboardingView(frame: .zero, pageViews: views)
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)
        view.addConstraints([
            onboarding.topAnchor.constraint(equalTo: view.topAnchor),
            onboarding.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            onboarding.leftAnchor.constraint(equalTo: view.leftAnchor),
            onboarding.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
    
    @objc func onCloseFunc() {
        self.onClose?()
    }
}
