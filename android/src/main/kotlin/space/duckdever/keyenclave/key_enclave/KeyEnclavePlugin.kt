package space.duckdever.keyenclave.key_enclave

import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyPermanentlyInvalidatedException
import android.security.keystore.KeyProperties
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import android.util.Base64
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.PrivateKey
import java.security.Signature
import java.security.spec.ECGenParameterSpec

/** KeyEnclavePlugin */
public class KeyEnclavePlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "key_enclave")
    channel.setMethodCallHandler(this);
  }

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "key_enclave")
      channel.setMethodCallHandler(KeyEnclavePlugin())
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "generateKeyPair") {
        val tag = call.argument<String>("TAG")!!
        try {
            val public = this.generateKey(tag)
            result.success(public)
        }
        catch (e:java.lang.Exception) {
            result.error("400", "generate key failed "+e.message, null)
            return
        }
    } else if(call.method == "sign"){
        val tag = call.argument<String>("TAG")!!
        val message = call.argument<String>("MESSAGE")!!
        try {
           var signature = this.signData(tag,message)
            result.success(signature)
        } catch(e :java.lang.Exception) {
            result.error("400", "sign failed "+e.message, null)
        }

    } else if (call.method == "deleteKey") {
        val tag = call.argument<String>("TAG")!!
        try {
            this.deleteKey(tag)
            result.success("success")
        } catch(e :java.lang.Exception) {
            result.error("400", "sign failed "+e.message, null)
        }

    } else {
        result.notImplemented();
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }


  val ANDROID_KEYSTORE = "AndroidKeyStore"

    private fun signData(tag: String,message: String): String? {
        try {
            //We get the Keystore instance
            val keyStore: KeyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply {
                load(null)
            }

            val privateKey: PrivateKey = keyStore.getKey(tag, null) as PrivateKey

            val signature: ByteArray? = Signature.getInstance("SHA512withECDSA").run {
                initSign(privateKey)
                update(message.toByteArray())
                sign()
            }

            if (signature != null) {
                 return Base64.encodeToString(signature, Base64.DEFAULT);
            } else {
                throw Error("invalid signature")
            }

        } catch (e: KeyPermanentlyInvalidatedException) {
            throw e
        } catch (e: Exception) {
            throw RuntimeException(e)
        }
    }

    private fun deleteKey(tag: String) {
        val keyStore: KeyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply {
            load(null)
        }
        keyStore.deleteEntry(tag)
    }

    private fun generateKey(tag: String): String? {
        val keyPairGenerator: KeyPairGenerator = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, ANDROID_KEYSTORE)
        val parameterSpec: KeyGenParameterSpec =   KeyGenParameterSpec.Builder(tag,
                KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY).
        setDigests(KeyProperties.DIGEST_SHA512).
        setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1")).
        build()
        keyPairGenerator.initialize(parameterSpec)
         return Base64.encodeToString(keyPairGenerator.genKeyPair().public.encoded,Base64.DEFAULT)
        }

}
