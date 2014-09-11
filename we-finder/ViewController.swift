//
//  ViewController.swift
//  we-finder
//
//  Created by Jake Weiss on 9/7/14.
//  Copyright (c) 2014 Stever4. All rights reserved.
//

import Cocoa
import WebKit
import Foundation

class ViewController: NSViewController, WKScriptMessageHandler{
    var theWebView: WKWebView?
    var lat: Double = 0.0
    var lon: Double = 0.0
    
    
    
    
    @IBOutlet var someText: NSTextField!
    @IBOutlet var button: NSButton!
    @IBAction func start(sender: AnyObject) {
        button.title = "Click here to refresh\n the GPS if you \nmove out of range"
        button.sizeToFit()
        someText.stringValue = "Click exactly where you are on the map.\nThese data points will be a part of a global database."
        someText.textColor = NSColor .whiteColor()
        loadMap()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    
    func userContentController(userContentController: WKUserContentController!, didReceiveScriptMessage message: WKScriptMessage!) {
        let sentData = message.body as NSString
        getInfo(sentData)
        let myAlert:NSAlert = NSAlert()
        myAlert.informativeText = "Please add as many points from as many locations as you can!"
        myAlert.messageText = "Thanks for your submission."
        myAlert.runModal()
    }
    
    func loadMap() {
        var url = NSURL(string: "http://www.we-fi.me/home/mapTest")
        var request = NSURLRequest(URL:url)
        var theConfiguration = WKWebViewConfiguration()
        theConfiguration.userContentController.addScriptMessageHandler(self, name: "latlon")
        theWebView = WKWebView(frame:CGRectMake(355, 5, 320, 360), configuration: theConfiguration)
        //var theWebView:WKWebView = WKWebView(frame:CGRectMake(10, 10, 300, 300))
        theWebView!.loadRequest(request)
        self.view.addSubview(theWebView!)
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        lat = appDelegate.lat
        lon = appDelegate.lon
        
        let javascript = "window.addEventListener('load', function() { setCoords(\(lat), \(lon)); }, false);"
        
        
        theWebView!.evaluateJavaScript(javascript) { resultOrNil, error in
            //println(resultOrNil)
            //println(error)
        }
        
        
    }
    
    func getInfo(location: NSString) {
        var locArray = location.componentsSeparatedByString(",")
        let task = NSTask()
        task.launchPath = "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
        task.arguments = ["-I"]
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        var rssi: Int = 0
        var security: String = ""
        var mac: String = ""
        var ssid: String = ""
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        var output: String = NSString(data: data, encoding: NSUTF8StringEncoding)
        var networkArray = output.componentsSeparatedByString("\n")
        for i in [0,10,11,12] {
            var network = networkArray[i].substringFromIndex(advance((networkArray[i].rangeOfString(":")?.startIndex)!,2))
            switch i {
            case 0:
                rssi = network.toInt()!
                break;
            case 10:
                security = network
                break;
            case 11:
                mac = network
                break;
            case 12:
                ssid = network
                break;
            default:
                break;
            }
            
        }
        var router = Router(ssid: ssid, mac: mac, rssi: rssi, security: security, lat: locArray[0].doubleValue, lon: locArray[1].doubleValue)
        
        sendData(router)
    }
    
    func sendData(router: Router){
        
        var request = NSMutableURLRequest(URL: NSURL(string: "http://www.we-fi.me/server/post_metric"), cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)
        var response: NSURLResponse?
        var error: NSError?
        var jsonString="[{\"lat\":\(router.lat),\"lon\":\(router.lon),\"ssid\":\"\(router.ssid)\",\"security\":\"\(router.security)\",\"mac\":\"\(router.mac)\",\"rssi\":\(router.rssi)}]"
        request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        //GET NSHTTPURLRESPONSE BODY
        if let httpResponse = response as? NSHTTPURLResponse {
            println("HTTP response: \(httpResponse.statusCode)")
        } else {
            println("No HTTP response")
        }
    }
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
        
    }
    
    
}

class Router {
    var ssid: String
    var mac: String
    var rssi: Int
    var security: String
    var lat: Double
    var lon: Double
    init(ssid: String, mac: String, rssi: Int, security: String, lat: Double, lon: Double) {
        self.ssid = ssid
        self.mac = mac
        self.rssi = rssi
        self.security = security
        self.lat = lat
        self.lon = lon
    }
    func getNetwork()-> String{
        var name:String = self.ssid
        return name
    }
}
