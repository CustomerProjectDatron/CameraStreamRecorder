# {{PROJECT_NAME}}

## Installation for Development

For development, individual folders of the project are mapped to the program directory of Next using symbolic links.
This allows different repositories to be "installed" together and easily managed and committed individually.

To set up SimPL-Extension, follow these steps:

1. Clone the repository to your local machine:

2. Navigate to the project directory:
3. Run the PowerShell script `InstallLinks.ps1` to create a symbolic link in the SimPL directory:

   ```powershell
   ./InstallLinks.ps1
   ```

   This symbolic link allows the SimPL library to use the modules directly.&#x20;

## Installation on Customer Machines

The install process for SimPL-Extension is done via a package installer file with the extension `.nextpkg`.

It`s controlled over the `metadata.json` file in the root of the package, which defines the file mappings and metadata.

(See [NextPackageConfiguration.md](NextPackageConfiguration.md) for details on the metadata schema.)


To install SimPL-Extension on customer machines, follow these steps:

1. Run the `create_package.bat` script to create package installer.

   ```cmd
   create_package.bat
   ```

   This script will generate a File with the ending `.nextpkg` in the `Install` folder.

2. Copy the `nextpkg` file to the target machine where you want to install the SimPL-Extension.

3. Open the Next software on the target machine. Go to the folder where you copied the `nextpkg` file. Install the package by clicking the install button on it.

---
