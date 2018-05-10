<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_of_Approval</fullName>
        <description>Notification of Approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>UNITY_Email_Templates/UNITY_Quote_Manager_Approved</template>
    </alerts>
    <alerts>
        <fullName>Notification_of_Rejection</fullName>
        <description>Notification of Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>UNITY_Email_Templates/UNITY_Quote_Manager_Rejected</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Notify_Agent_on_Proposal_Status_Update</fullName>
        <description>Notify Agent on Proposal Status Update</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customersupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Proposal_Status_Notification</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Notify_Agent_on_Proposal_Status_Update_Craft</fullName>
        <ccEmails>Customer_Support_Craft@email.address</ccEmails>
        <description>Notify Agent on Proposal Status Update Craft</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customersupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Proposal_Status_Notification</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Notify_Agent_on_Proposal_Status_Update_MNS</fullName>
        <description>Notify Agent on Proposal Status Update MNS</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customersupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Proposal_Status_Notification</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Notify_Agent_on_Proposal_Status_Update_NSBS</fullName>
        <description>Notify Agent on Proposal Status Update NSBS</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customersupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Proposal_Status_Notification</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Notify_Customer_for_Proposal_Approval</fullName>
        <description>UNITY Customer for Proposal Approval</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Customer_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customersupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Quote_Initial_Acceptance</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Notify_Customer_for_Proposal_Approval_Craft</fullName>
        <ccEmails>Customer_Support_Craft@email.address</ccEmails>
        <description>UNITY Customer for Proposal Approval Craft</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Customer_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customersupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/UNITY_Quote_Initial_Acceptance_v2</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Notify_Customer_for_Proposal_Approval_MNS</fullName>
        <description>UNITY Customer for Proposal Approval MNS</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Customer_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/UNITY_Quote_Initial_Acceptance_v2</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Notify_Customer_for_Proposal_Approval_NSBS</fullName>
        <description>UNITY Customer for Proposal Approval NSBS</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Customer_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customersupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/UNITY_Quote_Initial_Acceptance_v2</template>
    </alerts>
    <fieldUpdates>
        <fullName>UNITY_Clear_Manager_Discount_Approval</fullName>
        <description>Clears the Manager Approved Discount Checkbox</description>
        <field>UNITY_Manager_Approved_Discounts__c</field>
        <literalValue>0</literalValue>
        <name>Clear Manager Discount Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Manager_Approved_Discounts</fullName>
        <description>Set Manager Approved Discount as TRUE once approved by manager</description>
        <field>UNITY_Manager_Approved_Discounts__c</field>
        <literalValue>1</literalValue>
        <name>Manager Approved Discounts</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Master_Quote_Approved_by_Manager</fullName>
        <field>UNITY_Proposal_Status__c</field>
        <literalValue>Quote Finalized</literalValue>
        <name>Master Quote Approved by Manager</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Master_Quote_Pending_Manager_Appl</fullName>
        <field>UNITY_Proposal_Status__c</field>
        <literalValue>Pending Manager Approval</literalValue>
        <name>Master Quote Pending Manager Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Master_Quote_Rejected_by_Manager</fullName>
        <field>UNITY_Proposal_Status__c</field>
        <literalValue>Rejected by Manager</literalValue>
        <name>Master Quote Rejected by Manager</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Master_Quote_Reset_Pend_Approval</fullName>
        <description>Uncheck the UNITY_Has_Pending_Approval_Sub_Quotes__c.</description>
        <field>UNITY_Has_Pending_Approval_Sub_Quotes__c</field>
        <literalValue>0</literalValue>
        <name>Master Quote Reset Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Proposal_Status_Return_to_Agent</fullName>
        <description>Change status from Sent to Customer to Returned to Agent</description>
        <field>UNITY_Proposal_Status__c</field>
        <literalValue>Returned to Agent</literalValue>
        <name>Proposal Status Return to Agent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Reset_Customer_Comments</fullName>
        <description>Reset Customer Comments</description>
        <field>UNITY_Comments__c</field>
        <name>Reset Customer Comments</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Reset_Customer_Status</fullName>
        <description>Resets Customer Status field to null</description>
        <field>UNITY_Status__c</field>
        <name>Reset Customer Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Reset_Manager_Approved_Discount</fullName>
        <description>Reset the Manager Approved Discount to false</description>
        <field>UNITY_Manager_Approved_Discounts__c</field>
        <literalValue>0</literalValue>
        <name>Reset Manager Approved Discount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Reset_Master_Quote_to_Draft</fullName>
        <description>Reset master quote after approval manager or customer</description>
        <field>UNITY_Proposal_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>Reset Master Quote to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_48_hrs_False</fullName>
        <description>Update 48 hrs to false on update of customer status</description>
        <field>UNITY_48_Hours__c</field>
        <literalValue>0</literalValue>
        <name>Update 48 hrs False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_48_hrs_True</fullName>
        <description>Update 48 hrs to trigger esclation rule</description>
        <field>UNITY_48_Hours__c</field>
        <literalValue>1</literalValue>
        <name>Update 48 hrs True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Customer_Status</fullName>
        <field>UNITY_Status__c</field>
        <name>Update Customer Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Customer_Status_to_NULL</fullName>
        <description>UPdates customer status to NULL on manager approval or rejection</description>
        <field>UNITY_Status__c</field>
        <name>Update Customer Status to NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Master_Quote_Effective_Date</fullName>
        <description>the effective date should be today() + 30 after the Master quote is set to finalized</description>
        <field>UNITY_Effective_Till_Date__c</field>
        <formula>today()+30</formula>
        <name>Update Master Quote Effective Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Proposal_Status_Mgr_Approve</fullName>
        <description>Update Proposal status to Mgr Approved</description>
        <field>UNITY_Proposal_Status__c</field>
        <literalValue>Discount - Approved by Manager</literalValue>
        <name>Update Proposal Status Mgr Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Quote_Escalation_Field</fullName>
        <description>Update escalation field after 48 hrs of no response</description>
        <field>UNITY_Customer_Provided_Quote_No_Reply__c</field>
        <literalValue>1</literalValue>
        <name>Update Quote Escalation Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Status_Approval</fullName>
        <description>Set status to Sent for manager approval when the Submit for approval button is clicked.</description>
        <field>UNITY_Proposal_Status__c</field>
        <literalValue>Proposal sent for Manager Approval</literalValue>
        <name>UNITY_Update_Status_Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_to_Quote_Finalized_Status</fullName>
        <field>UNITY_Proposal_Status__c</field>
        <literalValue>Quote Finalized</literalValue>
        <name>Update to Quote Finalized Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNTIY_Proposal_Status_Mgr_Reject</fullName>
        <description>Update Proposal Status to Discount - Mgr Rejected</description>
        <field>UNITY_Proposal_Status__c</field>
        <literalValue>Discount - Rejected by Manager</literalValue>
        <name>Proposal Status Mgr Reject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>UNITY_Customer_Proposal_Accept</fullName>
        <actions>
            <name>UNITY_Proposal_Status_Return_to_Agent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Update_48_hrs_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>UNITY_Proposal__c.UNITY_Status__c</field>
            <operation>equals</operation>
            <value>Accepted</value>
        </criteriaItems>
        <criteriaItems>
            <field>UNITY_Proposal__c.UNITY_Proposal_Status__c</field>
            <operation>equals</operation>
            <value>Sent to Customer</value>
        </criteriaItems>
        <description>WF to perform tasks when Proposal is accepted by customer</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Customer_Proposal_Reject</fullName>
        <actions>
            <name>UNITY_Proposal_Status_Return_to_Agent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Update_48_hrs_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>UNITY_Proposal__c.UNITY_Status__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>UNITY_Proposal__c.UNITY_Proposal_Status__c</field>
            <operation>equals</operation>
            <value>Sent to Customer</value>
        </criteriaItems>
        <description>Tasks to be performed when Customer Rejects a Proposal</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Master_quote_effective_date</fullName>
        <actions>
            <name>UNITY_Update_Master_Quote_Effective_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>UNITY_Proposal__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Master Quote</value>
        </criteriaItems>
        <criteriaItems>
            <field>UNITY_Proposal__c.UNITY_Proposal_Status__c</field>
            <operation>equals</operation>
            <value>Quote Finalized</value>
        </criteriaItems>
        <description>the effective date on Master Quote should be today() + 30 after the Master quote is set to finalized</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Agents_on_Proposal_Status</fullName>
        <actions>
            <name>UNITY_Notify_Agent_on_Proposal_Status_Update</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>notify Agents whether the Status is Accepted/Rejected</description>
        <formula>OR( AND ( ISPICKVAL(PRIORVALUE(UNITY_Status__c), &apos;Rejected&apos;), ISPICKVAL(UNITY_Status__c, &apos;Accepted&apos;) ) , AND ( ISPICKVAL(PRIORVALUE(UNITY_Status__c), &apos;Accepted&apos;), ISPICKVAL(UNITY_Status__c, &apos;Rejected&apos;) )  , AND (  ISBLANK(PRIORVALUE(UNITY_Status__c)) , ISPICKVAL(UNITY_Status__c, &apos;Accepted&apos;) ) , AND (  ISBLANK(PRIORVALUE(UNITY_Status__c))  , ISPICKVAL(UNITY_Status__c, &apos;Rejected&apos;) )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Agents_on_Proposal_Status_MNS</fullName>
        <actions>
            <name>UNITY_Notify_Agent_on_Proposal_Status_Update_MNS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>notify Agents whether the Status is Accepted/Rejected BU MNS</description>
        <formula>AND ( OR( ISPICKVAL( UNITY_Case__r.UNITY_Business_Unit__c,&apos;MNS&apos;),  CONTAINS(  UNITY_Case__r.UNITY_Business_Unit_Formula__c , &apos;MSP&apos;) ),  OR( AND ( ISPICKVAL(PRIORVALUE(UNITY_Status__c), &apos;Rejected&apos;), ISPICKVAL(UNITY_Status__c, &apos;Accepted&apos;) ) , AND ( ISPICKVAL(PRIORVALUE(UNITY_Status__c), &apos;Accepted&apos;), ISPICKVAL(UNITY_Status__c, &apos;Rejected&apos;) )  , AND (  ISBLANK(PRIORVALUE(UNITY_Status__c)) , ISPICKVAL(UNITY_Status__c, &apos;Accepted&apos;) ) , AND (  ISBLANK(PRIORVALUE(UNITY_Status__c))  , ISPICKVAL(UNITY_Status__c, &apos;Rejected&apos;) )  ),  RecordType.Name = &quot;Master Quote&quot; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Agents_on_Proposal_Status_NSBS</fullName>
        <actions>
            <name>UNITY_Notify_Agent_on_Proposal_Status_Update_NSBS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>notify Agents whether the Status is Accepted/Rejected BU NSBS</description>
        <formula>AND ( ISPICKVAL( UNITY_Case__r.UNITY_Business_Unit__c ,&apos;NSBS&apos;), OR( AND ( ISPICKVAL(PRIORVALUE(UNITY_Status__c), &apos;Rejected&apos;), ISPICKVAL(UNITY_Status__c, &apos;Accepted&apos;) ) , AND ( ISPICKVAL(PRIORVALUE(UNITY_Status__c), &apos;Accepted&apos;), ISPICKVAL(UNITY_Status__c, &apos;Rejected&apos;) )  , AND (  ISBLANK(PRIORVALUE(UNITY_Status__c)) , ISPICKVAL(UNITY_Status__c, &apos;Accepted&apos;) ) , AND (  ISBLANK(PRIORVALUE(UNITY_Status__c))  , ISPICKVAL(UNITY_Status__c, &apos;Rejected&apos;) )  ) ,  RecordType.Name = &quot;Master Quote&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Agents_on_Proposal_Status_craft</fullName>
        <actions>
            <name>UNITY_Notify_Agent_on_Proposal_Status_Update_Craft</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>notify Agents whether the Status is Accepted/Rejected BU Craft</description>
        <formula>AND ( ISPICKVAL( UNITY_Case__r.UNITY_Business_Unit__c ,&apos;Craft&apos;), OR( AND ( ISPICKVAL(PRIORVALUE(UNITY_Status__c), &apos;Rejected&apos;), ISPICKVAL(UNITY_Status__c, &apos;Accepted&apos;) ) , AND ( ISPICKVAL(PRIORVALUE(UNITY_Status__c), &apos;Accepted&apos;), ISPICKVAL(UNITY_Status__c, &apos;Rejected&apos;) )  , AND (  ISBLANK(PRIORVALUE(UNITY_Status__c)) , ISPICKVAL(UNITY_Status__c, &apos;Accepted&apos;) ) , AND (  ISBLANK(PRIORVALUE(UNITY_Status__c))  , ISPICKVAL(UNITY_Status__c, &apos;Rejected&apos;) )  ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Customer_of_Pending_Proposal</fullName>
        <actions>
            <name>UNITY_Notify_Customer_for_Proposal_Approval</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notify Customer that a Proposal is pending for approval</description>
        <formula>ISPICKVAL( UNITY_Status__c,&apos;&apos; ) &amp;&amp; ISPICKVAL( UNITY_Proposal_Status__c,&apos;Ready to Send to Customer&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Customer_of_Pending_Proposal_Craft</fullName>
        <actions>
            <name>UNITY_Notify_Customer_for_Proposal_Approval_Craft</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notify Customer that a Proposal is pending for approval Craft</description>
        <formula>ISPICKVAL( UNITY_Status__c,&apos;&apos; ) &amp;&amp; ISPICKVAL( UNITY_Proposal_Status__c,&apos;Sent to Customer&apos; ) &amp;&amp; ISPICKVAL( UNITY_Case__r.UNITY_Business_Unit__c,&apos;Craft&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Customer_of_Pending_Proposal_MNS</fullName>
        <actions>
            <name>UNITY_Notify_Customer_for_Proposal_Approval_MNS</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notify Customer that a Proposal is pending for approval MNS</description>
        <formula>ISPICKVAL( UNITY_Status__c,&apos;&apos; ) &amp;&amp; ISPICKVAL( UNITY_Proposal_Status__c,&apos;Sent to Customer&apos; ) &amp;&amp; OR( ISPICKVAL(UNITY_Case__r.UNITY_Business_Unit__c,&apos;MNS&apos;),  CONTAINS( UNITY_Case__r.UNITY_Business_Unit_Formula__c , &apos;MSP&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Customer_of_Pending_Proposal_NSBS</fullName>
        <actions>
            <name>UNITY_Notify_Customer_for_Proposal_Approval_NSBS</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notify Customer that a Proposal is pending for approval NSBS</description>
        <formula>ISPICKVAL( UNITY_Status__c,&apos;&apos; ) &amp;&amp; ISPICKVAL( UNITY_Proposal_Status__c,&apos;Sent to Customer&apos; ) &amp;&amp; ISPICKVAL( UNITY_Case__r.UNITY_Business_Unit__c,&apos;NSBS&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Proposal_Amended_Sent_Mgr</fullName>
        <actions>
            <name>UNITY_Reset_Customer_Comments</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Reset_Manager_Approved_Discount</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Update_Customer_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>UNITY_Proposal__c.UNITY_Proposal_Status__c</field>
            <operation>equals</operation>
            <value>Quote Creation,Proposal Amended</value>
        </criteriaItems>
        <description>Proposal Amended and sent to Manager</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Set_Escalation_48hrs_Customer_No_response</fullName>
        <active>true</active>
        <criteriaItems>
            <field>UNITY_Proposal__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Proposal</value>
        </criteriaItems>
        <criteriaItems>
            <field>UNITY_Proposal__c.UNITY_Proposal_Status__c</field>
            <operation>equals</operation>
            <value>Sent to Customer</value>
        </criteriaItems>
        <criteriaItems>
            <field>UNITY_Proposal__c.UNITY_Status__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Set escalation field after 48hrs of no response by customer and trigger PB to post to chatter</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>UNITY_Update_48_hrs_True</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>48</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>UNITY_Update_UNITY_Customer_Provided_Quote_No_Reply%5F%5Fc</fullName>
        <actions>
            <name>UNITY_Update_Quote_Escalation_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>UNITY_Proposal__c.UNITY_48_Hours__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>UNITY_Proposal__c.UNITY_Status__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>UNITY_Proposal__c.UNITY_Proposal_Status__c</field>
            <operation>equals</operation>
            <value>Sent to Customer</value>
        </criteriaItems>
        <description>Update UNITY_Customer_Provided_Quote_No_Reply__c after 48 hrs = true</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
