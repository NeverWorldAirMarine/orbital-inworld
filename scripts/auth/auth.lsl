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

string authurl = "https://nwamgroup.com/app/modules/api/auth.php";
key authrequest;

key user;
integer gListener; // Dialog listeners
integer oListener;

list users;

default
{
    state_entry()
    { 
        llSay( 0, "Initializing, please wait..." );
        llSleep( 3.0 );
        state available;
    }
}

state available
{
    state_entry()
    {
        llSetText( "", <1, 1, 1>, 1.0 );
        llSay( 0, "Terminal is now available" );
    }
    touch_start( integer num_detected )
    {
        state in_use;
    }
}

state in_use
{
    state_entry()
    {
        llSay( 0, "Terminal now in use by " + llGetDisplayName( user ) );
        llListenRemove( gListener );
        gListener = llListen( -2468, "", "", "" );
        users += llGetDisplayName( user );
        llTextBox( user, "Please Enter Your Command/Authentication Code for Verifacation", -2468 );
        llSetTimerEvent( 60.0 );
    }
    timer()
    {
        llListenRemove( gListener );
        llSetTimerEvent( 0 );
        state available;
    }
    listen( integer chan, string name, key id, string msg )
    {
        llListenRemove( gListener );
        authrequest = llHTTPRequest( authurl, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], "uuid=" + ( string )user + "&code=" + ( string )msg );
    }
    http_response( key request_id, integer stat, list metadata, string body )
    {
        if ( request_id == authrequest )
        {
            if ( stat == 200 )
            {
                list result = llParseString2List( body, ["|"], [] );
                string status = llList2String( result, 0 );
                if ( status == "OK" )
                {
                    integer accountID = llList2Integer( result, 1 );
                    string rank = llList2String( result, 1 );
                    string name = llList2String( result, 2 );
                    string division = llList2String( result, 3 );
                    string dname = llRequestDisplayName( user );
                    llSay( 0, "Acknowledged. Welcome, " + rank + " " + name + ".\nDivision: " + division + "\n Your code is valid and authenticated." );
                    llSleep( 5 );
                    state available;
                }
                else if ( status == "ERROR" )
                {
                    string errcode = llList2String( result, 1 );
                    llSay( 0, "There was an error. Error: " + errcode );
                    llSleep( 2 );
                    state available;
                }
            }
            else if ( stat == 500 )
            {
                llSetText( "Error 500", <1, 1, 1>, 1.0 );
                llSleep( 2 );
                state available;
            }
            else
            {
                llSetText( "Generic Error: " + body, <1, 1, 1>, 1.0 );
                llSleep( 2 );
                state available;
            }
        }
    }
}
