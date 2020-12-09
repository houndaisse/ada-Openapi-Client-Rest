with Ves.Clients;
with Ves.Models;
with Swagger;
with Util.Http.Clients.Curl;
with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Exceptions;

procedure Ves.Client is

   use Ada.Text_IO;

   procedure Usage;
   Server    : constant Swagger.UString := Swagger.To_UString ("http://serveurves:8080");
-- Variables du descripteur json
   G    : character := '"';     -- guillemet
   V    : character := ',';     -- virgule
   Co   : character := '[';     -- crochet ouvrant
   Cf   : character := ']';     -- crochet fermant
   Ao   : character := '{';     -- accolade ouvrante
   Af   : character := '}';     -- accolade fermante  
   PV   : character := ';';     -- point-virgule
   DP   : character := ':';     -- deux-points
   E    : character := ' ';     -- espace
   GV   : string    := G & V;   -- guillemet + virgule 
   CoAo : string    := Co & Ao; -- crochet ouvrant + accolade ouvrante
   AoG  : string    := Ao & G;  -- accolade ouvrante + guillemet
   AfCf : string    := Af & Cf; -- accolade fermante + crocher fermant

   -- json
   Ves_Version   : string := "v7";
   Ves_Unique_Id : string := "fd69d432-5cd5-4c15-9d34-407c81c61c6a-0";
   -- commonEventHeader
   Ves_Version_Event_Header  : string := "3.0";
   Ves_Event                 : string := "Slave MPU is offline";
   Ves_Domain                : string := "fault";       
   Ves_Event_Id              : string := "1501489595451";
   Ves_Event_Type            : string := "applicationVnf";
   Ves_NFC_Naming_Code       : string := "nfcNamingCode";
   Ves_NF_Naming_Code        : string := "nfNamingCode";
   Ves_Source_Id             : string := "example-vnf-id-val-31366";
   Ves_Source_Name           : string := "example-vnf-name-val-51172";
   Ves_Reporting_Entity_Id   : string := "0000ZTHX1";
   Ves_Reporting_Entity_Name : string := "0000ZTHX1";
   Ves_Priority              : string := "High";
   Ves_Start_Epoch_MicroSec  : string := "1501518702";
   Ves_Last_Epoch_MicroSecy  : string := "1501518702";
   Ves_Sequence              : string := "960";
   -- faultFields
   Fault_Fields_Version      : string := "2.0";
   Event_Severity            : string := "CRITICAL";
   Event_Source_Type         : string := "PgwFunction";
   Event_Category            : string := "equipmentAlarm";
   Alarm_Condition           : string := "The slave MPU board is offline or abnormal";
   Specific_Problem          : string := "The slave MPU board is offline or abnormal";
   Vf_Status                 : string := "Active";
   Alarm_Interface_A         : string := "VNF_194.15.13.138";

   Alarm_Add_Inform_Spec_Pb_ID_Name     : string := "specificProblemID";
   Alarm_Add_Inform_Spec_Pb_ID_Value    : string := "315";
   Alarm_Add_Inform_Object_UID_Name     : string := "objectUID";
   Alarm_Add_Inform_Object_UID_Value    : string := "0000ZTHX1PGWGJI6V1";
   Alarm_Add_Inform_Location_Info_Name  : string := "locationInfo";
   Alarm_Add_Inform_Location_Info_Value : string := "MPU_22_20_0";
   Alarm_Add_Inform_Add_Info_Name       : string := "addInfo";
   Alarm_Add_Inform_Add_Info_Value      : string :=
       "Aid:17;AlarmCode:110010;AlarmReasonCode110010;Remark\""DeployUnit=22,Node=21,SubNode=0\"";";
   
   Alarm_Add_Inform   : string :=
     CoAo & """name"""  & DP & E & G & Alarm_Add_Inform_Spec_Pb_ID_Name      & G & V  &
            """value""" & DP & E & G & Alarm_Add_Inform_Spec_Pb_ID_Value     & G & Af & V  & Ao &

            """name"""  & DP & E & G & Alarm_Add_Inform_Object_UID_Name      & G & V  &
            """value""" & DP & E & G & Alarm_Add_Inform_Object_UID_Value     & G & Af & V  & Ao &

            """name"""  & DP & E & G & Alarm_Add_Inform_Location_Info_Name   & G & V  &
            """value""" & DP & E & G & Alarm_Add_Inform_Location_Info_Value  & G & Af & V  & Ao &

            """name"""  & DP & E & G & Alarm_Add_Inform_Add_Info_Name        & G & V  &
            """value""" & DP & E & G & Alarm_Add_Inform_Add_Info_Value       & G & Af &
          Cf;

   Json : string:= 
      AoG & "VESversion"  & G & DP & G & Ves_Version   & G & V &
        G & "VESuniqueId" & G & DP & G & Ves_Unique_Id & G & V;
    Event : string := G & "event" & G & DP & E & 
       Ao;
      Common_Event_Header : string := 
         """commonEventHeader"": " &
         Ao &
           """version"": "             &     Ves_Version_Event_Header  &  V &
           """eventName"": "           & G & Ves_Event                 & GV & 
           """domain"": "              & G & Ves_Domain                & GV &
           """eventId"": "             & G & Ves_Event_Id              & GV &
           """eventType"": "           & G & Ves_Event_Type            & GV &
           """nfcNamingCode"": "       & G & Ves_NFC_Naming_Code       & GV &
           """nfNamingCode"": "        & G & Ves_NF_Naming_Code        & GV &
           """sourceId"": "            & G & Ves_Source_Id             & GV &
           """sourceName"": "          & G & Ves_Source_Name           & GV &
           """reportingEntityId"": "   & G & Ves_Reporting_Entity_Id   & GV &
           """reportingEntityName"": " & G & Ves_Reporting_Entity_Name & GV &
           """priority"": "            & G & Ves_Priority              & GV &
           """startEpochMicrosec"": "  & G & Ves_Start_Epoch_MicroSec  & GV &
           """lastEpochMicrosec"": "   & G & Ves_Last_Epoch_MicroSecy  & GV &
           """sequence"": "            &     Ves_Sequence              &
         Af & V;
     Fault_Fields : string :=
         """faultFields""" & DP &
         Ao &
           """faultFieldsVersion"""         & DP & E & G &  Fault_Fields_Version & GV &
           """eventSeverity"""              & DP & E & G &  Event_Severity       & GV &
           """eventSourceType"""            & DP & E & G &  Event_Source_Type    & GV &
           """eventCategory"""              & DP & E & G &  Event_Category       & GV &
           """alarmCondition"""             & DP & E & G &  Alarm_Condition      & GV &
           """specificProblem"""            & DP & E & G &  Specific_Problem     & GV &
           """vfStatus"""                   & DP & E & G &  Vf_Status            & GV &
           """alarmInterfaceA"""            & DP & E & G &  Alarm_Interface_A    & GV &
           """alarmAdditionalInformation""" & DP & E &      Alarm_Add_Inform     &
         Af &
       Af &
     Af;

   Cr : string := Json & Event & Common_Event_Header & Fault_Fields;

   procedure Usage is
   begin
      Put_Line ("Usage: ves {params}...");
   end Usage;

begin
   Util.Http.Clients.Curl.Register;
   declare
      --Command : constant String := Ada.Command_Line.Argument (Arg);
      C       : Ves.Clients.Client_Type;
      Title   : Swagger.UString;
      Result : Swagger.UString;
   begin
      C.Set_Server (Server);
      Title := Swagger.To_UString (Cr);
      C.Receive_Event_Using_POST (Title, Result);
   exception
      when E : Constraint_Error =>
         Put_Line ("Constraint error raised: " & Ada.Exceptions.Exception_Message (E));

   end;
end Ves.Client;
