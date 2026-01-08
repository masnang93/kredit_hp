package com.example.customer_app

import android.app.Activity
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "device_admin"
    private val DEVICE_ADMIN_REQUEST_CODE = 1001

    private lateinit var devicePolicyManager: DevicePolicyManager
    private lateinit var deviceAdminComponent: ComponentName
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        deviceAdminComponent = ComponentName(this, DeviceAdmin::class.java)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestDeviceAdmin" -> {
                    requestDeviceAdmin(result)
                }
                "isDeviceAdminEnabled" -> {
                    val isEnabled = devicePolicyManager.isAdminActive(deviceAdminComponent)
                    result.success(isEnabled)
                }
                "lockDevice" -> {
                    if (devicePolicyManager.isAdminActive(deviceAdminComponent)) {
                        devicePolicyManager.lockNow()
                        result.success(true)
                    } else {
                        result.error("NOT_ENABLED", "Device admin not enabled", null)
                    }
                }
                "enableKioskMode" -> {
                    if (devicePolicyManager.isAdminActive(deviceAdminComponent)) {
                        try {
                            startLockTask()
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("KIOSK_ERROR", "Failed to enable kiosk mode: ${e.message}", null)
                        }
                    } else {
                        result.error("NOT_ENABLED", "Device admin not enabled", null)
                    }
                }
                "disableKioskMode" -> {
                    try {
                        stopLockTask()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("KIOSK_ERROR", "Failed to disable kiosk mode: ${e.message}", null)
                    }
                }
                "isKioskModeActive" -> {
                    try {
                        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
                        val lockTaskMode = activityManager.lockTaskModeState
                        val isActive = lockTaskMode != android.app.ActivityManager.LOCK_TASK_MODE_NONE
                        result.success(isActive)
                    } catch (e: Exception) {
                        result.error("KIOSK_ERROR", "Failed to check kiosk mode: ${e.message}", null)
                    }
                }
                "removeDeviceAdmin" -> {
                    if (devicePolicyManager.isAdminActive(deviceAdminComponent)) {
                        devicePolicyManager.removeActiveAdmin(deviceAdminComponent)
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun requestDeviceAdmin(result: MethodChannel.Result) {
        if (devicePolicyManager.isAdminActive(deviceAdminComponent)) {
            result.success(true)
            return
        }

        pendingResult = result
        val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
        intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, deviceAdminComponent)
        intent.putExtra(
            DevicePolicyManager.EXTRA_ADD_EXPLANATION,
            "This app requires device admin permission to lock the device for credit payment security."
        )
        startActivityForResult(intent, DEVICE_ADMIN_REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == DEVICE_ADMIN_REQUEST_CODE) {
            val isEnabled = resultCode == Activity.RESULT_OK
            pendingResult?.success(isEnabled)
            pendingResult = null
        }
    }
}
