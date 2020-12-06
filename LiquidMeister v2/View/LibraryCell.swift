//
//  LibraryCell.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/27/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit

class LibraryCell: UITableViewCell {
    var dataType: DataType?
    var customerToDisplay: Customer?
    var inventoryItemToDisplay: InventoryItem?
    var itemToDisplay: Item?
    var recipeToDisplay: PersonalRecipe?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        clearCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        clearCell()
        
        guard let dataType = dataType else { return }
        switch dataType {
        case .customer:     layoutForCustomer()
        case .inventory:    layoutForInventoryItem()
        case .item:         layoutForItem()
        case .recipe:       layoutForPersonalRecipe()
        }
    }
    
    private func layoutForCustomer() {
        clearCell()
        guard let customer = customerToDisplay else { return }
        
        let nameLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont(name: Font.bold, size: 22)
            label.text = customer.name
            label.textColor = Color.white.color
            return label
        }()
        
        let emailLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont(name: Font.regular, size: 18)
            label.text = customer.email ?? "No email listed..."
            label.textColor = Color.white.color
            return label
        }()
        
        nameLabel.anchor(to: self,
                         top: self.topAnchor,
                         leading: self.leadingAnchor,
                         trailing: self.trailingAnchor,
                         padding: .init(top: 5, left: 5, bottom: 0, right: 5))
        
        emailLabel.anchor(to: self,
                          top: nameLabel.bottomAnchor,
                          leading: self.leadingAnchor,
                          trailing: self.trailingAnchor,
                          padding: .init(top: 5, left: 5, bottom: 0, right: 5))
        
        emailLabel.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor, constant: 5).isActive = true
    }
    
    private func layoutForInventoryItem() {
        clearCell()
        guard let inventoryItem = inventoryItemToDisplay else { return }
        let detailLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont(name: Font.bold, size: 22)
            label.textColor = Color.white.color
            label.text = {
                guard let manufacturer = inventoryItem.manufacturer else { return inventoryItem.name }
                return "\(inventoryItem.name) - \(manufacturer)"
            }()
            return label
        }()
        
        let amountLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont(name: Font.regular, size: 18)
            label.text = inventoryItem.stock.amountString
            label.textAlignment = .right
            label.textColor = {
                if inventoryItem.stock <= inventoryItem.orderAt ?? 7.5 {
                    return .red
                }
                return Color.white.color
            }()
            return label
        }()
        
        amountLabel.anchor(to: self,
                           top: self.topAnchor,
                           trailing: self.trailingAnchor,
                           padding: .init(top: 5, left: 0, bottom: 0, right: 5),
                           size: .init(width: 75, height: 0))
        
        detailLabel.anchor(to: self,
                         top: self.topAnchor,
                         leading: self.leadingAnchor,
                         trailing: amountLabel.leadingAnchor,
                         padding: .init(top: 5, left: 5, bottom: 0, right: 5))
        
        amountLabel.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor, constant: 5).isActive = true
        detailLabel.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor, constant: 5).isActive = true
    }
    
    private func layoutForItem() {
        clearCell()
        guard let item = itemToDisplay else { return }
        
        let nameLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont(name: Font.bold, size: 22)
            label.text = item.name
            label.textColor = Color.white.color
            return label
        }()
        
        let priceLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont(name: Font.regular, size: 18)
            label.text = item.price?.priceString
            label.textAlignment = .right
            label.textColor = Color.white.color
            return label
        }()
        
        priceLabel.anchor(to: self,
                          top: self.topAnchor,
                          trailing: self.trailingAnchor,
                          padding: .init(top: 5, left: 0, bottom: 0, right: 5),
                          size: .init(width: 75, height: 0))
        
        nameLabel.anchor(to: self,
                         top: self.topAnchor,
                         leading: self.leadingAnchor,
                         trailing: priceLabel.leadingAnchor,
                         padding: .init(top: 5, left: 5, bottom: 0, right: 5))
        
        priceLabel.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor, constant: 5).isActive = true
        nameLabel.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor, constant: 5).isActive = true
    }
    
    private func layoutForPersonalRecipe() {
        clearCell()
        guard let recipe = recipeToDisplay else { return }
        
        let nameLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont(name: Font.bold, size: 22)
            label.text = recipe.name
            label.textColor = Color.white.color
            return label
        }()
        
        let favoriteIcon: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.image = {
                if recipe.favorite {
                    return #imageLiteral(resourceName: "favorite_active")
                } else {
                    return #imageLiteral(resourceName: "favorite")
                }
            }()
            return imageView
        }()
        
        favoriteIcon.anchor(to: self,
                            trailing: self.trailingAnchor,
                            centerY: self.centerYAnchor,
                            padding: .init(top: 0, left: 0, bottom: 0, right: 5),
                            size: .init(width: 30, height: 30))
        
        nameLabel.anchor(to: self,
                         top: self.topAnchor,
                         leading: self.leadingAnchor,
                         trailing: favoriteIcon.leadingAnchor,
                         padding: .init(top: 5, left: 5, bottom: 0, right: 5))
        
        nameLabel.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor, constant: -5).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
