//
//  SettingViewController.swift
//  WebSocialNetwork
//
//  Created by Jason on 1/27/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit
import Firebase

class SettingViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func updateInfo(_ sender: Any) {
        let mainStoreBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc =  mainStoreBoard.instantiateViewController(withIdentifier: "EditProfileViewController")
        navigationController?.pushViewController(vc, animated: true)
        
        
        
        
    }
    

    
    @IBAction func signOut(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            let mainStoreBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nav =  mainStoreBoard.instantiateViewController(withIdentifier: "Main.nav") as! UINavigationController
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController = nav
            
        } catch let err {
            print("sign out")
        }
    }

    
    
    
//    override func loadView() {
//
//      // Create a GMSCameraPosition that tells the map to display the
//      // coordinate -33.86,151.20 at zoom level 6.
//      let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
//      let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//      view = mapView
//
//      // Creates a marker in the center of the map.
//      let marker = GMSMarker()
//      marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
//      marker.title = "Sydney"
//      marker.snippet = "Australia"
//      marker.map = mapView
//
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
