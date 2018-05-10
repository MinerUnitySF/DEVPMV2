<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Hide_Detail_Lines</fullName>
        <field>Hide_Line_c__c</field>
        <literalValue>1</literalValue>
        <name>Hide Detail Lines</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ID_Line_Cost_Per_Unit_idc</fullName>
        <description>Updated Line Cost Per Unit</description>
        <field>Line_Price_per_Unit__c</field>
        <formula>Work_Detail__r.SVMXC__Actual_Price2__c</formula>
        <name>ID Line Cost Per Unit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Record_Type_Read_Only</fullName>
        <description>When the status on the Invoice is set to &quot;In-Batch&quot; or &quot;Billed&quot;, switch the Invoice Detail record type to Read Only.</description>
        <field>RecordTypeId</field>
        <lookupValue>MH_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Record Type = Read Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SL_Invoiced_Date</fullName>
        <description>Update date invoiced on an invoice detail line to mirror the date selected on the invoice header for back-billing purposes</description>
        <field>Date_Invoiced__c</field>
        <formula>IF( ISBLANK(Work_Order__r.SL_Invoice_Date__c) , TODAY() , Work_Order__r.SL_Invoice_Date__c)</formula>
        <name>SL Invoiced Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Invoice_Date_Invoiced</fullName>
        <field>Date_Invoiced__c</field>
        <formula>TODAY()</formula>
        <name>Set Invoice Date Invoiced</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_ID_Cost</fullName>
        <field>Detail_Line_Cost__c</field>
        <formula>Work_Detail__r.SVMXC__Actual_Quantity2__c   *  Work_Detail__r.Vendor_Cost_Per_Unit__c</formula>
        <name>Update ID Cost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_ID_UOM_idc</fullName>
        <description>Update invoice detail UOM</description>
        <field>Unit_of_Measure_idc__c</field>
        <formula>Work_Detail__r.Unit_of_Measure__c</formula>
        <name>Update ID UOM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_TFS_Sales_Tax_ID</fullName>
        <field>Sales_Tax__c</field>
        <formula>0</formula>
        <name>Update TFS Sales Tax IDetail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Detail_Update_idc</fullName>
        <description>Update work description with work detail description</description>
        <field>Work_Description_idc__c</field>
        <formula>Work_Detail__r.SVMXC__Work_Description__c</formula>
        <name>Work Detail Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Hide All Invoice Details</fullName>
        <actions>
            <name>Hide_Detail_Lines</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>MH_Invoice__c.Hide_Line_ic__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>MH_Invoice__c.Status__c</field>
            <operation>notEqual</operation>
            <value>In-Batch,Billed</value>
        </criteriaItems>
        <description>Sets all detail lines to TRUE when TRUE</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Invoice Detail - Read Only</fullName>
        <actions>
            <name>Record_Type_Read_Only</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>MH_Invoice_Details__c.Invoice_Status__c</field>
            <operation>contains</operation>
            <value>In-Batch</value>
        </criteriaItems>
        <description>When the status of the Invoice is set to &quot;In-Batch&quot; switch the record type of the Invoice Detail to Read Only.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Invoice Detail Date Update</fullName>
        <actions>
            <name>SL_Invoiced_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>MH_Invoice__c.Status__c</field>
            <operation>equals</operation>
            <value>Not Billed,In-Batch,Billed,Void,Under Review</value>
        </criteriaItems>
        <description>Update date invoiced on an invoice detail line to mirror the date selected on the invoice header for back-billing purposes</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Invoice Work Details</fullName>
        <actions>
            <name>ID_Line_Cost_Per_Unit_idc</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_ID_UOM_idc</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Work_Detail_Update_idc</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>MH_Invoice__c.Status__c</field>
            <operation>equals</operation>
            <value>Not Billed</value>
        </criteriaItems>
        <description>Updates invoice work detail lines with work description</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update ID Cost</fullName>
        <actions>
            <name>Update_ID_Cost</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>MH_Invoice_Details__c.Line_Type__c</field>
            <operation>equals</operation>
            <value>Parts,Labor,Expenses,Travel,Vendor Services</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update TFS Sales Tax IDetail</fullName>
        <actions>
            <name>Update_TFS_Sales_Tax_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>MH_Invoice__c.Status__c</field>
            <operation>equals</operation>
            <value>Not Billed</value>
        </criteriaItems>
        <criteriaItems>
            <field>MH_Invoice__c.Service_Team_ic__c</field>
            <operation>equals</operation>
            <value>Total Fleet Solutions</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
