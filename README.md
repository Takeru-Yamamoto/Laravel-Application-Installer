# Laravel Application Installer

## Tested Linux Distributions

* AlmaLinux 9.2

## About

This Installer configure the following Apache settings

* DocumentRoot
* DirectoryIndex
* AllowOverride

## Usage

Execute the following command as a user with root privileges.  
The Installer requires the following arguments

* INSTALL_DIR: The directory where Laravel will be installed
* OWNER_USER: The user who owns the Laravel directory
* ACCESS_URL: The URL to access the Laravel application
* IS_INSTALL_LATEST_LARAVEL: Whether to install the latest version of Laravel

If you want to install the [Takeru-Yamamoto/Laravel-Customized](https://github.com/Takeru-Yamamoto/Laravel-Customized.git), set the argument IS_INSTALL_LATEST_LARAVEL to 1.

Please replace the respective argument parts and execute.

```
curl -s https://raw.githubusercontent.com/Takeru-Yamamoto/Laravel-Application-Installer/master/script.bash | bash -s "${INSTALL_DIR}" "${OWNER_USER}" "${ACCESS_URL}" "${IS_INSTALL_LARAVEL_CUSTOMIZED}"
```

As soon as the building is complete, run the Laravel migration.

```
php artisan migrate --seed
```