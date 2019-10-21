/*
* Copyright 2019 United Federation Starfleet
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
*/

// User configurable variables.
string TAG_PAGE = "https://astraios.vortexapp.tk/modules/api/tag.php";
string HTTP_ERROR = "An unexpected error occured while attempting to lookup a title.";

// Variable Init
key USER = "";
key TagReq = ""; // Clock request HTTP Key
list TAG_PARAMS_POST = [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"];
list TAG_PARAMS_GET = [HTTP_METHOD, "GET", HTTP_MIMETYPE, "application/x-www-form-urlencoded"];
integer listenhandle;
string version = "3.5.1";

// Function declarations

// Main entry Point //
default
{
    state_entry()
    {
        listenhandle = llListen( 899, "", NULL_KEY, "" ); //adding a listener var to use later for closing
        llOwnerSay( "INIT: Systems starting" );
        TagReq = llHTTPRequest( TAG_PAGE, TAG_PARAMS_POST, "uuid=" + ( string )llGetOwner() );
        // TagReq = llHTTPRequest(TAG_PAGE+"?uuid="+(string)llGetOwner(), TAG_PARAMS, "");
    }
    listen( integer chan, string name, key id, string msg )
    {
        if( msg == "reset" )
        {
            llListenRemove( listenhandle ); //closing the listen before we reset the titler
            llResetScript();
        }
        else if( msg == "list" )
        {
            // Broadcast owner name and version number
            llRegionSay( 899, ( string )llGetDisplayName( llGetOwner() ) + " is using version " + version );
        }
    }

    changed( integer change )
    {
        if( change & CHANGED_OWNER )
        {
            llListenRemove( listenhandle );
            llResetScript();
        }
    }

    http_response( key req , integer stat, list met, string body )
    {
        if( req == TagReq && stat==200 )   // Response was from the Database
        {
            // Set up if statment to handle server Errors here
            if( llToLower( llGetSubString( body, 0, 5 ) ) == "error:" )
            {
                llOwnerSay( HTTP_ERROR + "\nSTAT: " + ( string )stat + "\nRES: " + ( string )body );
            }
            else
            {
                list temp = llParseString2List( body, [":"], [] );
                vector color = ( vector )llList2String( temp, 0 ) / 255; // Convert RGB stored values database side to Vectors for LSL
                string tag = llList2String( temp, 1 );
                llSetText( tag, color, 1.0 );
            }
            USER = "";
        }
        else
        {
            llOwnerSay( HTTP_ERROR + "\nSTAT: " + ( string )stat + "\nRES: " + ( string )body );
        }
    }
}
