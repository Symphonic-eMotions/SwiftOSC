//
//  OSCNetwork.swift
//  SwiftOSC
//
//  Created by Devin Roth on 2018-12-01.
//  Copyright © 2018 Devin Roth. All rights reserved.
//

import Foundation
import Network

protocol OSCNetwork {
    
    var delegate: OSCDelegate? { get set }
    
    var connection: NWConnection? { get set }
    var queue: DispatchQueue { get set }
    
    func decodePacket(_ data: Data)
    func decodeBundle(_ data: Data)->OSCBundle?
    func decodeMessage(_ data: Data)->OSCMessage?
    func sendToDelegate(_ element: OSCElement)
    
    func send(_ element: OSCElement)
}

extension OSCNetwork {
    
    func decodePacket(_ data: Data){
        
        DispatchQueue.main.async {
            self.delegate?.didReceive(data)
        }
        
        //
        if data[0] == 0x2f { // check if first character is "/"
            if let message = decodeMessage(data){
                self.sendToDelegate(message)
            } else {
                print("invalid message")
            }
        } else if data.count > 8 {//make sure we have at least 8 bytes before checking if a bundle.
            if "#bundle\0".toData() == data.subdata(in: Range(0...7)){//matches string #bundle
                if let bundle = decodeBundle(data){
                    self.sendToDelegate(bundle)
                } else {
                    print("invalid bundle")
                }
            }
        } else {
            print("invalid packet")
        }
    }
    
    func decodeBundle(_ data: Data)->OSCBundle? {
        
        //extract timetag
        let bundle = OSCBundle(Timetag(data.subdata(in: 8..<16)))
        
        var bundleData = data.subdata(in: 16..<data.count)
        
        while bundleData.count > 0 {
            let length = Int(bundleData.subdata(in: Range(0...3)).toInt32())
            let nextData = bundleData.subdata(in: 4..<length+4)
            bundleData = bundleData.subdata(in:length+4..<bundleData.count)
            if "#bundle\0".toData() == nextData.subdata(in: Range(0...7)){//matches string #bundle
                if let newbundle = self.decodeBundle(nextData){
                    bundle.add(newbundle)
                } else {
                    return nil
                }
            } else {
                
                if let message = self.decodeMessage(nextData) {
                    bundle.add(message)
                } else {
                    return nil
                }
            }
        }
        return bundle
    }
    
    func decodeMessage(_ data: Data)->OSCMessage?{
        var messageData = data
        var message: OSCMessage
        
        //extract address and check if valid
        if let addressEnd = messageData.index(of: 0x00){
        
            let addressString = messageData.subdata(in: 0..<addressEnd).toString()
            var address = OSCAddressPattern()
            if address.valid(addressString) {
                address.string = addressString
                message = OSCMessage(address)
                
                //extract types
                messageData = messageData.subdata(in: (addressEnd/4+1)*4..<messageData.count)
                let typeEnd = messageData.index(of: 0x00)!
                let type = messageData.subdata(in: 1..<typeEnd).toString()
                
                messageData = messageData.subdata(in: (typeEnd/4+1)*4..<messageData.count)
                
                for char in type {
                    switch char {
                    case "i"://int
                        message.add(Int(messageData.subdata(in: Range(0...3))))
                        messageData = messageData.subdata(in: 4..<messageData.count)
                    case "f"://float
                        message.add(Float(messageData.subdata(in: Range(0...3))))
                        messageData = messageData.subdata(in: 4..<messageData.count)
                    case "s"://string
                        let stringEnd = messageData.index(of: 0x00)!
                        message.add(String(messageData.subdata(in: 0..<stringEnd)))
                        messageData = messageData.subdata(in: (stringEnd/4+1)*4..<messageData.count)
                    case "b": //blob
                        var length = Int(messageData.subdata(in: Range(0...3)).toInt32())
                        messageData = messageData.subdata(in: 4..<messageData.count)
                        message.add(Blob(messageData.subdata(in: 0..<length)))
                        while length%4 != 0 {//remove null ending
                            length += 1
                        }
                        messageData = messageData.subdata(in: length..<messageData.count)
                        
                    case "T"://true
                        message.add(true)
                    case "F"://false
                        message.add(false)
                    case "N"://null
                        message.add()
                    case "I"://impulse
                        message.add(Impulse())
                    case "t"://timetag
                        message.add(Timetag(messageData.subdata(in: Range(0...7))))
                        messageData = messageData.subdata(in: 8..<messageData.count)
                    default:
                        print("unknown osc type")
                        return nil
                    }
                }
            } else {
                return nil
            }
            return message
        } else {
            return nil
        }
    }
    func sendToDelegate(_ element: OSCElement){
        DispatchQueue.main.async {
            if let message = element as? OSCMessage {
                self.delegate?.didReceive(message)
            }
            if let bundle = element as? OSCBundle {
                self.delegate?.didReceive(bundle)
                for element in bundle.elements {
                    self.sendToDelegate(element)
                }
            }
        }
    }
    
    // receive
    func receive() {
        connection?.receiveMessage { (content, context, isCompleted, error) in
            if let data = content {
                self.decodePacket(data)
            }

            if error == nil {
                self.receive()
            }
        }
    }
}
