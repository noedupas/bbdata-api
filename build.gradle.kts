import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
import org.springframework.boot.gradle.tasks.bundling.BootJar // for launchScript

plugins {
    id("org.springframework.boot") version "2.2.1.RELEASE"
    id("io.spring.dependency-management") version "1.0.8.RELEASE"
    id("com.gorylenko.gradle-git-properties") version "2.0.0"
    war
    kotlin("jvm") version "1.3.50"
    kotlin("plugin.spring") version "1.3.50"
    kotlin("plugin.jpa") version "1.3.50"
}

group = "ch.derlin.bbdata.api"
version = "2.0.0-alpha"
java.sourceCompatibility = JavaVersion.VERSION_1_8

val developmentOnly by configurations.creating
configurations {
    runtimeClasspath {
        extendsFrom(developmentOnly)
    }
}

repositories {
    mavenCentral()
}

springBoot {
    buildInfo() // add build info so it is shown in actuator /info
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    // NO HAL REST: implementation("org.springframework.boot:spring-boot-starter-data-rest")
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-data-redis")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    implementation("org.jetbrains.kotlin:kotlin-reflect")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
    implementation("org.springframework.session:spring-session-core")
    developmentOnly("org.springframework.boot:spring-boot-devtools")
    runtimeOnly("mysql:mysql-connector-java")
    providedRuntime("org.springframework.boot:spring-boot-starter-tomcat")
    testImplementation("org.springframework.boot:spring-boot-starter-test") {
        exclude(group = "org.junit.vintage", module = "junit-vintage-engine")
    }

    // joda-time
    implementation("org.jadira.usertype:usertype.core:7.0.0.CR1")
    implementation("com.fasterxml.jackson.datatype:jackson-datatype-joda:2.0.1")
    implementation("joda-time:joda-time:2.8")

    // cassandra
    implementation("org.springframework.data:spring-data-cassandra")

    // swagger doc
    implementation("org.springdoc:springdoc-openapi-ui:1.4.1")

    // metrics
    implementation("org.springframework.boot:spring-boot-starter-actuator")

    // kafka
    // see compatibility matrix at https://spring.io/projects/spring-kafka
    implementation("org.springframework.kafka:spring-kafka")

    // for XML support
    // implementation("com.fasterxml.jackson.dataformat:jackson-dataformat-xml")
}

tasks.withType<Test> {
    useJUnitPlatform()
}

tasks.withType<KotlinCompile> {
    kotlinOptions {
        freeCompilerArgs = listOf("-Xjsr305=strict")
        jvmTarget = "1.8"
    }
}

// see https://docs.spring.io/spring-boot/docs/current/gradle-plugin/reference/html/#packaging-executable-configuring-launch-script
tasks.getByName<BootJar>("bootJar") {
    launchScript()
}
// expand variables in application.properties, for example the ${version}
tasks.withType<ProcessResources> {
    filesMatching("application.properties") {
        expand(project.properties)
    }
}