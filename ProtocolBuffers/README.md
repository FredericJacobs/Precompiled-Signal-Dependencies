Protocol Buffers for Objective-C
================================

[![Build Status](https://travis-ci.org/alexeyxo/protobuf-objc.svg?branch=master)](https://travis-ci.org/alexeyxo/protobuf-objc) [![Version](http://img.shields.io/cocoapods/v/ProtocolBuffers.svg)](http://cocoapods.org/?q=ProtocolBuffers) [![Platform](http://img.shields.io/cocoapods/p/ProtocolBuffers.svg)](http://cocoapods.org/?q=ProtocolBuffers)

An implementation of Protocol Buffers in Objective C.

Protocol Buffers are a way of encoding structured data in an efficient yet extensible format. This project is based on an implementation of Protocol Buffers from Google. See the [Google protobuf project](https://developers.google.com/protocol-buffers/docs/overview) for more information.

This fork contains only ARC version of library.

How To Install Protobuf
-----------------------

1.`ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

2.`brew install automake`

3.`brew install libtool`

4.`brew instal protobuf`

5.`ln -s /usr/local/Cellar/protobuf/2.6.1/bin/protoc /usr/local/bin` (optional)

6.`git clone git@github.com:alexeyxo/protobuf-objc.git`

7.`./build.sh`

8.Add `/src/runtime/ProtocolBuffers.xcodeproj` in your project.

##Installing from CocoaPods

...

8.`cd <your .xcodeproj directory>`

9.`echo -e "platform :ios , 6.0 \nlink_with '<YourAppTarget>', '<YourAppTarget_Test>' \npod 'ProtocolBuffers', '1.9.6' " > Podfile`

10.`pod install`

Compile ".proto" files.
-----------------------

`protoc --plugin=/usr/local/bin/protoc-gen-objc person.proto --objc_out="./"`

Example
-------

### Web

Server-side requires Ruby(2.0+) and Sinatra gem.

To start `ruby sinatra.rb` in /Example/Web

if you need to recompile ruby proto models please install ruby_protobuf gem and make 'rprotoc person.proto'

### iOS Example

/Example/iOS/Proto.xcodeproj

Project contains protobuf example and small json comparison.

### Credits

Maintainer - Alexey Khokhlov

Booyah Inc. - Jon Parise

Google Protocol Buffers, Objective C - Cyrus Najmabadi - Sergey Martynov

Google Protocol Buffers - Kenton Varda, Sanjay Ghemawat, Jeff Dean, and others
