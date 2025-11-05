# SimPL-Extension Documentation

## Introduction

SimPL-Extension is a repository that enhances the SimPL programming language by providing additional modules. These modules address specific challenges and extend the language's core functionality.

## Installation for Development

To set up SimPL-Extension, follow these steps:

1. Clone the repository to your local machine:
   ```bash
   git clone https://github.com/CustomerProjectDatron/SimPL-Extension.git
   ```
2. Navigate to the project directory:
   ```bash
   cd SimPL-Extension
   ```
3. Run the PowerShell script `InstallLinks.ps1` to create a symbolic link in the SimPL directory:
   ```powershell
   ./InstallLinks.ps1
   ```
   This symbolic link allows the SimPL library to use the modules directly.&#x20;

## Installation on Customer Machines

To install SimPL-Extension on customer machines, follow these steps:

1. Run the `CreateInstallationFolder.bat` script to create an installation folder:

   ```cmd
   CreateInstallationFolder.bat
   ```

   This script will generate a folder named `Install`.

2. Copy the `Install` folder to the target machine.

3. On the target machine, navigate to the `Install` folder and run the `Install.simpl` script:

   ```bash
   ./Install.simpl
   ```

4. Update the library folder manually to ensure the latest dependencies are included.

5. Verify the setup and confirm that all required files are accessible from the SimPL environment.
---

Additional chapters or details will be added as the documentation evolves.

