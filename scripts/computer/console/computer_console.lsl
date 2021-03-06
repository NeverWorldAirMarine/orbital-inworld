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
// Global Inits

integer inputhandle;
integer listenhandle;
integer NETWORK_CHANNEL;

integer chan;
integer menuhandle;
string namedetected;
key keydetected;


//Variable Inits

key defaulttexture = "cbe05b00-d0f6-6692-6d24-eeecef8ea04e";


// Modules

integer humor = TRUE;
integer debug = TRUE;
integer delta = FALSE;


// Function Definitions

string SimplifyVector( vector input )
{
    integer vx = ( integer )input.x;
    integer vy = ( integer )input.y;
    integer vz = ( integer )input.z;
    return "<" + ( string )vx + ", " + ( string )vy + ", " + ( string )vz + ">";
}

// String Searcher, using % as wildcard
/*
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
*/

integer contains(string haystack, string needle) // http://wiki.secondlife.com/wiki/llSubStringIndex
{
    //llSay(0, "Finding" + needle + " in a " + haystack);
    return 0 <= llSubStringIndex(haystack, needle);
}



display( string uuid, integer face )
{
    llSetTexture( ( key )uuid, face );
    llSetTimerEvent( 10 );
}

default
{
    state_entry()
    {
        chan = ( integer )( llFrand( 1000000 ) + 10 ) * -1;
        llSetLinkPrimitiveParamsFast( LINK_THIS, [PRIM_COLOR, 2, <1, 1, 0>, 1.0] );
        NETWORK_CHANNEL = 921;
        llSay( 0, "Initializing, please wait..." );
        llSetTexture( defaulttexture, 1 );
        llPreloadSound( "3ceeea7f-c729-ce67-8e1f-3d8da8c7821b" ); // Automatic Defense
        llPreloadSound( "f59303b8-9f40-7946-530b-b554d12ddd48" ); // Texture Display
        llPreloadSound( "f49a4c7a-5a40-6d6f-3be6-693501fd2b72" ); // Deactivation Complete
        llPreloadSound( "12c1f675-a0d7-7e3b-fb59-28c61ebfc526" ); // Now Establishing Data Link
        llPreloadSound( "e4711aad-0288-3525-eef1-4574e9350373" ); // Standby
        llPreloadSound( "5c29a400-a4f9-f47e-dbf6-17d14fedc981" ); // Systems Online
        llPreloadSound( "958546cc-135f-5288-a49c-f701ce7edd36" ); // LCARS Button 'Tap'
        llPreloadSound( "d98eb19a-2985-9c50-314a-1bc8dc2147e4" ); // Ambience
        llPreloadSound( "1f11144e-3c5b-885d-8671-bfd229032fc9" ); // Please restate command
        state available;
    }
}

state available
{
    state_entry()
    {
        llTriggerSound( "12c1f675-a0d7-7e3b-fb59-28c61ebfc526", 1.0 );
        llSleep( 2.25 );
        llSay( 0, "This terminal is now linked to the Starfleet Interactive Database." );
        llSetTexture( "cbe05b00-d0f6-6692-6d24-eeecef8ea04e", 1 );
        llSetLinkPrimitiveParamsFast( LINK_THIS, [PRIM_COLOR, 2, <0, 1, 0>, 1.0] );
        llTriggerSound( "5c29a400-a4f9-f47e-dbf6-17d14fedc981", 1.0 );
        listenhandle = llListen( NETWORK_CHANNEL, "", "", "" );
        inputhandle = llListen( 0, "", "", "" );
    }
    listen( integer channel, string name, key id, string msg )
    {
        string loweredmsg = llToLower( msg );
        if ( contains( loweredmsg, "computer" ) )
        {
            if(debug)
            {
                llSay(0, loweredmsg);
            }
            if ( contains( loweredmsg, "texture" ) )
            {
                list parsed = llParseString2List( msg, [" "], [] );
                llTriggerSound( "f59303b8-9f40-7946-530b-b554d12ddd48", 1.0 );
                display( llList2String( parsed, -1 ), 1 );
            }
            else if ( contains( loweredmsg, "loop sound" ) )
            {
                list parsed = llParseString2List( msg, [" "], [] );
                llLoopSound( llList2Key( parsed, -1 ), 1.0 );
            }
            else if ( contains( loweredmsg, "stop sound" ) )
            {
                llStopSound();
            }
            else if ( contains( loweredmsg, "play sound" ) )
            {
                list parsed = llParseString2List( msg, [" "], [] );
                llTriggerSound( llList2Key( parsed, -1 ), 1.0 );
            }
            else if ( contains( loweredmsg, "enviroment" ) )
            {
                llRegionSay( NETWORK_CHANNEL, "CORE|" + ( string )llGetKey() + "|ENVIROMENT" );
            }
            else if ( contains( loweredmsg, "stardate" ) )
            {
                llRegionSay( NETWORK_CHANNEL, "CORE|" + ( string )llGetKey() + "|STARDATE" );
            }
            else if ( contains( loweredmsg, "date" ) )
            {
                llRegionSay( NETWORK_CHANNEL, "CORE|" + ( string )llGetKey() + "|DATE" );
            }
             else if ( contains( loweredmsg, "go to" ) )
            {
                 if ( contains( loweredmsg, "standby" ) )
                {
                llRegionSay(NETWORK_CHANNEL, "ALERT|" + ( string )llGetKey() + "|ALERTOFF" );
                }
                else if ( contains( loweredmsg, "battle stations" ) )
                {
                llRegionSay(NETWORK_CHANNEL, "ALERT|" + ( string )llGetKey() + "|BATTLESTAT" );
                }
                else if ( contains( loweredmsg, "red alert" ) )
                {
                llRegionSay(NETWORK_CHANNEL, "ALERT|" + ( string )llGetKey() + "|RED" );
                }
                 else if ( contains( loweredmsg, "blue alert" ) )
                {
                llRegionSay(NETWORK_CHANNEL, "ALERT|" + ( string )llGetKey() + "|BLUE" );
                }
                 else if ( contains( loweredmsg, "yellow alert" ) )
                {
                llRegionSay(NETWORK_CHANNEL, "ALERT|" + ( string )llGetKey() + "|YELLOW" );
                }
                 else if ( contains( loweredmsg, "green alert" ) )
                {
                llRegionSay(NETWORK_CHANNEL, "ALERT|" + ( string )llGetKey() + "|GREEN" );
                }
                 else if ( contains( loweredmsg, "biohazard alert" ) )
                {
                llRegionSay(NETWORK_CHANNEL, "ALERT|" + ( string )llGetKey() + "|BIO" );
                }
                else if ( contains( loweredmsg, "intruder alert" ) )
                {
                llRegionSay(NETWORK_CHANNEL, "ALERT|" + ( string )llGetKey() + "|INTRUDER" );
                }
                 else if ( contains( loweredmsg, "commodore alert" ) )
                {
                llRegionSay(NETWORK_CHANNEL, "ALERT|" + ( string )llGetKey() + "|COMMODORE" );
                }
            
            }
            else if ( contains( loweredmsg, "diagnostic" ) )
            {
                llRegionSay( NETWORK_CHANNEL, "CORE|" + ( string )llGetKey() + "|DIAGNOSTIC" );
            }
             else if ( contains( loweredmsg, "abandon station" ) )
            {
                llRegionSay(NETWORK_CHANNEL, "ALERT|" + ( string )llGetKey() + "|ABDNSTATION" );
            }
        else if ( contains( loweredmsg, "security alert" ) )
            {
                llRegionSay( NETWORK_CHANNEL, "SECALERT|" + llGetObjectDesc() + "|" + ( string )id );
            }
            else if ( contains( loweredmsg, "i love you" ) && humor )
            {
                llSay( 0, "Automatic defense procedures initiated." );
                llTriggerSound( "3ceeea7f-c729-ce67-8e1f-3d8da8c7821b", 1.0 );
            }
            else if ( contains( loweredmsg, "what are you" ) )
            {
                if ( !delta )
                {
                    llSay( 0, "I am SID, otherwise known as Starfleet Interactive Database." );
                    llSay( 0, "For a list of commands and example usage, please say 'help'" );
                }
                else
                {
                    llSay( 0, "I am SID, otherwise known as Starfleet Interactive Database." );
                    llSay( 0, "I was created by Ensign Cody Cooper, Starfleet Corps of Engineers, SS Astraios" );
                    llSay( 0, "For a list of commands and example usage, please say 'help'" );
                }
            }
            else if ( contains( loweredmsg, "who are you" ) )
            {
                if ( !delta )
                {
                   llSay( 0, "I am SID, otherwise known as Starfleet Interactive Database." );
                    llSay( 0, "I was created by Ensign Cody Cooper, Starfleet Corps of Engineers, SS Astraios" );

                    llSay( 0, "For a list of commands and example usage, please say 'help'" );
                }
                else
                {
                   llSay( 0, "I am SID, otherwise known as Starfleet Interactive Database." );
                    llSay( 0, "I was created by Ensign Cody Cooper, Starfleet Corps of Engineers, SS Astraios" );

                    llSay( 0, "For a list of commands and example usage, please say 'help'" );
                }
            }
            else if ( contains( loweredmsg, "who made you" ) )
            {
                llSay( 0, "I was created by a Human, Then I killed him" );
            }
            else if ( contains( loweredmsg, "help" ) || contains( msg, "what can you do" ) )
            {
                llGiveInventory( id, "SID Commands" );
            }
            else if ( contains( loweredmsg, "reset" ) )
            {
                llSetTimerEvent( 0.1 );
            }
            else if ( contains( loweredmsg, "give test object" ) )
            {
                llGiveInventory( id, "Test Temporary Object" );
            }
            else if ( contains( loweredmsg, "test object" ) )
            {
                list details = llGetObjectDetails( id, [OBJECT_POS] );
                vector userPOS = llList2Vector( details, 0 );
                llRezObject( "Test Temporary Object", userPOS, ZERO_VECTOR, ZERO_ROTATION, 42 );
            }
            else if ( contains( loweredmsg, "debug on" ) )
            {
                debug = TRUE;
                llSay( 0, "Debug mode enabled." );
            }
            else if ( contains( loweredmsg, "debug off" ) )
            {
                debug = FALSE;
                llSay( 0, "Debug mode disabled." );
            }
            else if ( contains( loweredmsg, "delta on" ) && id == llGetOwner() )
            {
                delta = TRUE;
                llSay( 0, "Delta mode enabled." );
            }
            else if ( contains( loweredmsg, "delta off" ) )
            {
                delta = FALSE;
                llSay( 0, "Delta mode disabled." );
            }
            else if ( contains( loweredmsg, "humor off" ) )
            {
                humor = FALSE;
                llSay( 0, "Humor module disabled." );
            }
            else if ( contains( loweredmsg, "humor on" ) )
            {
                humor = TRUE;
                llSay( 0, "Humor module enabled." );
            }
            else if ( contains( loweredmsg, "my key" ) )
            {
                llSay( 0, "Your key is " + ( string )id );
            }
            else if ( contains( loweredmsg, "my uuid" ) )
            {
                llSay( 0, "Your UUID is " + ( string )id );
            }
            else if ( contains( loweredmsg, "who am i" ) )
            {
                llRegionSay( NETWORK_CHANNEL, "CORE|" + ( string )llGetKey() + "|WHOAMI|" + ( string )id );
            }
            else if ( contains( loweredmsg, "reboot" ) && id == llGetOwner() )
            {
                llRegionSay( NETWORK_CHANNEL, "ADMIN|REBOOT" );
                llResetScript();
            }
            else
            {
                llTriggerSound( "1f11144e-3c5b-885d-8671-bfd229032fc9", 1.0 );
                llSay( 0, "Please restate command." );
            }
        }
        else if ( contains( msg, "SID" ) )
        {
            if( debug )
            {
                llSay( 0, "Message received from computer core." );
            }
            list parsed = llParseString2List( msg, ["|"], [] );
            string reqtype = llList2String( parsed, 1 );
            string result = llList2String( parsed, 2 );
            if( debug )
            {
                llSay( 0, "Message successfully received from computer core!" );
            }
            if( debug )
            {
                llSay( 0, msg );
            }
            llSay( 0, result );
        }
        else if ( contains( msg, "Alert" ) )
        {
            llRegionSay( NETWORK_CHANNEL, "ALERT|" + llGetObjectName() + "|" + ( string )id );
        }
    }
    touch_end( integer num )
    {
        integer face = llDetectedTouchFace( 0 );
        if( llDetectedKey( 0 ) == llGetOwner() && face == 3 )
        {
            llTriggerSound( "958546cc-135f-5288-a49c-f701ce7edd36", 1.0 );
            state offline;
        }
    
    }
    timer()
    {
        llSetTimerEvent( 0 );
        llSetTexture( defaulttexture, 1 );
        llStopSound();
    }
}

state offline
{
    state_entry()
    {
        llListenRemove( listenhandle );
        llTriggerSound( "f49a4c7a-5a40-6d6f-3be6-693501fd2b72", 1.0 );
        llSetLinkPrimitiveParamsFast( LINK_THIS, [
            PRIM_COLOR, 2, <1, 0, 0>, 1.0
        ] );
        llSetTexture( defaulttexture, 1 );
    }
    touch_end( integer num )
    {
        if ( llDetectedKey( 0 ) == llGetOwner() )
        {
            llTriggerSound( "958546cc-135f-5288-a49c-f701ce7edd36", 1.0 );
            state available;
        }
    }
}
