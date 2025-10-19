package com.foririon.project.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.context.annotation.Configuration;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.io.InputStream;

@Configuration
public class FirebaseInitializer {

  @PostConstruct
  public void initialize() {
    try {
      InputStream serviceAccount = null;

      // Try classpath resource first
      String serviceAccountKeyPath = "key/for-irion-firebase-adminsdk-fbsvc-5962b46b9e.json";
      serviceAccount = getClass().getClassLoader().getResourceAsStream(serviceAccountKeyPath);

      // If not found in classpath, try file system
      if (serviceAccount == null) {
        String userDir = System.getProperty("user.dir");

        java.io.File keyFile = new java.io.File(userDir, "src/main/resources/" + serviceAccountKeyPath);

        if (keyFile.exists()) {
          serviceAccount = new java.io.FileInputStream(keyFile);
        } else {
          // Try backend directory
          java.io.File backendKeyFile = new java.io.File(userDir, "backend/src/main/resources/" + serviceAccountKeyPath);

          if (backendKeyFile.exists()) {
            serviceAccount = new java.io.FileInputStream(backendKeyFile);
          } else {
            throw new IOException("Firebase service account key file not found");
          }
        }
      }

      FirebaseOptions options = FirebaseOptions.builder()
              .setCredentials(GoogleCredentials.fromStream(serviceAccount))
              .build();

      if (FirebaseApp.getApps().isEmpty()) {
        FirebaseApp.initializeApp(options);
      }

    } catch (IOException e) {
      throw new RuntimeException("Firebase initialization failed", e);
    }
  }
}
