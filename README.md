# Phone to SD Card File Transfer App

## Overview

This Flutter application facilitates seamless file management, primarily focusing on transferring files between your phone's internal storage and an SD card. It also provides functionalities for displaying various file types, including PDF documents, and managing application settings.

## Features

-   **File Transfer**: Easily move files from phone storage to SD card and vice-versa.
-   **File Browsing**: Navigate through your device's file system to locate and manage files.
-   **PDF Viewer**: Built-in support for viewing PDF documents directly within the app.
-   **Permission Handling**: Robust handling of necessary storage permissions for smooth operation.
-   **Storage Unit Information**: Display information about available storage space on both internal and external storage.
-   **User Settings**: Customizable settings to enhance user experience.

## Technologies Used

This application is built using Flutter and leverages several key packages:

-   `path_provider`: For accessing commonly used locations on the device's file system.
-   `permission_handler`: To manage and request necessary runtime permissions.
-   `file_picker`: For picking files from the device storage.
-   `shared_storage`: For interacting with Android's Storage Access Framework (SAF) to manage external storage.
-   `open_file`: To open various file types using the default application.
-   `flutter_pdfview`: For rendering and displaying PDF documents.
-   `device_info_plus`: To get information about the device.
-   `shared_preferences` & `get_storage`: For local data storage and preferences.
-   `url_launcher`: For launching URLs.
-   `cached_network_image` & `flutter_cache_manager`: For efficient image caching.

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

-   Flutter SDK installed. ([Installation Guide](https://flutter.dev/docs/get-started/install))
-   Android Studio or VS Code with Flutter and Dart plugins.

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/psprogrammer-07/smart_file_transfer_app
    cd smart_file_transfer_app
    ```
   

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the application**:
    ```bash
    flutter run
    ```

## Project Structure

```
phone_to_sd/
├── lib/
│   ├── display_files/        # Widgets and logic for displaying files
│   │   └── display_files.dart
│   ├── settings/             # Application settings and configurations
│   │   └── settings.dart
│   ├── transer_files_folder/ # Logic for file selection and transfer
│   │   ├── file_select_page.dart
│   │   └── transfer_files.dart
│   ├── file_manager.dart     # Core file management utilities
│   ├── main.dart             # Main entry point of the application
│   ├── sidebar.dart          # Navigation sidebar implementation
│   └── storage_units.dart    # Logic for handling storage unit information
├── appicon/                  # Application icons
├── local_image/              # Local images and assets
├── .gitignore                # Specifies intentionally untracked files to ignore
├── pubspec.yaml              # Project dependencies and metadata
└── README.md                 # This file
```

## License

Distributed under the MIT License. See `LICENSE` for more information. (You might want to create a `LICENSE` file if you don't have one).

