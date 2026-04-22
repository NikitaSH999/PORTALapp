package com.hiddify.hiddify

import java.nio.file.Files
import java.nio.file.Path
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidPublicSurfaceTest {
    @Test
    fun manifestKeepsPokrovBrandAndDeepLinks() {
        val manifest = readRepoFile(
            "app/src/main/AndroidManifest.xml",
            "src/main/AndroidManifest.xml",
        )

        assertTrue(manifest.contains("android:label=\"POKROV\""))
        assertTrue(manifest.contains("android:scheme=\"pokrov\""))
        assertTrue(manifest.contains("android:scheme=\"pokrovvpn\""))
        assertTrue(manifest.contains("android.permission.QUERY_ALL_PACKAGES"))
        assertFalse(manifest.contains("android:label=\"Hiddify\""))
        assertFalse(manifest.contains("android:scheme=\"hiddify\""))
    }

    @Test
    fun buildGradleKeepsPokrovPackageContinuity() {
        val buildGradle = readRepoFile("app/build.gradle", "build.gradle")
        val shortcuts = readRepoFile(
            "app/src/main/res/xml/shortcuts.xml",
            "src/main/res/xml/shortcuts.xml",
        )

        assertTrue(buildGradle.contains("applicationId \"space.pokrov.vpn\""))
        assertFalse(buildGradle.contains("applicationId \"app.hiddify.com\""))
        assertTrue(shortcuts.contains("android:targetPackage=\"space.pokrov.vpn\""))
        assertFalse(shortcuts.contains("android:targetPackage=\"app.hiddify.com\""))
    }

    @Test
    fun nativeServiceSurfacesStayPokrovBranded() {
        val serviceNotification = readRepoFile(
            "app/src/main/kotlin/com/hiddify/hiddify/bg/ServiceNotification.kt",
            "src/main/kotlin/com/hiddify/hiddify/bg/ServiceNotification.kt",
        )
        val vpnService = readRepoFile(
            "app/src/main/kotlin/com/hiddify/hiddify/bg/VPNService.kt",
            "src/main/kotlin/com/hiddify/hiddify/bg/VPNService.kt",
        )

        assertTrue(serviceNotification.contains("\"POKROV\""))
        assertFalse(serviceNotification.contains("\"Hiddify\""))
        assertTrue(vpnService.contains("setSession(\"POKROV\")"))
        assertFalse(vpnService.contains("setSession(\"hiddify\")"))
    }

    private fun readRepoFile(vararg relativeCandidates: String): String {
        for (candidate in relativeCandidates) {
            val path = Path.of(candidate)
            if (Files.exists(path)) {
                return Files.readString(path)
            }
        }
        error("Unable to locate any of: ${relativeCandidates.joinToString()}")
    }
}
