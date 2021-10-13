//
//  MapViewController.swift
//  WorldTweets
//
//  Created by David Avendaño on 12/10/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var mapContainer: UIView!
    
    // MARK: - Properties
    private var posts = [Post]()
    private var map: MKMapView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupMap()
    }
    
    private func setupMap(){
        map = MKMapView(frame: mapContainer.bounds)
        mapContainer.addSubview(map ?? UIView())
    }

}
