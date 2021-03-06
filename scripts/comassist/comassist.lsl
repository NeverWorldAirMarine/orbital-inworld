/*
* Copyright 2018 Orbital Group
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


string ACCOUNT_LIST = "https://orbital.omega-grid.org/modules/api/online.php";
key queryID; // the id key 
key REQ;
integer DEBUG = FALSE;
list ACCOUNT_IDS = [];

list PostParams = [HTTP_VERBOSE_THROTTLE, FALSE, HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"];

default
{
    state_entry()
    {
        llSay( 0, "Starting Script." );
        REQ = llHTTPRequest( ACCOUNT_LIST, PostParams, "debug=" + ( string )DEBUG + "&branch=lookup" );
        //llSetTimerEvent(10.0);
    }

    timer()
    {
        llSetTimerEvent( 0.0 );
        REQ = llHTTPRequest( ACCOUNT_LIST, PostParams, "debug=" + ( string )DEBUG + "&branch=lookup" );
    }

    http_response( key req , integer stat, list met, string body )
    {
        if( DEBUG )
        {
            llSay( 0, body );
        }
        // Fall back for any error messages that come back.
        if( req == REQ )
        {
            if( llToLower( llList2String( llParseString2List( body, ["|"], [""] ), 0 ) ) == "error" )
            {
                llOwnerSay( llList2String( llParseString2List( body, ["|"], [""] ), 1 ) );
            }
            else if( llToLower( llList2String( llParseString2List( body, ["|"], [""] ), 0 ) ) == "accounts" )
            {
                ACCOUNT_IDS = llDeleteSubList( llParseString2List( body, ["|"], [""] ), 0, 0 ); //Drop the First Entry ACCOUNTS
                ACCOUNT_IDS = llDeleteSubList( ACCOUNT_IDS, -1, -1 ); //Dump the Last entry -EOF-
                queryID = llRequestAgentData( llList2Key( ACCOUNT_IDS, 0 ), DATA_ONLINE ); // returns if the owner is online or not
            }
        }
    }

    dataserver( key query, string info )
    {
        // find the correct query id
        if( query == queryID && llGetListLength( ACCOUNT_IDS ) > 0 )
        {
            string message;
            if( info == "0" )   //Offline
            {
                if( DEBUG )
                {
                    llSay( 0, "secondlife:///app/agent/" + ( string )llList2Key( ACCOUNT_IDS, 0 ) + "/about is now marked as Offline" );
                }
                llHTTPRequest( ACCOUNT_LIST, PostParams, "debug=" + ( string )DEBUG + "&branch=remove&uuid=" + ( string )llList2Key( ACCOUNT_IDS, 0 ) );
                ACCOUNT_IDS = llDeleteSubList( ACCOUNT_IDS, 0, 0 ); //Drop the First Entry
                queryID = llRequestAgentData( llList2Key( ACCOUNT_IDS, 0 ), DATA_ONLINE ); // returns if the owner is online or not
            }
            else if( info == "1" )   //Online just remove them from our check list we dont want to remove there commlink
            {
                ACCOUNT_IDS = llDeleteSubList( ACCOUNT_IDS, 0, 0 ); //Drop the First Entry
                queryID = llRequestAgentData( llList2Key( ACCOUNT_IDS, 0 ), DATA_ONLINE ); // returns if the NEXT owner is online or not
            }
        }
        else
        {
            llSetTimerEvent( 60.0 );
        }
    }
}