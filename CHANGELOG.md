#  Changelog for OpenAccessStorage
All notable changes to this project will be documented in this file

## [v1.0.0]
basic matlab interface to MYSQL database for retrieving field inputs to generate json tag files.

## 
Web site to view database contents, plus web interface to generate json files.
Also now added a python interface for the generation of json files. A connection parameter file is included to an example database (only NIN accessible).

## 
Reorganized folder structure. All dependencies are now in folders : **dependent**, **par**, **mysql**, **jsonlab**.
Temporary paths are added to access these folders when you use : `getdbFields`, `dbBrowser` and `dbEdit`.
The username/password parameter file should be saved in the par folder, files in this folder are ignored on github commits.

## 
Enhanced user experience for `dbBrowser`. Both selecting fields and generating a treeview is now done in one user interface by loading a an updated Treeview JAVA object from ttv1.jar. This enables a user to view and select subsets of records within datasets from different perspectives.

## [ v1.0.1 : 10/26/2020 ]
dbBrowser and dbEdit have become obsolete and are replaced by services using Datajoint, a Scientific workflow management framework built on top of a relational database. Two services are added (importandgenerate, GetDouble_JSONS). The first enables users to generate jsonfiles for datasets that have not yet been associated with jsonfiles. The second helps to keep your database consistent bij reporting double entries, for example due to multiple copies of your data.

## [ v1.1.0 : 01/01/2021 ]
Since GUIDE applications are slowly being outphased by matlab, I have made a replacement for getdbfields. **getFYD.m**.
GetFyd encapsulates **getFYDfields.mlapp** effectively making it a dialog. When the app is closed it returns values from a handle that is a parameter to the app on startup and acts as a persistent data store when the app is closed.
However, you can also use getFYDfields.mlapp as a stand alone app, and retrieve values directly from a handle to the app, like so:   
` app=getFYDfields;`     
` fields = app.fydsaved %retrieve values`   
` app.setsessionnr(1) %set the session number`  

This makes this app more versatile than getdbfields (you can either incorporate it in your workflow scripts or as a stand alone app). When the app is closed it will also save the last set of values to fydsaved.mat and retrieve these values when you open the app again. This way, you only have to select options that change from session to session.

## [ v1.1.1 : 01/20/2021 ]
The python implementation is renewed : getFYD.py  
This provides the same functionality as getFYD.m  
Run with : 
` python getFYD.py `  
Alternatively, use in Jupyter Notebook: 
` saveJSON.ipynb `

