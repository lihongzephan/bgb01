package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import com.infitio.adharasocketio.AdharaSocketIoPlugin;
import io.flutter.plugins.camera.CameraPlugin;
import io.flutter.plugins.connectivity.ConnectivityPlugin;
import com.mr.flutter.plugin.filepicker.FilePickerPlugin;
import com.tundralabs.fluttertts.FlutterTtsPlugin;
import com.cloudwebrtc.webrtc.FlutterWebRTCPlugin;
import io.github.ponnamkarthik.toast.fluttertoast.FluttertoastPlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import com.baseflow.permissionhandler.PermissionHandlerPlugin;
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;
import bz.rxla.flutter.speechrecognition.SpeechRecognitionPlugin;
import com.tekartik.sqflite.SqflitePlugin;
import io.flutter.plugins.videoplayer.VideoPlayerPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    AdharaSocketIoPlugin.registerWith(registry.registrarFor("com.infitio.adharasocketio.AdharaSocketIoPlugin"));
    CameraPlugin.registerWith(registry.registrarFor("io.flutter.plugins.camera.CameraPlugin"));
    ConnectivityPlugin.registerWith(registry.registrarFor("io.flutter.plugins.connectivity.ConnectivityPlugin"));
    FilePickerPlugin.registerWith(registry.registrarFor("com.mr.flutter.plugin.filepicker.FilePickerPlugin"));
    FlutterTtsPlugin.registerWith(registry.registrarFor("com.tundralabs.fluttertts.FlutterTtsPlugin"));
    FlutterWebRTCPlugin.registerWith(registry.registrarFor("com.cloudwebrtc.webrtc.FlutterWebRTCPlugin"));
    FluttertoastPlugin.registerWith(registry.registrarFor("io.github.ponnamkarthik.toast.fluttertoast.FluttertoastPlugin"));
    PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    PermissionHandlerPlugin.registerWith(registry.registrarFor("com.baseflow.permissionhandler.PermissionHandlerPlugin"));
    SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));
    SpeechRecognitionPlugin.registerWith(registry.registrarFor("bz.rxla.flutter.speechrecognition.SpeechRecognitionPlugin"));
    SqflitePlugin.registerWith(registry.registrarFor("com.tekartik.sqflite.SqflitePlugin"));
    VideoPlayerPlugin.registerWith(registry.registrarFor("io.flutter.plugins.videoplayer.VideoPlayerPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
