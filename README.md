# Powershell | ps-file-organizer
This PowerShell script organizes files in a given folder based on their file extensions. It sorts the files into separate folders named according to their file types.

---
## Requirements
- Windows OS with PowerShell (v5.1 or later)
- Linux OS with PowerShell Core (v6.0 or later)
  - install-psh.sh script can be used to install PowerShell Core on Linux

## Usage
1. Save the `MoveFilesToFolder.ps1` script to a location of your choice.
2. Open PowerShell (Windows PowerShell or PowerShell Core).
3. Change the current directory to the location where you saved the script.
4. Run the script and provide the folder path as an argument to sort the files. For example:

   ```powershell
    # Windows
    powershell.exe -ExecutionPolicy Bypass -File MoveFilesToFolder.ps1 "C:\Example\pg"
   ```

   ```powershell
   # Linux
   pwsh MoveFilesToFolder.ps1 "/home/user/Example/pg"
   ```

   Replace `"C:\Example\pg"` with the full path to the folder you want to sort.

5. The script will process the specified folder and organize its files into appropriate subfolders based on their file extensions.

## File Categories

The script categorizes files into the following groups:

- **Images**: `.jpg, .png, .jpeg, .gif, .bmp, .tiff`
- **Documents**: `.pdf, .docx, .doc, .txt, .md, .rtf, .csv, .xls, .xlsx, .ppt, .pptx, .`odt, .ods, .odp
- **Executables**: `.exe, .msi, .bat, .cmd, .ps1, .psm1, .vbs, .sh, .bash, .app, .elf, .`jar, .deb
- **Compressed**: `.zip, .rar, .7z, .gz, .tar, .iso, .dmg, .pkg`
- **Audio**: `.mp3, .wav, .ogg, .flac, .aac`
- **Videos**: `.mp4, .mov, .avi, .mkv, .wmv, .flv, .webm`
- **Graphics**: `.psd, .ai, .indd, .svg, .eps`
- **Other**: `Any files that do not match the above categories`
---
## Notes

- The script does not traverse subfolders. It only processes files present in the specified folder.
- If a file does not have an extension or its extension does not match any known category, it will be placed in the "Other" folder.
- The script will handle file and folder names with spaces correctly.
- Before running the script, ensure that you have the necessary permissions to create folders and move files in the target folder.

## License

This script is licensed under the [MIT License](LICENSE).
