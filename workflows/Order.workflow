<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>UNITY_Multiple_Shipment_Notification_to_Vendor</fullName>
        <description>Multiple Shipment Notification to Vendor</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Multiple_Shipment_Notification</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Multiple_Shipment_Notification_to_Vendor_Craft</fullName>
        <ccEmails>Vendor_Support_Craft@email.address</ccEmails>
        <description>Multiple Shipment Notification to Vendor Craft</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>vendorsupport_uat@nsbs.net</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Multiple_Shipment_Notification</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Multiple_Shipment_Notification_to_Vendor_MNS</fullName>
        <description>Multiple Shipment Notification to Vendor MNS</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Multiple_Shipment_Notification</template>
    </alerts>
    <alerts>
        <fullName>UNITY_Multiple_Shipment_Notification_to_Vendor_NSBS</fullName>
        <description>Multiple Shipment Notification to Vendor NSBS</description>
        <protected>false</protected>
        <recipients>
            <field>UNITY_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>vendorsupport_uat@minercorp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>UNITY_Email_Templates/UNITY_Multiple_Shipment_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Populate_Ship_to_Country</fullName>
        <field>ShippingCountry</field>
        <formula>UNITY_Ship_To_Account__r.ShippingCountry</formula>
        <name>Populate Ship to Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ShipToContact_Street</fullName>
        <description>Updates shipping street when ship to contact is changed</description>
        <field>ShippingStreet</field>
        <formula>ShipToContact.MailingStreet</formula>
        <name>ShipToContact Update Street</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ShipToContact_Update_City</fullName>
        <description>When ship to contact changes, update shipping city</description>
        <field>ShippingCity</field>
        <formula>ShipToContact.MailingCity</formula>
        <name>ShipToContact Update City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ShipToContact_Update_Country</fullName>
        <field>ShippingCountry</field>
        <formula>ShipToContact.MailingCountry</formula>
        <name>ShipToContact Update Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ShipToContact_Update_State</fullName>
        <field>ShippingState</field>
        <formula>ShipToContact.MailingState</formula>
        <name>ShipToContact Update State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ShipToContact_Update_Zip</fullName>
        <field>ShippingPostalCode</field>
        <formula>ShipToContact.MailingPostalCode</formula>
        <name>ShipToContact Update Zip</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Skip_Pricing_Rule</fullName>
        <field>MSPFS_Skip_Pricing_Rules__c</field>
        <literalValue>1</literalValue>
        <name>Skip Pricing Rule</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Check_Extended_Labor</fullName>
        <description>Set extended labor to true</description>
        <field>UNITY_Extended_Labor_Only__c</field>
        <literalValue>1</literalValue>
        <name>Check Extended Labor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Order_Start_Date_Populate</fullName>
        <field>EffectiveDate</field>
        <formula>Today()</formula>
        <name>Order Start Date Populate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Populate_Ship_To_City</fullName>
        <field>ShippingCity</field>
        <formula>UNITY_Ship_To_Account__r.ShippingCity</formula>
        <name>Populate Ship To City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Populate_Ship_To_State</fullName>
        <field>ShippingState</field>
        <formula>UNITY_Ship_To_Account__r.ShippingState</formula>
        <name>Populate Ship To State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Populate_Ship_To_Street</fullName>
        <field>ShippingStreet</field>
        <formula>UNITY_Ship_To_Account__r.ShippingStreet</formula>
        <name>Populate Ship To Street</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Populate_Ship_to_Postal_Code</fullName>
        <field>ShippingPostalCode</field>
        <formula>UNITY_Ship_To_Account__r.ShippingPostalCode</formula>
        <name>Populate Ship to Postal Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Populate_Vendor_Email</fullName>
        <field>UNITY_Vendor_Email__c</field>
        <formula>FSO__WorkOrder__r.UNITY_Vendor_Email__c</formula>
        <name>Populate Vendor Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Set_Paid_with_CC_DateTime</fullName>
        <field>UNITY_Paid_with_CC_Date__c</field>
        <formula>NOW()</formula>
        <name>UNITY Set Paid with CC DateTime</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Ship_to_Country</fullName>
        <field>ShippingCountry</field>
        <formula>TEXT(UNITY_Ship_To_Account__r.ShippingCountryCode)</formula>
        <name>UNITY Ship to Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UNITY_Uncheck_Draft_Mode</fullName>
        <description>Unchecks drfat mode in order</description>
        <field>UNITY_Draft_Mode__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Draft Mode</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>UNITY Set Paid with CC DateTime</fullName>
        <actions>
            <name>UNITY_Set_Paid_with_CC_DateTime</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order.UNITY_Paid_with_CC__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Adjustment_Purchase_Order_Skip_Pricing_Rule</fullName>
        <actions>
            <name>Skip_Pricing_Rule</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order.RecordTypeId</field>
            <operation>equals</operation>
            <value>Adjustment Purchase Order</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_OrderStartDate</fullName>
        <actions>
            <name>UNITY_Order_Start_Date_Populate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate today&apos;s date for Order</description>
        <formula>RecordType.Name = &quot;Purchase Order&quot; || RecordType.Name = &quot;Usage Request&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Order_Draft_Mode_Disable</fullName>
        <actions>
            <name>UNITY_Uncheck_Draft_Mode</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>Draft</value>
        </criteriaItems>
        <description>ORDER OBJECT - Uncheck DRAFT mode once the status is changed to SUBMITTED TO MINER</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Set_extended_Labor</fullName>
        <actions>
            <name>UNITY_Check_Extended_Labor</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Extended labor field to true on PO creation</description>
        <formula>$RecordType.Name = &quot;Purchase Order&quot; &amp;&amp;  isPickVal(FSO__WorkOrder__r.Status , &apos;In Progress&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_ShipToAddress</fullName>
        <actions>
            <name>Populate_Ship_to_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Populate_Ship_To_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Populate_Ship_To_State</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Populate_Ship_To_Street</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Populate_Ship_to_Postal_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UNITY_Ship_to_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Auto-populate ship to address based on Account</description>
        <formula>(RecordType.Name = &quot;Purchase Order&quot; || RecordType.Name = &quot;Usage Request&quot; || RecordType.Name = &quot;Parts Sourcing Purchase Order&quot;) &amp;&amp; (ISChanged(UNITY_Ship_To_Account__c) &amp;&amp; !IsBLANK(UNITY_Ship_To_Account__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_ShipToContact</fullName>
        <actions>
            <name>ShipToContact_Street</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ShipToContact_Update_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ShipToContact_Update_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ShipToContact_Update_State</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ShipToContact_Update_Zip</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Auto-populate ship to address based on the Ship to Contact</description>
        <formula>(RecordType.Name = &quot;Purchase Order&quot; || RecordType.Name = &quot;Usage Request&quot; || RecordType.Name = &quot;Parts Sourcing Purchase Order&quot;) &amp;&amp; IsChanged( ShipToContactId) &amp;&amp; !IsBlank(ShipToContactId) &amp;&amp; (!IsBlank(ShipToContact.MailingStreet) || !IsBlank(ShipToContact.MailingCity)|| !IsBlank(ShipToContact.MailingState) || !IsBlank(ShipToContact.MailingPostalCode) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Vendor Email Address</fullName>
        <actions>
            <name>UNITY_Populate_Vendor_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order.RecordTypeId</field>
            <operation>equals</operation>
            <value>Purchase Order,Usage Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Vendor Notification for Multiple Shipments</fullName>
        <actions>
            <name>UNITY_Multiple_Shipment_Notification_to_Vendor</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Order.RecordTypeId</field>
            <operation>equals</operation>
            <value>Usage Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>Parts Being Delivered</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.UNITY_Number_of_Shipments__c</field>
            <operation>greaterThan</operation>
            <value>1</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Vendor Notification for Multiple Shipments MNS</fullName>
        <actions>
            <name>UNITY_Multiple_Shipment_Notification_to_Vendor_MNS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order.RecordTypeId</field>
            <operation>equals</operation>
            <value>Usage Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>Parts Being Delivered</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.UNITY_Number_of_Shipments__c</field>
            <operation>greaterThan</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.UNITY_Business_Unit__c</field>
            <operation>equals</operation>
            <value>MNS,MSP Atlanta,MSP Dallas,MSP El Paso,MSP Houston,MSP Jacksonville,MSP Memphis,MSP Miami,MSP Nashville,MSP New Orleans,MSP Orlando,MSP Phoenix,MSP San Antonio,MSP Tampa</value>
        </criteriaItems>
        <description>Vendor notification of multiple shipments to Vendor MNS BU</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Vendor Notification for Multiple Shipments NSBS</fullName>
        <actions>
            <name>UNITY_Multiple_Shipment_Notification_to_Vendor_NSBS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order.RecordTypeId</field>
            <operation>equals</operation>
            <value>Usage Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>Parts Being Delivered</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.UNITY_Number_of_Shipments__c</field>
            <operation>greaterThan</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.UNITY_Business_Unit__c</field>
            <operation>equals</operation>
            <value>NSBS</value>
        </criteriaItems>
        <description>Vendor notification of multiple shipments to Vendor NSBS BU</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UNITY_Vendor Notification for Multiple Shipments craft</fullName>
        <actions>
            <name>UNITY_Multiple_Shipment_Notification_to_Vendor_Craft</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order.RecordTypeId</field>
            <operation>equals</operation>
            <value>Usage Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>Parts Being Delivered</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.UNITY_Number_of_Shipments__c</field>
            <operation>greaterThan</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.UNITY_Business_Unit__c</field>
            <operation>equals</operation>
            <value>Craft</value>
        </criteriaItems>
        <description>Vendor notification of multiple shipments to Vendor Craft BU</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
