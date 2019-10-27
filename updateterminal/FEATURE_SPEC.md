1. User Clicks on Registration Terminal "Update" button
2. Registration only listens to user while in use
3. Dialog Asks to pick between the following options 
- Name
- Rank
- Title
- Division
- Station

if choice = name
then open text box asking for "Character name"
then on "submit" post info along with UUID to url 

if choice = rank
Ask if Marine Officer, Fleet Officer, Marine Enlisted, Fleet Enlisted, or Cadet
Show the appropiate response from the Rank.pdf file in this folder, and then depending on the response,
save it in the script as the appropiate numbers
    
Example: I chose "Fleet Officer" then chose "Ensign", do a http request to the server with the following URL
https://astraios.vortexapp.tk/modules/api/updatesj.php?uuid=00000000-0000-0000-0000-000000000000&info=rank&update=1
    
    
 if choice = title and they must have division set first
 
 Show all division available titles in the text. and choose number from dialog. 
 
 
 if choice = station 
 Ask from a list from stations.pdf
 
 if choice = division
 ask from list in divisions.pdf
 

    
    
    
    
    
https://astraios.vortexapp.tk/modules/api/updatesj.php?uuid={user.uuid}&info={field being updated}&update={response}
