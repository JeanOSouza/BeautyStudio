buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0") // Ou a versão do seu AGP
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.0")
        classpath("com.google.gms:google-services:4.4.2") // Use a mesma versão que você definiu no plugin!
    }
}
plugins {
    id("com.android.application") apply false // Geralmente vem aqui, se você não tem, pode ignorar
    id("kotlin-android") apply false // Geralmente vem aqui, se você não tem, pode ignorar
    id("dev.flutter.flutter-gradle-plugin") apply false // Geralmente vem aqui, se você não tem, pode ignorar
 }

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
