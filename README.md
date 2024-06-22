# [RO]
#  Safe ME

Safe ME este o aplicație mobilă care vine în ajutorul persoanelor care se confruntă cu stări de nesiguranță. Aplicația reprezintă un mod rapid de a găsi și accesa cel mai apropiat loc deschis, cu ajutorul sistemului de navigație integrat care te îndrumă într-un mod eficient către destinație, dar și o soluție pentru urmărirea în timp real a locației prietenilor tăi.

## Cuprins

- [Funcționalități](#features)

- [Instalare](#installation)

  - [Clonarea repository-ului](#clone-the-repository)

  - [Configurare](#configuration)

  - [Build & Run](#build-and-run)

## Funcționalități

- Navigarea către un loc marcat ca fiind sigur
    - Utilizatorii pot accesa rapid și ușor informații despre locațiile considerate sigure din proximitatea lor, prin intermediul API-ului oferit de către Google.

- Semnalul de SOS
    - La apăsarea lungă a butonului de pe ecranul principal, contactele de urgență vor primi atât un SMS predefinit, cât și o notificare, pentru a le atrage atenția asupra dispozitivului. În plus, locația utilizatorului va fi activată pentru a putea fi urmărită de către oricare dintre prieteni.

- Platforma de socializare
    - Facilitează comunicarea și coordonarea în cazul situațiilor de urgență, oferind utilizatorilor un mijloc eficient de a-și exprima nevoile și de a primi sprijinul necesar.

- Monitorizarea prietenilor
    - Ecranul destinat acestei acțiuni permite utilizatorului nu doar să urmărească traseul altor persoane, ci și să comunice cu aceștia prin intermediul sistemului de mesagerie integrat sau prin aplicația de mesagerie implicită a dispozitivului acestora.

## Instalare

### Clonarea repository-ului

Se rulează comanda `git clone https://github.com/loredanagostian/SafeME.git` în terminal.

### Configurare

1. Navighează spre repository-ul clonat: `cd safeME`

2. Instalează dependințele proiectului:

    `flutter clean`

    `flutter pub get`

În cazul unor erori, rulează comanda `flutter doctor` sau `flutter doctor --verbose` pentru a te asigura că setup-ul este configurat corect.

### Build & Run

1. Conectează un device fizic sau pornește un emulator.

2. Pentru build & run, rulează comanda: 

    `flutter run`

Această comandă va instala proiectul pe device-ul folosit.

Mulțumesc pentru încrederea oferită proiectului SafeME!

# [ENG]
# Safe ME

Safe ME is a mobile application that assists individuals facing feelings of insecurity. The app provides a quick way to find and access the nearest open place, using the integrated navigation system to efficiently guide you to your destination. It also offers a solution for real-time tracking of your friends' locations.

## Table of Contents

- [Features](#features)

- [Installation](#installation)

  - [Clone the Repository](#clone-the-repository)

  - [Configuration](#configuration)

  - [Build and Run](#build-and-run)

## Features

- Navigation to a place marked as safe
    - Users can quickly and easily access information about safe locations in their vicinity through the API provided by Google.

- SOS signal
    - By long-pressing the button on the main screen, emergency contacts will receive both a predefined SMS and a notification to draw their attention to the device. Additionally, the user's location will be activated to be tracked by any of their friends.

- Social platform
    - Facilitates communication and coordination in emergency situations, offering users an efficient means to express their needs and receive necessary support.

- Monitoring friends
    - The screen dedicated to this action allows the user not only to track the route of other people but also to communicate with them through the integrated messaging system or the device's default messaging app.

## Installation

Follow these steps to install and run SafeME on your system.

### Clone the Repository

1. Open your terminal or command prompt.

2. Use the following command to clone the ProjectName repository:

`git clone https://github.com/loredanagostian/SafeME.git`

### Configuration

1. Change your working directory to the cloned repository: `cd SafeME`

2. Install the project dependencies:

`flutter clean`

`flutter pub get`

In case of errors, run the command `flutter doctor` or `flutter doctor --verbose` to ensure that the setup is correctly configured.

### Build and Run

1. Connect your device or start an emulator.

2. To build and run the project, use the following command: `flutter run`

This will build the project and install it on your connected device or emulator.

Thank you for choosing SafeME!