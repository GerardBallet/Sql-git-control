
# Introduction

That project gives a tool for have control on sql server table's registers changes. 
That tool is a set of scripts that allow generate a script for every table on your database containing all the rows of that table.
That files allow you to have a control version of the content of a tables, following the steps below.

+ Run the scripts on that project (every time you want a instance of your database content)
+ Copy the files on [results](.\results) folder and copy them to your git repository 
+ Commit and Push your changes 


# Requirements

+ Docker 
+ Docker-compose


# Settings

For use that tool you must to configure a setting file. An example of that file could by found [here](.\ExampleSettings\settings.json). and put it on [that directory](settings).

# Run Scripts generation

``
docker-compose up --build
``