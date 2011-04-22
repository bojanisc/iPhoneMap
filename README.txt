iPhoneMap v0.1
============== 

This program is simply a port of iPhoneTracker written by Alasdair Allan 
and Pete Warden available at 
http://petewarden.github.com/iPhoneTracker/. 

iPhoneMap uses a Python script available at 
http://stackoverflow.com/questions/3085153/how-to-parse-the-manifest-mbd 
b-file-in-an-ios-4-0-itunes-backup to locate the database file. Once the 
database file is located, you just have to give the file name to 
iPhoneMap and it will create an HTML page same as one used by 
iPhoneTracker. 

HOW TO USE?
=========== 

First locate the database: 

  $ ./find_sqlite.py
  Your iPhone database is located in file: 
  4096c9ec676f2847dc283405900e284a7c815836

  Execute the following command: 

  ./iPhoneMap.pl myIphone 4096c9ec676f2847dc283405900e284a7c815836 

Now generate the HTML file: 

  ./iPhoneMap.pl myIphone 4096c9ec676f2847dc283405900e284a7c815836 

Open index.html and enjoy! 

WHERE ARE DATABASE FILES?
========================= 

On Mac, they are in /Users/<your user name>/Library/Application 
Support/MobileSync/Backups/ 

On Windows, they are in C:\Users\<your user name>\AppData\Roaming\Apple 
Computer\MobileSync\Backup 

In order to find the database file, you have to have the following two
files in same directory as find_sqlite.py:

Manifest.mbdb
Manifest.mbdx

find_sqlite.py will then print which file contains the database.

