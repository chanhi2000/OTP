//
//  ContentView.swift
//  OTP
//
//  Created by chlee on 2022/03/24.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    
    var body: some View {
        
        VStack {
            if status {
                Home()
            } else {
                NavigationView {
                    FirstPage()
                }
            }
        }.onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("statusChange"), object: nil, queue: .main) { _ in
                
                let status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
                self.status = status
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct FirstPage: View {
    @State var ccode = ""
    @State var no = ""
    @State var show = false
    @State var ID = ""
    @State var msg = ""
    @State var alert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image("pic")
            Text("Verify Your Number").font(.largeTitle).fontWeight(.heavy)
            Text("Please Enter Your Number To Verify Your Account")
                .font(.body)
                .foregroundColor(.gray)
                .padding(.top, 12)
            
            HStack {
                TextField("+1", text: $ccode)
                    .keyboardType(.numberPad)
                    .frame(width: 45)
                    .padding()
                    .background(Color("Color"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                TextField("Number", text: $no)
                    .padding()
                    .background(Color("Color"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
            }.padding(.top, 15)
            
            NavigationLink(destination: SecondPage(ID: $ID, show: $show), isActive: $show) {
                Button(action: {
                    // Firebase Auth: Phone Number Verification
                    PhoneAuthProvider.provider().verifyPhoneNumber("+"+self.ccode+self.no, uiDelegate: nil, completion: { (ID, err) in
                        
                        if err != nil {
                            self.msg = (err?.localizedDescription)!
                            self.alert.toggle()
                            return
                        }
                        self.ID = ID!
                        self.show.toggle()
                    })
                }, label: {
                    Text("Send").frame(width: UIScreen.main.bounds.width - 30, height: 50)
                        .foregroundColor(.white)
                        .background(Color.orange)
                        .cornerRadius(10)
                })
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }.padding()
        .alert(isPresented: $alert) {
            Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("Ok")))
        }
    }
}


struct SecondPage: View {
    @State var code = ""
    @Binding var ID: String
    @Binding var show: Bool
    
    @State var msg = ""
    @State var alert = false
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            GeometryReader { _ in
                VStack(spacing: 20) {
                    Image("pic")
                    Text("Verification Code").font(.largeTitle).fontWeight(.heavy)
                    Text("Please Enter The Verification Code")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.top, 12)
                    
                    TextField("Code", text: $code)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color("Color"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.top, 15)
                    
                
                    Button(action: {
                        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.ID, verificationCode: self.code)
                        
                        Auth.auth().signIn(with: credential) { (res, err) in
                            if (err != nil) {
                                self.msg = (err?.localizedDescription)!
                                self.alert.toggle()
                                return
                            }
                            
                            UserDefaults.standard.set(true, forKey: "status")
                            
                            NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                        }
                    }, label: {
                        Text("Verify").frame(width: UIScreen.main.bounds.width - 30, height: 50)
                    })
                    .foregroundColor(.white)
                    .background(Color.orange)
                    .cornerRadius(10)
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
                }
            }
            
            Button(action: {
                self.show.toggle()
            }, label: {
                Image(systemName: "chevron.left").font(.title)
            }).foregroundColor(.orange)
        }.padding()
        .alert(isPresented: $alert) {
            Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("Ok")))
        }
    }
}


struct Home: View {
    var body : some View {
        VStack {
            Text("Home")
            
            Button(action: {
                try! Auth.auth().signOut()
                
                UserDefaults.standard.set(false, forKey: "status")
                
                NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                
                
            }, label: {
                Text("Logout")
            })
        }
    }
}
