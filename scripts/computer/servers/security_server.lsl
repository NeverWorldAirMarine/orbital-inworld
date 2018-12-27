/*
* Copyright NWAM
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


integer count;

integer listenhandle;
integer NETWORK_CHANNEL;
string COORDS;
string RELAYNAME;
string PUSHERNAME;

integer debug = FALSE;
//// Put the UUIDs of your security staff here, eventually they will be retrieved by URL
list Names = [
                 "",
			 ""
             ];


integer ID2Chan( string id )
{
    integer mainkey = 921;
    string tempkey = llGetSubString( ( string )id, 0, 7 );
    integer hex2int = ( integer )( "0x" + tempkey );
    return hex2int + mainkey;
}

key owner;

default
{
    state_entry()
    {
        NETWORK_CHANNEL = 921;
        owner = llGetOwner();
        if( debug )
        {
            llSay( 0, "Initializing, please wait..." );
        }
        if( debug )
        {
            llSay( 0, "Ready." );
        }
        listenhandle = llListen( NETWORK_CHANNEL, "", "", "" );
    }
    listen( integer chan, string name, key id, string msg )
    {
        if( llList2String( llParseString2List( msg, ["|"], [] ), 0 ) == "SECALERT" )
        {
            RELAYNAME = llList2String( llParseString2List( msg, ["|"], [] ), 1 );
            PUSHERNAME = llList2Key( llParseString2List( msg, ["|"], [] ), 2 );
            vector COORDS = ( vector )COORDS;
            for ( count = 0; count < llGetListLength( Names ); count++ )
            {
                if( debug )
                {
                    llSay( 0, llList2String( Names, count ) );
                }
                string simName = llGetRegionName();
                string newSlurlPrefix = "http://maps.secondlife.com/secondlife/";
                list details = llGetObjectDetails( PUSHERNAME, [OBJECT_POS] );
                vector userPOS = llList2Vector( details, 0 );
                string urlSuffix = llEscapeURL( simName ) + "/" + ( string )llRound( userPOS.x + 1 ) + "/" + ( string )llRound( userPOS.y ) + "/" + ( string )llRound( userPOS.z );

                llInstantMessage( llList2Key( Names, count ), llGetDisplayName( PUSHERNAME ) + " is sending a Security Alert at coordinates " + newSlurlPrefix + urlSuffix + " on/at  " + RELAYNAME );
            }
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
