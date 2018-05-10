<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>MSPFS_Work_Order_Assigned_to_Tech</fullName>
        <description>MSPFS Work Order Assigned to Tech</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>UNITY_Primary_Technician__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>minerdev@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/MSPFS_Work_Order_Assigned_Tech</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Send_Purchase_Order</fullName>
        <ccEmails>vendorsupport_uat@minercorp.com</ccEmails>
        <description>UNITY Send Purchase Order</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Purchase_Order_New</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Send_Purchase_Order_Craft</fullName>
        <ccEmails>vendor_Support_Craft@email.address</ccEmails>
        <description>UNITY Send Purchase Order Craft</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Purchase_Order_New</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Send_Purchase_Order_MNS</fullName>
        <ccEmails>vendorsupport_uat@minercorp.com</ccEmails>
        <description>UNITY Send Purchase Order MNS</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Purchase_Order_New</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Send_Purchase_Order_MNS_Disney</fullName>
        <ccEmails>vendorsupport_uat@minercorp.com</ccEmails>
        <description>UNITY Send Purchase Order MNS - Disney</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Purchase_Order_New_Disney</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Send_Purchase_Order_MNS_TJX</fullName>
        <ccEmails>vendorsupport_uat@minercorp.com</ccEmails>
        <description>UNITY Send Purchase Order MNS - TJX</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Purchase_Order_New_TJX</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Send_Purchase_Order_NSBS</fullName>
        <ccEmails>vendorsupport_uat@minercorp.com</ccEmails>
        <description>UNITY Send Purchase Order NSBS</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Purchase_Order_New</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Work_Order_Acceptance</fullName>
        <description>UNITY Work Order Acceptance</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Work_Order_Acceptance</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Work_Order_Acceptance_Craft</fullName>
        <ccEmails>Vendor_Support_Craft@email.address</ccEmails>
        <description>UNITY Work Order Acceptance Craft</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Work_Order_Acceptance_v2_Craft</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Work_Order_Acceptance_MNS</fullName>
        <description>UNITY Work Order Acceptance MNS</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Work_Order_Acceptance_v2_Miner</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Work_Order_Acceptance_MNS_Disney</fullName>
        <description>UNITY Work Order Acceptance MNS Disney</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Work_Order_Acceptance_MNS_Disney</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Work_Order_Acceptance_MNS_TJX</fullName>
        <description>UNITY Work Order Acceptance MNS TJX</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Work_Order_Acceptance_MNS_TJX</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Work_Order_Acceptance_NSBS</fullName>
        <description>UNITY Work Order Acceptance NSBS</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Work_Order_Acceptance_v2_NSBS</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Work_Order_Assignment_Notification</fullName>
        <ccEmails>customersupport_uat@minercorp.com</ccEmails>
        <description>UNITY Work Order Assignment Notification</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_WorkOrder_Assignment</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Work_Order_Assignment_Notification_Craft_Vendor</fullName>
        <ccEmails>Vendor_Support_Craft@email.address</ccEmails>
        <description>UNITY Work Order Assignment Notification Craft Vendor</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_WorkOrder_Assignment</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Work_Order_Assignment_Notification_MNS_Vendor</fullName>
        <ccEmails>vendorsupport_uat@minercorp.com</ccEmails>
        <description>UNITY Work Order Assignment Notification MNS Vendor</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_WorkOrder_Assignment</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Work_Order_Assignment_Notification_NSBS_Vendor</fullName>
        <ccEmails>vendorsupport_uat@nsbs.net</ccEmails>
        <description>UNITY Work Order Assignment Notification NSBS Vendor</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_WorkOrder_Assignment</template>
    </alerts>
    <fieldUpdates>
        <fullName>Attachment_Compliant_Checkbox_True</fullName>
        <field>UNITY_Attachment_Compliant__c</field>
        <literalValue>1</literalValue>
        <name>Attachment Compliant Checkbox - True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FSO__Update_WO_Lat_Field</fullName>
        <field>Latitude</field>
        <formula>Account.BillingLatitude</formula>
        <name>Update WO Lat Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FSO__Update_WO_Lat_Field2</fullName>
        <field>FSO__Geolocation__Latitude__s</field>
        <formula>Account.BillingLatitude</formula>
        <name>Update WO Lat Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FSO__Update_WO_Long_Field</fullName>
        <field>Longitude</field>
        <formula>Account.BillingLongitude</formula>
        <name>Update WO Long Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FSO__Update_WO_Long_Field2</fullName>
        <field>FSO__Geolocation__Longitude__s</field>
        <formula>Account.BillingLongitude</formula>
        <name>Update WO Long Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FSO__WO_Latitude_Update</fullName>
        <field>FSO__Geolocation__Latitude__s</field>
        <formula>Account.BillingLatitude</formula>
        <name>WO Latitude Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_Date_Debriefed_Completed</fullName>
        <field>UNITY_Date_Time_Debrief_Completed__c</field>
        <name>Remove Date Debriefed Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Intercompany_Transfer_Flag</fullName>
        <description>Reset the intercompany transfer flag</description>
        <field>MSPFS_Intercompany_Transfer__c</field>
        <literalValue>0</literalValue>
        <name>Reset Intercompany Transfer Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SFPS_FS_FirstCheckIn_Set</fullName>
        <field>SFPS_FS_FirstCheckIn__c</field>
        <formula>FSO__Check_In_Date__c</formula>
        <name>SFPS FS First CheckIn Set</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SFPS_FS_FirstTravel_Set</fullName>
        <field>SFPS_FS_FirstTravel__c</field>
        <formula>FSO__Start_Travel_Date__c</formula>
        <name>SFPS FS First Travel Set</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SFPS_FS_Is_Vendor_Dispatcher</fullName>
        <description>Updates if Accepted Vendor account record contains a Vendor Dispatcher value</description>
        <field>SFPS_FS_Is_Vendor_Dispatcher__c</field>
        <literalValue>1</literalValue>
        <name>SFPS FS Is Vendor Dispatcher?</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SFPS_FS_OverallStatus_InProgress</fullName>
        <field>SFPS_FS_OverallStatus__c</field>
        <literalValue>In Progress</literalValue>
        <name>SFPS FS Overall Status In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SFPS_FS_OverallStatus_New</fullName>
        <field>SFPS_FS_OverallStatus__c</field>
        <literalValue>New</literalValue>
        <name>SFPS FS Overall Status New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SFPS_OverallStartDate_Set</fullName>
        <field>SFPS_FS_Overall_Start__c</field>
        <formula>StartDate</formula>
        <name>SFPS Overall Start Date Set</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_All_Task_Completed</fullName>
        <description>Set all task completed? on WO to Completed</description>
        <field>SFPS_FS_AllTasks_Completed__c</field>
        <literalValue>All Tasks Completed/Verified</literalValue>
        <name>Set All Task Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Margin_Approved</fullName>
        <field>UNITY_Margin_Approved__c</field>
        <literalValue>1</literalValue>
        <name>Set Margin Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Next_Step_Confirmed</fullName>
        <field>UNITY_Next_Step__c</field>
        <literalValue>Completion Confirmed</literalValue>
        <name>Set Next Step Confirmed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_WO_Margin_Approval</fullName>
        <field>Status</field>
        <literalValue>Pending Margin Approval</literalValue>
        <name>Set WO Margin Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY</fullName>
        <description>Update Scheduled Date/Time field on WO based on when Dispatcher assigns technician to a Start Date on WO</description>
        <field>UNITY_Scheduled_Date_Time__c</field>
        <formula>Now()</formula>
        <name>UNITY_Scheduled_Date_Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Attachment_Compliance_to_True</fullName>
        <description>Set Attachment Compliant checkbox to true on Work Order</description>
        <field>UNITY_Attachment_Compliant__c</field>
        <literalValue>1</literalValue>
        <name>UNITY Attachment Compliance to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Check_Attachment_Compliant</fullName>
        <field>UNITY_Attachment_Compliant__c</field>
        <literalValue>1</literalValue>
        <name>Check Attachment Compliant</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Clear_ACTION_field</fullName>
        <description>When the action picklist is set to reject, flip the vendor assignment status to &apos;Reject-Other&apos; and clear the action picklist field itself. if action picklist is set to &quot;Accept&quot;, change vendor assignment status to &quot;Accepted&quot; and dont clear the action field</description>
        <field>UNITY_Action__c</field>
        <name>Clear ACTION field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Clear_Comments_field</fullName>
        <field>UNITY_Work_Order_Notes__c</field>
        <name>Clear Comments field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Clear_WO_Comments</fullName>
        <field>UNITY_Work_Order_Notes__c</field>
        <name>Clear WO Comments</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_FlagWOContractPricing</fullName>
        <field>UNITY_Include__c</field>
        <literalValue>1</literalValue>
        <name>UNITY_FlagWOContractPricing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_FlagWOMenuPricing</fullName>
        <field>UNITY_Use_Menu_Pricing__c</field>
        <literalValue>1</literalValue>
        <name>UNITY_FlagWOMenuPricing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_OON_Vendor_Eligible</fullName>
        <field>UNITY_OON_Vendor_Eligible__c</field>
        <literalValue>1</literalValue>
        <name>OON Vendor Eligible</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Reject_WorkOrder_No_Response</fullName>
        <field>UNITY_Vendor_Status__c</field>
        <literalValue>Rejected-No Response</literalValue>
        <name>UNITY Reject WorkOrder - No Response</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Rem_Ttl_Min_Btw_Last_IVR_Debrif</fullName>
        <field>UNITY_Time_to_Debrief__c</field>
        <name>Remove Total Min Btw Last IVR and Debrif</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Remove_Debrief_User_Name</fullName>
        <field>UNITY_Debrief_Agent__c</field>
        <name>Remove Debrief User Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_Accept_Time_to_30_mins</fullName>
        <description>Set Accept Time to 16 hrs for 12, 24, 48, 72 hr response</description>
        <field>UNITY_Accept_Time__c</field>
        <formula>30</formula>
        <name>Set Accept Time to 30 mins</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_Accept_Time_to_60_mins</fullName>
        <description>Set accept time to 60 mins for Project and Planned Maintenance priorities</description>
        <field>UNITY_Accept_Time__c</field>
        <formula>60</formula>
        <name>Set Accept Time to 60 mins</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_Accept_time_2_4_Hr_Response</fullName>
        <description>Sets Accept time to 15mins for priority 2/4 Hr response</description>
        <field>UNITY_Accept_Time__c</field>
        <formula>15</formula>
        <name>Set Accept time - 2/4 Hr Response</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_Attachment_Date</fullName>
        <field>UNITY_Attachment_Completed_At__c</field>
        <formula>Now()</formula>
        <name>Set Attachment Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_Complete_Date</fullName>
        <field>UNITY_Complete_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Set_Complete_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_Vendor_PO_Sent_Timestamp</fullName>
        <field>UNITY_Vendor_PO_Sent_Date__c</field>
        <formula>NOW()</formula>
        <name>UNITY Set Vendor PO Sent Timestamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_Vendor_Status_Accepted</fullName>
        <description>When the action picklist is set to reject, flip the vendor assignment status to &apos;Reject-Other&apos; and clear the action picklist field itself. if action picklist is set to &quot;Accept&quot;, change vendor assignment status to &quot;Accepted&quot; and dont clear the action field</description>
        <field>UNITY_Vendor_Status__c</field>
        <literalValue>Accepted</literalValue>
        <name>Set Vendor Status Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_WOStatus_to_Pending_Assignment</fullName>
        <description>Set WO statu sot pending assignment</description>
        <field>Status</field>
        <literalValue>Pending Assignment</literalValue>
        <name>Set WO Status to Pending Assignment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_WO_IVR_Checkout</fullName>
        <field>Status</field>
        <literalValue>IVR Check Out - Agent Review Needed</literalValue>
        <name>Set WO IVR Checkout</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_WO_Pending_Dispatch</fullName>
        <field>Status</field>
        <literalValue>Pending Tech Dispatch</literalValue>
        <name>Set WO Pending Dispatch</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_WO_Status_to_NEW</fullName>
        <field>Status</field>
        <literalValue>New</literalValue>
        <name>Set WO Status to NEW</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_WO_Tech_Onsite</fullName>
        <field>Status</field>
        <literalValue>Tech Onsite</literalValue>
        <name>Set WO Tech Onsite</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_WO_to_Accept</fullName>
        <description>Set WO status to Accept</description>
        <field>Status</field>
        <literalValue>Accepted</literalValue>
        <name>Set WO to Accept</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_WO_to_Assigned</fullName>
        <field>Status</field>
        <literalValue>Assigned</literalValue>
        <name>Set WO to Assigned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_WO_to_Completed</fullName>
        <description>UNITY_Set_WO_to_Completed</description>
        <field>Status</field>
        <literalValue>Completed</literalValue>
        <name>Set WO to Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_WO_to_In_Progress</fullName>
        <field>Status</field>
        <literalValue>In Progress</literalValue>
        <name>Set WO to In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_WO_to_In_transit</fullName>
        <description>Set WO to In transit</description>
        <field>Status</field>
        <literalValue>In Transit</literalValue>
        <name>Set WO to In transit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_WO_to_Pending_Accept</fullName>
        <description>Set WO status to Pending Acceptance</description>
        <field>Status</field>
        <literalValue>Pending Acceptance</literalValue>
        <name>Set WO to Pending Accept</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Start_Date_Time_Not_Missed</fullName>
        <field>UNITY_Start_Date_Time_Missed__c</field>
        <literalValue>0</literalValue>
        <name>Start Date/Time Not Missed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_FSO_Start_date</fullName>
        <field>StartDate</field>
        <formula>Now()</formula>
        <name>Update FSO Start date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Vendor_Status_Reject_Other</fullName>
        <description>When the action picklist is set to reject, flip the vendor assignment status to &apos;Reject-Other&apos; and clear the action picklist field itself. if action picklist is set to &quot;Accept&quot;, change vendor assignment status to &quot;Accepted&quot; and dont clear the action field</description>
        <field>UNITY_Vendor_Status__c</field>
        <literalValue>Rejected-Other</literalValue>
        <name>Update Vendor Status to Reject Other</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_WO_Combined_Comments</fullName>
        <field>UNITY_Combined_Notes__c</field>
        <formula>&apos;******&apos; + BR() + &apos;Created By:&apos; + $User.FirstName + &quot; &quot; + $User.LastName + &apos; (&apos; + TEXT(Today()) + &apos; &apos; + 
CASE( TEXT($User.UNITY_Segment__c), 
&apos;MNS&apos;, 
IF( 
OR( 
VALUE( MID( TEXT( NOW() - 0.25 ), 12, 2 ) ) = 0, 
VALUE( MID( TEXT( NOW() - 0.25 ), 12, 2 ) ) = 12 
), 
&quot;12&quot;, 
TEXT( VALUE( MID( TEXT( NOW() - 0.25 ), 12, 2 ) ) 
- 
IF( 
VALUE( MID( TEXT( NOW() - 0.25 ), 12, 2 ) ) &lt; 12, 
0, 
12 
) 
) 
) 
&amp; &quot;:&quot; &amp; 
MID( TEXT( NOW() - 0.25 ), 15, 2 ) 
&amp; &quot;:&quot; &amp; 
MID( TEXT( NOW() - 0.25 ), 18, 2 ) 
&amp; &quot; &quot; &amp; 
IF( 
VALUE( MID( TEXT( NOW() - 0.25 ), 12, 2 ) ) &lt; 12, 
&quot;AM&quot;, 
&quot;PM&quot; 
), 
&apos;NSBS&apos;, 
IF( 
OR( 
VALUE( MID( TEXT( NOW() - 0.3333), 12, 2 ) ) = 0, 
VALUE( MID( TEXT( NOW() - 0.3333), 12, 2 ) ) = 12 
), 
&quot;12&quot;, 
TEXT( VALUE( MID( TEXT( NOW() - 0.3333), 12, 2 ) ) 
- 
IF( 
VALUE( MID( TEXT( NOW() - 0.3333), 12, 2 ) ) &lt; 12, 
0, 
12 
) 
) 
) 
&amp; &quot;:&quot; &amp; 
MID( TEXT( NOW() - 0.3333), 15, 2 ) 
&amp; &quot;:&quot; &amp; 
MID( TEXT( NOW() - 0.3333), 18, 2 ) 
&amp; &quot; &quot; &amp; 
IF( 
VALUE( MID( TEXT( NOW() - 0.3333), 12, 2 ) ) &lt; 12, 
&quot;AM&quot;, 
&quot;PM&quot; 
), 
IF( 
OR( 
VALUE( MID( TEXT( NOW()), 12, 2 ) ) = 0, 
VALUE( MID( TEXT( NOW()), 12, 2 ) ) = 12 
), 
&quot;12&quot;, 
TEXT( VALUE( MID( TEXT( NOW()), 12, 2 ) ) 
- 
IF( 
VALUE( MID( TEXT( NOW() ), 12, 2 ) ) &lt; 12, 
0, 
12 
) 
) 
) 
&amp; &quot;:&quot; &amp; 
MID( TEXT( NOW() ), 15, 2 ) 
&amp; &quot;:&quot; &amp; 
MID( TEXT( NOW() ), 18, 2 ) 
&amp; &quot; &quot; &amp; 
IF( 
VALUE( MID( TEXT( NOW()), 12, 2 ) ) &lt; 12, 
&quot;AM GMT&quot;, 
&quot;PM GMT&quot; 
) 
) 

+ &apos;)&apos; + BR() + UNITY_Work_Order_Notes__c + BR() + &apos;******&apos; + BR()+ UNITY_Combined_Notes__c

/** &apos;******&apos; + BR() + &apos;Created By:&apos; + $User.FirstName + &quot; &quot; + $User.LastName + &apos; (&apos; + TEXT(Today()) + &apos;)&apos; + BR() + UNITY_Work_Order_Notes__c + BR() + &apos;******&apos;+ BR() + UNITY_Combined_Notes__c **/</formula>
        <name>Update WO Combined Comments</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_WO_SelfPerform_Status</fullName>
        <description>Update Work Order status when owner of record is Self-Perform Dispatcher and status is New</description>
        <field>Status</field>
        <name>UNITY_Update_WO_SelfPerform_Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Work_Window_End</fullName>
        <field>UNITY_Work_Window_End__c</field>
        <formula>IF(ISPICKVAL( Priority ,&quot;2 Hour Response&quot;), UNITY_Work_Window_Begin__c + 0.083333333333333, 
IF(ISPICKVAL( Priority ,&quot;4 Hour Response&quot;),UNITY_Work_Window_Begin__c + 0.166666666666667, 
IF(ISPICKVAL( Priority ,&quot;12 Hour Response&quot;),UNITY_Work_Window_Begin__c + 0.5, 
IF(ISPICKVAL( Priority ,&quot;24 Hour Response&quot;),UNITY_Work_Window_Begin__c + 1.0, 
IF(ISPICKVAL( Priority ,&quot;48 Hour Response&quot;),UNITY_Work_Window_Begin__c + 2.0, 
IF(ISPICKVAL( Priority ,&quot;72 Hour Response&quot;),UNITY_Work_Window_Begin__c + 3.0, 
NOW()))))))</formula>
        <name>Update Work Window End</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_WO_Accepted</fullName>
        <field>UNITY_WO_Assigned_Not_Accepted__c</field>
        <literalValue>0</literalValue>
        <name>WO Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_WO_Assigned</fullName>
        <field>UNITY_WO_Created_Not_Assigned__c</field>
        <literalValue>0</literalValue>
        <name>WO Assigned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_WO_Checked_in_before_SLA</fullName>
        <field>UNITY_SLA_Expired__c</field>
        <literalValue>0</literalValue>
        <name>WO Checked-in before SLA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_WO_Not_Checked_In_Checkmark</fullName>
        <field>UNITY_Start_Date_Time_Missed__c</field>
        <literalValue>1</literalValue>
        <name>WO Not Checked-In Checkmark</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_WO_Not_Yet_Accepted_Checkmark</fullName>
        <field>UNITY_WO_Assigned_Not_Accepted__c</field>
        <literalValue>1</literalValue>
        <name>WO Not Yet Accepted Checkmark</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_WO_Not_Yet_Scheduled_Checkmark</fullName>
        <field>UNITY_WO_Accepted_Not_Scheduled__c</field>
        <literalValue>1</literalValue>
        <name>WO Not Yet Scheduled Checkmark</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_WO_SLA_Expiry_Checkmark</fullName>
        <field>UNITY_SLA_Expired__c</field>
        <literalValue>1</literalValue>
        <name>WO SLA Expiry Checkmark</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_WO_Scheduled</fullName>
        <field>UNITY_WO_Accepted_Not_Scheduled__c</field>
        <literalValue>0</literalValue>
        <name>WO Scheduled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_WO_SetLastCheckOut</fullName>
        <description>Sets the last check-out date with the date on the check-out field</description>
        <field>SFPS_FS_LastCheckOut__c</field>
        <formula>FSO__Completed_Date__c</formula>
        <name>UNITY_WO_SetLastCheckOut</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_WO_Work_Window_Begin</fullName>
        <field>UNITY_Work_Window_Begin__c</field>
        <formula>Case.UNITY_Work_Window_Begin__c</formula>
        <name>UNITY_WO_Work_Window_Begin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_WO_Work_Window_End</fullName>
        <field>UNITY_Work_Window_End__c</field>
        <formula>Case.UNITY_Work_Window_End__c</formula>
        <name>UNITY_WO_Work_Window_End</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WO_Not_Yet_Assigned_Checkmark</fullName>
        <field>UNITY_WO_Created_Not_Assigned__c</field>
        <literalValue>1</literalValue>
        <name>WO Not Yet Assigned Checkmark</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Default Attachment Compliant Check Box</fullName>
        <actions>
            <name>Attachment_Compliant_Checkbox_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND (RecordType.DeveloperName != &apos;Preventative_Maintenance&apos;, OR (    ISBLANK( UNITY_Customer_Service_Contract__r.UNITY_Required_Documentation__c ),    RecordType.DeveloperName = &apos;UNITY_Non_Work&apos; ))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MSPFS - WO Acceptance Email</fullName>
        <actions>
            <name>MSPFS_Work_Order_Assigned_to_Tech</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UNITY_Set_Vendor_PO_Sent_Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Email template to be sent to the WO owner when the Service request Work Order BU Account Is MSP BU and Work Order Status changed to &quot;Assigned&quot;</description>
        <formula>AND( CONTAINS(TEXT(UNITY_Business_Unit__c),&quot;MSP&quot;),  CASESAFEID(UNITY_Accepted_Vendor__c) == CASESAFEID(UNITY_Business_Unit_Account__c),  ISPICKVAL(Status, &quot;Assigned&quot;),  RecordType.DeveloperName = &quot;Service_Request&quot;  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SFPS_FS_Is_Vendor_Dispatcher</fullName>
        <actions>
            <name>SFPS_FS_Is_Vendor_Dispatcher</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Determines if Accepted Vendor account has a Vendor Dispatcher, used for Multi-Day PB</description>
        <formula>NOT(ISBLANK( UNITY_Vendor_Dispatcher__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SFPS_FS_SyncFirstCheckIn</fullName>
        <actions>
            <name>SFPS_FS_FirstCheckIn_Set</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.SFPS_FS_FirstCheckIn__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.FSO__Check_In_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SFPS_FS_SyncStartTravel</fullName>
        <actions>
            <name>SFPS_FS_FirstTravel_Set</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SFPS_FS_OverallStatus_InProgress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.SFPS_FS_FirstTravel__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.FSO__Start_Travel_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SFPS_FS_SyncWOLevelStatus_InProgress</fullName>
        <actions>
            <name>SFPS_FS_OverallStatus_InProgress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.Status</field>
            <operation>notEqual</operation>
            <value>New,Canceled,Completed,Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.RecordTypeId</field>
            <operation>equals</operation>
            <value>Service Request,Preventative Maintenance,Project Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.SFPS_FS_OverallStatus__c</field>
            <operation>notEqual</operation>
            <value>In Progress</value>
        </criteriaItems>
        <description>Set Overall Status = In Progress when WO status &lt;&gt; New, Completed, Canceled, Closed

OR(
NOT(ISPICKVAL( Status, &quot;New&quot;)),
NOT(ISPICKVAL( Status, &quot;Completed&quot;)),
NOT(ISPICKVAL( Status, &quot;Canceled&quot;)),
NOT(ISPICKVAL( Status, &quot;Closed&quot;))
)</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SFPS_FS_SyncWOLevelStatus_New</fullName>
        <actions>
            <name>SFPS_FS_OverallStatus_New</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>WorkOrder.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <description>Set Overall WO status to &apos;New&apos; when WO status is = &apos;New&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SFPS_OverallStartDate_Set</fullName>
        <actions>
            <name>SFPS_OverallStartDate_Set</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK ( SFPS_FS_Overall_Start__c ) &amp;&amp; ISCHANGED ( StartDate )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY - WO Acceptance Email</fullName>
        <actions>
            <name>UNITY_Work_Order_Acceptance</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UNITY_Set_Vendor_PO_Sent_Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Email template to be sent to the WO owner when the WO.Vendor_Status = Accepted</description>
        <formula>NOT(RecordType.Name = &quot;Preventative Maintenance&quot;) &amp;&amp; ISPICKVAL(UNITY_Vendor_Status__c, &apos;Accepted&apos;) &amp;&amp; !ISBLANK(UNITY_Current_PO__c) &amp;&amp; ISBLANK(UNITY_Vendor_PO_Sent_Date__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY - WO Acceptance Email Craft</fullName>
        <actions>
            <name>UNITY_Work_Order_Acceptance_Craft</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UNITY_Set_Vendor_PO_Sent_Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Email template to be sent to the WO owner when the WO.Vendor_Status = Accepted &amp; BU = Craft</description>
        <formula>ISPICKVAL(UNITY_Vendor_Status__c, &apos;Accepted&apos;) &amp;&amp; !ISBLANK(UNITY_Current_PO__c) &amp;&amp; ISBLANK(UNITY_Vendor_PO_Sent_Date__c) &amp;&amp; ISPICKVAL( UNITY_Business_Unit__c ,&apos;Craft&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY - WO Acceptance Email MNS</fullName>
        <actions>
            <name>UNITY_Work_Order_Acceptance_MNS</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UNITY_Set_Vendor_PO_Sent_Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Email template to be sent to the WO owner when the WO.Vendor_Status = Accepted &amp; BU = MNS</description>
        <formula>NOT(RecordType.Name = &quot;Preventative Maintenance&quot;) &amp;&amp; ISPICKVAL(UNITY_Vendor_Status__c, &apos;Accepted&apos;) &amp;&amp; !ISBLANK(UNITY_Current_PO__c) &amp;&amp; ISBLANK(UNITY_Vendor_PO_Sent_Date__c) &amp;&amp;  OR( ISPICKVAL(UNITY_Business_Unit__c,&apos;MNS&apos;),  CONTAINS( UNITY_Business_Unit_Formula__c , &apos;MSP&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY - WO Acceptance Email NSBS</fullName>
        <actions>
            <name>UNITY_Work_Order_Acceptance_NSBS</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UNITY_Set_Vendor_PO_Sent_Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Email template to be sent to the WO owner when the WO.Vendor_Status = Accepted &amp; BU = NSBS</description>
        <formula>NOT(RecordType.Name = &quot;Preventative Maintenance&quot;) &amp;&amp; ISPICKVAL(UNITY_Vendor_Status__c, &apos;Accepted&apos;) &amp;&amp; !ISBLANK(UNITY_Current_PO__c) &amp;&amp; ISBLANK(UNITY_Vendor_PO_Sent_Date__c) &amp;&amp; ISPICKVAL( UNITY_Business_Unit__c ,&apos;NSBS&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY BS Vendor Contract on Non-Work Work Order</fullName>
        <active>false</active>
        <description>Non-Work Work Order - need to populate vendor service contract</description>
        <formula>AND(RecordType.DeveloperName = &apos;UNITY_NoN_Work&apos;, ISBLANK(UNITY_Vendor_Contract__c) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UNITY Non-Work Document Compliance</fullName>
        <actions>
            <name>UNITY_Attachment_Compliance_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.RecordTypeId</field>
            <operation>equals</operation>
            <value>Non-Work</value>
        </criteriaItems>
        <description>Set document compliance to true for all non-work work orders</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UNITY Set Attachment date</fullName>
        <actions>
            <name>UNITY_Set_Attachment_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.UNITY_Attachment_Compliant__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY WO Non-Work Auto Attachment Compliat</fullName>
        <actions>
            <name>UNITY_Attachment_Compliance_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.RecordTypeId</field>
            <operation>equals</operation>
            <value>Non-Work</value>
        </criteriaItems>
        <description>Automatically set Non-Work WO to Attachment Compliant = true on create</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Attachment Compliant for Non-Work</fullName>
        <actions>
            <name>UNITY_Check_Attachment_Compliant</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.RecordTypeId</field>
            <operation>equals</operation>
            <value>Non-Work</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_ContractPricingWorkOrder</fullName>
        <actions>
            <name>UNITY_FlagWOContractPricing</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(UNITY_Customer_Service_Contract__r.UNITY_Contract_Sub_type__c , &quot;Contract Pricing&quot;) &amp;&amp; RecordType.Name = &quot;Service Request&quot; &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_De-escalation - WO Accepted but not Scheduled</fullName>
        <actions>
            <name>UNITY_WO_Scheduled</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordType.Name = &apos;Service Request&apos; &amp;&amp;  RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; ISPICKVAL(UNITY_Vendor_Status__c, &apos;Accepted&apos;)&amp;&amp;  !ISBLANK(UNITY_Vendor_Accept_Date__c ) &amp;&amp;  !ISBLANK( StartDate  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_De-escalation - WO Assigned but Not Accepted</fullName>
        <actions>
            <name>UNITY_WO_Accepted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordType.Name = &apos;Service Request&apos; &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; ISPICKVAL(UNITY_Vendor_Status__c, &apos;Accepted&apos;)&amp;&amp; !UNITY_Auto_Dispatch__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_De-escalation - WO Created but Not Assigned</fullName>
        <actions>
            <name>UNITY_WO_Assigned</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordType.Name = &apos;Service Request&apos; &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; !ISPICKVAL(UNITY_Vendor_Status__c, &apos;&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_De-escalation - WO SLA Expiry</fullName>
        <actions>
            <name>UNITY_WO_Checked_in_before_SLA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordType.Name = &apos;Service Request&apos; &amp;&amp;  RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; FSO__Check_In_Date__c  &lt;= UNITY_Work_Window_End__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_De-escalation - WO Start Date%2FTime Missed %28No Check-in%29</fullName>
        <actions>
            <name>UNITY_Start_Date_Time_Not_Missed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordType.Name = &apos;Service Request&apos; &amp;&amp; !ISBLANK(  StartDate  ) &amp;&amp; !ISBLANK(  FSO__Check_In_Date__c  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Escalation - WO Accepted but not Scheduled - 12 Hour SLA</fullName>
        <active>true</active>
        <formula>RecordType.Name = &apos;Service Request&apos; &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; ISPICKVAL( Priority , &apos;12 Hour Response&apos;) &amp;&amp; ISPICKVAL(UNITY_Vendor_Status__c, &apos;Accepted&apos;)&amp;&amp; !ISBLANK(UNITY_Vendor_Accept_Date__c ) &amp;&amp; ISBLANK( StartDate  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>UNITY_WO_Not_Yet_Scheduled_Checkmark</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>WorkOrder.UNITY_WO_Vendor_Accept_Trigger_30_Minute__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>UNITY_Escalation - WO Accepted but not Scheduled - 2%2F4 Hour SLA</fullName>
        <active>true</active>
        <formula>RecordType.Name = &apos;Service Request&apos; &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; (ISPICKVAL( Priority , &apos;2 Hour Response&apos;)||ISPICKVAL(Priority, &apos;4 Hour Response&apos;)) &amp;&amp; ISPICKVAL(UNITY_Vendor_Status__c, &apos;Accepted&apos;)&amp;&amp; !ISBLANK(UNITY_Vendor_Accept_Date__c ) &amp;&amp; ISBLANK( StartDate  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>UNITY_WO_Not_Yet_Scheduled_Checkmark</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>WorkOrder.UNITY_WO_Created_Time_Trigger_5_Minutes__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>UNITY_Escalation - WO Accepted but not Scheduled - 24%2F48%2F72 Hour SLA</fullName>
        <active>true</active>
        <formula>RecordType.Name = &apos;Service Request&apos; &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; (ISPICKVAL( Priority , &apos;24 Hour Response&apos;)||ISPICKVAL(Priority, &apos;48 Hour Response&apos;)||ISPICKVAL(Priority, &apos;72 Hour Response&apos;)) &amp;&amp; ISPICKVAL(UNITY_Vendor_Status__c, &apos;Accepted&apos;)&amp;&amp; !ISBLANK(UNITY_Vendor_Accept_Date__c ) &amp;&amp; ISBLANK( StartDate  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>UNITY_WO_Not_Yet_Scheduled_Checkmark</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>8</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>UNITY_Escalation - WO Assigned but Not Accepted</fullName>
        <actions>
            <name>UNITY_WO_Not_Yet_Accepted_Checkmark</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordType.Name = &apos;Service Request&apos; &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; !ISPICKVAL(UNITY_Vendor_Status__c, &apos;&apos;) &amp;&amp; !ISPICKVAL(UNITY_Vendor_Status__c, &apos;Assigned&apos;)&amp;&amp; !ISPICKVAL(UNITY_Vendor_Status__c, &apos;Accepted&apos;) &amp;&amp; !UNITY_Auto_Dispatch__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Escalation - WO Created but Not Assigned - 12 Hour SLA</fullName>
        <active>true</active>
        <formula>RecordType.Name = &apos;Service Request&apos; &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; ISPICKVAL( Priority , &apos;12 Hour Response&apos;) &amp;&amp; ISPICKVAL(UNITY_Vendor_Status__c, &apos;&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>WO_Not_Yet_Assigned_Checkmark</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>WorkOrder.UNITY_WO_Create_Time_Trigger_30_Minutes__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>UNITY_Escalation - WO Created but Not Assigned - 2%2F4 Hour SLA</fullName>
        <active>true</active>
        <formula>RecordType.Name = &apos;Service Request&apos; &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; (ISPICKVAL( Priority , &apos;2 Hour Response&apos;) || ISPICKVAL(Priority, &apos;4 Hour Response&apos;)) &amp;&amp; ISPICKVAL(UNITY_Vendor_Status__c, &apos;&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>WO_Not_Yet_Assigned_Checkmark</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>WorkOrder.UNITY_WO_Created_Time_Trigger_5_Minutes__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>UNITY_Escalation - WO Created but Not Assigned - 24 Hour SLA</fullName>
        <active>true</active>
        <formula>RecordType.Name = &apos;Service Request&apos; &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; ISPICKVAL(Priority, &apos;24 Hour Response&apos;) &amp;&amp; ISPICKVAL(UNITY_Vendor_Status__c, &apos;&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>WO_Not_Yet_Assigned_Checkmark</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>UNITY_Escalation - WO Created but Not Assigned - 48%2F72 Hour SLA</fullName>
        <active>true</active>
        <formula>RecordType.Name = &apos;Service Request&apos; &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; (ISPICKVAL(Priority, &apos;48 Hour Response&apos;)|| ISPICKVAL(Priority, &apos;72 Hour Response&apos;) ) &amp;&amp; ISPICKVAL(UNITY_Vendor_Status__c, &apos;&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>WO_Not_Yet_Assigned_Checkmark</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>UNITY_Escalation - WO SLA Expiry - 12 Hour SLA</fullName>
        <active>true</active>
        <formula>RecordType.Name = &apos;Service Request&apos; &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp;  ISPICKVAL(Priority, &apos;12 Hour Response&apos;) &amp;&amp; !(ISPICKVAL(Status , &quot;Completed&quot;) || ISPICKVAL(Status, &quot;Closed&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>UNITY_WO_SLA_Expiry_Checkmark</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>WorkOrder.UNITY_Work_Window_End__c</offsetFromField>
            <timeLength>-2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>UNITY_Escalation - WO SLA Expiry - 2%2F4 Hour SLA</fullName>
        <active>true</active>
        <formula>RecordType.Name = &apos;Service Request&apos; &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; (ISPICKVAL(Priority, &apos;2 Hour Response&apos;) || ISPICKVAL(Priority, &apos;4 Hour Response&apos;)) &amp;&amp; !(ISPICKVAL(Status , &quot;Completed&quot;) || ISPICKVAL(Status, &quot;Closed&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>UNITY_WO_SLA_Expiry_Checkmark</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>WorkOrder.UNITY_SLA_Expiry_Time_Trigger_30_Minutes__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>UNITY_Escalation - WO SLA Expiry - 24%2F48%2F72 Hour SLA</fullName>
        <active>true</active>
        <formula>RecordType.Name = &apos;Service Request&apos; &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; (ISPICKVAL(Priority, &apos;24 Hour Response&apos;)||ISPICKVAL(Priority, &apos;48 Hour Response&apos;)||ISPICKVAL(Priority, &apos;72 Hour Response&apos;)) &amp;&amp; !(ISPICKVAL(Status , &quot;Completed&quot;) || ISPICKVAL(Status, &quot;Closed&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>UNITY_WO_SLA_Expiry_Checkmark</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>WorkOrder.UNITY_Work_Window_End__c</offsetFromField>
            <timeLength>-6</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>UNITY_Escalation - WO Start Date%2FTime Missed %28No Check-in%29 - 2%2F4%2F12%2F24%2F48%2F72 Hour SLA</fullName>
        <active>true</active>
        <formula>RecordType.Name = &apos;Service Request&apos; &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; (ISPICKVAL(Priority, &apos;2 Hour Response&apos;)||ISPICKVAL(Priority, &apos;4 Hour Response&apos;)||ISPICKVAL(Priority, &apos;12 Hour Response&apos;)||ISPICKVAL(Priority, &apos;24 Hour Response&apos;)||ISPICKVAL(Priority, &apos;48 Hour Response&apos;)||ISPICKVAL(Priority, &apos;72 Hour Response&apos;)) &amp;&amp; !ISBLANK(  StartDate  ) &amp;&amp; ISBLANK(  FSO__Check_In_Date__c  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>UNITY_WO_Not_Checked_In_Checkmark</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>WorkOrder.UNITY_Start_Date_Time_Trigger_15_Minutes__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>UNITY_Initial WO Assignment Email</fullName>
        <actions>
            <name>UNITY_Work_Order_Assignment_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Email template to be sent to the WO owner when the WO.Vendor_Status = ASSIGNED</description>
        <formula>ISCHANGED( UNITY_Assigned_Vendor__c ) &amp;&amp;  ISPICKVAL(  UNITY_Vendor_Status__c  , &apos;Assigned&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Initial WO Assignment Email BU Craft</fullName>
        <actions>
            <name>UNITY_Work_Order_Assignment_Notification_Craft_Vendor</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email template to be sent to the WO owner when the WO.Vendor_Status = ASSIGNED &amp; BU = Craft</description>
        <formula>ISCHANGED( UNITY_Assigned_Vendor__c ) &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; ISPICKVAL(  UNITY_Vendor_Status__c  , &apos;Assigned&apos;) &amp;&amp;   ISPICKVAL(UNITY_Business_Unit__c,&apos;Craft&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Initial WO Assignment Email BU MNS</fullName>
        <actions>
            <name>UNITY_Work_Order_Assignment_Notification_MNS_Vendor</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email template to be sent to the WO owner when the WO.Vendor_Status = ASSIGNED &amp; BU = MNS</description>
        <formula>ISCHANGED( UNITY_Assigned_Vendor__c ) &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; ISPICKVAL(  UNITY_Vendor_Status__c  , &apos;Assigned&apos;) &amp;&amp;   OR( ISPICKVAL(UNITY_Business_Unit__c,&apos;MNS&apos;), CONTAINS( UNITY_Business_Unit_Formula__c , &apos;MSP&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Initial WO Assignment Email BU NSBS</fullName>
        <actions>
            <name>UNITY_Work_Order_Assignment_Notification_NSBS_Vendor</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email template to be sent to the WO owner when the WO.Vendor_Status = ASSIGNED &amp; BU = NSBS</description>
        <formula>ISCHANGED( UNITY_Assigned_Vendor__c ) &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp;  ISPICKVAL(  UNITY_Vendor_Status__c  , &apos;Assigned&apos;) &amp;&amp;   ISPICKVAL(UNITY_Business_Unit__c,&apos;NSBS&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_MenuPricingWorkOrder</fullName>
        <actions>
            <name>UNITY_FlagWOMenuPricing</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(UNITY_Customer_Service_Contract__r.UNITY_Contract_Sub_type__c , &quot;Menu Pricing&quot;) &amp;&amp;  RecordType.Name = &quot;Service Request&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Remove Name Total Min Last IVR and Debrf</fullName>
        <actions>
            <name>Remove_Date_Debriefed_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Rem_Ttl_Min_Btw_Last_IVR_Debrif</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Remove_Debrief_User_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.SFPS_FS_AllTasks_Completed__c</field>
            <operation>notContain</operation>
            <value>All Tasks Completed/Verified</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Scheduled_Date_Time_Update</fullName>
        <actions>
            <name>UNITY</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Scheduled Date/Time on WO based on when Dispatcher assigns a Start Date on WO</description>
        <formula>NOT(ISBLANK( StartDate ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Set WO Assigned</fullName>
        <actions>
            <name>UNITY_Set_WO_to_Assigned</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.Status</field>
            <operation>equals</operation>
            <value>Pending Re-Dispatch,Pending Tech Dispatch</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.UNITY_Vendor_Status__c</field>
            <operation>equals</operation>
            <value>Accepted</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.StartDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Preventative Maintenance</value>
        </criteriaItems>
        <description>Set WO to Assigned when the WO is accepted by the Vendor and assigned to a Tech</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Set WO Pending Dispatch</fullName>
        <actions>
            <name>UNITY_Set_WO_Pending_Dispatch</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.Status</field>
            <operation>equals</operation>
            <value>Pending Acceptance</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.UNITY_Vendor_Status__c</field>
            <operation>equals</operation>
            <value>Accepted</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.UNITY_Primary_Technician__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Preventative Maintenance</value>
        </criteriaItems>
        <description>Set WO to Pending Dispatch when the WO is accepted by the Vendor but not assigned to a Tech</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Set WO to Accept</fullName>
        <actions>
            <name>UNITY_Set_WO_to_Accept</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Set WO to accept when the previous status is Assigned and the tech accepts the WO</description>
        <formula>OR(NOT(ISNULL(UNITY_Technician_Accept_Date__c )), NOT(ISNULL(StartDate)) ) &amp;&amp;  NOT(ISNULL(UNITY_Assigned_Vendor__c) ) &amp;&amp;  ISPICKVAL( UNITY_Vendor_Status__c ,&apos;Accepted&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Set WO to Completed</fullName>
        <actions>
            <name>UNITY_Set_WO_to_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Set WO to IVR CHeckout when the previous status is Tech Onsite and adds Completed date time</description>
        <formula>NOT(ISNULL(   FSO__Completed_Date__c   ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Set WO to In Transit</fullName>
        <actions>
            <name>UNITY_Set_WO_to_In_transit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set WO to In transit when the previous status is Accepted and the tech accepts the WO and adds the start travel info</description>
        <formula>NOT(ISNULL( FSO__Start_Travel_Date__c )) &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; NOT(ISNULL(UNITY_Assigned_Vendor__c) ) &amp;&amp;  ISPICKVAL( UNITY_Vendor_Status__c ,&apos;Accepted&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Set WO to Pending Accept</fullName>
        <actions>
            <name>UNITY_Set_WO_to_Pending_Accept</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set WO to Pending Accept when Vendor is manually assigned by agent</description>
        <formula>NOT(ISNULL(UNITY_Assigned_Vendor__c))   &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp;   ISPICKVAL(UNITY_Vendor_Status__c,&apos;Assigned&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Set WO to Pending Assign</fullName>
        <actions>
            <name>UNITY_Set_WOStatus_to_Pending_Assignment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set WO to pending Assignment if auto dispatch doesnt work for 3 attempts.</description>
        <formula>ISPICKVAL( UNITY_Vendor_Status__c, &apos;No Auto-Dispatch Candidate&apos;) ||  ISPICKVAL( UNITY_Vendor_Status__c, &apos;Rejected&apos;) ||  ISPICKVAL( UNITY_Vendor_Status__c, &apos;Rejected-No Response&apos;) ||  ISPICKVAL( UNITY_Vendor_Status__c, &apos;Rejected-Other&apos;) ||  (  UNITY_Auto_Dispatch__c = false &amp;&amp;  UNITY_Dispatch_Attempts__c &gt;= 1 &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; ISNULL( UNITY_Assigned_Vendor__c ) &amp;&amp;  (  ISPICKVAL( UNITY_Vendor_Status__c, &apos;Rejected&apos;) ||  ISPICKVAL( UNITY_Vendor_Status__c, &apos;Rejected-No Response&apos;) ||  ISPICKVAL( UNITY_Vendor_Status__c, &apos;Rejected-Other&apos;)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Set WO to Tech Onsite</fullName>
        <actions>
            <name>UNITY_Set_WO_to_In_Progress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set WO to In transit when the previous status is In transit and adds the start travel info and check in date time..the WF sets it to IN PROGESS and the other WF sets to Tech Onsite.</description>
        <formula>NOT(ISNULL( FSO__Check_In_Date__c )) &amp;&amp;  NOT(ISNULL(UNITY_Assigned_Vendor__c)) &amp;&amp;  NOT(ISPICKVAL( Status ,&apos;Completed&apos;)) &amp;&amp;  NOT(ISPICKVAL( Status ,&apos;Tech Onsite&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Set_Accept_Time_12_24_48_72_Hr_Response</fullName>
        <actions>
            <name>UNITY_Set_Accept_Time_to_30_mins</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.Priority</field>
            <operation>equals</operation>
            <value>12 Hour Response,24 Hour Response,48 Hour Response,72 Hour Response</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Preventative Maintenance</value>
        </criteriaItems>
        <description>UNITY_Set_Accept_Time for 12_24_48_72_Hr_Response</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Set_Accept_time_Project_Planned</fullName>
        <actions>
            <name>UNITY_Set_Accept_Time_to_60_mins</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.Priority</field>
            <operation>equals</operation>
            <value>Project,Planned Maintenance</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Preventative Maintenance</value>
        </criteriaItems>
        <description>UNITY_Set_Accept_time_Project_Planned Maintenance</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Set_Complete_Date</fullName>
        <actions>
            <name>UNITY_Set_Complete_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.Status</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Update_WO_SelfPerform_Status</fullName>
        <actions>
            <name>UNITY_Update_WO_SelfPerform_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Work Order status when owner of record is Self-Perform Dispatcher and status is New</description>
        <formula>OR(ISPICKVAL( Status, &quot;New&quot;), ISPICKVAL( Status, &quot;Re-Dispatch&quot;)) &amp;&amp; CONTAINS( Owner:User.Profile.Name , &apos;UNITY_Service Coordinator(Self Perform)&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_WO Assignment - Planned Maintenance%2FProject%2FBundle</fullName>
        <active>true</active>
        <description>Rules to drive time based action based on priority - Planned Maintenance/Project/Bundle</description>
        <formula>(ISPICKVAL(Priority, &apos;Planned Maintenance&apos;) || ISPICKVAL(Priority, &apos;Project&apos;) || ISPICKVAL(Priority, &apos;Bundle&apos;)) &amp;&amp; ISPICKVAL(UNITY_Vendor_Status__c, &apos;Assigned&apos;) &amp;&amp; !ISBLANK(UNITY_Vendor_Last_Assigned__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>UNITY_Reject_WorkOrder_No_Response</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>WorkOrder.UNITY_Vendor_Last_Assigned__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>UNITY_WO Vendor Eligible</fullName>
        <actions>
            <name>UNITY_OON_Vendor_Eligible</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(RecordType.Name = &quot;Service Request&quot; || RecordType.Name = &quot;Site Survey&quot; || RecordType.Name = &quot;Non-Work&quot; || RecordType.Name = &quot;Project Management&quot; || RecordType.Name = &quot;Preventative Maintenance&quot; || RecordType.Name = &quot;Project Phase&quot;)&amp;&amp; !ISBLANK(UNITY_OON_Vendor_Reason__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_WO Work Window Update Manual</fullName>
        <actions>
            <name>UNITY_Update_Work_Window_End</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>( RecordType.Name = &quot;Service Request&quot; || RecordType.Name = &quot;Site Survey&quot; || RecordType.Name = &quot;Project Management&quot; || RecordType.Name = &quot;Project Phase&quot;) &amp;&amp; ((NOT(ISBLANK(UNITY_Work_Window_Begin__c )) &amp;&amp; ISCHANGED(UNITY_Work_Window_Begin__c)) || ISCHANGED(Priority))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_WO_Accept_Time_2_hr_Response</fullName>
        <actions>
            <name>UNITY_Set_Accept_time_2_4_Hr_Response</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.Priority</field>
            <operation>equals</operation>
            <value>2 Hour Response</value>
        </criteriaItems>
        <description>UNITY_WO_Accept_Time_2_hr_Response</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_WO_Accept_Time_4_hr_Response</fullName>
        <actions>
            <name>UNITY_Set_Accept_time_2_4_Hr_Response</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.Priority</field>
            <operation>equals</operation>
            <value>4 Hour Response</value>
        </criteriaItems>
        <description>UNITY_WO_Accept_Time_4_hr_Response</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_WO_Action_Reset</fullName>
        <actions>
            <name>UNITY_Clear_ACTION_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.UNITY_Action__c</field>
            <operation>equals</operation>
            <value>Accept,Reject</value>
        </criteriaItems>
        <description>Reset the action picklist field regardless if the action is performed or not, as the &quot;Action&quot; is more of an operation on WO, not a WO attribute</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_WO_Action_Send_PO</fullName>
        <actions>
            <name>UNITY_Send_Purchase_Order</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UNITY_Clear_ACTION_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>When the action picklist is set to Send PO, send email to vendor that includes current PO and work plan if a PO is linked to work order and in Final status</description>
        <formula>NOT(RecordType.Name = &apos;Preventative Maintenance&apos;) &amp;&amp; ISPICKVAL(UNITY_Action__c, &quot;Send PO&quot;) &amp;&amp; !ISBLANK(UNITY_Current_PO__c) &amp;&amp; !ISBLANK( UNITY_Vendor_PO_Sent_Date__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_WO_Action_Send_PO_Craft</fullName>
        <actions>
            <name>UNITY_Send_Purchase_Order_Craft</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UNITY_Clear_ACTION_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>When the action picklist is set to Send PO, send email to vendor that includes current PO and work plan if a PO is linked to work order and in Final status . BU Craft</description>
        <formula>ISPICKVAL(UNITY_Action__c, &quot;Send PO&quot;) &amp;&amp; !ISBLANK(UNITY_Current_PO__c) &amp;&amp; OR(!ISBLANK( UNITY_Vendor_PO_Sent_Date__c )&amp;&amp;( RecordType.Name = &apos;Service Request&apos;),RecordType.Name = &apos;Non-Work&apos;) &amp;&amp;  ISPICKVAL ( UNITY_Business_Unit__c, &apos;Craft&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_WO_Action_Send_PO_MNS</fullName>
        <actions>
            <name>UNITY_Send_Purchase_Order_MNS</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UNITY_Clear_ACTION_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>When the action picklist is set to Send PO, send email to vendor that includes current PO and work plan if a PO is linked to work order and in Final status . BU MNS</description>
        <formula>NOT(RecordType.Name = &apos;Preventative Maintenance&apos;) &amp;&amp; ISPICKVAL(UNITY_Action__c, &quot;Send PO&quot;) &amp;&amp; !ISBLANK(UNITY_Current_PO__c) &amp;&amp; OR(!ISBLANK( UNITY_Vendor_PO_Sent_Date__c )&amp;&amp;( RecordType.Name = &apos;Service Request&apos;),RecordType.Name = &apos;Non-Work&apos;) &amp;&amp;  OR( ISPICKVAL(UNITY_Business_Unit__c,&apos;MNS&apos;),  CONTAINS( UNITY_Business_Unit_Formula__c , &apos;MSP&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_WO_Action_Send_PO_NSBS</fullName>
        <actions>
            <name>UNITY_Send_Purchase_Order_NSBS</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UNITY_Clear_ACTION_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>When the action picklist is set to Send PO, send email to vendor that includes current PO and work plan if a PO is linked to work order and in Final status . BU NSBS</description>
        <formula>NOT(RecordType.Name = &apos;Preventative Maintenance&apos;) &amp;&amp; ISPICKVAL(UNITY_Action__c, &quot;Send PO&quot;) &amp;&amp; !ISBLANK(UNITY_Current_PO__c) &amp;&amp; OR(!ISBLANK( UNITY_Vendor_PO_Sent_Date__c )&amp;&amp;( RecordType.Name = &apos;Service Request&apos;),RecordType.Name = &apos;Non-Work&apos;) &amp;&amp;  ISPICKVAL ( UNITY_Business_Unit__c, &apos;NSBS&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_WO_Creation</fullName>
        <actions>
            <name>UNITY_Set_WO_Status_to_NEW</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set status to Pending Assignment when WO is created</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_WO_InProgress to TechOnsite</fullName>
        <actions>
            <name>UNITY_Set_WO_Tech_Onsite</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>WorkOrder.Status</field>
            <operation>equals</operation>
            <value>In Progress</value>
        </criteriaItems>
        <description>Change status from In progress to Tech Onsite</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_WO_LastCheckOut</fullName>
        <actions>
            <name>UNITY_WO_SetLastCheckOut</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the last check-out date field whenever the check-out field is populated/updated and it is not null or blank</description>
        <formula>AND( OR( ISNEW(),  ISCHANGED(FSO__Completed_Date__c) ), NOT(ISBLANK(FSO__Completed_Date__c)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_WO_Vendor_Assignement_Action_Accept</fullName>
        <actions>
            <name>UNITY_Clear_ACTION_field</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Set_Vendor_Status_Accepted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.UNITY_Action__c</field>
            <operation>equals</operation>
            <value>Accept</value>
        </criteriaItems>
        <description>When the action picklist is set to reject, flip the vendor assignment status to &apos;Reject-Other&apos; and clear the action picklist field itself. if action picklist is set to &quot;Accept&quot;, change vendor assignment status to &quot;Accepted&quot; and dont clear the action field</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_WO_Vendor_Assignement_Action_Reject</fullName>
        <actions>
            <name>Reset_Intercompany_Transfer_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Clear_ACTION_field</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Update_Vendor_Status_Reject_Other</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.UNITY_Action__c</field>
            <operation>equals</operation>
            <value>Reject</value>
        </criteriaItems>
        <description>When the action picklist is set to reject, flip the vendor assignment status to &apos;Reject-Other&apos; and clear the action picklist field itself. if action picklist is set to &quot;Accept&quot;, change vendor assignment status to &quot;Accepted&quot; and dont clear the action field</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_WO_Work_Window_Update</fullName>
        <actions>
            <name>UNITY_WO_Work_Window_Begin</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_WO_Work_Window_End</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.RecordTypeId</field>
            <operation>equals</operation>
            <value>Preventative Maintenance,Project Management,Service Request,Site Survey</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.UNITY_Work_Window_Begin__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.UNITY_Work_Window_End__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populate Work Order work begin and end times based on Case values</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Work Order Comment - New Work Order Comment</fullName>
        <actions>
            <name>UNITY_Clear_WO_Comments</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Update_WO_Combined_Comments</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate Work Order work begin and end times based on Case values</description>
        <formula>(RecordType.Name = &quot;Service Request&quot; || RecordType.Name = &quot;Preventative Maintenance&quot; || RecordType.Name = &quot;Project Management&quot; || RecordType.Name = &quot;Site Survey&quot;)&amp;&amp; !ISBLANK( UNITY_Work_Order_Notes__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_set IVR Checkout</fullName>
        <actions>
            <name>UNITY_Set_WO_IVR_Checkout</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.Status</field>
            <operation>equals</operation>
            <value>In Progress</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.FSO__Completed_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Set IVR checkout when Tech Onsite and Completed date is not null</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
