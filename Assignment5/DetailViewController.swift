//
//  DetailViewController.swift
//  Assignment4
//
//  Created by Carly Dobie on 11/3/20.
//  Copyright © 2020 Carly Dobie. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var presidentNumberLabel: UILabel!
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var nicknamesLabel: UILabel!
    @IBOutlet weak var partyLabel: UILabel!
    @IBOutlet weak var portrait: UIImageView!
    
    var portraitStore: PortraitStore?
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = nameLabel {
                label.text = detail.name
            }
            if let label = presidentNumberLabel {
                // Format numbers ordinally
                let ordinalFormatter = NumberFormatter()
                ordinalFormatter.numberStyle = .ordinal
                // Set text in detail view for president number
                // Convert detail.number, int, to NSNumber
                // Use "" if detail.number == nil
                label.text = (ordinalFormatter.string(from: NSNumber(value: detail.number)) ?? "") + " President of the United States"
            }
            if let label = datesLabel {
                // Set text in detail view for date range of presidency
                label.text = "(" + detail.startDate + " to " + detail.endDate + ")"
            }
            if let label = nicknamesLabel {
                // Set text in detail view for president's nicknames
                label.text = detail.nickname
            }
            if let label = partyLabel {
                // Set text in detail view for president's party
                label.text = detail.party
            }
            if let portrait = portrait, let portraitStore = portraitStore {
                portraitStore.downloadImage(with: detail.url, completion: {
                    (image: UIImage?) in
                    portrait.image = image
                })
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    var detailItem: President? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    // When memory is low, let system clear the image cache
    override func didReceiveMemoryWarning() {
        portraitStore?.clearCache()
    }

}

