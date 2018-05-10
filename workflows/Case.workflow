<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Case_Alert</fullName>
        <description>New Case Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Operations_Mgmt_TMC</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SVMXC__ServiceMaxEmailTemplates/Case_Created</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Cancelled_Case_Notification</fullName>
        <description>UNITY_Cancelled_Case_Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>customersupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Cancelled_Review_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Cancelled_Case_Notification_Customer</fullName>
        <description>UNITY_Cancelled_Case_Notification_Customer</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>customersupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Cancelled_Case</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Cancelled_Case_Notification_Customer_Craft</fullName>
        <ccEmails>Customer_Support_Craft@email.address</ccEmails>
        <description>UNITY_Cancelled_Case_Notification_Customer Craft</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>customersupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Cancelled_Case</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Cancelled_Case_Notification_Customer_MNS</fullName>
        <description>UNITY_Cancelled_Case_Notification_Customer MNS</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>customersupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Cancelled_Case</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Cancelled_Case_Notification_Customer_NSBS</fullName>
        <description>UNITY_Cancelled_Case_Notification_Customer NSBS</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>customersupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Cancelled_Case</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Email_Team_Lead_Manager_of_Case_Escalation</fullName>
        <description>Email Team Lead/Manager of Case Escalation</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>customersupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Escalation_Case_Created_but_Not_Assigned</template>
    </alerts>
    <fieldUpdates>
        <fullName>Case_Owner_E_mail</fullName>
        <field>Case_Owner_E_mail__c</field>
        <formula>Owner:User.Email</formula>
        <name>Case Owner E-mail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Owner_Mobile</fullName>
        <field>Case_Owner_Mobile__c</field>
        <formula>Owner:User.MobilePhone</formula>
        <name>Case Owner Mobile</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Owner_Phone</fullName>
        <field>Case_Owner_Phone__c</field>
        <formula>Owner:User.Phone</formula>
        <name>Case Owner Phone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Most_Recent_Case_Notes</fullName>
        <field>Most_Recent_Case_Notes__c</field>
        <formula>UNITY_Case_Notes__c</formula>
        <name>Populate Most Recent Case Notes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SFPS_GNC_Set_Default_GNC_Priority_Date</fullName>
        <field>SFPS_GNC_PriorityDate__c</field>
        <formula>CreatedDate</formula>
        <name>SFPS GNC Set Default GNC Priority Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITYPM_Set_Case_to_Verified</fullName>
        <description>PM Case status update to verified</description>
        <field>Status</field>
        <literalValue>Verified</literalValue>
        <name>UNITYPM Set Case to Verified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_BU_Populate_MNS</fullName>
        <description>When BU is blank on account, BU set as UNITY_Account_Business_Unit__c</description>
        <field>UNITY_Business_Unit__c</field>
        <literalValue>MNS</literalValue>
        <name>UNITY_BU_Populate_MNS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Case_Work_Window_Begin</fullName>
        <description>Populate work window begin date on case based on create date and priority</description>
        <field>UNITY_Work_Window_Begin__c</field>
        <formula>CreatedDate</formula>
        <name>UNITY_Case_Work_Window_Begin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Case_Work_Window_End</fullName>
        <description>Populate case work window end based on case create date and priority</description>
        <field>UNITY_Work_Window_End__c</field>
        <formula>IF(ISPICKVAL( Priority ,&quot;2 Hour Response&quot;),CreatedDate + 0.083333333333333, 
IF(ISPICKVAL( Priority ,&quot;4 Hour Response&quot;),CreatedDate + 0.166666666666667, 
IF(ISPICKVAL( Priority ,&quot;12 Hour Response&quot;),CreatedDate + 0.5, 
IF(ISPICKVAL( Priority ,&quot;24 Hour Response&quot;),CreatedDate + 1.0, 
IF(ISPICKVAL( Priority ,&quot;48 Hour Response&quot;),CreatedDate + 2.0, 
IF(ISPICKVAL( Priority ,&quot;72 Hour Response&quot;),CreatedDate + 3.0, 
NOW()))))))</formula>
        <name>UNITY_Case_Work_Window_End</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Clear_Case_Comments_field</fullName>
        <field>UNITY_Case_Notes__c</field>
        <name>Clear Case Comments field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Clear_Case_Notes</fullName>
        <field>UNITY_Case_Notes__c</field>
        <name>Clear Case Notes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_CustomerIVRPopulate</fullName>
        <field>UNITY_Customer_IVR_Pin__c</field>
        <formula>IF( 
UNITY_Customer_Service_Contract__r.UNITY_Customer_IVR_Required__c = TRUE &amp;&amp; (!ISBLANK(UNITY_Customer__r.UNITY_IVR_Phone_Number__c)&amp;&amp;!ISBLANK(UNITY_Customer__r.UNITY_IVR_Pin__c)) , UNITY_Customer__r.UNITY_IVR_Phone_Number__c + &quot; Pin: &quot; + UNITY_Customer__r.UNITY_IVR_Pin__c, 
IF( 
UNITY_Customer_Service_Contract__r.UNITY_Customer_IVR_Required__c = TRUE &amp;&amp; !ISBLANK(UNITY_Customer__r.UNITY_IVR_Phone_Number__c),UNITY_Customer__r.UNITY_IVR_Phone_Number__c, &quot;&quot;))</formula>
        <name>UNITY_CustomerIVRPopulate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_De_escalate_case_standard</fullName>
        <description>Unchecked the Case Escalated checkbox</description>
        <field>IsEscalated</field>
        <literalValue>0</literalValue>
        <name>UNITY - De-escalate case standard</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Escalate_Case_Standard</fullName>
        <description>Case Escataled = true</description>
        <field>IsEscalated</field>
        <literalValue>1</literalValue>
        <name>UNITY Escalate Case - Standard</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Fire_Assignment_Rule</fullName>
        <field>UNITY_Fire_Assignment_Rule__c</field>
        <literalValue>1</literalValue>
        <name>UNITY_Fire_Assignment_Rule</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_MinerIVRPopulate</fullName>
        <field>UNITY_Miner_IVR_Phone_Number__c</field>
        <formula>IF( UNITY_Customer_Service_Contract__r.UNITY_Miner_IVR_Required__c = TRUE &amp;&amp;  UNITY_Customer__r.UNITY_Service_Channel_IVR__c = FALSE,UNITY_Business_Unit_Account__r.UNITY_IVR_Phone_Number__c,&quot;&quot;)</formula>
        <name>UNITY_MinerIVRPopulate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Reassign_to_Account_not_active</fullName>
        <field>OwnerId</field>
        <lookupValue>UNITY_Case_Not_Active_Account</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Reassign to Account not active queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Service_Completed_Date_Time</fullName>
        <field>UNITY_Service_Completed_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Service Completed Date Time Population</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_GNC_Priority_Date</fullName>
        <field>SFPS_GNC_PriorityDate__c</field>
        <formula>CASE(TEXT(Priority), 
&apos;2 Hour Response&apos;, CreatedDate + (2 / 24), 
&apos;4 Hour Response&apos;, CreatedDate + (4 / 24), 
&apos;12 Hour Response&apos;, CreatedDate + (12 / 24), 
&apos;24 Hour Response&apos;, CreatedDate + (24 / 24), 
&apos;48 Hour Response&apos;, CreatedDate + (48 / 24), 
&apos;72 Hour Response&apos;, CreatedDate + (72 / 24), 
CreatedDate)</formula>
        <name>UNITY Set GNC Priority Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_GNC_Priority_Level</fullName>
        <description>Set Priority Level by Case Priority in three types: hours based, standard, bundle</description>
        <field>SFPS_GNC_PriorityLevel__c</field>
        <formula>IF(CONTAINS(Owner:Queue.QueueName, &quot;Tier&quot;),  UNITY_SLA_Rank__c +  UNITY_Customer_Account_Tier__c , IF(CONTAINS(Owner:Queue.QueueName, &quot;MSP &quot;),UNITY_SLA_Rank__c, 13 + UNITY_SLA_Rank__c + UNITY_Customer_Account_Tier__c))</formula>
        <name>UNITY Set GNC Priority Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Asset_Down_At</fullName>
        <description>Updates the asset down at field</description>
        <field>UNITY_Asset_Down_At__c</field>
        <formula>CreatedDate</formula>
        <name>Update_Asset_Down_At</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Cancelled_Review</fullName>
        <description>Update the Cancelled Review checkbox to True</description>
        <field>UNITY_Cancelled_Review__c</field>
        <literalValue>1</literalValue>
        <name>UNITY_Update_Cancelled_Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Case_Combined_Comments</fullName>
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
VALUE( MID( TEXT( NOW() - 0.3333 ), 12, 2 ) ) &lt; 12, 
0, 
12 
) 
) 
) 
&amp; &quot;:&quot; &amp; 
MID( TEXT( NOW() - 0.3333 ), 15, 2 ) 
&amp; &quot;:&quot; &amp; 
MID( TEXT( NOW() - 0.3333), 18, 2 ) 
&amp; &quot; &quot; &amp; 
IF( 
VALUE( MID( TEXT( NOW() - 0.3333), 12, 2 ) ) &lt; 12, 
&quot;AM&quot;, 
&quot;PM&quot; 
), 
&quot; &quot;
) 

+ &apos;)&apos; + BR() +  IF( UNITY_Integration_Send_Case_Notes__c, &apos;==Note sent to customer==&apos; + BR() , &apos;&apos;) +    UNITY_Case_Notes__c  + BR() + &apos;******&apos; + BR()+ UNITY_Combined_Notes__c</formula>
        <name>Update Case Combined Comments</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Case_Origin_to_WEb</fullName>
        <field>Origin</field>
        <literalValue>Web</literalValue>
        <name>Update Case Origin to WEb</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Work_Window_End</fullName>
        <field>UNITY_Work_Window_End__c</field>
        <formula>IF(ISPICKVAL( Priority ,&quot;2 Hour Response&quot;), UNITY_Work_Window_Begin__c  + 0.083333333333333, 
IF(ISPICKVAL( Priority ,&quot;4 Hour Response&quot;),UNITY_Work_Window_Begin__c  + 0.166666666666667, 
IF(ISPICKVAL( Priority ,&quot;12 Hour Response&quot;),UNITY_Work_Window_Begin__c  + 0.5, 
IF(ISPICKVAL( Priority ,&quot;24 Hour Response&quot;),UNITY_Work_Window_Begin__c  + 1.0, 
IF(ISPICKVAL( Priority ,&quot;48 Hour Response&quot;),UNITY_Work_Window_Begin__c  + 2.0, 
IF(ISPICKVAL( Priority ,&quot;72 Hour Response&quot;),UNITY_Work_Window_Begin__c  + 3.0, 
NOW()))))))</formula>
        <name>Update Work Window End</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_update_Portal_Source</fullName>
        <field>UNITY_Portal_Source__c</field>
        <literalValue>Community</literalValue>
        <name>UNITY update Portal Source</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Asset Down At - default value</fullName>
        <actions>
            <name>UNITY_Update_Asset_Down_At</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Default Asset Down At IF Asset down has been checked and asset down at was not populated.</description>
        <formula>AND(  UNITY_Asset_Down__c = true,  ISBLANK(UNITY_Asset_Down_At__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Notes Populated</fullName>
        <actions>
            <name>Populate_Most_Recent_Case_Notes</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.UNITY_Case_Notes__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Owner Info</fullName>
        <actions>
            <name>New_Case_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Case_Owner_E_mail</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Case_Owner_Mobile</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Case_Owner_Phone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Hao - test</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Assigned_To__c</field>
            <operation>equals</operation>
            <value>Hao Dong</value>
        </criteriaItems>
        <description>test rule</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SFPS_GNC Priority Date is NULL</fullName>
        <actions>
            <name>SFPS_GNC_Set_Default_GNC_Priority_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.SFPS_GNC_PriorityDate__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UNITY De-Escalate Case when Action Required unchecked</fullName>
        <actions>
            <name>UNITY_De_escalate_case_standard</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.UNITY_Service_Channel_Action_Required__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>De-escalates a case when unchecking Service Channel Action Required</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY Escalate Case when Action Required</fullName>
        <actions>
            <name>UNITY_Escalate_Case_Standard</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.UNITY_Service_Channel_Action_Required__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Makes a case escalated when an Action Required note comes through for a Service Channel customer</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY Hao Test Rule</fullName>
        <active>false</active>
        <formula>ISCHANGED( UNITY_Business_Unit__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITYPM Update Case Status To Verified</fullName>
        <actions>
            <name>UNITYPM_Set_Case_to_Verified</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update PM case status when the following are populated 1. SC 2. Location 3. Parent Case (program case)</description>
        <formula>AND( RecordType.Name == &quot;Preventative Maintenance&quot;,  UNITY_Customer_Service_Contract__c != null,  Parent.RecordType.Name == &quot;Program Case&quot;,  AccountId != null,  ISPICKVAL(Status, &quot;New&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_BU_Populate</fullName>
        <actions>
            <name>UNITY_BU_Populate_MNS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Fire_Assignment_Rule</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.UNITY_Business_Unit__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>populate BU as MNS UNITY_Account_Business_Unit__c if BU is empty on Account</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Cancelled_Case_Notification_Case_Owner</fullName>
        <actions>
            <name>UNITY_Cancelled_Case_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Send an email notifications to the case owner if the case is cancelled</description>
        <formula>AND(Owner:User.Profile.Name != &apos;UNITY_Customer&apos;, ISPICKVAL(Status, &apos;Cancelled&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Case Notes - New Case Note</fullName>
        <actions>
            <name>UNITY_Clear_Case_Notes</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Update_Case_Combined_Comments</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(RecordType.Name = &quot;Service Request&quot; || RecordType.Name = &quot;Preventative Maintenance&quot; || RecordType.Name = &quot;Project Management&quot; || RecordType.Name = &quot;Site Survey&quot;) &amp;&amp;  !ISBLANK(UNITY_Case_Notes__c ) &amp;&amp;  UNITY_Integration_Send_Case_Notes__c = false</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Case Origin to Web</fullName>
        <actions>
            <name>UNITY_Fire_Assignment_Rule</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Update_Case_Origin_to_WEb</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_update_Portal_Source</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If case is created from community set the Case origin to Web</description>
        <formula>CreatedBy.Profile.Name = &apos;UNITY_Customer&apos;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Case_Work_Window_Update</fullName>
        <actions>
            <name>UNITY_Case_Work_Window_Begin</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Case_Work_Window_End</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Project Phase,Project Management,Service Request,Site Survey</value>
        </criteriaItems>
        <description>Populate work window begin and end times based on case create date and priority</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Case_Work_Window_Update-Manual</fullName>
        <actions>
            <name>UNITY_Update_Work_Window_End</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Populate work window begin and end times based on case create date and priority when work window begin or priority is manually changed</description>
        <formula>( RecordType.Name = &quot;Service Request&quot; ||  RecordType.Name = &quot;Site Survey&quot; ||  RecordType.Name = &quot;Project Management&quot; ||  RecordType.Name = &quot;Project Phase&quot; ||  RecordType.Name = &quot;Preventative Maintenance&quot;) &amp;&amp;  (ISCHANGED(UNITY_Work_Window_Begin__c ) || ISCHANGED(Priority))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Escalation - Case Created but Not Assigned - 12%2F24%2F48%2F72 Hour SLA</fullName>
        <active>true</active>
        <formula>RecordType.Name = &apos;Service Request&apos; &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; RecordType.Name != &apos;Program Case&apos; &amp;&amp; (ISPICKVAL( Priority , &apos;12 Hour Response&apos;)||ISPICKVAL(Priority, &apos;24 Hour Response&apos;)||ISPICKVAL(Priority, &apos;48 Hour Response&apos;)||ISPICKVAL(Priority, &apos;72 Hour Response&apos;)) &amp;&amp;   !ISBLANK(Owner:Queue.Id)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>UNITY_Email_Team_Lead_Manager_of_Case_Escalation</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.UNITY_Case_Created_Trigger_30_minutes__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>UNITY_Escalation - Case Created but Not Assigned - 2%2F4 Hour SLA</fullName>
        <active>true</active>
        <formula>RecordType.Name = &apos;Service Request&apos; &amp;&amp; RecordType.Name != &apos;Preventative Maintenance&apos; &amp;&amp; RecordType.Name != &apos;Program Case&apos; &amp;&amp; (ISPICKVAL( Priority , &apos;2 Hour Response&apos;)||ISPICKVAL(Priority, &apos;4 Hour Response&apos;)) &amp;&amp;  !ISBLANK(Owner:Queue.Id)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>UNITY_Email_Team_Lead_Manager_of_Case_Escalation</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.UNITY_Case_Created_Trigger_15_minutes__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>UNITY_IVRNumber</fullName>
        <actions>
            <name>UNITY_CustomerIVRPopulate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_MinerIVRPopulate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Service Request,Preventative Maintenance,Project Management,Site Survey,Project Phase,Non-Work</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Inactive Account Reassign</fullName>
        <actions>
            <name>UNITY_Reassign_to_Account_not_active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>(ISNEW() || ISCHANGED(  UNITY_Customer__c)) &amp;&amp; NOT(ISPICKVAL( UNITY_Customer__r.Account_Status__c , &apos;Active&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Mark_Case_as_Cancelled_Review</fullName>
        <actions>
            <name>UNITY_Update_Cancelled_Review</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <description>If the case status changes to cancelled, check Cancelled Review on the case</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Customer_Cancelled_Case</fullName>
        <actions>
            <name>UNITY_Cancelled_Case_Notification_Customer</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <description>Notify Customer (Case owner if Customer-Community Profile) or Account.Customer.Email that the case has been cancelled</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Customer_Cancelled_Case_Craft</fullName>
        <actions>
            <name>UNITY_Cancelled_Case_Notification_Customer_Craft</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.UNITY_Business_Unit__c</field>
            <operation>equals</operation>
            <value>Craft</value>
        </criteriaItems>
        <description>Notify Customer (Case owner if Customer-Community Profile) or Account.Customer.Email that the case has been cancelled Craft</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Customer_Cancelled_Case_MNS</fullName>
        <actions>
            <name>UNITY_Cancelled_Case_Notification_Customer_MNS</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.UNITY_Business_Unit__c</field>
            <operation>equals</operation>
            <value>MNS,MSP Atlanta,MSP Dallas,MSP El Paso,MSP Houston,MSP Jacksonville,MSP Memphis,MSP Miami,MSP Nashville,MSP New Orleans,MSP Orlando,MSP Phoenix,MSP San Antonio,MSP Tampa</value>
        </criteriaItems>
        <description>Notify Customer (Case owner if Customer-Community Profile) or Account.Customer.Email that the case has been cancelled MNS</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Customer_Cancelled_Case_NSBS</fullName>
        <actions>
            <name>UNITY_Cancelled_Case_Notification_Customer_NSBS</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.UNITY_Business_Unit__c</field>
            <operation>equals</operation>
            <value>NSBS</value>
        </criteriaItems>
        <description>Notify Customer (Case owner if Customer-Community Profile) or Account.Customer.Email that the case has been cancelled NSBS</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_ServiceCompleted DateTime</fullName>
        <actions>
            <name>UNITY_Service_Completed_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>When status is changed to service completed, populate date/time</description>
        <formula>OR( RecordType.Name = &quot;Service Request&quot;, RecordType.Name = &quot;Site Survey&quot;, RecordType.Name = &quot;Preventative Maintenance&quot; ) &amp;&amp; ISPICKVAL(Status, &quot;Service Completed&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Set GNC Case Priority</fullName>
        <actions>
            <name>UNITY_Set_GNC_Priority_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Set_GNC_Priority_Level</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>BEGINS(OwnerId,&apos;00G&apos;) &amp;&amp;  OR(RecordType.Name=&apos;Preventative Maintenance&apos;, RecordType.Name=&apos;Project Management&apos;, RecordType.Name=&apos;Service Request&apos;, RecordType.Name=&apos;Site Survey&apos;, RecordType.Name=&apos;Non-Work&apos;, RecordType.Name=&apos;Project Phase&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
