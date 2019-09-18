//
//  Card.swift
//  ShopifyMemoryMatcher
//
//  Created by Ben Sykes on 2019-09-17.
//  Copyright © 2019 Sheridan College. All rights reserved.
//

import Foundation

// Card object used for each card in Game
class Card : NSObject {
    private var cardID : String!
    private var selected : Bool!
    private var imageURL : String!
    
    init(id: String, imageURL: String) {
        self.cardID = id
        self.selected = false
        self.imageURL = imageURL
    }
    
    public func getID() -> String {
        return self.cardID
    }
    
    public func isSelected() -> Bool {
        return self.selected
    }
    
    public func toggleSelected() {
        self.selected = !self.selected
    }
    
    public func getImageURL() -> String {
        return self.imageURL
    }
    
    public func setImageURL(imageURL: String) {
        self.imageURL = imageURL
    }
}
