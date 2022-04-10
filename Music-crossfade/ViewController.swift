//
//  ViewController.swift
//  Music-crossfade
//
//  Created by mac on 08.04.2022.
//

import UIKit
import AVFAudio
import Cephalopod

class ViewController: UIViewController, UINavigationControllerDelegate, UIDocumentPickerDelegate {
    
    private var audioModel = AudioModel()
    private var firstAudioPlayer: AVAudioPlayer!
    private var secondAudioPlayer: AVAudioPlayer!
    lazy private var cephalopod = Cephalopod(player: self.secondAudioPlayer)
    
    private lazy var firstDocumentPickerController = UIDocumentPickerViewController(
        forOpeningContentTypes: audioModel.types)
    private lazy var secondDocumentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: audioModel.types)
    
    //MARK: - @IBOutlets
    
    @IBOutlet weak var crossFadeSlider: UISlider!
    
    @IBOutlet weak var addSong1Button: UIButton!
    
    @IBOutlet weak var addSong2Button: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    
    //MARK: - @IBActions
    
    @IBAction func selectFirstFileTouched(_ sender: Any) {
        selectFirstFile()
    }
    
    @IBAction func selectSecondFileTouched(_ sender: Any) {
        selectSecondFile()
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        audioModel.crossFadeValue = Double(crossFadeSlider.value)
    }
    
    @IBAction func playTouched(_ sender: Any) {
        prepareForFirstAudio()
        prepareForSecondAudio()
        if firstAudioPlayer != nil && secondAudioPlayer != nil {
            startAudio()
        } else {
            alertInitialize(message: audioModel.alertMessage)
        }
    }
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        elementsCustomisation()
    }
    
    //MARK: - methods
    
    private func elementsCustomisation() {
        addSong1Button.layer.cornerRadius = 26
        addSong2Button.layer.cornerRadius = 26
        playButton.layer.cornerRadius = 26
    }
    
    private func selectFirstFile() {
        firstDocumentPickerController.delegate = self
        self.present(firstDocumentPickerController, animated: true, completion: nil)
    }
    
    private func selectSecondFile() {
        secondDocumentPickerController.delegate = self
        self.present(secondDocumentPickerController, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if controller == firstDocumentPickerController {
            guard let firstURL = urls.first else {
                return
            }
            audioModel.track1URL = firstURL
        } else {
            guard let secondURL = urls.first else {
                return
            }
            audioModel.track2URL = secondURL
        }
    }
    
    private func prepareForFirstAudio() {
        guard audioModel.track1URL == nil else {
            do {
                firstAudioPlayer = try AVAudioPlayer(contentsOf: audioModel.track1URL!)
                firstAudioPlayer.prepareToPlay()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            return
        }
    }
    
    private func prepareForSecondAudio() {
        guard audioModel.track2URL == nil else {
            do {
                secondAudioPlayer = try AVAudioPlayer(contentsOf: audioModel.track2URL!)
                secondAudioPlayer.prepareToPlay()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            return
        }
    }
    
    private func startAudio() {
        firstAudioPlayer.play()
        firstAudioPlayer.volume = AVAudioSession.sharedInstance().outputVolume
        DispatchQueue.main.asyncAfter(deadline: .now() + (firstAudioPlayer.duration - audioModel.crossFadeValue)) { [self] in
            firstAudioPlayer.setVolume(0.0, fadeDuration: audioModel.crossFadeValue)
            secondAudioPlayer.play()
            secondAudioPlayer.volume = 0
            cephalopod.fadeIn(duration: audioModel.crossFadeValue)
            DispatchQueue.main.asyncAfter(deadline: .now() + (secondAudioPlayer.duration)) {
                startAudio()
            }
        }
    }
    
    private func alertInitialize(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Default action"), style: .default, handler: { _ in
        NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
}


