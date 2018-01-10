//
//  TableViewCell.swift
//  SmoothTableView
//
//  Created by Li-Heng Hsu on 10/01/2018.
//  Copyright © 2018 Li-Heng Hsu. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var myImageView: UIImageView!
    override var imageView: UIImageView? {
        return myImageView
    }

}
