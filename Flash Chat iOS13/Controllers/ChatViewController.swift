//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var messageTextfield: UITextField!

  let database = Firestore.firestore()

  var messages: [Message] = []

  override func viewDidLoad() {
    tableView.dataSource = self
    title = K.appName
    navigationItem.hidesBackButton = true

    super.viewDidLoad()
    loadMessages()
    tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
  }

  func loadMessages() {
    database.collection(K.FStore.collectionName)
      .order(by: K.FStore.dateField)
      .addSnapshotListener { (querySnapshot, err) in

        if let err = err {
          print("Error getting documents: \(err)")
        } else {
          if let docs = querySnapshot?.documents {
            self.messages = []
            for doc in docs {
              let data = doc.data()
              let body = data[K.FStore.bodyField] as? String
              let sender = data[K.FStore.senderField] as? String
              let message = Message(sender: sender!, body: body!)

              self.messages.append(message)
            }

            DispatchQueue.main.async {
              let indexPath = IndexPath(row: self.messages.count - 1, section: 0)

              self.tableView.reloadData()
              self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
          }
        }
    }
  }

  @IBAction func sendPressed(_ sender: UIButton) {
    if let messageBody = messageTextfield.text, let sender = Auth.auth().currentUser?.email {
      database.collection(K.FStore.collectionName).addDocument(data: [
        K.FStore.senderField: sender,
        K.FStore.bodyField: messageBody,
        K.FStore.dateField: Date().timeIntervalSince1970
      ]) { err in
        if let err = err {
          print("something bad happened", err)
        } else {
          DispatchQueue.main.async {
            self.messageTextfield.text = ""
          }
        }
      }
    }

  }

  @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
    let firebaseAuth = Auth.auth()

    do {
      try firebaseAuth.signOut()
      navigationController?.popToRootViewController(animated: true)
    } catch let signOutError as NSError {
      print("Error signing out: %@", signOutError)
    }
  }
}

extension ChatViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let message = messages[indexPath.row]
    let sender = message.sender
    let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as? MessageCell

    cell?.label.text = message.body

    if sender == Auth.auth().currentUser?.email {
      cell?.leftImageView.isHidden = true
      cell?.rightImageView.isHidden = false
      cell?.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
      cell?.label.textColor = UIColor(named: K.BrandColors.purple)
    } else {
      cell?.leftImageView.isHidden = false
      cell?.rightImageView.isHidden = true
      cell?.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
      cell?.label.textColor = UIColor(named: K.BrandColors.lightPurple)
    }

    return cell!
  }
}
