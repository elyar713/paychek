import com.android.build.gradle.AppExtension
import java.io.File
import java.io.FileInputStream
import java.util.Properties

val keystoreProperties = Properties()
// 1) android/key.properties (recommandé, ignoré par Git)
// 2) %USERPROFILE%\.android\key.properties
// 3) idem avec double extension key.properties.properties (Windows « Type : Fichier PRO »)
val projectKeyProperties = rootProject.file("key.properties")
val projectKeyPropertiesTypo = rootProject.file("key.properties.properties")
val userKeyFromHome = File(System.getProperty("user.home"), ".android/key.properties")
val userKeyTypoHome = File(System.getProperty("user.home"), ".android/key.properties.properties")
val userKeyFromProfile =
    System.getenv("USERPROFILE")?.trim()?.takeIf { it.isNotEmpty() }?.let { File(it, ".android/key.properties") }
val userKeyTypoProfile =
    System.getenv("USERPROFILE")?.trim()?.takeIf { it.isNotEmpty() }?.let { File(it, ".android/key.properties.properties") }
val keystorePropertiesFile =
    when {
        projectKeyProperties.isFile -> projectKeyProperties
        projectKeyPropertiesTypo.isFile -> projectKeyPropertiesTypo
        userKeyFromHome.isFile -> userKeyFromHome
        userKeyTypoHome.isFile -> userKeyTypoHome
        userKeyFromProfile?.isFile == true -> userKeyFromProfile!!
        userKeyTypoProfile?.isFile == true -> userKeyTypoProfile!!
        else -> projectKeyProperties
    }
if (keystorePropertiesFile.isFile) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "pro.paychek.app" 
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // Signature release si key.properties est trouvé (voir en-tête du script pour les emplacements).
    signingConfigs {
        if (keystorePropertiesFile.isFile) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                    ?: error("key.properties : propriété keyAlias manquante")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                    ?: error("key.properties : propriété keyPassword manquante")
                val storePath = keystoreProperties.getProperty("storeFile")
                    ?: error("key.properties : propriété storeFile manquante")
                // Absolu : tel quel. Relatif : même dossier que le fichier key.properties utilisé.
                val storeCandidate = File(storePath)
                storeFile =
                    if (storeCandidate.isAbsolute) {
                        file(storePath)
                    } else {
                        file(File(keystorePropertiesFile.parentFile, storePath))
                    }
                storePassword = keystoreProperties.getProperty("storePassword")
                    ?: error("key.properties : propriété storePassword manquante")
            }
        }
    }

    defaultConfig {
        // CORRECTION : Ton ID officiel pour le Play Store
        applicationId = "pro.paychek.app" 
        
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")
                ?: signingConfigs.getByName("debug")
            
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

// Les tâches bundleRelease / assembleRelease n’existent qu’après le plugin Android : hook en afterEvaluate.
// Sinon findByName renvoie null → aucune vérif. → AAB encore signé debug → erreur rouge Play Console.
afterEvaluate {
    val app = extensions.getByType(AppExtension::class.java)
    listOf("bundleRelease", "assembleRelease").forEach { taskName ->
        tasks.findByName(taskName)?.doFirst {
            if (!keystorePropertiesFile.isFile) {
                val pTypoH = userKeyTypoHome.absolutePath
                val pTypoP = userKeyTypoProfile?.absolutePath ?: "(USERPROFILE non défini)"
                throw GradleException(
                    """
                    |Signature release absente : aucun fichier key.properties trouvé.
                    |Gradle a cherché (fichier normal, pas un dossier) :
                    |  1) ${projectKeyProperties.absolutePath}
                    |  2) ${projectKeyPropertiesTypo.absolutePath}
                    |  3) ${userKeyFromHome.absolutePath}
                    |  4) $pTypoH
                    |  5) ${userKeyFromProfile?.absolutePath ?: "(USERPROFILE non défini)"}
                    |  6) $pTypoP
                    |Renomme key.properties.properties → key.properties si besoin, ou copie android/key.properties.example → android/key.properties
                    """.trimMargin(),
                )
            }
            val releaseCfg = app.signingConfigs.findByName("release")
                ?: throw GradleException(
                    "key.properties est illisible ou incomplet : signingConfigs « release » non créé.",
                )
            val store = releaseCfg.storeFile
                ?: throw GradleException("key.properties : storeFile non résolu pour la signature release.")
            if (!store.isFile) {
                throw GradleException("Keystore introuvable (storeFile) : ${store.absolutePath}")
            }
            val canon = store.canonicalPath.replace('\\', '/')
            if (canon.endsWith("debug.keystore") || canon.contains("/.android/debug.keystore")) {
                throw GradleException(
                    "La build release pointe encore sur le keystore DEBUG. Vérifie storeFile dans key.properties.",
                )
            }
        }
    }
}

dependencies {
    implementation("androidx.core:core-splashscreen:1.0.1")
}