//
//  ViewController.swift
//  7SwiftyWords
//
//  Created by Oleg Plugaru on 01.10.2023.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var cluesLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var currentAnswer: UITextField!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var letterButtons = [UIButton]()
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var level = 1
    
    func loadLevel() {
        var clueString = ""
        var solutionstring = ""
        var letterBits = [String]()

        if let levelFilePath = Bundle.main.path(forResource: "level\(level)", ofType: "txt") {
            if let levelContents = try? String(contentsOfFile: levelFilePath) {

                var lines = levelContents.components(separatedBy: "\n")

                for (index, line) in lines.enumerated() {
                    print(line, "====")
                    let parts = line.components(separatedBy: ":")
                    
                    // Check if there are at least two parts (answer and clue)
                    if parts.count >= 2 {
                        let answer = parts[0]
                        print(answer)
                        let clue = parts[1]
                        print(clue)
                        clueString += "\(index + 1). \(clue)\n"

                        let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                        solutions.append(solutionWord)

                        solutionstring += "\(solutionWord.count) letters \n"

                        let bits = answer.components(separatedBy: "|")
                        letterBits += bits
                    } else {
                        // Handle the case where a line doesn't have enough parts
                        print("Invalid line format at line \(index + 1): \(line)")
                    }
                }
            }
        }

        cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
        answersLabel.text = solutionstring.trimmingCharacters(in: .whitespacesAndNewlines)

        letterBits.shuffle()
        letterButtons.shuffle()

        if letterBits.count == letterButtons.count {
            for i in 0 ..< letterBits.count {
                letterButtons[i].setTitle(letterBits[i], for: .normal)
            }
        }
    }
    
    @objc func letterTapped(_ btn: UIButton) {
        currentAnswer.text = currentAnswer.text! + btn.titleLabel!.text!
        activatedButtons.append(btn)
        btn.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        for subview in view.subviews {
            if subview.tag == 1001 {
                let btn = subview as! UIButton
                letterButtons.append(btn)
                
                btn.addTarget(self, action: #selector(letterTapped(_:)), for: .touchUpInside)
            }
        }
        
        loadLevel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func submitTapped(_ sender: Any) {
        if let solutionPosition = solutions.firstIndex(of: currentAnswer.text ?? "") {

            activatedButtons.removeAll()
            
            var splitClues = answersLabel.text!.components(separatedBy: "\n")
            splitClues[solutionPosition] = currentAnswer.text!
            answersLabel.text = splitClues.joined(separator: "\n")
            
            currentAnswer.text = ""
            score += 1
            
            if score % 7 == 0 {
                let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Let's go", style: .default, handler: levelUP))
                present(ac, animated: true)
            }
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    func levelUP(action: UIAlertAction) {
        level += 1
        loadLevel()
        
        for btn in letterButtons {
            btn.isHidden = false
        }
    }
    
    @IBAction func clearTapped(_ sender: Any) {
        currentAnswer.text = ""
        
        for btn in activatedButtons {
            btn.isHidden = false
        }
        
        activatedButtons.removeAll()
    }
}

