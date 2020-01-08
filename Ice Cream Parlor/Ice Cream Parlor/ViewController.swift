//
//  ViewController.swift
//  Ice Cream Parlor
//
//  Created by Omar Eduardo Gomez Padilla on 1/7/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import UIKit

class NumberCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: NumberCell.self)
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var image: UIImageView!
}

struct MenuItem : Hashable {
    
    let id: String
    let backgroundColor: UIColor
    let shape: String
    let title: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Int, MenuItem>!
    
    // Helper properties
    
    var layout: UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func getSnapshot(_ data: [MenuItem]) -> NSDiffableDataSourceSnapshot<Int, MenuItem> {
        var result = NSDiffableDataSourceSnapshot<Int, MenuItem>()
        result.appendSections([0])
        result.appendItems(data)
        return result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.collectionViewLayout = layout
        
        dataSource = UICollectionViewDiffableDataSource<Int, MenuItem>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NumberCell.reuseIdentifier, for: indexPath) as? NumberCell else {
                fatalError("Cannot create new cell")
            }
            
            cell.label.text = item.title
            let img = UIImage(named: item.shape)
            cell.image.image = img

            cell.layer.borderWidth = 1.0
            cell.layer.borderColor = UIColor.gray.cgColor
            
            cell.image.backgroundColor = item.backgroundColor

            return cell
        }

        // Load data
        URLSession.shared.doJsonTask(forURL: URL(string: "https://gl-endpoint.herokuapp.com/products")!) { [weak self] (data, error) in
            
            guard let rawData = data as? Array<[String:String]>, let self = self else {
                return
            }
            
            let finalData: [MenuItem] = rawData.map {
                
                var color = UIColor.gray
                if let strColor = $0["name2"] {
                    switch strColor {
                    case "Fuscia", "Puce":
                        color = UIColor.systemPink
                    case "Indigo", "Blue":
                        color = UIColor.blue
                    case "Khaki", "Yellow":
                        color = UIColor.yellow
                    case "Crimson":
                        color = UIColor.red
                    case "Green":
                        color = UIColor.green
                    case "Aquamarine":
                        color = UIColor.cyan
                    case "Teal":
                        color = UIColor.systemTeal
                    case "Violet", "Purple":
                        color = UIColor.purple
                    default:
                        do {}
                    }
                }
                
                let shape = $0["type"] ?? "popsicle"
                
                let name = $0["name1"] ?? "??"
                let name2 = $0["name2"] ?? "??"
                let title = "\(name) \(name2)"
                
                return MenuItem( id:UUID().uuidString,  backgroundColor: color, shape: shape, title: title )

            }
            
            self.dataSource.apply( self.getSnapshot(finalData), animatingDifferences: false)
        }
            

        
    }

    

}

