//
//  NoteViewController.swift
//  Notes
//
//  Created by Sanjeev Garg on 24/04/20.
//  Copyright © 2020 Karan. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {
    var note: Note!
    
    @IBOutlet var textView: UITextView!
    
    @IBAction func deleteButtonClick() {
        NoteManager.main.delete(note: note)
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = note.content
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        note.content = textView.text
        NoteManager.main.save(note: note)
    }
}
