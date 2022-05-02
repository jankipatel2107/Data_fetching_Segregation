# Data_fetching_Segregation

Worked on fetching, cleaning, and segregating the data from given set of Journals.
• Developed R project to fetch different data fields like Author name, DOI, Date of publication etc. according to the requirement from the chosen journal publication and download and excel sheet with all the fields with required data.
• Fetched data based on appropriate HTML tags.
• Used Regular Expression for data cleaning and extracting only the cleaned and required data.

Project Details:
In order to make it work on your computer please add your local path to “srcPath” variable. Also, just change the year (2001-2021) according to you at the end of the code.        
FIELDS	DATA FETCHED FROM THIS PATH
DOI, Title, Authors, Abstract, Publication_Date	--> https://www.jstage.jst.go.jp/browse/cbij/list/-char/en  --> The link of the website

Author_Affliation, Keywords -->	I got this from the data on DOI links provided on the original(above) websites.
Corresponding_Author, Corresponding_Author’s_Email -->	I had to abstract this from the pdf file.

The files in the pdf as well as .xlsx format will be downloaded on your local machine as per the year mentioned.

