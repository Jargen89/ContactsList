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


Approach

-  The implementation is very direct. Login credentials are asked for immediately and prompts appear in the event of bad authentication, failed fetching or successful fetching.

-  Only contacts with a name and email, or phone number, are added to the list.
-  There is a refreshControl added to the tableView as well, so the user can update the list of contacts whenever they wish.
-  When the user logs out, the username and password are cleared and so is the list of contacts.

Features Completed

- this is just a basic implementation, as this task was alloted only 4 hours and I started with the incorrect framework (I chuckled)

Given more time, what else would you have liked to complete and how long it would have taken you?
- I only needed a few more minutes to integrate some persistence in the username. That way the most recently used username remains in the login field. I didn't because I wanted to keep true to the 4 hours alloted, and most of the time was spent learning the GData framework (and Google+ api, since I first assumed I could try and use that instead).
- I wanted to integrate some coreData into this app for offline persistence as well. Syncing with each new fetch for contacts. This would have taken a couple more hours with respect to any debugging and testing.
- If each instance of a contact included an image (I'm not sure if they do or not. Again, this was the first time I've worked with this framework) then I would have implemented image loading as well. I would even figure out a means to support offline persistence, saving images to the NSCachesDirectory.
- If I had another couple hours, I would have also created a UIViewController that displays outstanding contact information that wasn't already present. That, or I would try to add a side-menu that slides into view that would display more information. It's an approach I would like to experiment with in the realm of user experiences. The UX takes a big part in attracting users, so I would spend a lot of time refining it.

Given more time, what else would you have done to make the project more robust?
- I wanted to keep all of the processing done on a separate class or thread, as means to keeping things nice and quick for the user.
- I mentioned that I wanted to add some coreData into the project, I would have also taken a singleton approach to this.

