//
//  RoomManager.swift
//  Kinovechor
//
//  Created by Свят on 20.10.26.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseDatabase

class RoomManager : ObservableObject {
    @Published var isInRoom : Bool = false
    @Published var currentRoomId : String? = nil
    @Published var errorMessage : String? = nil
    
    private var ref = Database.database().reference()
    
    // MARK: Create room with password
    func createRoom(password : String, completion : @escaping (Bool) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Пользователь не автаризован"
            completion(false)
            return
        }
        
        let roomId = String(Int.random(in: 100000...999999))
        
        let roomData : [String : Any] = [
            "creatorId" : currentUserId,
            "password" : password,
            "createdAt" : Date().timeIntervalSince1970,
            "members" : [currentUserId : true]
        ]
        
        ref.child("rooms").child(roomId).setValue(roomData) { [weak self] error, _ in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                
                self?.currentRoomId = roomId
                self?.isInRoom = true
                self?.errorMessage = nil
                completion(true)
            }
        }
    }
    
    // MARK: Join room by ID and password
    func joinRoom(roomId : String, password : String, completion : @escaping (Bool) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Пользователь не автаризован"
            completion(false)
            return
        }
        
        let cleanRoomId = roomId.trimmingCharacters(in: .whitespacesAndNewlines)
        
        ref.child("rooms").child(cleanRoomId).getData { [weak self] error, snapshot in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                
                guard snapshot?.exists() == true, let roomDict = snapshot?.value as? [String : Any], let dbPassword = roomDict["password"] as? String else {
                    self?.errorMessage = "Комната с таким ID не найдена"
                    completion(false)
                    return
                }
                
                if dbPassword == password {
                    self?.ref.child("rooms").child(cleanRoomId).child("members").child(currentUserId).setValue(true)
                    self?.currentRoomId = cleanRoomId
                    self?.isInRoom = true
                    self?.errorMessage = nil
                    completion(true)
                } else {
                    self?.errorMessage = "Неверный пароль от комнаты"
                    completion(false)
                }
            }
        }
    }
    
    // MARK: Leaving from room
    func leaveRoom() {
        isInRoom = false
        currentRoomId = nil
    }
}
