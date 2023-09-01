//
//  OverlayView.swift
//  DragTest
//
//  Created by C.H Lee on 2023/09/01.
//

import UIKit
import SnapKit

class OverlayView: UIView {
    
    let dragView = DragView()
    
    init() {
        super.init(frame: .zero)
        setupView()
        setupConstraints()
        addTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.7) // 반투명 검정색
        
        dragView.onShouldHide = { [weak self] in
            self?.hide()
        }
        
        addSubview(dragView)
    }
    
    private func setupConstraints() {
        dragView.snp.makeConstraints {[weak dragView] make in
            make.left.right.equalToSuperview()
            make.height.equalTo(600).priority(.high)
            dragView?.bottomConstraint = make.bottom.equalToSuperview().constraint
        }
    }
    
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
    
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        
        if !dragView.frame.contains(location) {
            dragView.hide() // 이미 정의된 hide 메소드 호출
            hide() // OverlayView 숨기기
        }
    }
    
    func show() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0) // 초기 투명도

        // DragView의 애니메이션 설정
        dragView.heightConstraint?.update(offset: 0)
        self.layoutIfNeeded()

        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.7) // 목표 투명도
            self.dragView.heightConstraint?.update(offset: 600)
            self.layoutIfNeeded()
        }
    }
    
    func hide(completion: (() -> Void)? = nil) {
        self.dragView.bottomConstraint?.update(offset: 600)
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundColor = UIColor.black.withAlphaComponent(0) // 투명하게
            self.layoutIfNeeded()
        }) { _ in
            self.dragView.heightConstraint?.update(offset: 0)
            self.removeFromSuperview()
            completion?()
        }
    }
}


