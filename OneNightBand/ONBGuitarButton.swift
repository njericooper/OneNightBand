//
//  ONBGuitarButton.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 11/3/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import UIKit


class ONBGuitarButton: UIImageView, UIGestureRecognizerDelegate {
    var lane = 0
    var sessionName: String?
    var session: Session?
    var sessionViews: Int?
    var isDisplayed: Bool?
    var tap: NSObject?
    var _yPosition: CGFloat = 0.0
    var _slope = CGFloat()
    var _baseX: CGFloat = 0.0
    
    var sessionFeedKey: String?
    
    let kStartY = 200
    let kMaxY = 12.5
    
    func initWithLane(lane: Int){
        self.lane = lane
        //print(lane)
        self.setIsDiplayedButton(isDisplayedButton: false)
        self.tintColor = UIColor.red
        self.image = UIImage(named: "GuitarPin_Red.png")
        switch (self.lane) {
        case 0:
            if UIScreen.main.bounds.width == 320{
                _baseX = 109
            }

            if UIScreen.main.bounds.width == 375{
                _baseX = 157
            }
            if UIScreen.main.bounds.width == 414{
                _baseX = 180
            }
            _slope = -0.85
            break;
        case 1:
            if UIScreen.main.bounds.width == 320{
                _baseX = 124
            }

            if UIScreen.main.bounds.width == 375{
                _baseX = 167
            }
            if UIScreen.main.bounds.width == 414{
                _baseX = 193
            }
            _slope = -0.53
            break;
        case 2:
            if UIScreen.main.bounds.width == 320{
                _baseX = 147
            }

            if UIScreen.main.bounds.width == 375{
                _baseX = 180
            }
            if UIScreen.main.bounds.width == 414{
                _baseX = 200
            }

            _slope = -0.2
            break;
        case 3:
            if UIScreen.main.bounds.width == 320{
                _baseX = 167
            }

            if UIScreen.main.bounds.width == 375{
                _baseX = 194
            }
            if UIScreen.main.bounds.width == 414{
                _baseX = 210
            }
            _slope = 0.14
            break;
        case 4:
            if UIScreen.main.bounds.width == 320{
                _baseX = 192
            }

            if UIScreen.main.bounds.width == 375{
                _baseX = 210
            }
            if UIScreen.main.bounds.width == 414{
                _baseX = 220
            }
            _slope = 0.47
            break;
        case 5:
            if UIScreen.main.bounds.width == 320{
                _baseX = 207
            }

            if UIScreen.main.bounds.width == 375{
                _baseX = 220
            }
            if UIScreen.main.bounds.width == 414{
                _baseX = 230
            }
            _slope = 0.83
            break
        default:
            break
        }

        
    }
    func setYPosition(yPosition: CGFloat){
        var tempPosition = yPosition
        _yPosition = yPosition
        if (tempPosition < 1) {
            tempPosition = 1
            self.alpha = 0
            //_yPosition = yPosition //might be line thats fucking shit up
            //return;
        }
        let size = powf(Float(tempPosition), 1.5) + 10
        //print(size)
        self.frame = CGRect(x: 0, y: 0, width: CGFloat(size), height: CGFloat(size))
        //self.center = CGPointMake(yPosition * 5.0 * _slope + _baseX, yPosition * 5.0 + kStartY);
        self.center = CGPoint(x: CGFloat(powf(Float(tempPosition), 2)) * _slope + _baseX,y: CGFloat(powf(Float(tempPosition), 2)) + CGFloat(kStartY))
        
        //Intro fade
        if (tempPosition < 8){
        self.alpha = min(1, (tempPosition - 1) * 0.2)
        }
        if (tempPosition > 10){ //Trailing Fade
        self.alpha = min(1, max(0, 1 - (tempPosition - CGFloat(kMaxY)) * 0.5))
        }
        
    }
    
    func setIsDiplayedButton(isDisplayedButton: Bool)
    {
        if (isDisplayedButton == self.isDisplayed){
            return
        }
        if (isDisplayedButton){
            self.image = UIImage(named:"GuitarPin_Green.png")
        }
        else{
            self.image = UIImage(named:"GuitarPin_Red.png")
        }
        self.isDisplayed = isDisplayedButton
        
    }

    
    func offsetYPosition(offset: CGFloat){
        setYPosition(yPosition: _yPosition + offset)
    }
    

   

}
