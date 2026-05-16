import org.gradle.api.tasks.compile.JavaCompile
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// firebase_storage 13.4.0 : `var codeNumber: Int` sans assignation sur tous les chemins (rejet Kotlin 2.2).
// Corrige le fichier dans le pub-cache une fois par build (idempotent). Pas d'afterEvaluate (conflit avec evaluationDependsOn).
subprojects {
    if (project.name != "firebase_storage") return@subprojects
    tasks.withType<KotlinCompile>().configureEach {
        doFirst {
                val f =
                    project.file(
                        "src/main/kotlin/io/flutter/plugins/firebase/storage/FlutterFirebaseStorageException.kt",
                    )
                if (!f.exists()) return@doFirst
                var text = f.readText(Charsets.UTF_8)
                if (text.contains("PATCH_PAYCHEK_FIREBASE_STORAGE_EXCEPTION")) return@doFirst
                val needle =
                    "    var code = \"UNKNOWN\"\n" +
                        "    var message = \"An unknown error occurred:\" + nativeException.message\n" +
                        "    var codeNumber: Int\n" +
                        "\n" +
                        "    if (nativeException is StorageException) {\n" +
                        "      codeNumber = nativeException.errorCode"
                if (!text.contains(needle)) return@doFirst
                val replacement =
                    "    var code = \"UNKNOWN\"\n" +
                        "    var message = \"An unknown error occurred:\" + nativeException.message\n" +
                        "\n" +
                        "    if (nativeException is StorageException) {\n" +
                        "      val codeNumber = nativeException.errorCode // PATCH_PAYCHEK_FIREBASE_STORAGE_EXCEPTION"
                f.writeText(text.replace(needle, replacement), Charsets.UTF_8)
            }
        }
}

// Plugins pub (ex. cloud_firestore) : notes javac (unchecked, deprecation). On les masque en sortie Gradle.
subprojects {
    tasks.withType<JavaCompile>().configureEach {
        options.compilerArgs.addAll(
            listOf(
                "-Xlint:-options",
                "-Xlint:-unchecked",
                "-Xlint:-deprecation",
            ),
        )
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
