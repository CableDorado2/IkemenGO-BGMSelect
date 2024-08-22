# IkemenGO-BGM-Select-Module
Ikemen Go External Module that adds BGM Select to Stage Select Menu
Tested in Ikemen GO v0.98.2, 0.99.0 and Nightly Build

**Auto** Option works like stage select default song assignment (Uses select.def or stage.def music added).
**Random** Option will select a random music stored in "**./sound**" directory.
Custom BGM will show all the sounds that you have stored in the "**./sound**" directory and you can use them for round 1 of each stage.

##  _Installation:_
1- Extract archive content into "**./external/mods**" directory

2- Version 1.0 Notes:
IMPORTANT! **HOW TO FIX bgmSelect.lua:121** error:
GO TO "**./external/script/start.lua**" AND FOR "**local stageListNo = 0**"
remove "**local**" and save the file to that stage select works with this module...

3- New SYSTEM.DEF parameters assignments:

>[Select Info]
>
>;BGM Select
>
>bgm.move.snd = 100,0
>
>bgm.pos = 160,164
>
>bgm.active.font = 3,0,0
>
>bgm.active2.font = 3,2  ;Second font color for blinking
>
>bgm.done.font = 3,0
