<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>UNITY_Notify_Agent_when_Invoice_Status_changes</fullName>
        <description>Notify Agent on Invoice Status changes</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Notify_Agents_Invoice_Status</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Notify_Agent_when_Invoice_Status_changes_Craft</fullName>
        <ccEmails>Customer_Support_Craft@email.address</ccEmails>
        <description>Notify Agent on Invoice Status changes Craft</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customersupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Notify_Agents_Invoice_Status</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Notify_Agent_when_Invoice_Status_changes_MNS</fullName>
        <description>Notify Agent on Invoice Status changes MNS</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Notify_Agents_Invoice_Status</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Notify_Agent_when_Invoice_Status_changes_NSBS</fullName>
        <description>Notify Agent on Invoice Status changes NSBS</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Agent__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Notify_Agents_Invoice_Status</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Notify_Customer_for_Invoice_Approval</fullName>
        <description>Notify Customer for Invoice Approval</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Customer_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Invoice_Email</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Notify_Customer_for_Invoice_Approval_Craft</fullName>
        <ccEmails>Customer_Support_Craft@email.address</ccEmails>
        <description>Notify Customer for Invoice Approval Craft</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Customer_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customersupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Invoice_Email</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Notify_Customer_for_Invoice_Approval_MNS</fullName>
        <description>Notify Customer for Invoice Approval MNS</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Customer_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Invoice_Email</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Notify_Customer_for_Invoice_Approval_NSBS</fullName>
        <description>Notify Customer for Invoice Approval NSBS</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Customer_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Invoice_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>UNITY_Manager_Approval_Discounts</fullName>
        <field>UNITY_Manager_Approved_Discounts__c</field>
        <literalValue>1</literalValue>
        <name>Manager Approval Discounts</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Margin_Value_Approved</fullName>
        <field>UNITY_Margin_Value_Approval__c</field>
        <literalValue>1</literalValue>
        <name>Margin Value Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Margin_Value_Field_Not_Approved</fullName>
        <field>UNITY_Margin_Value_Approval__c</field>
        <literalValue>0</literalValue>
        <name>Margin Value Field Not Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Margin_Value_Not_Approved</fullName>
        <field>UNITY_Margin_Value_Sent_for_Approval__c</field>
        <literalValue>0</literalValue>
        <name>Margin Value Not Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Reset_Customer_Comment_FIelds</fullName>
        <description>Reset COmments from customer</description>
        <field>UNITY_Comments__c</field>
        <name>Reset Customer Comment FIelds</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Reset_Customer_Status</fullName>
        <field>UNITY_Status__c</field>
        <literalValue>Accepted</literalValue>
        <name>Reset Customer Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Reset_InvManager_Approved_Discount</fullName>
        <description>Reset Manager Approved Disocunt to False</description>
        <field>UNITY_Manager_Approved_Discounts__c</field>
        <literalValue>0</literalValue>
        <name>Reset Inv Manager Approved Discount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Send_for_Margin_Approval</fullName>
        <field>UNITY_Margin_Value_Sent_for_Approval__c</field>
        <literalValue>1</literalValue>
        <name>Send for Margin Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Customer_Status_to_NULL</fullName>
        <description>Update customer status to null after manager approval of invoice discount approval</description>
        <field>UNITY_Status__c</field>
        <name>Update Customer Status to NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Invoice_Status_Return_Agent</fullName>
        <description>UPdate the invoice status to &quot;Return to Agent&quot;</description>
        <field>UNITY_Invoice_Status__c</field>
        <literalValue>Returned to Agent</literalValue>
        <name>Update Invoice Status Return to Agent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Manager_Approved_DIscount</fullName>
        <description>Update the Manager approved discount to NULL</description>
        <field>UNITY_Manager_Approved_Discounts__c</field>
        <literalValue>0</literalValue>
        <name>Update Manager Approved DIscount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Status_Return_to_Agent</fullName>
        <description>Update the invoice status to &quot;Return to Agent&quot;</description>
        <field>UNITY_Invoice_Status__c</field>
        <literalValue>Returned to Agent</literalValue>
        <name>Update Status Return to Agent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Status_Submit_for_Approval</fullName>
        <description>Update the status of the invoice to &quot;Invoice Sent for Manager approval&quot;</description>
        <field>UNITY_Invoice_Status__c</field>
        <literalValue>Invoice sent for Manager Approval</literalValue>
        <name>Update Status Submit for Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Status_to_Discount_Approved</fullName>
        <description>Update the status of invoice to Discount - Approved by Manager</description>
        <field>UNITY_Invoice_Status__c</field>
        <literalValue>Discount - Approved by Manager</literalValue>
        <name>Update Status to Discount Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Update_Status_to_Discount_Rejected</fullName>
        <description>Update status of the invoice to Discount Rejected</description>
        <field>UNITY_Invoice_Status__c</field>
        <literalValue>Discount - Rejected by Manager</literalValue>
        <name>Update Status to Discount Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>UNITY_Customer_Invoice_Accept</fullName>
        <actions>
            <name>UNITY_Update_Status_Return_to_Agent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>UNITY_Invoice__c.UNITY_Invoice_Status__c</field>
            <operation>equals</operation>
            <value>Sent to Customer</value>
        </criteriaItems>
        <criteriaItems>
            <field>UNITY_Invoice__c.UNITY_Status__c</field>
            <operation>equals</operation>
            <value>Accepted</value>
        </criteriaItems>
        <description>WF to perform tasks when Invoice is accepted by customer</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Customer_Invoice_Reject</fullName>
        <actions>
            <name>UNITY_Update_Invoice_Status_Return_Agent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>UNITY_Invoice__c.UNITY_Invoice_Status__c</field>
            <operation>equals</operation>
            <value>Sent to Customer</value>
        </criteriaItems>
        <criteriaItems>
            <field>UNITY_Invoice__c.UNITY_Status__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <description>Tasks to be performed when Customer Rejects a Invoice</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Invoice_Amended_Sent_Mgr</fullName>
        <actions>
            <name>UNITY_Reset_Customer_Comment_FIelds</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Reset_Customer_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Reset_InvManager_Approved_Discount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>UNITY_Invoice__c.UNITY_Invoice_Status__c</field>
            <operation>equals</operation>
            <value>Invoice Creation,Invoice Amended</value>
        </criteriaItems>
        <description>Reset the Manager discount approved to false when status is Invoice Amended</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Agent_Invoice_Status</fullName>
        <actions>
            <name>UNITY_Notify_Agent_when_Invoice_Status_changes</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>notify Agents whether the Status is Accepted/Rejected</description>
        <formula>OR(  AND (ISPICKVAL(PRIORVALUE(UNITY_Status__c), &apos;Rejected&apos;), ISPICKVAL(UNITY_Status__c, &apos;Accepted&apos;) )  ,  AND (ISPICKVAL(PRIORVALUE(UNITY_Status__c), &apos;Accepted&apos;), ISPICKVAL(UNITY_Status__c, &apos;Rejected&apos;) )  ,  AND ( ISBLANK(PRIORVALUE(UNITY_Status__c)) , ISPICKVAL(UNITY_Status__c, &apos;Accepted&apos;) )  ,  AND ( ISBLANK(PRIORVALUE(UNITY_Status__c)) , ISPICKVAL(UNITY_Status__c, &apos;Rejected&apos;) )   )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Agent_Invoice_Status_Craft</fullName>
        <actions>
            <name>UNITY_Notify_Agent_when_Invoice_Status_changes_Craft</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>notify Agents whether the Status is Accepted/Rejected BU Craft</description>
        <formula>AND (  ISPICKVAL(UNITY_Case__r.UNITY_Business_Unit__c,&apos;Craft&apos;),   OR(   AND (ISPICKVAL(PRIORVALUE(UNITY_Status__c), &apos;Rejected&apos;), ISPICKVAL(UNITY_Status__c, &apos;Accepted&apos;) )  ,   AND (ISPICKVAL(PRIORVALUE(UNITY_Status__c), &apos;Accepted&apos;), ISPICKVAL(UNITY_Status__c, &apos;Rejected&apos;) )  ,   AND ( ISBLANK(PRIORVALUE(UNITY_Status__c)) , ISPICKVAL(UNITY_Status__c, &apos;Accepted&apos;) )  ,   AND ( ISBLANK(PRIORVALUE(UNITY_Status__c)) , ISPICKVAL(UNITY_Status__c, &apos;Rejected&apos;) )    ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Agent_Invoice_Status_MNS</fullName>
        <actions>
            <name>UNITY_Notify_Agent_when_Invoice_Status_changes_MNS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>notify Agents whether the Status is Accepted/Rejected BU MNS</description>
        <formula>AND (  OR( ISPICKVAL(UNITY_Case__r.UNITY_Business_Unit__c,&apos;MNS&apos;),       CONTAINS( UNITY_Case__r.UNITY_Business_Unit_Formula__c , &apos;MSP&apos;) ),  OR(        AND (ISPICKVAL(PRIORVALUE(UNITY_Status__c), &apos;Rejected&apos;), ISPICKVAL(UNITY_Status__c, &apos;Accepted&apos;) )  ,        AND (ISPICKVAL(PRIORVALUE(UNITY_Status__c), &apos;Accepted&apos;), ISPICKVAL(UNITY_Status__c, &apos;Rejected&apos;) )  ,        AND ( ISBLANK(PRIORVALUE(UNITY_Status__c)) , ISPICKVAL(UNITY_Status__c, &apos;Accepted&apos;) )  ,        AND ( ISBLANK(PRIORVALUE(UNITY_Status__c)) , ISPICKVAL(UNITY_Status__c, &apos;Rejected&apos;) )       ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Agent_Invoice_Status_NSBS</fullName>
        <actions>
            <name>UNITY_Notify_Agent_when_Invoice_Status_changes_NSBS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>notify Agents whether the Status is Accepted/Rejected BU NSBS</description>
        <formula>AND (  ISPICKVAL(UNITY_Case__r.UNITY_Business_Unit__c,&apos;NSBS&apos;),   OR(   AND (ISPICKVAL(PRIORVALUE(UNITY_Status__c), &apos;Rejected&apos;), ISPICKVAL(UNITY_Status__c, &apos;Accepted&apos;) )  ,   AND (ISPICKVAL(PRIORVALUE(UNITY_Status__c), &apos;Accepted&apos;), ISPICKVAL(UNITY_Status__c, &apos;Rejected&apos;) )  ,   AND ( ISBLANK(PRIORVALUE(UNITY_Status__c)) , ISPICKVAL(UNITY_Status__c, &apos;Accepted&apos;) )  ,   AND ( ISBLANK(PRIORVALUE(UNITY_Status__c)) , ISPICKVAL(UNITY_Status__c, &apos;Rejected&apos;) )    ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Customer_of_Pending_Invoice</fullName>
        <actions>
            <name>UNITY_Notify_Customer_for_Invoice_Approval</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>UNITY_Invoice__c.UNITY_Invoice_Status__c</field>
            <operation>equals</operation>
            <value>Sent to Customer</value>
        </criteriaItems>
        <criteriaItems>
            <field>UNITY_Invoice__c.UNITY_Status__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Notify Customer that a Invoice is pending for approval</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Customer_of_Pending_Invoice_Craft</fullName>
        <actions>
            <name>UNITY_Notify_Customer_for_Invoice_Approval_Craft</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notify Customer that a Invoice is pending for approval BU Craft</description>
        <formula>ispickval( UNITY_Invoice_Status__c ,&apos;Sent to Customer&apos;) &amp;&amp;  ispickval( UNITY_Status__c ,&apos;&apos;) &amp;&amp;  ispickval( UNITY_Case__r.UNITY_Business_Unit__c, &apos;Craft&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Customer_of_Pending_Invoice_MNS</fullName>
        <actions>
            <name>UNITY_Notify_Customer_for_Invoice_Approval_MNS</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notify Customer that a Invoice is pending for approval BU MNS</description>
        <formula>ispickval( UNITY_Invoice_Status__c ,&apos;Sent to Customer&apos;) &amp;&amp;  ispickval( UNITY_Status__c ,&apos;&apos;) &amp;&amp;  OR( ISPICKVAL(UNITY_Case__r.UNITY_Business_Unit__c,&apos;MNS&apos;),  CONTAINS( UNITY_Case__r.UNITY_Business_Unit_Formula__c , &apos;MSP&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Notify_Customer_of_Pending_Invoice_NSBS</fullName>
        <actions>
            <name>UNITY_Notify_Customer_for_Invoice_Approval_NSBS</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notify Customer that a Invoice is pending for approval BU NSBS</description>
        <formula>ispickval( UNITY_Invoice_Status__c ,&apos;Sent to Customer&apos;) &amp;&amp;  ispickval( UNITY_Status__c ,&apos;&apos;) &amp;&amp;  ispickval( UNITY_Case__r.UNITY_Business_Unit__c, &apos;NSBS&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
