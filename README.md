# Device-Agnostic Design Course Project I - 7f8b5639-5a37-4d43-80e1-ddd67f52e840

# Quiz App

This is a quiz app for the course Device Agnostic Design. It is created according to the specs of "Passing with merits".

The Application allows the user to view questions from different topics, and answer them. The user may also choose to answer questions from ANY topic, in which case the application chooses questions from the least answered topics. 

The statistics view can be accessed from the bar graph icon in the top right corner - if launched in debug mode, the "DEBUG" label might visually cover the button but you can still click it. 

**File Structure:** I didn't realise the project came with a template file structure, so I started my own project from scratch... there's quite a bit of repetition in the different screen files, and I definitely would've written cleaner code had I known about it. I'm writing this as I'm preparing to submit the project, so I'd honestly rather not go back and improve the structure. If it works, it works.

## Getting Started 

You can run the app with `flutter run` - for example: <br />
`CHROME_EXECUTABLE=/Applications/Chromium.app/Contents/MacOS/Chromium flutter run -d chrome`

If you have trouble running the application, please try the web version: https://emiliarepo.github.io/dad-quiz/

For the best experience run the application in a tall, mobile-shaped window. It will work in wide windows as well, but the UI definitely is mobile-optimized. 

## Tests 

Tests can be run with the command `flutter test`. <br />
Test coverage is at 88.3% - see https://i.imgur.com/uYfxhSz.png.

## Challenges and learning moments 

Going to just briefly reflect both of these at the same time: 
During the project I learned to write more complicated projects and apply different aspects I've learned during the course.
I faced some difficulties with running a native app (in fact still doesn't work on macOS, it can't connect to the internet), and the tests were hard to get running at first. In any case, I've learned a lot during this project & hope to be able to create better apps in the future.

## pubspec.yaml 

```
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.2
  flutter_riverpod: ^2.2.0
  go_router: ^6.0.1
  http: ^0.13.5
  riverpod: ^2.2.0
  shared_preferences: ^2.0.17

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^2.0.0
  nock: ^1.2.2
```
