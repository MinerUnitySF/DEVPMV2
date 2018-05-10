<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>UNITY_Send_WO_Retraction_Email</fullName>
        <description>UNITY Send WO Retraction Email</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Work_Order_Retraction_Email</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Send_WO_Retraction_Email_Craft</fullName>
        <ccEmails>Vendor_Support_Craft@email.address</ccEmails>
        <description>UNITY Send WO Retraction Email Craft</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>vendorsupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Work_Order_Retraction_Email</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Send_WO_Retraction_Email_MNS</fullName>
        <description>UNITY Send WO Retraction Email MNS</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Work_Order_Retraction_Email</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Send_WO_Retraction_Email_NSBS</fullName>
        <description>UNITY Send WO Retraction Email NSBS</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Work_Order_Retraction_Email</template>
    </alerts>
    <rules>
        <fullName>UNITY_Work_Order_Retraction</fullName>
        <actions>
            <name>UNITY_Send_WO_Retraction_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND ( OR( ISPICKVAL(PRIORVALUE(Status__c),&apos;Assigned&apos;), ISPICKVAL(PRIORVALUE(Status__c),&apos;Accepted&apos;)), BEGINS(TEXT(Status__c), &apos;Rejected&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Work_Order_Retraction_Craft</fullName>
        <actions>
            <name>UNITY_Send_WO_Retraction_Email_Craft</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND (  ISPICKVAL( Work_Order__r.UNITY_Business_Unit__c,&apos;Craft&apos;) , OR( ISPICKVAL(PRIORVALUE(Status__c),&apos;Assigned&apos;), ISPICKVAL(PRIORVALUE(Status__c),&apos;Accepted&apos;)), BEGINS(TEXT(Status__c), &apos;Rejected&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Work_Order_Retraction_MNS</fullName>
        <actions>
            <name>UNITY_Send_WO_Retraction_Email_MNS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND (  OR( ISPICKVAL(Work_Order__r.UNITY_Business_Unit__c,&apos;MNS&apos;),  CONTAINS( Work_Order__r.UNITY_Business_Unit_Formula__c , &apos;MSP&apos;) ) , OR( ISPICKVAL(PRIORVALUE(Status__c),&apos;Assigned&apos;), ISPICKVAL(PRIORVALUE(Status__c),&apos;Accepted&apos;)), BEGINS(TEXT(Status__c), &apos;Rejected&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Work_Order_Retraction_NSBS</fullName>
        <actions>
            <name>UNITY_Send_WO_Retraction_Email_NSBS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND (  ISPICKVAL( Work_Order__r.UNITY_Business_Unit__c,&apos;NSBS&apos;) , OR( ISPICKVAL(PRIORVALUE(Status__c),&apos;Assigned&apos;), ISPICKVAL(PRIORVALUE(Status__c),&apos;Accepted&apos;)), BEGINS(TEXT(Status__c), &apos;Rejected&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
