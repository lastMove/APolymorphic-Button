# Polymorphic-UIButton
A rectangular UIButton that transform itself into a circle (animated), with a built-in Activity indicator. Written entirely in Swift.

[![A short youtube Demo of the component](http://share.gifyoutube.com/mG5W3w.gif
)](https://www.youtube.com/watch?v=Gxfdfn0uioA)


## Table Of contents 
- [Try it](#try-it)
- [Installation](#installation)
- [Features](#features)
- [Requirements](#requirements)
- [How to use](#how-to-use)
- [How it works](#how-it-works)
- [Misc](#misc)
- [Needs Help](#needs-help)


## Try It 
Download/Clone the project. 
Open it with Xcode.
Go in the Main.Storyboard File Select a Button.
Now you can play/custom it with the attributes Inspector. ![Image](https://dl-web.dropbox.com/get/Captures%20d'écran/Capture%20d'écran%202015-05-23%2021.52.16.png?_subject_uid=85982894&w=AABrYwm8quOp7OYwD6aUGYUhtDRZEBxmYr8odXeOUe1EPg)
Then Just Launch It (On simulator Or Device).

## Installation 
1. Drop the `LMPolymorphicButton.swift` into your project
2. There is no step Two.

## Features
- Highly and easily customizable
- Built with and for Autolayout
- Made with love

## Requirements
- Needs AutoLayout.

## How to use 
I will present here a simple usage case From Storyboard/Inteface builder. there is a lot of way to use this component. 
1 Create a UIView
2 Inside that UIView Put a UIButton with these constraints:
- Same Width (**priority 750**)
- Same Height (**priority 750**)
- Center Vertically
- Center Horizontally
3 Change the Class of that UIButton to LMPolymorphicButton In the identity Inspector

That's It.

Now from the code you can just call the startActivity Method:

`myAwesomeButton.startActivity()`

`myAwesomeButton.stopActivity()`

## How it works

LMPolymorphicButton Uses Autolayout's.

There are two animations, the CornerRadius Animation (To transform it into a Circle) and the AspectRatio Constraint’s Animation (to set the width equal to the height, circle/square).
LMPolymorphic add programttically a constraints to Itself: AspectRatio 1:1.
When I Need to collapse It I change the priority Of this constraint to 800(this value must be greater than the « Same Width » and « Same Height » priority. And when I need to expand it I change the priority from 800 to 200.
I Just Animate this priority Change.

The CornerRadius Animation is a simple CABasicAnimation.

So LMPOlymorphicButton Requires AutoLayout To works.

Fully Customizable From Storyboard.

## Misc
Pull requests are welcome
Just Open an Issue Or Make A pull Request to add It here.

## Needs Help?
Just open an Issue.
