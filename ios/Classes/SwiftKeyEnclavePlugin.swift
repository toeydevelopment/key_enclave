import Flutter
import UIKit

public class SwiftKeyEnclavePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "key_enclave", binaryMessenger: registrar.messenger())
        let instance = SwiftKeyEnclavePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        let args = call.arguments as! Dictionary<String,Any>
        let currentVersion = UIDevice.current.systemVersion
        
        if (call.method == "generateKeyPair") {
            let tag = args["TAG"] as! String
            
            do {
                let publicKey = try self.generateKeyPair(tag: tag)
                result(publicKey)
            } catch SecureError.VersionUnsupported {
                result(FlutterError.init(code: "generate failed", message: "unsupport ios \(currentVersion) support only 10.0 or above", details: nil))
            } catch SecureError.CopyPublicKey  {
                result(FlutterError.init(code: "generate failed", message: "cannot copy public key failed", details: nil))
            } catch SecureError.GenerateKeyPair {
                result(FlutterError.init(code: "generate failed", message: "something went wrong canno generate key pair", details: nil))
            } catch {
                result(FlutterError.init(code: "generate failed", message: "something went wrong canno generate key pair unknow error occured", details: nil))
            }
            
            
        } else if (call.method == "sign") {
               let tag = args["TAG"] as! String
               let message = args["MESSAGE"] as! String
            do {
               let signedMessage = try self.sign(tag: tag, message: message)
                result(signedMessage)
            } catch  {
                result(FlutterError.init(code: "sign failed", message: "something went wrong", details: nil))
            }
        
        } else if (call.method == "deleteKey") {
             let tag = args["TAG"] as! String
            do {
                try self.deleteKeyIfExist(tag: tag)
                reult("success")
            } catch  {
                result(FlutterError.init(code: "delete key failed", message: "something went wrong when try to delete", details: nil))
            }
        } else {
            result(FlutterError.init(code: "wrong method", message: "unknow method is calling", details: nil))
        }
        
    }
    
    
    enum SecureError: Error {
        case GenerateKeyPair
        case CopyPublicKey
        case MessageData
        case SignData
        case Delete
        case VersionUnsupported
    }
    
    
    func generateKeyPair(tag: String) throws -> String {
        if #available(iOS 9.0, *) {
            let access = SecAccessControlCreateWithFlags(
                kCFAllocatorDefault,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                [.privateKeyUsage],
                nil
                )!
            if #available(iOS 10.0, *) {
                let attributes: [String: Any] = [
                    kSecAttrKeyType as String:            kSecAttrKeyTypeECSECPrimeRandom,
                    kSecAttrKeySizeInBits as String:      256,
                    kSecAttrTokenID as String:            kSecAttrTokenIDSecureEnclave,
                    kSecPrivateKeyAttrs as String: [
                        kSecAttrIsPermanent as String:      true,
                        kSecAttrApplicationTag as String:    tag,
                        kSecAttrAccessControl as String:    access
                    ]
                ]
                
                var error: Unmanaged<CFError>?
                guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary,&error) else {
                    print("ERORR OCCURED GENERATE KEY FAILED")
                    throw SecureError.GenerateKeyPair
                }
                
                guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
                    print("ERROR Generate Public Key failed")
                    throw SecureError.CopyPublicKey
                }
                
                let publicKeyData = SecKeyCopyExternalRepresentation(publicKey,nil)! as Data
                
                return self.putHeaderIntoPublicKey(publicKey: publicKeyData)
            } else {
                throw SecureError.VersionUnsupported
            }
        } else {
            throw SecureError.VersionUnsupported
        }
    }
    
    func loadPrivateKey(tag: String) throws -> SecKey? {
        let tag = tag.data(using: String.Encoding.utf8)!
        if #available(iOS 10.0, *) {
            let query:[String:Any] = [
                kSecClass as String : kSecClassKey,
                kSecAttrType as String : kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrApplicationTag as String: tag,
                kSecReturnRef as String : true
            ]
            var item: CFTypeRef?
            
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            guard status == errSecSuccess else {
                print("retreive private key failed")
                return nil
            }
            
            return (item as! SecKey)
            
        } else {
            throw SecureError.VersionUnsupported
        }
    }
    
    
    func sign(tag: String,message: String) throws -> String {
        
        guard let messageData = message.data(using: String.Encoding.utf8) else {
            print("message dataencode failed")
            throw SecureError.MessageData
        }
        
        if #available(iOS 10.0, *) {
            do {
                guard let signData = SecKeyCreateSignature(try loadPrivateKey(tag: tag)!, SecKeyAlgorithm.ecdsaSignatureDigestX962SHA512, messageData as CFData, nil) else {
                    print ("sign data failed")
                    throw SecureError.SignData
                }
                
                let signedData = signData as Data
                
                return signedData.base64EncodedString()
            } catch  {
                throw SecureError.SignData
            }
            
        } else {
            throw SecureError.VersionUnsupported
        }
    }
    
    
    func deleteKeyIfExist(tag: String) throws {
        let tag = tag.data(using: String.Encoding.utf8)!
        if #available(iOS 10.0, *) {
            let query:[String:Any] = [
                kSecClass as String : kSecClassKey,
                kSecAttrType as String : kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrApplicationTag as String: tag,
                kSecReturnRef as String : true
            ]
          SecItemDelete(query as CFDictionary)
        } else {
            throw SecureError.VersionUnsupported
        }
        
    }
    
    
    func putHeaderIntoPublicKey(publicKey: Data) -> String{
        let data = NSData(bytes: [0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02, 0x01, 0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03, 0x42, 0x00] as [UInt8], length: 26)
        let result = data + publicKey
        return result.base64EncodedString()
    }
    
    
}
