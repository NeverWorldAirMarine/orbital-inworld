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

// Definitions
key authrequest;
key user;
integer gListener; // Dialog listeners

// Configurable Settings
string authurl = "https://nwamgroup.com/app/modules/api/auth.php";
 float openingTime=2.0;      // in seconds
 float openingAngle=85.0;    // in degrees
 float autocloseTime=5.0;    // in seconds
 integer steps=1;            // number of internal rotation steps
 integer useOmega=TRUE; 
 float omega=0.0;
  
 vector axis;
 rotation closedRot;
 rotation openRot;
  
 integer swinging;
 integer open;
  
// Code
 openDoor(integer yes)
 {
     vector useAxis=axis;
     open=yes;
  
     if(!yes)
         useAxis=-axis;
  
     llSetTimerEvent(openingTime/(float) steps);
     if (useOmega) llTargetOmega(useAxis,omega,1.0);
 }
  
 go()
 {
     if(swinging==0)
     {
         if(!open)
         {
             axis=llRot2Up(llGetLocalRot());
             closedRot=llGetLocalRot();
             openRot=llEuler2Rot(<0.0,0.0,openingAngle>*DEG_TO_RAD)*closedRot;
         }
         swinging=steps;
         openDoor(!open);
     }
 }
  
 rotation  slerp(rotation source,rotation target,float amount)
 {
     float startAngle = llRot2Angle(source);
     float endAngle = llRot2Angle(target);
     
     //llOwnerSay((string)startAngle+ " " + (string)(startAngle*RAD_TO_DEG));
     //llOwnerSay((string)(endAngle*RAD_TO_DEG));
    // llOwnerSay(llRot2Axis(source*target));
     float thisAngle = (endAngle-startAngle) * amount + startAngle;
     //llOwnerSay((string)(thisAngle*RAD_TO_DEG));
     //if (thisAngle > PI) thisAngle -= TWO_PI;
     //llOwnerSay((string)(thisAngle*RAD_TO_DEG));
     
     rotation newRot;
     newRot = llAxisAngle2Rot(llRot2Axis(source*target),thisAngle);
     //newRot = llAxisAngle2Rot(<0.0,0.0,1.0>,thisAngle);
     //newRot = llAxisAngle2Rot(xaxis,thisAngle);
     return newRot;
 }
 
default
{
    state_entry()
    { 
        llSetText("", ZERO_VECTOR, 0);
         swinging=0;
         open=FALSE;
         omega=DEG_TO_RAD*openingAngle/openingTime;
         //omega=TWO_PI/360*openingAngle/openingTime;
         if (useOmega) llTargetOmega(ZERO_VECTOR,1.0,1.0);
    }
    touch_start(integer user)
    {
        llListenRemove( gListener );
        gListener = llListen( -2468, "", "", "" );
        llTextBox(llDetectedKey(0), "Please Enter Your Command Code", -2468 );
        llSetTimerEvent( 60.0 );
    }
    timer()
    {
        llListenRemove( gListener );
        llSetTimerEvent( 0 );
        if(swinging>0)
         {
             swinging--;
             if(swinging!=0)
             {
                 float amount=(float) swinging/(float) steps;
                 if(open)
                     amount=1.0-amount;
                 llSetLocalRot(slerp(closedRot,openRot,amount));
                 return;
             }
  
             if (useOmega) llTargetOmega(axis,0.0,0.0);
             if(open)
             {
                 llSetLocalRot(openRot);
                 llSetTimerEvent(autocloseTime);
             }
             else
             {
                 llSetLocalRot(closedRot);
                 llSetTimerEvent(0.0);
             }
         }
         else // autoclose time reached
         {
             llSetTimerEvent(0.0);
             openDoor(!open);
             swinging=steps;
         }
    }
    listen( integer chan, string name, key id, string msg )
    {
        llListenRemove( gListener );
        authrequest = llHTTPRequest( authurl, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], "uuid=" + ( string )id + "&code=" + ( string )msg );
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
                    llSay( 0, "Access Granted. Welcome, " + rank + " " + name + ".\nDivision: " + division);
                    go();
                    llSleep(5);
                    state default;
                }
                else if ( status == "ERROR" )
                {
                    string errcode = llList2String( result, 1 );
                    llSay( 0, "There was an error. Error: " + errcode );
                    llSleep( 2 );
                    state default;
                }
            }
            else if ( stat == 500 )
            {
                llSetText( "Error 500", <1, 1, 1>, 1.0 );
                llSleep( 2 );
                state default;
            }
            else
            {
                llSetText( "Generic Error: " + body, <1, 1, 1>, 1.0 );
                llSleep( 2 );
                state default;
            }
        }
    }
}

