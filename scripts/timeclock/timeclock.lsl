/*
* Copyright 2019 NeverWorld Air and Marine
*
*   Licensed under the Apache License, Version 2.0 (the "License");
*   you may not use this file except in compliance with the License.
*   You may obtain a copy of the License at
*
*       http://www.apache.org/licenses/LICENSE-2.0
*
*   Unless required by applicable law or agreed to in writing, software
*   distributed under the License is distributed on an "AS IS" BASIS,
*   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*   See the License for the specific language governing permissions and
*   limitations under the License.
*
*
*
*
*/


// User configurable variables.
string CLOCK_PAGE = "http://api.nwamgroup.com/clock.php";


key USER = "";
key ClockReq = ""; // Clock request HTTP Key
integer CONSOLE_FACE = 3;// Console Face
string HTTP_ERROR = "An Unexpected Error Occured";

SetText(string WTP)
{
    string CommandList = ""; // Storage for our drawing commands
 if(WTP = "SB")
 {
        CommandList = osMovePen( CommandList, 10, 10 );           // Upper left corner at <10,10>
        CommandList = osDrawText( CommandList, "SB"  ); // Place some text
 }
 else
  {
        CommandList = osMovePen( CommandList, 10, 10 );           // Upper left corner at <10,10>
        CommandList = osDrawText( CommandList, "NeverWorld Aviation and Marine\nTimeclock" ); // Place some text
 }
 
        // Now draw the image
       // osSetDynamicTextureData( "", "vector", CommandList, "width:256,height:256", 3 );
osSetDynamicTextureDataBlendFace("", "vector", CommandList, "width:256,height:256",
                                         FALSE, 2, 0, 255, 3);
}
// Main entry Point //
default
{
    state_entry()
    {
        llSay( 0, "INIT: Systems starting" );
        SetText("");
    }

    http_response( key req , integer stat, list met, string body )
    {
        llSay(0,"REQ: "+(string)req+"\nSTAT: "+(string)stat);

        if( req == ClockReq )     //Response was from the TimeClock
        {
            if( stat == 200 )
            {
                //llSay(0,body);
                //Set up if statment to handle server Errors here
                if( llToLower( llGetSubString( body, 0, 5 ) ) == "error:" )
                {
                    llSay( 0, HTTP_ERROR + "\nSTAT: " + ( string )stat + "\nRES: " + ( string )body );
                }
                else
                {
                    if( body == "User Clocked In" )
                    {
                        llInstantMessage( USER, "You have been clocked in. Please remember to clock out at the end of your shift. If for any reason you are offline for more than 5 minutes the system will automatically clock you out." );
                    }
                    else if( body == "User Clocked Out" )
                    {
                        llInstantMessage( USER, "You have been clocked out. Please remember to clock in at the begining of your next shift. Thank you for your time today." );
                    }
                    else if ( body == "New Account Created" )
                    {
                        llInstantMessage( USER, "Welcome to NeverWorld Aviation and Marine. Your account has been updated with the server and you have been clocked in as active duty. Please clock out at the end of your shift." );
                        llGiveInventory( USER, llGetInventoryName( INVENTORY_OBJECT, 0 ) );
                    }
                }
                USER = "";
            }
            else
            {
                llSay( 0, HTTP_ERROR + "\nSTAT: " + ( string )stat + "\nRES: " + ( string )body );
            }
        }
    }

    touch_start( integer total_number )
    {
        USER = llDetectedKey( 0 );
        integer link = llDetectedLinkNumber( 0 );
        integer face = llDetectedTouchFace( 0 );
        integer sameGroup = llSameGroup( USER );
        string groupKey = llList2String( llGetObjectDetails( llGetKey(), [OBJECT_GROUP] ), 0 );
        if ( face == TOUCH_INVALID_FACE )
        {
            llInstantMessage( USER, "Sorry, your viewer doesn't support touched faces. In order to clock in you may need to upgrade your browser or contact your Department head to keep track of your hours." );
        }
        else if( face == CONSOLE_FACE && sameGroup )   // Not invalid Log user in IF they touched the proper face AND they are in the SAME GROUP Group MUST be active
        {
            llInstantMessage( USER, "System is processing your request. Another IM will be sent once the system has registered the clock update." );
            ClockReq = llHTTPRequest( CLOCK_PAGE, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], "?uuid=" + ( string )USER + "&name=" + llGetUsername( USER ) );
      //  llSay(0, CLOCK_PAGE + "?uuid=" + ( string )USER + "&name=" + llGetUsername( USER ) );
        }
        else if( face == CONSOLE_FACE && !sameGroup )
        {
            llInstantMessage( USER, "Unfortunatly you are not in the same group as me. Please check your group tag is set to secondlife:///app/group/" + ( string )groupKey + "/about and try again." );
        }
    }
}
