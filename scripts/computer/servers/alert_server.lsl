/*
* Copyright 2019 United Federation Starfleet, Astraios
* Originally Created by Cody Cooper, Starfleet Corp of Engineers
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




// Global inits

integer listenhandle;
integer adminhandle;
integer NETWORK_CHANNEL;

key destination;
string reqtype;
key owner;
integer debug = FALSE; // Set to true for debug output

// Function Definitions



// String searcher function, using % for wildcard
integer contains( string value, string mask )
{
    integer tmpy = ( llGetSubString( mask,  0,  0 ) == "%" ) |
                   ( ( llGetSubString( mask, -1, -1 ) == "%" ) << 1 );
    if( tmpy )
    {
        mask = llDeleteSubString( mask, ( tmpy / -2 ), -( tmpy == 2 ) );
    }

    integer tmpx = llSubStringIndex( value, mask );
    if( ~tmpx )
    {
        integer diff = llStringLength( value ) - llStringLength( mask );
        return  ( ( !tmpy && !diff )
                  || ( ( tmpy == 1 ) && ( tmpx == diff ) )
                  || ( ( tmpy == 2 ) && !tmpx )
                  ||  ( tmpy == 3 ) );
    }
    return FALSE;
}





default
{
    state_entry()
    {
        llSay( 0, "Booting up." );
        owner = llGetOwner();
        if( debug )
        {
            llSay( 0, "Initializing, please wait..." );
        }
        if( debug )
        {
            llSay( 0, "Ready." );
        }
        NETWORK_CHANNEL = 921;
        listenhandle = llListen( NETWORK_CHANNEL, "", "", "" );
    }
    
    /////////////// Begain the Part for Developers/////////
    listen( integer chan, string name, key id, string msg )
    {
        if( llList2String( llParseString2List( msg, ["|"], [] ), 0 ) == "ALERT" )
        {
            destination = llList2Key( llParseString2List( msg, ["|"], [] ), 1 );
            reqtype = llList2String( llParseString2List( msg, ["|"], [] ), 2 );
            if( debug )
            {
                llSay( 0, "Processing request type: " + reqtype + " on " + llGetObjectDesc() );
            }
            if ( reqtype == "ALERTOFF" )
            {
                // Send a Off Message Here
            }
            else if ( reqtype == "ABDNSTATION" )
            {
                //// Send the Abandon Station Alert Here
            }
            else if ( reqtype == "BATTLESTAT" )
            {
                //// Send the Battle Station Alert Here
            }
            else if ( reqtype == "RED" )
            {
                //// Send the Red Alert Here
            }
            else if ( reqtype == "BLUE" )
            {
                //// Send the Blue Alert Here
            }
            else if ( reqtype == "YELLOW" )
            {
                //// Send the Yellow Alert Here
            }
            else if ( reqtype == "GREEN" )
            {
                //// Send the Green Alert Here
            }
            else if ( reqtype == "BIO" )
            {
                //// Send the Biohazard Alert Here
            }
            else if ( reqtype == "INTRUDER" )
            {
                //// Send the Intruder Alert Here
            }
            else if ( reqtype == "COMMODORE" )
            {
                //// Send the Battle Station Alert Here
            }
/////////////////////// End the Part for Developers //////          
        }
        else if( llList2String( llParseString2List( msg, ["|"], [] ), 0 ) == "ADMIN" )
        {
            string setting = llToLower( llList2String( llParseString2List( msg, ["|"], [] ), 1 ) );
            string value = llToLower( llList2String( llParseString2List( msg, ["|"], [] ), 2 ) );
            if( debug )
            {
                llSay( 0, "Processing admin command: " + setting + ":" + ( string )value );
            }
            if ( setting == "debug" )
            {
                if ( value == "off" )
                {
                    debug = FALSE;
                }
                else if ( value == "on" )
                {
                    debug = TRUE;
                }
            }
            else if ( setting == "reboot" )
            {
                llResetScript();
            }
        }
        
        }
        }
