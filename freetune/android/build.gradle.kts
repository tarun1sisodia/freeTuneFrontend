allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    afterEvaluate {
        project.extensions.findByType(com.android.build.gradle.BaseExtension::class)?.apply {
            compileSdkVersion(35)
            // Fix for AGP 8.0+ requiring namespace
            if (namespace == null) {
                 val defaultPackage = "com.example.${project.name.replace("-", "_")}"
                 namespace = when (project.name) {
                     "isar_flutter_libs" -> "dev.isar.isar_flutter_libs"
                     "flutter_secure_storage" -> "com.it_nomads.fluttersecurestorage"
                     else -> defaultPackage
                 }
            }
        }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
