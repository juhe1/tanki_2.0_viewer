# Tanki 2.0 viewer
Tanki 2.0 viewer is opensource remake of tanki 2.0 demo. The original tanki 2.0 demo was created by alternativa games to show off some stuff that they developed for game that they never released. That game was named "Tanki 2.0" and they planed to replace their another game named "Tanki Online" with it.
Video of original Tanki 2.0 demo (this video is not mine): https://youtube.com/watch?v=GOkeDkOYoSA

I have used some decompiled code from TLVK, so you should not use code from this repository for anything that will be published to public, because it will be probably illegal.
## How to compile
1. Install FlashDevelop.
2. Open "tanki_2.0_map_viewer.as3proj" file with FlashDevelop.
3. Install SDK. I used "AIR SDK for Flex Developers", which you can get from this site: https://airsdk.harman.com/download. Some other SDK may also work.
4. Compile.
5. Add "resource" folder to the blace where your swf file is located. Into "resource" folder you need to add all Tanki 2.0 resources like maps, hulls, turrets and color maps. You can find these resources from Tanki 2.0 demo. Check from the code the correct folder structure.
6. Drag and drop the swf file to "Flash Player 11.exe" or to "FlashPlayerDebug.exe" file. If you get some policy error when affter running the swf, try adding the folder where the swf is located to trusted locations. You can do that by opening "GlobalSettings.exe", then go to "Advanced" tab and from there click "Trusted Location Settings". Now you click add button and then paste the location to the text box. (you can find these exe file from "flash_exes" folder)
## Features
* Tanki 2.0 map loader
* Tanki 2.0 hull and turret loader
	- Tracks are missing for now
* Tank physics (So you can drive around.)
* Free camera and follow camera
## TODO
* Fix follow camera
* Fix light beams (They only work when there is nothing behind)
* Add tracks for tank
* Add better free camera (i want smoother camera controls)
## Screen shots
![Tank](/images/Tank2.png)

![Tank](/images/Tank2.png)

![Map](/images/Map.png)
