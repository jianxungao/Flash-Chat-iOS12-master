//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import MongoSwift

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    let DB_URL = "mongodb://47.92.218.78:27017"
    let DB_NAME = "myDB"
    let DB_COLLECTION = "messages"
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
       
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        
        retrieveMessages()
        
    }
    
    
    

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
//        let messageArray = ["1st Message", "2nd Message"]
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        return cell
        
    }
    
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped(_ tapGesture : UITapGestureRecognizer){
        
        messageTextfield.endEditing(true)
        
    }
    
    
    
    //TODO: Declare configureTableView here:
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
        
    }
    
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
            
        }
    }
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
        
    }
    

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        
        //TODO: Send the message to Firebase and save it in our database
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        //let messageDB = Database.database().reference().child("Messages")
        
        let messageDict : Document = [
                            "Sender": Auth.auth().currentUser?.email ?? "test@t.com",
                            "MessageBody": messageTextfield.text!]
        
        //let myDb = Database.database().reference()
        print("get db info...")
        do {
            print("Init DB ...")
            let client = try MongoClient(DB_URL)
            let db = client.db(DB_NAME)
            let messages = db.collection(DB_COLLECTION)
            let result = try messages.insertOne(messageDict)
            
            //let collection = try db.createCollection("myCollection")
            //let doc: Document = ["_id": 100, "a": 1, "b": 2, "c": 3]
            
            print(result?.insertedId ?? "") // prints `100`
            
            print("Message saved!")
            
            let message = Message()
            message.sender = Auth.auth().currentUser?.email as! String
            message.messageBody = messageTextfield.text!
            
            self.messageArray.append(message)
            
            self.messageTextfield.isEnabled = true
            self.sendButton.isEnabled = true
            self.messageTextfield.text = ""
            self.configureTableView()
            self.messageTableView.reloadData()
            
        } catch {
            print("Failed to initialize MongoDB  iOS SDK: \(error.localizedDescription)")
        }
        
        //print(myDb.key)
        
//        messageDB.childByAutoId().setValue(messageDict){
//            (error, reference) in
//
//            if error != nil {
//                print("Error for sending message...")
//                print(error!)
//            } else {
//                print("Message saved!")
//
//                self.messageTextfield.isEnabled = true
//                self.sendButton.isEnabled = true
//                self.messageTextfield.text = ""
//            }
//
//        }
        //retrieveMessages()
        
    }
    
    //TODO: Create the retrieveMessages method here:
    
    func retrieveMessages() {
    
        
        do {
            print("Retrieve DB ...")
            let client = try MongoClient(DB_URL)
            let db = client.db(DB_NAME)
            let messages = db.collection(DB_COLLECTION)
//            let query: Document = ["Sender": (Auth.auth().currentUser?.email)!]
//            let documents = try messages.find(query)
            let documents = try messages.find()
            for d in documents {
                let message = Message()
                message.sender = d.Sender as! String
                message.messageBody = d.MessageBody as! String
                
                self.messageArray.append(message)
                self.configureTableView()
                self.messageTableView.reloadData()
            }

        } catch {
            print("db error...")
        }
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print(error)
        }
        
        
        
    }
    
}


