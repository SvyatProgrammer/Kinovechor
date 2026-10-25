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
    @Published var isLoading : Bool = true
    
    private var ref = Database.database().reference()
    
    init() {
        checkActiveRoom()
    }
    
    // MARK: Check active room
    func checkActiveRoom(completion: (() -> Void)? = nil) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.isLoading = false
                completion?()
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        ref.child("rooms").getData() { [weak self] error, snapshot in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                defer {
                    self.isLoading = false
                    completion?()
                }
                
                guard let roomsDict = snapshot?.value as? [String: [String: Any]] else { return }
                
                for (roomId, roomData) in roomsDict {
                    if let members = roomData["members"] as? [String: Bool], members[currentUserId] == true {
                        DispatchQueue.main.async {
                            self.currentRoomId = roomId
                            self.isInRoom = true
                        }
                    }
                }
            }
        }
    }
    
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
        guard let currentUserId = Auth.auth().currentUser?.uid, let roomId = currentRoomId else {
            resetLocalState()
            return
        }
        
        let roomRef = ref.child("rooms").child(roomId)
        
        roomRef.getData { [weak self] _, snapshot in
            guard let self = self, let roomDict = snapshot?.value as? [String: Any] else {
                DispatchQueue.main.async { self?.resetLocalState() }
                return
            }
            
            let creatorId = roomDict["creatorId"] as? String
            var members = roomDict["members"] as? [String: Bool] ?? [:]
            
            members.removeValue(forKey: currentUserId)
            
            DispatchQueue.main.async {
                if members.isEmpty {
                    roomRef.removeValue()
                    self.resetLocalState()
                } else {
                    if creatorId == currentUserId, let newCreatorId = members.keys.first {
                        roomRef.updateChildValues([
                            "creatorId": newCreatorId,
                            "members": members
                        ]) { _, _ in
                            self.resetLocalState()
                        }
                    } else {
                        roomRef.child("members").child(currentUserId).removeValue { _, _ in
                            self.resetLocalState()
                        }
                    }
                }
            }
        }
    }
    
    func resetLocalState() {
        self.currentRoomId = nil
        self.isInRoom = false
    }
    
}
