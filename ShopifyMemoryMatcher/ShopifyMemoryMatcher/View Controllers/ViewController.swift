//
//  ViewController.swift
//  ShopifyMemoryMatcher
//
//  Created by Ben Sykes on 2019-09-17.
//  Copyright © 2019 Sheridan College. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // Instance vars
    var dataSource : String! = "https://shopicruit.myshopify.com/admin/products.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
    var cardData : NSMutableArray!
    var gameCards : [Card]! = []
    var matched : Int! = 0
    var curSelected : [String]! = []
    var buttonsSelected : [UIButton]! = []
    
    // Outlets
    @IBOutlet var cardButtons : [UIButton]!
    @IBOutlet var lbMatched : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupGameFetchData()
    }

    // Actions
    @IBAction func cardSelected(sender: UIButton!) {
        // Set background image of sender
        var bgImage : UIImage?
        let imageURL : String = self.gameCards[sender.tag].getImageURL()
        let url = NSURL(string: imageURL)! as URL
        if let imageData: NSData = NSData(contentsOf: url) {
            bgImage = UIImage(data: imageData as Data)
        }
        sender.setBackgroundImage(bgImage, for: .normal)
        
        // Select the card
        self.curSelected.append(self.gameCards[sender.tag].getID())
        self.buttonsSelected.append(sender)
        sender.isUserInteractionEnabled = false
        
        // Game logic
        if !(self.curSelected.count < 2) {
            // Compare cards
            if (self.curSelected[0] == self.curSelected[1]) {
                // MATCH! award points and reset curSelected
                self.matched += 1
                updateScore()
                
                self.resetSelected()
                
                // Check win condition
                if (self.matched >= 10) {
                    // WIN!
                    let winPopup = UIAlertController.init(title: "YOU WIN!", message: "Congratulations! You won the game by getting 10 matches!", preferredStyle: .alert)
                    let actions = UIAlertAction(title: "AWESOME!", style: .default, handler: nil)
                    
                    winPopup.addAction(actions)
                    self.present(winPopup, animated: true)
                }
            } else {
                // No Match :( Flip cards back to original state and do not award points
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {  // Delay so user can see their choices for 2 seconds
                    self.resetCards(cardsToReset: self.buttonsSelected)
                    
                    self.resetSelected()
                }
            }
        }
    }
    
    @IBAction func restartGame(sender: UIButton?) {
        // Restart the game
        self.matched = 0
        self.gameCards = []
        self.curSelected = []
        self.cardData = []
        let defaultImg : UIImage? = UIImage(named: "listing-shopify-logo.png")
        self.cardButtons.forEach{button in
            button.isUserInteractionEnabled = true
            button.setBackgroundImage(defaultImg, for: .normal)
        }
        setupGameFetchData()
        self.gameCards.shuffle()
        
        // Reset fields/labels
        updateScore()
    }
    
    // Reset selected card pair
    func resetCards(cardsToReset: [UIButton]!) {
        cardsToReset.forEach{btn in
            btn.isUserInteractionEnabled = true
            flipToBack(card: btn)
        }
    }
    
    // Flip card over
    func flipToBack(card: UIButton!) {
        let defaultImg : UIImage? = UIImage(named: "listing-shopify-logo.png")
        card.setBackgroundImage(defaultImg, for: .normal)
    }
    
    func resetSelected() {
        self.curSelected = [] // Reset currently selected cards
        self.buttonsSelected = [] // Reset buttons selected
    }
    
    // Updates score label
    func updateScore() {
        lbMatched.text = "Matches: " + String(self.matched)
    }
    
    // Loads all products from shopify JSON endpoint
    func setupGameFetchData() {
        let url = NSURL(string: dataSource)
        let request = NSURLRequest(url: url! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            // Parse JSON data from raw response data
            let cardDict : NSDictionary!=(try! JSONSerialization.jsonObject (with: data as! Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
            
            // Make products available to other functions
            self.cardData = cardDict["products"] as? NSMutableArray
            
            // Load the cards on the game board with their respective data
            self.loadProductCards()
            
            // Shuffle the positions of the card
            self.gameCards.shuffle()
            
            // Personal Note: Each card is automacally associated to a button via their tag from 0-19 which is directly related to their positions in the gameCards array
        })
        
        task.resume()
    }
    
    func loadProductCards() {
        do {
            // For each button we are going to select it a product from the datasource JSON
            for _ in 0 ... ((self.cardButtons.count / 2) - 1) {
                // Select a random index in the cardData from JSON endpoint
                let itemIndex = Int.random(in: 0 ... (self.cardData.count - 1))
                
                // Get card information
                let thisCard : NSDictionary = self.cardData.object(at: itemIndex) as! NSDictionary
                let thisCardImages : NSMutableArray = thisCard["images"] as! NSMutableArray
                let thisCardImage : NSDictionary = thisCardImages.object(at: 0) as! NSDictionary
                let thisCardID : String = "\(thisCard["id"] ?? "-1")"
                let thisCardImageSrc : String = "\(thisCardImage["src"] ?? "-1")"
                
                // Valid card selected from product list
                if thisCardID != "-1" && thisCardImageSrc != "-1" {
                    self.gameCards.append(Card(id: thisCardID, imageURL: thisCardImageSrc))
                    
                    // Remove selected product/card from cardData so as to prevent too many copies of the same product
                    self.cardData.removeObject(at: itemIndex)
                }
            }
            
            // Duplicate each card in gameCards
            for i in 0 ... (self.gameCards.count - 1) {
                self.gameCards.append(self.gameCards[i])
            }
        }
    }
}
