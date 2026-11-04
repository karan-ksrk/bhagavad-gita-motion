package io.github.karan_ksrk.moksharan

import android.app.Activity
import android.os.StatFs
import com.google.android.gms.tasks.Task
import com.google.android.play.core.assetpacks.AssetPackException
import com.google.android.play.core.assetpacks.AssetPackManager
import com.google.android.play.core.assetpacks.AssetPackManagerFactory
import com.google.android.play.core.assetpacks.AssetPackState
import com.google.android.play.core.assetpacks.AssetPackStateUpdateListener
import com.google.android.play.core.assetpacks.AssetPackStates
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Play Asset Delivery bridge for on-demand chapter media packs (D-139).
 *
 * Method channel `moksharan/asset_packs`: getPackStates, fetch, cancel,
 * remove, showConfirmationDialog, availableBytes. Failures are returned
 * as errors whose code is Play's AssetPackErrorCode.
 *
 * Event channel `moksharan/asset_packs/events`: one state map per update
 * while any pack is being fetched.
 */
class AssetPackChannel(
    private val activity: Activity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val manager: AssetPackManager =
        AssetPackManagerFactory.getInstance(activity.applicationContext)
    private var sink: EventChannel.EventSink? = null

    private val listener = AssetPackStateUpdateListener { state ->
        sink?.success(stateMap(state))
    }

    init {
        MethodChannel(messenger, METHOD_CHANNEL).setMethodCallHandler(this)
        EventChannel(messenger, EVENT_CHANNEL).setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPackStates" -> {
                val packs = call.argument<List<String>>("packs").orEmpty()
                manager.getPackStates(packs).reply(result) { states ->
                    statesMap(states)
                }
            }
            "fetch" -> {
                val pack = call.argument<String>("pack")!!
                manager.fetch(listOf(pack)).reply(result) { null }
            }
            "cancel" -> {
                val pack = call.argument<String>("pack")!!
                manager.cancel(listOf(pack))
                result.success(null)
            }
            "remove" -> {
                val pack = call.argument<String>("pack")!!
                manager.removePack(pack).reply(result) { null }
            }
            "showConfirmationDialog" -> {
                @Suppress("DEPRECATION")
                manager.showConfirmationDialog(activity).reply(result) { code ->
                    code == Activity.RESULT_OK
                }
            }
            "availableBytes" ->
                result.success(StatFs(activity.filesDir.path).availableBytes)
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        sink = events
        manager.registerListener(listener)
    }

    override fun onCancel(arguments: Any?) {
        manager.unregisterListener(listener)
        sink = null
    }

    fun dispose() {
        manager.unregisterListener(listener)
        sink = null
    }

    private fun statesMap(states: AssetPackStates): Map<String, Any?> =
        states.packStates().mapValues { (_, state) -> stateMap(state) }

    private fun stateMap(state: AssetPackState): Map<String, Any?> {
        val location = manager.getPackLocation(state.name())
        val assetsPath = location?.assetsPath()
        return mapOf(
            "name" to state.name(),
            "status" to state.status(),
            "error" to state.errorCode(),
            "bytesDownloaded" to state.bytesDownloaded(),
            "totalBytes" to state.totalBytesToDownload(),
            "assetsPath" to assetsPath,
            "installedBytes" to assetsPath?.let { dirSize(File(it)) },
        )
    }

    private fun dirSize(dir: File): Long =
        dir.walkTopDown().filter { it.isFile }.sumOf { it.length() }

    private fun <T> Task<T>.reply(
        result: MethodChannel.Result,
        transform: (T) -> Any?,
    ) {
        addOnSuccessListener { value -> result.success(transform(value)) }
        addOnFailureListener { e ->
            val code = (e as? AssetPackException)?.errorCode ?: INTERNAL_ERROR
            result.error(code.toString(), e.message, null)
        }
    }

    companion object {
        const val METHOD_CHANNEL = "moksharan/asset_packs"
        const val EVENT_CHANNEL = "moksharan/asset_packs/events"

        /** AssetPackErrorCode.INTERNAL_ERROR. */
        private const val INTERNAL_ERROR = -100
    }
}
