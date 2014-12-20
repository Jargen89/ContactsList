ContactsList
============

Uses GData to pull Google Contacts from an email

To run properly, you require the GData framework here:
https://www.dropbox.com/s/m9krlbll7nonuq9/Gdata.zip?dl=0

- add in the headers and libGDataTouchStaticLib.a 

- Goto TARGETS -> Summary

   Linked Frameworks : Add libxml2.2 and libxml2
   
- Goto TARGETS -> Build Settings

  Other Linker Flags : "-lxml2" and "-all_load"
   
  Header Search Paths : "/usr/include/libxml2"


Future Additions/Improvements
=============================
-refactor the code so the refetching is done in a separate class, maybe even set it up as a singleton object.

-make the UI much nicer than this, this is too boring

-add a ContactDetail view controller to display more information.
