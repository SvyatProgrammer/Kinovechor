import Foundation
import FirebaseAuth
import Combine

class AuthManager: ObservableObject {
    @Published var user: User? = nil
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: Observeing when state use is changed
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isAuthenticated = (user != nil)
            }
        }
    }

    // MARK: Registration by email
    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                self?.errorMessage = nil
                completion(true)
            }
        }
    }

    // MARK: Authentication by email
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                self?.errorMessage = nil
                completion(true)
            }
        }
    }

    // MARK: SignOut from account
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            errorMessage = error.localizedDescription
        }
    }
}
