# Tech Challenge - Mobile Developer @CPS 2022 Technical Challenge 

App that search movies from http://themoviedb.org and shows it in a scrollable list

![preview](https://user-images.githubusercontent.com/106440170/171147237-124848b9-5fc0-4830-aa3c-9d96e5311fc6.gif)


## How to setup and run the app:

Prerequisites: 
* Mac computer
* Xcode 13.3 or newer version

Clone the repository and open `MoviesApp.xcodeproj` file from repository's root path. 
Once Xcode opens and loads the project, choose a destination device on the top bar, `MoviesApp` → [Select any iPhone Simulator] and press `Cmd+R` or press on the ▶️ button to build and run the app.

To run the Unit Tests, press `Cmd+6` or click on the Test navigator icon from the top left bar to show all the tests. Press on the ▶️ button at the right of `MoviesAppTests` to run all tests.

## Troubleshooting

### Build fails with error: Package Loading -> Missing package product 'AsyncPlus'

Please, on the Xcode menu bar at the top, select **File → Packages → Reset Package Caches**. Then rebuild the app.
