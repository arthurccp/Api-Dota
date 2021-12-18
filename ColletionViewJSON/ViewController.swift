//
//  ViewController.swift
//  ColletionViewJSON
//
//  Created by Arthur on 18/12/2021.
//  Copyright © 2021 br.com.arthursilva. All rights reserved.
//

import UIKit




struct Hero:Decodable{
    let localized_name: String
    let name: String
    let img: String

}
class ViewController: UIViewController, UICollectionViewDataSource {
    
    
    
    var heroes = [Hero]()
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        
        let url = URL(string: "https://api.opendota.com/api/heroStats")
        URLSession.shared.dataTask(with: url!){ (data,response,error)in
            if error == nil{
                do{
                    self.heroes = try JSONDecoder().decode([Hero].self, from: data!)
                }catch{
                    print("parse error\(error)")
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            }.resume()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return heroes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! CustomCollectionViewCell
        
        cell.nameLbl.text = heroes[indexPath.row].localized_name.capitalized
        cell.imageView.contentMode = .scaleAspectFill
        
        
        let defaultLink = "https://api.opendota.com"
        let completeLink = defaultLink + heroes[indexPath.row].img
        
        cell.imageView.downloaded(from: completeLink)
        cell.imageView.clipsToBounds = true
        cell.imageView.layer.cornerRadius = cell.imageView.frame.height / 2
        cell.imageView.contentMode = .scaleAspectFill
        return cell
    }
    
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
            }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
        
    }
}

