//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit


class PhotoAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var photo: UIImage!
    
    var title: String? {
        return "\(coordinate.latitude)"
    }
}



class PhotoMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, LocationsViewControllerDelegate {
    
    
    var resizeRenderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))//CGRectMake(0, 0, 45, 45))
    let rightAccesoryButton = UIButton(type: .detailDisclosure)
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBAction func onPhotoButton(_ sender: Any) {
        
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        
        //vc.sourceType = UIImagePickerControllerSourceType.camera
        
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            vc.sourceType = .camera
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            vc.sourceType = .photoLibrary
        }
        
        
        
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
    @IBOutlet weak var photoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        //one degree of latitude is approximately 111 kilometers (69 miles) at all times.
        let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667),
                                              MKCoordinateSpanMake(0.1, 0.1))
        mapView.setRegion(sfRegion, animated: false)
        
        mapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var image: UIImage!
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        

        dismiss(animated: true, completion: { self.performSegue(withIdentifier: "tagSegue", sender: Any?.self) })
    }
    
    func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber) {
        self.navigationController?.popToViewController(self, animated: true)
        
        let locationCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        let annotation = PhotoAnnotation()
        annotation.coordinate = locationCoordinate
        annotation.photo = image
        mapView.addAnnotation(annotation)
        
        
        rightAccesoryButton.addTarget(self, action: #selector(onRightAccesoryButton), for: .touchUpInside)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseID = "myAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        resizeRenderImageView.contentMode = UIViewContentMode.scaleAspectFill
        resizeRenderImageView.image = image
        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.render(in: (UIGraphicsGetCurrentContext() as! CGContext!))
        
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    
        
        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView!.canShowCallout = true
            annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))
            annotationView?.rightCalloutAccessoryView = rightAccesoryButton
            annotationView?.image = thumbnail
            
        }
        let imageView = annotationView?.leftCalloutAccessoryView as! UIImageView
        
        imageView.image = thumbnail
        return annotationView
    }
    
    
    @objc func onRightAccesoryButton(){
        
        self.performSegue(withIdentifier: "fullImageSegue", sender: self)
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addLocationViewController = segue.destination as? LocationsViewController {
            addLocationViewController.delegate = self
        }
        if let fullImageViewController = segue.destination as? FullImageViewController{
            
            fullImageViewController.photo = image
            
        }
    }
    

}
