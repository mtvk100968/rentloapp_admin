buildscript {
    repositories {
        google()
        mavenCentral() // ✅ Ensure repositories are defined
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.9.0") // ✅ Latest Gradle Plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.20") // ✅ Updated Kotlin plugin
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
