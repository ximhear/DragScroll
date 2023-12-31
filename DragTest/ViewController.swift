//
//  ViewController.swift
//  DragTest
//
//  Created by gzonelee on 2023/09/01.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    let dragView = DragView()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setupUI()
        }
        
        private func setupUI() {
            view.backgroundColor = .white
            
            let showButton = UIButton(type: .system)
            showButton.setTitle("Show DragView", for: .normal)
            showButton.addTarget(self, action: #selector(showDragView), for: .touchUpInside)
            
            view.addSubview(showButton)
            view.addSubview(dragView)
            
            showButton.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
            
            dragView.snp.makeConstraints { (make) in
                make.bottom.leading.trailing.equalToSuperview()
            }
        }
        
    @objc private func showDragView() {
        let overlay = OverlayView()
          self.view.addSubview(overlay)
          
          overlay.snp.makeConstraints { make in
              make.edges.equalToSuperview()
          }
          
          overlay.show()
    }
}

