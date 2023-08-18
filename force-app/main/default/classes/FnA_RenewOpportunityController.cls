/**************************************************** FnA ORG CODE ***************************************************************** 
* Class  Name       : FnA_RenewOpportunityController
* Division          : Food and Agriculture
* Version           : 1.0
* Code reviewed By  : Amitava Dutta 
* Complexity : Toughest
* JIRA Ticket       : SF20FA-37
* Functionality     : This controller used in lwc component fnA_RenewOpportunity to clone bundle opportunity and related list.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        24-11-2022                          Initial version 
* Umesh Kumar                        21-12-2022                          Added clone functionalty for bundle opportunity also https://scsglobalservices.atlassian.net/browse/SF20FA-402 
* Utkarsh Goswami                    18-12-2023                          Added affiliated fields
************************************************************************************************************************************/


public with sharing class FnA_RenewOpportunityController {
    
    //Get related opportunity of bundle opportunity...
    @AuraEnabled(cacheable = true)
    public static List<Opportunity> getOpportunityList(String oppId){
        List<Opportunity> result =[SELECT Id,Name,Engagement_Type__c,CloseDate,StageName FROM Opportunity WHERE Bundle_Opportunity__c =:oppId];
        return result;
    }
    
    //Create renewal bundle opportunity and related opportunity...
    @AuraEnabled
    public static String createBundleOpportunity(List<String> oppoIds,String previousId,List<String> isRelatedClone,Opportunity newBundle){
        System.debug('step-1'+oppoIds);
        System.debug('step-1'+newBundle);
        System.debug('step-1'+isRelatedClone);
        
        Id opptyCertRT_Id = Schema.SObjectType.Opportunity_Certificate__c.getRecordTypeInfosByDeveloperName().get('Open').getRecordTypeId();
        
        //Query bundle opportunity and related opportunity...
        Map<Id,Opportunity> result = new Map<Id,Opportunity>([SELECT Id,Name,Engagement_Type__c,CloseDate,StageName,Type,AccountId,Affiliate_Name__c,Affiliate_Opportunity_flag__c,
        Billing_Contact__c,Bill_To_Company__c,Show_Discount__c,Include_Cover_Page__c,Payment_Term__c,RecordTypeId,Programc__c,
        Entity__c,fw2__Entity__c,Program_List__c,Bill_To_Address__c,LeadSource,Lead_Source_Details__c,Application_Status__c,Pricebook2Id,
        Web_Traffic_Source__c,Language__c,NextStep,Description,Notes__c,Target_Audit_Date__c,Payment_Terms_Approval__c,Requested_Payment_Term__c,
        Project_Start_Date__c,SCS_Probability__c,Closed_Lost_Date__c,Loss_Reason__c,
        (SELECT Id,Name,CustomerSite__c,Opportunity__c,Shipping_Address__c,Site_Name__c, Customer__c FROM Sites_Covered__r),
        (SELECT Id,Name,Standard__c,Opportunity__c, Program__c FROM Standard_Covered__r),
        (SELECT Id, OpportunityId, UserId, Name, Title, TeamMemberRole, OpportunityAccessLevel FROM OpportunityTeamMembers),
        (SELECT Id, OpportunityId, ContactId, Role, IsPrimary,DMS_Contact_Id__c  FROM OpportunityContactRoles),
        (SELECT Id, Name, RecordTypeId, Description__c, Engagement_Type__c, Entity__c, Language__c, Opportunity__c, Program__c, 
        Title__c, SubScope__c,RecordType.DeveloperName FROM Scope__r WHERE RecordTypeId != null),
        (SELECT Id, Name, RecordTypeId, Description__c, Engagement_Type__c, Entity__c, Language__c, Opportunity__c, Program__c, Title__c FROM Terms_Conditions__r),
        (SELECT Id, OpportunityId, PricebookEntryId, Product2Id, ProductCode, Name, Quantity, Discount, Discount_Amount__c, UnitPrice, ListPrice, ServiceDate, Description,
        fw2__Recurring__c, Cost_Price__c, Total_Sales_Price__c, Description__c, Invoice_Quantity__c  FROM OpportunityLineItems WHERE PricebookEntry.IsActive = TRUE),
        (SELECT Id,Name,Account__c, Certificate_Type__c, Certificate__c, Opportunity__c, Date_of_Audit__c, Date_of_Decision__c,
        Site_Code__c, Has_Achieved__c, GLOBAL_STANDARD_START__c, Certificate_Issue_Date__c, Date_of_Expiry__c, Date_of_Next_Recertification_Audit__c,
        Auditor_Number__c, Product_Category__c, FSC__c, Scope_of_activities__c, Exclusions__c, Has_Achieved_Grade__c, Audit_Programme__c,
        Products__c, Harvest_Method_Observed__c, Date_of_Assessment__c, Valid_From__c, Certification_Type__c, Valid_To__c, Production_Area_NOT_covered_under_FSMA_P__c,
        Production_Area_covered_under_FSMA_PSR__c, Product_Handling_inspected_for_FSMA_PSR__c, Product_s__c, Date_of_issuing__c, GGN__c, Product_Certificate_Number__c,
        Harvest_Included__c, Parallel_Production__c, Parallel_Ownership__c, Ranch_Field_name_and_location__c, Facility_name_and_address__c, Date_of_Certification_Decision__c,
        ANNEX_for_GGN__c, Facility__c, Field__c, Number_of_Producers__c, Product_Handling_PostHarvest_Activity__c, Sub_GLN_or_GGN__c, Certificate_Status__c, Operation_Scope__c,
        Covered_by_PSR__c, Covered_by_PCHF__c, Activities__c, Multi_site_Central_Office__c, Group_Entity__c, RSPO_membership_number__c, Other_sites_certified__c, RSPO_registered_parent_company__c,
        RSPO_membership_number_of_parent_company__c, Scope_of_certification__c, Supply_chain_model__c, Issued_by__c, Authorized_signatory_name__c, Authorized_signature__c, Group_members__c,  Mill_Address__c, 
        GPS_Location__c,CSPO_Projected_Tonnage_Total_module__c, CSPK_Projected_Tonnage_Total_module__c, Outgrowers_ISH_FFB_Projected_Tonnage_mo__c, Start_date_of_first_certificate__c, Start_date_of_current_certificate__c, 
        End_date_of_current_certificate__c, Anniversary_Date__c,Customer__c,RecordTypeId FROM Opportunity_Certificates__r) FROM Opportunity WHERE Id IN:oppoIds]);
        //Add child opportunity of bundle opportunity into list...
        List<Opportunity> childOpportunityList = new List<Opportunity> ();
        List<Opportunity> allOpportunityList = new List<Opportunity> ();
        Opportunity newBundleRecord = new Opportunity();
        //Create bundle opportunity...
        if(String.isNotBlank(previousId) && !result.isEmpty() && result.containsKey(previousId)){
            newBundle.Previous_Opportunity__c = previousId;
            newBundle.Programc__c = result.get(previousId).Programc__c;
            newBundle.AccountId = result.get(previousId).AccountId;
            newBundle.Billing_Contact__c = result.get(previousId).Billing_Contact__c;
            newBundle.Bill_To_Company__c = result.get(previousId).Bill_To_Company__c;
            newBundle.Show_Discount__c = result.get(previousId).Show_Discount__c;
            newBundle.Affiliate_Name__c = result.get(previousId).Affiliate_Name__c;
            newBundle.Affiliate_Opportunity_flag__c = result.get(previousId).Affiliate_Opportunity_flag__c;
            newBundle.Engagement_Type__c = result.get(previousId).Engagement_Type__c;
            newBundle.Include_Cover_Page__c = false;
            newBundle.Payment_Term__c = result.get(previousId).Payment_Term__c;
            newBundle.RecordTypeId = result.get(previousId).RecordTypeId;
            newBundle.Entity__c = result.get(previousId).Entity__c;
            newBundle.fw2__Entity__c = result.get(previousId).fw2__Entity__c;
            newBundle.Bill_To_Address__c = result.get(previousId).Bill_To_Address__c;
            newBundle.LeadSource = result.get(previousId).LeadSource;
            newBundle.Lead_Source_Details__c = result.get(previousId).Lead_Source_Details__c;
            newBundle.Application_Status__c = result.get(previousId).Application_Status__c;
            newBundle.Web_Traffic_Source__c = result.get(previousId).Web_Traffic_Source__c;
            newBundle.Language__c = result.get(previousId).Language__c;
            newBundle.NextStep = result.get(previousId).NextStep;
            newBundle.Description = result.get(previousId).Description;
            newBundle.Notes__c = result.get(previousId).Notes__c;
            newBundle.Target_Audit_Date__c = result.get(previousId).Target_Audit_Date__c;
            newBundle.Program_List__c = result.get(previousId).Program_List__c;
            newBundle.Requested_Payment_Term__c = result.get(previousId).Requested_Payment_Term__c;
            //newBundle.Project_Start_Date__c = result.get(previousId).Project_Start_Date__c;//SS-15
            newBundle.SCS_Probability__c = result.get(previousId).SCS_Probability__c; 
            newBundle.Closed_Lost_Date__c = result.get(previousId).Closed_Lost_Date__c;
            newBundle.Loss_Reason__c = result.get(previousId).Loss_Reason__c;
            newBundle.Is_Scope_Clone__c = ! isRelatedClone.isEmpty() && isRelatedClone.contains('Scope') ? true : false;
            newBundle.Is_T_C_Clone__c = ! isRelatedClone.isEmpty() && isRelatedClone.contains('TermsAndCondition') ? true : false;
            system.debug('newBundle' + newBundle.Id);
            insert newBundle;
        }
        //Create child opportunitys of bundle opportunity...
        if(String.isNotBlank(newBundle.Id)) {
            List<Opportunity> oldOpportunity = result.values();
            for(Opportunity record :result.values()) {
                system.debug('@@@ '+record.id + ' prev '+previousId);
                if(record.Id != previousId) {
                    Opportunity childRecord = record.clone(false, true, false, false);
                    childRecord.Name = childRecord.Name +'-'+ newBundle.Name;
                    childRecord.StageName = newBundle.StageName;
                    childRecord.CloseDate = newBundle.CloseDate;
                    childRecord.Type = newBundle.Type;
                    childRecord.Previous_Opportunity__c = record.Id;
                    childRecord.Bundle_Opportunity__c = newBundle.Id;
                    childRecord.Pricebook2Id = record.Pricebook2Id;
                    childRecord.Is_Scope_Clone__c = ! isRelatedClone.isEmpty() && isRelatedClone.contains('Scope') ? true : false;
                    childRecord.Is_T_C_Clone__c = ! isRelatedClone.isEmpty() && isRelatedClone.contains('TermsAndCondition') ? true : false;
                    childOpportunityList.add(childRecord);
                }
            } 
            //clone bundle's child opportunity...
            if(!childOpportunityList.isEmpty()){
                insert childOpportunityList;
                // update all opportunity...
                for(Opportunity childoppo : childOpportunityList) {
                    allOpportunityList.add(new Opportunity (Id = childoppo.Id,Is_Scope_Clone__c = false,Is_T_C_Clone__c =false));
                }
                    allOpportunityList.add(new Opportunity (Id = newBundle.Id,Is_Scope_Clone__c = false,Is_T_C_Clone__c =false)); 
            }
        }
        //Create related list of childs opportunity...
        if(!isRelatedClone.isEmpty()) {
            Map<String,String> mapOfChild = new Map<String,String>();
            List<Site_Covered__c> newSiteCoveredList = new List<Site_Covered__c>();
            List<Standard_Covered__c> newStandardCoveredList = new List<Standard_Covered__c>();
            List<OpportunityTeamMember> newOpportunityTeamMemberList = new List<OpportunityTeamMember>();
            List<OpportunityContactRole> newOpportunityContactRoleList = new List<OpportunityContactRole>();
            List<OpportunityLineItem> newOpportunityLineItemList = new List<OpportunityLineItem>();
            List<Opportunity_Certificate__c> newOpportunityCertificateList = new List<Opportunity_Certificate__c>();
            List<Certified_Sites__c>  cerToInsert = new List<Certified_Sites__c>();
            List<CertifiedProducts__c>  certProductsToInsert = new List<CertifiedProducts__c>();
            Map<Id,CertifiedProducts__c>  oldCertProdIdNewCPMap = new Map<Id,CertifiedProducts__c>();
            List<Scope__c> newScopeList = new List<Scope__c>();
            List<Terms_Condition__c> termsAndConditionList = new List<Terms_Condition__c>();
            List<Certified_Species__c>  certSpeciesToInsert = new List<Certified_Species__c>();
            List<Certified_volume__c>  certVolumneToInsert = new List<Certified_volume__c>();
            //Add previous opportunity as key and new child opportunity id as a value...
            for(Opportunity record : childOpportunityList) {
                mapOfChild.put(record.Previous_Opportunity__c,record.Id);  
            }
            
            /* Utkarsh Changes to include Certified Sites */
            Map<Id, Opportunity_Certificate__c> originalIdAndRenewOC = new Map<Id,Opportunity_Certificate__c>();
            //Add new bundle id in map to clone previous related record...
            mapOfChild.put(previousId,newBundle.Id);
            for(Opportunity record :result.values()) { 
                system.debug('@@@ '+record.id + ' prev '+previousId);
                //Clone sub scope from previous opportunity...
                if((isRelatedClone.contains('Scope') || isRelatedClone.contains('SubScope')) && !record.Scope__r.isEmpty()){
                    for(Scope__c scopRecord : record.Scope__r ){
                        Scope__c newScopRecord = scopRecord.clone(false, true, false, false);
                        newScopRecord.Opportunity__c = mapOfChild.get(record.Id);
                        if(isRelatedClone.contains('Scope') && scopRecord.RecordType.DeveloperName == 'Opportunity'){
                           newScopeList.add(newScopRecord);
                        } else if(isRelatedClone.contains('SubScope') && scopRecord.RecordType.DeveloperName == 'Sub_Scope'){
                            newScopeList.add(newScopRecord);
                        }
                    }
                }
                //Clone Terms and condition from previous opportunity...
                if(isRelatedClone.contains('TermsAndCondition') && !record.Terms_Conditions__r.isEmpty()){
                    for(Terms_Condition__c tcRecord : record.Terms_Conditions__r ){
                        Terms_Condition__c newTCRecord = tcRecord.clone(false, true, false, false);
                        newTCRecord.Opportunity__c = mapOfChild.get(record.Id);
                        termsAndConditionList.add(newTCRecord);
                    }
                }
                //Clone site covered from previous opportunity...
                if(isRelatedClone.contains('Site_Covered') || (record.Id == previousId) ){
                    for(Site_Covered__c sitecovered : record.Sites_Covered__r ){
                        Site_Covered__c sc = sitecovered.clone(false, true, false, false);
                        sc.Opportunity__c = mapOfChild.get(record.Id);
                        newSiteCoveredList.add(sc);
                    }
                }
                //Clone standard covered from previous opportunity...
                if(isRelatedClone.contains('Standard_Covered') || (record.Id == previousId) ){
                    for(Standard_Covered__c standardCovered : record.Standard_Covered__r ){
                        Standard_Covered__c stdCovd = standardCovered.clone(false, true, false, false);
                        stdCovd.Opportunity__c = mapOfChild.get(record.Id);
                        if(stdCovd.Opportunity__c != null)
                        newStandardCoveredList.add(stdCovd);  
                    }
                }
                //Clone products from previous opportunity...
                if(isRelatedClone.contains('Products') && (record.Id != previousId) ){
                    for(OpportunityLineItem oppoLineItem : record.OpportunityLineItems){
                        OpportunityLineItem oppoLine = oppoLineItem.clone(false, true, false, false);
                        oppoLine.OpportunityId = mapOfChild.get(record.Id);
                        oppoLine.Discount_Amount__c = oppoLineItem.Discount_Amount__c;
                        if(oppoLine.OpportunityId != null)
                        newOpportunityLineItemList.add(oppoLine);  
                    } 
                }
                //Clone Opportunity Team from previous opportunity...
                if(isRelatedClone.contains('OpportunityTeam') || (record.Id == previousId) ){
                    for(OpportunityTeamMember oppoTeam: record.OpportunityTeamMembers ){
                        OpportunityTeamMember oppoTeamMember = oppoTeam.clone(false, true, false, false);
                        oppoTeamMember.OpportunityId = mapOfChild.get(record.Id);
                        if(oppoTeamMember.OpportunityId != null)
                        newOpportunityTeamMemberList.add(oppoTeamMember);   
                    }
                }
                //Clone Opportunity Contact Role from previous opportunity...
                if(isRelatedClone.contains('ContactRole') || (record.Id == previousId) ){
                    for(OpportunityContactRole oppoRole : record.OpportunityContactRoles ){
                        OpportunityContactRole oppocontactRole = oppoRole.clone(false, true, false, false);
                        oppocontactRole.OpportunityId = mapOfChild.get(record.Id);
                        if(oppocontactRole.OpportunityId != null)
                        newOpportunityContactRoleList.add(oppocontactRole);    
                    }
                }
                //Clone Opportunity Certificates from previous opportunity...
                if(isRelatedClone.contains('Opportunity_Certificates') && (record.Id != previousId)){
                    for(Opportunity_Certificate__c oppoCertificate : record.Opportunity_Certificates__r ){
                        Opportunity_Certificate__c certificate = oppoCertificate.clone(false, true, false, false);
                        certificate.Opportunity__c = mapOfChild.get(record.Id);
                        certificate.Certificate_Generated__c = 'No';
                        certificate.Lock_Certificate__c = '';
                        Date dt = System.today();
                        dt = dt.addDays(1);
                        certificate.Date_of_Next_Recertification_Audit__c = dt;
                        certificate.RecordTypeId = opptyCertRT_Id;
                        
                        certificate.Date_of_Next_Recertification_Audit__c = certificate.Date_of_Next_Recertification_Audit__c <= System.today() ?
                                                                            null : certificate.Date_of_Next_Recertification_Audit__c;
                        // UT - added below line to populate the set with OC ids
                        originalIdAndRenewOC.put(oppoCertificate.Id, certificate);
                        // newOpportunityCertificateList.add(certificate);   
                    }
                }   
            }
            
            //insert Site Covered...
            if(!newSiteCoveredList.isEmpty()){ insert newSiteCoveredList;}
            //insert Standard Covered...
            if(!newStandardCoveredList.isEmpty()){insert newStandardCoveredList;}
            //insert opportunity line item...
            if(!newOpportunityLineItemList.isEmpty()){insert newOpportunityLineItemList;}
            //insert opportunity team member...
            if(!newOpportunityTeamMemberList.isEmpty()){insert newOpportunityTeamMemberList;}
            //insert opportunity contact role...
            if(!newOpportunityContactRoleList.isEmpty()){insert newOpportunityContactRoleList;}
            //Insert scope... 
            if(!newScopeList.isEmpty()){insert newScopeList;}
            //Insert Terms and condition...
            if(!termsAndConditionList.isEmpty()){insert termsAndConditionList;}
            //update opportunity...
            if(! allOpportunityList.isEmpty()){ update allOpportunityList; }
            // UT : Commented the below line and added the next one as we need to maintain the old OC certificate
            if(originalIdAndRenewOC.size() > 0 && originalIdAndRenewOC.values() != null){
                insert originalIdAndRenewOC.values();
            }
            
            System.debug('originalIdAndRenewOC ' + originalIdAndRenewOC);
            
            /*
            Utkarsh Goswami - 
            in the below code we are quering for Certified Sites from the map created above originalIdAndRenewOC
            It will query for Sites related to old OC and clone it, after cloning it we are updating the OC Lookup
            on sites to update it with new renewed OC
            */
            for(Certified_Sites__c cs : [SELECT Id,Certificate__c,Account__c,CustomerSite__c,OpportunityCertificate__c FROM
            Certified_Sites__c  WHERE OpportunityCertificate__c IN :originalIdAndRenewOC.keyset()]){
                
                Certified_Sites__c sites = cs.clone(false, true, false, false);
                sites.OpportunityCertificate__c = originalIdAndRenewOC.containsKey(cs.OpportunityCertificate__c) ? 
                originalIdAndRenewOC.get(cs.OpportunityCertificate__c).Id : '';
                
                
                cerToInsert.add(sites);                         
            }
            /*
            Utkarsh Goswami - 
            in the below code we are quering for Certificate Products from the map created above originalIdAndRenewOC
            It will query for Products related to old OC and clone it, after cloning it we are updating the OC Lookup
            on certified products to update it with new renewed OC
            */
            for(CertifiedProducts__c cp : [SELECT Id,Account__c,Activities__c,Address__c,Certificate__c,City__c,Company__c,Country__c,
                                            Covered_by_PCHF__c,Covered_by_PSR__c,Facility_name_and_address__c,First_Certfication_Date__c,
                                            GGN__c,Harvest_Included__c,Observed_during_audit__c,OpportunityCertificate__c,Parallel_Ownership__c,
                                            Parallel_Production__c,Producer_name_and_address__c,Product_Certificate__c,Product_Certificate_Number__c,
                                            Product_Handling_Facility__c,Product_Handling_Field__c,Product_Handling_inspected_for_FSMA_PSR__c,
                                            Product_Handling_PostHarvest_Activity__c,Product_s__c,Production_Area_covered_under_FSMA_PSR__c,Production_Area_NOT_covered_under_FSMA__c,
                                            RecordTypeId,Scope__c,Sub_code__c,Supply_chain_model__c,ZIP_Code__c FROM
                                            CertifiedProducts__c  WHERE OpportunityCertificate__c IN :originalIdAndRenewOC.keyset()]){
                
                CertifiedProducts__c certProd = cp.clone(false, true, false, false);
                certProd.OpportunityCertificate__c = originalIdAndRenewOC.containsKey(cp.OpportunityCertificate__c) ? 
                originalIdAndRenewOC.get(cp.OpportunityCertificate__c).Id : '';
              //  certProductsToInsert.add(certProd);
                oldCertProdIdNewCPMap.put(cp.Id, certProd);
                
            }
            
            System.debug('cerToInsert ' + cerToInsert);
            if(cerToInsert.size() > 0){
                insert cerToInsert;
            }
    /*        System.debug('certProductsToInsert ' + certProductsToInsert);
            if(certProductsToInsert.size() > 0){
                insert certProductsToInsert;
            } */

            if(oldCertProdIdNewCPMap.size() > 0){
                insert oldCertProdIdNewCPMap.values();
            }

            /*
                Added below logic to Clone Certified Volume for OC
                We are also cloning the Certified Volume present in the original Opp - OC 
                and will map it to the renewed OC
            */
            for(Certified_volume__c cv : [SELECT Id,FFB_Projected_Tonnage__c,IS_CSPKE_Projected_Tonnage_Total__c,IS_CSPKO_Projected_Tonnage_Total__c,
                                        IS_CSPO_Projected_Tonnage_Total__c,IS_FFB_Projected_Tonnage__c,Opportunity_Certificate__c,
                                        Phase__c FROM Certified_volume__c  WHERE Opportunity_Certificate__c IN :originalIdAndRenewOC.keyset()]){

                Certified_volume__c certVolume = cv.clone(false, true, false, false);
                certVolume.Opportunity_Certificate__c = originalIdAndRenewOC.containsKey(cv.Opportunity_Certificate__c) ? 
                originalIdAndRenewOC.get(cv.Opportunity_Certificate__c).Id : '';
                certVolumneToInsert.add(certVolume);

            }
            /*
                Added below logic to Clone Certified Species for Certified Products
                We are also cloning the Certified Species present in the original Opp - CP
                and will map it to the renewed OC
            */
            for(Certified_Species__c cs : [SELECT Id,Name,Product_Group_FSCCH__c,Product_Species_FSCPK__c, Certified_Product__c,
                                            Species__c FROM Certified_Species__c  WHERE Certified_Product__c IN :oldCertProdIdNewCPMap.keyset()]){

                Certified_Species__c certSpecies = cs.clone(false, true, false, false);
                certSpecies.Certified_Product__c = oldCertProdIdNewCPMap.containsKey(cs.Certified_Product__c) ? 
                oldCertProdIdNewCPMap.get(cs.Certified_Product__c).Id : '';
                certSpeciesToInsert.add(certSpecies);

            }

            if(certVolumneToInsert.size() > 0){
                insert certVolumneToInsert;
            }
            if(certSpeciesToInsert.size() > 0){
                insert certSpeciesToInsert;
            }
        }
        //return opportunity bundle opportunity id...
        return newBundle.Id;
    }  
}