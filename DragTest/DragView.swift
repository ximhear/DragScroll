//
//  DragView.swift
//  DragTest
//
//  Created by gzonelee on 2023/09/01.
//

import UIKit
import SnapKit

class DragView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    var onShouldHide: (() -> Void)?
    
    var heightConstraint: Constraint?
    var lastContentOffset: CGFloat = 0
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.text = "Drag Me"
        lbl.backgroundColor = .yellow
        lbl.textAlignment = .center
        return lbl
    }()
    
    let tableView: UITableView = {
        let tbl = UITableView()
        tbl.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tbl
    }()
    
    var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0)
    private var tableViewPanGesture: UIPanGestureRecognizer!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupViews() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(panGesture)

        tableViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleTableViewPan(_:)))
            tableView.addGestureRecognizer(tableViewPanGesture)
        tableViewPanGesture.delegate = self
        
        addSubview(label)
        addSubview(tableView)

        label.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // Setting the initial height of the DragView to 0
        self.snp.makeConstraints { make in
            heightConstraint = make.height.equalTo(0).constraint
        }

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - UIScrollViewDelegate methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // tableView가 아래로 스크롤되면 DragView의 높이를 조정합니다.
        if scrollView.contentOffset.y < 0 {
            let yOffset = abs(scrollView.contentOffset.y)
            heightConstraint?.update(offset: 600 - yOffset)
            scrollView.contentOffset.y = 0
        } else if let height = heightConstraint?.layoutConstraints.first?.constant, height < 600 {
            // DragView의 높이가 600보다 작으면 tableView의 스크롤 업을 방지합니다.
            scrollView.contentOffset.y = 0
        }
    }

    func scrollViewDidScrollggg(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            let yOffset = abs(scrollView.contentOffset.y)
            heightConstraint?.update(offset: 600 - yOffset)
            scrollView.contentOffset.y = 0
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if heightConstraint?.layoutConstraints.first?.constant != 600 {
            scrollView.isScrollEnabled = false
        } else {
            scrollView.isScrollEnabled = true
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.frame.height >= 300 {
            UIView.animate(withDuration: 0.3, animations: {
                self.heightConstraint?.update(offset: 600)
                self.layoutIfNeeded()
            }) { _ in
                scrollView.isScrollEnabled = true
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.heightConstraint?.update(offset: 0)
                self.layoutIfNeeded()
            }
        }
    }
    
    func show() {
        UIView.animate(withDuration: 0.3) {
            self.heightConstraint?.update(offset: 600)
            self.superview?.layoutIfNeeded()
        }
    }

    func hide() {
        UIView.animate(withDuration: 0.3, animations: {
            self.heightConstraint?.update(offset: 0)
            self.layoutIfNeeded()
        }, completion: { _ in
            if let overlay = self.superview as? OverlayView {
                overlay.removeFromSuperview()
            }
        })
    }
    
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let touchPoint = recognizer.location(in: self.window)
        
        switch recognizer.state {
        case .began:
            initialTouchPoint = touchPoint

        case .changed:
            let dy = touchPoint.y - initialTouchPoint.y
            var newHeight = 600 - dy // 여기를 수정
            newHeight = max(min(newHeight, 600), 0)
            heightConstraint?.update(offset: newHeight)
            layoutIfNeeded()

        case .ended, .cancelled:
            let swipeVelocity = recognizer.velocity(in: self).y
            print("swipeVelocity", swipeVelocity)
                    let thresholdVelocity: CGFloat = 300.0

                    if abs(swipeVelocity) > thresholdVelocity {
                        // 사용자가 빠르게 스와이프했습니다.
                        if swipeVelocity < 0 {
                            // 스와이프 업
                            restore()
                        } else {
                            // 스와이프 다운
                            onShouldHide?()
                        }
                    } else {
                        if self.frame.height >= 300 {
                            restore()
                        } else {
                            onShouldHide?()
                        }
                    }
        default:
            break
        }
    }
    
    @objc private func handleTableViewPan(_ recognizer: UIPanGestureRecognizer) {
        if tableView.contentOffset.y <= 0 {
            let translation = recognizer.translation(in: self)
            let velocity = recognizer.velocity(in: self).y
            
            switch recognizer.state {
            case .changed:
                if translation.y > 0 {  // Only slide down
                    let newHeight = 600 - translation.y
                    heightConstraint?.update(offset: newHeight)
                }
            case .ended, .cancelled:
                let thresholdVelocity: CGFloat = 300.0 // 임계 속도값
                print("velocity", velocity)
                if abs(velocity) > thresholdVelocity { // 빠르게 swipe down
                    if velocity < 0 {
                        // 스와이프 업
                        restore()
                    } else {
                        // 스와이프 다운
                        onShouldHide?()
                    }
                }
               else if let heightConstraint = heightConstraint {
                    if heightConstraint.layoutConstraints.first?.constant ?? 0 < 300 {
                        onShouldHide?()
                    } else {
                        restore()
                    }
                }
            default:
                break
            }
        }
    }
    
    private func restore() {
        show()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: tableView)
            if tableView.contentOffset.y <= 0, velocity.y > 0 {
                return false
            }
        }
        return true
    }

}

extension DragView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Item \(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44 // Assuming equal heights for all cells
    }
}
