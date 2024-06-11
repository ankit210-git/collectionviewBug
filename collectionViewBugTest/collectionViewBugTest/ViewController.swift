//
//  ViewController.swift
//  collectionViewBugTest
//
//  Created by Ankit Gupta on 6/10/24.
//

import UIKit

class ViewController: UIViewController {
    
    var dataSource: UICollectionViewDiffableDataSource<Int, Int>! = nil
    var collectionView: UICollectionView! = nil
    private let queue: DispatchQueue = DispatchQueue(label: "test.collection.reload")
    var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Orthogonal Sections"
        configureHierarchy()
        configureDataSource()
        
    }
}

extension ViewController {
    
    //   +-----------------------------------------------------+
    //   | +---------------------------------+  +-----------+  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |     1     |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  +-----------+  |
    //   | |               0                 |                 |
    //   | |                                 |  +-----------+  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |     2     |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |           |  |
    //   | +---------------------------------+  +-----------+  |
    //   +-----------------------------------------------------+
    
    /// - Tag: Orthogonal
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // if we have the space, adapt and go 2-up + peeking 3rd item
            let groupFractionalWidth = CGFloat(layoutEnvironment.container.effectiveContentSize.width > 500 ?
                                               0.425 : 0.85)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth),
                                                   heightDimension: .absolute(150))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 20
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
            
            return section
            
        }
        return layout
    }
}

extension ViewController {
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action:
                                                    #selector(handleRefreshControl),
                                                 for: .valueChanged)
    }
    @objc func handleRefreshControl() {
        setInitialData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.reloadData()
        }
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        //            self.setInitialData()
        //        }
        
        // Dismiss the refresh control.
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<TestCell, Int> { (cell, indexPath, identifier) in
            // Populate the cell with our item description.
            cell.label.text = "\(indexPath.section), \(indexPath.item)"
            var backgroundColor: UIColor = .black
            if indexPath.section % 2 == 0 {
                backgroundColor = .yellow
            } else {
                backgroundColor = .red
            }
            cell.contentView.backgroundColor = backgroundColor
            cell.contentView.layer.borderColor = UIColor.black.cgColor
            cell.contentView.layer.borderWidth = 1
            cell.contentView.layer.cornerRadius = 8
            cell.label.textAlignment = .center
            cell.label.font = UIFont.preferredFont(forTextStyle: .title1)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
        
        setInitialData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.reloadData()
        }
    }
    
    func setInitialData() {
        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        var identifierOffset = 0
        let itemsPerSection = 30
        for section in 0..<4 {
            snapshot.appendSections([section])
            let maxIdentifier = identifierOffset + itemsPerSection
            snapshot.appendItems(Array(identifierOffset..<maxIdentifier))
            identifierOffset += itemsPerSection
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        var identifierOffset = 0
        let itemsPerSection = 30
        for section in 0..<4 {
            snapshot.appendSections([section])
            let maxIdentifier = identifierOffset + itemsPerSection
            snapshot.appendItems(Array(identifierOffset..<maxIdentifier))
            identifierOffset += itemsPerSection
        }
        snapshot.deleteSections([1])
        
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}


