public class createRenewalOpportunityCertificate {
    
    @InvocableMethod(label='cloneOpportunityCertifiacte' description='Create Opportunity Certificate and Certified Sites')
    public static void createRenewalOpportunityCertificateAndCertifiedSites(List<String> renewOppId){
        system.debug('renewOppId-->'+renewOppId);
        Id opptyCertRT_Id = Schema.SObjectType.Opportunity_Certificate__c.getRecordTypeInfosByDeveloperName().get('Open').getRecordTypeId();
        Map<id,Opportunity_Certificate__c> oldcertificateIdMap = new Map<id,Opportunity_Certificate__c>();
        List<Certified_Sites__c>  cerToInsert = new List<Certified_Sites__c>();
        List<CertifiedProducts__c>  certProductsToInsert = new List<CertifiedProducts__c>();
        List<Certified_volume__c>  certVolumneToInsert = new List<Certified_volume__c>();
        List<Certified_Species__c>  certSpeciesToInsert = new List<Certified_Species__c>();
        Map<Id,CertifiedProducts__c>  oldCertProdIdNewCPMap = new Map<Id,CertifiedProducts__c>();
        
        Opportunity renewOpp = [SELECT Id,Name,Previous_Opportunity__c FROM Opportunity where Id = : renewOppId[0] Limit 1];
        List<Opportunity_Certificate__c> oppCertificateList = ([SELECT Id,Name,Account__c, Certificate_Type__c, Certificate__c, Opportunity__c, Date_of_Audit__c, 
                                                                Date_of_Decision__c,Site_Code__c, Has_Achieved__c, GLOBAL_STANDARD_START__c, Certificate_Issue_Date__c, 
                                                                Date_of_Expiry__c, Date_of_Next_Recertification_Audit__c,Auditor_Number__c, Product_Category__c, FSC__c, 
                                                                Scope_of_activities__c, Exclusions__c, Has_Achieved_Grade__c, Product_Certificate_Type__c, Audit_Programme__c,Products__c,
                                                                Harvest_Method_Observed__c, Date_of_Assessment__c, Valid_From__c, Certification_Type__c, Valid_To__c, 
                                                                Production_Area_NOT_covered_under_FSMA_P__c,Production_Area_covered_under_FSMA_PSR__c, 
                                                                Product_Handling_inspected_for_FSMA_PSR__c, Product_s__c, Date_of_issuing__c, GGN__c, Product_Certificate_Number__c,
                                                                Harvest_Included__c, Parallel_Production__c, Parallel_Ownership__c, Ranch_Field_name_and_location__c, 
                                                                Facility_name_and_address__c, Date_of_Certification_Decision__c,ANNEX_for_GGN__c, Facility__c, Field__c,
                                                                Number_of_Producers__c, Product_Handling_PostHarvest_Activity__c, Sub_GLN_or_GGN__c, Certificate_Status__c, 
                                                                Operation_Scope__c,Covered_by_PSR__c, Covered_by_PCHF__c, Activities__c, Multi_site_Central_Office__c, 
                                                                    Group_Entity__c, RSPO_membership_number__c, Other_sites_certified__c, RSPO_registered_parent_company__c,
                                                                RSPO_membership_number_of_parent_company__c, Supply_chain_model__c, Issued_by__c,
                                                                Authorized_signatory_name__c, Authorized_signature__c, Group_members__c, Mill_Address__c, GPS_Location__c, 
                                                                CSPO_Projected_Tonnage_Total_module__c, CSPK_Projected_Tonnage_Total_module__c,
                                                                Outgrowers_ISH_FFB_Projected_Tonnage_mo__c, Start_date_of_first_certificate__c, 
                                                                Start_date_of_current_certificate__c, End_date_of_current_certificate__c, Anniversary_Date__c,Customer__c, 
                                                                For_the_scope_of_Activities__c, Certificate_Generated__c,RecordTypeId,
                                                                (Select id,name,Certificate__c,Account__c,CustomerSite__c,OpportunityCertificate__c from Certified_Sites__r) 
                                                                FROM Opportunity_Certificate__c WHERE Opportunity__c =: renewOpp.Previous_Opportunity__c ]);
        
        for(Opportunity_Certificate__c oppCert : oppCertificateList){           
            Opportunity_Certificate__c certificate = oppCert.clone(false, true, false, false);
            certificate.Opportunity__c = renewOpp.Id;
            certificate.Certificate_Generated__c = 'No';
            certificate.Lock_Certificate__c = '';
            certificate.RecordTypeId = opptyCertRT_Id;
            certificate.Date_of_Next_Recertification_Audit__c = certificate.Date_of_Next_Recertification_Audit__c <= System.today() ?
                                                                null : certificate.Date_of_Next_Recertification_Audit__c;
            oldcertificateIdMap.put(oppCert.Id,certificate);
        }
        system.debug('before oldcertificateIdMap-->'+oldcertificateIdMap);
        insert oldcertificateIdMap.values(); 
        system.debug('after oldcertificateIdMap-->'+oldcertificateIdMap);
        
        for(Certified_Sites__c cs : [SELECT Id,Certificate__c,Account__c,CustomerSite__c,OpportunityCertificate__c FROM
                                     Certified_Sites__c  WHERE OpportunityCertificate__c IN :oldcertificateIdMap.keyset()]){
            
            Certified_Sites__c sites = cs.clone(false, true, false, false);
            sites.OpportunityCertificate__c = oldcertificateIdMap.containsKey(cs.OpportunityCertificate__c) ? 
                                                oldcertificateIdMap.get(cs.OpportunityCertificate__c).Id : '';
            cerToInsert.add(sites);                         
        }
        /*
            Added below logic to Clone Certified Products for OC
            We are also cloning the Certified products present in the original Opp - OC 
            and will map it to the renewed OC
        */
        for(CertifiedProducts__c cp : [SELECT Id,Account__c,Activities__c,Address__c,Certificate__c,City__c,Company__c,Country__c,
                                        Covered_by_PCHF__c,Covered_by_PSR__c,Facility_name_and_address__c,First_Certfication_Date__c,
                                        GGN__c,Harvest_Included__c,Observed_during_audit__c,OpportunityCertificate__c,Parallel_Ownership__c,
                                        Parallel_Production__c,Producer_name_and_address__c,Product_Certificate__c,Product_Certificate_Number__c,
                                        Product_Handling_Facility__c,Product_Handling_Field__c,Product_Handling_inspected_for_FSMA_PSR__c,
                                        Product_Handling_PostHarvest_Activity__c,Product_s__c,Production_Area_covered_under_FSMA_PSR__c,Production_Area_NOT_covered_under_FSMA__c,
                                        RecordTypeId,Scope__c,Sub_code__c,Supply_chain_model__c,ZIP_Code__c FROM
                                        CertifiedProducts__c  WHERE OpportunityCertificate__c IN :oldcertificateIdMap.keyset()]){

            CertifiedProducts__c certProd = cp.clone(false, true, false, false);
            certProd.OpportunityCertificate__c = oldcertificateIdMap.containsKey(cp.OpportunityCertificate__c) ? 
                                                oldcertificateIdMap.get(cp.OpportunityCertificate__c).Id : '';
         //   certProductsToInsert.add(certProd);
            oldCertProdIdNewCPMap.put(cp.Id, certProd);
                                
        }

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
                                        Phase__c FROM Certified_volume__c  WHERE Opportunity_Certificate__c IN :oldcertificateIdMap.keyset()]){

            Certified_volume__c certVolume = cv.clone(false, true, false, false);
            certVolume.Opportunity_Certificate__c = oldcertificateIdMap.containsKey(cv.Opportunity_Certificate__c) ? 
                                                oldcertificateIdMap.get(cv.Opportunity_Certificate__c).Id : '';
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

        if(cerToInsert.size() > 0){
            insert cerToInsert;
        }
    //    if(certProductsToInsert.size() > 0){
       //     insert certProductsToInsert;
      //  }

        if(certVolumneToInsert.size() > 0){
            insert certVolumneToInsert;
        }
        if(certSpeciesToInsert.size() > 0){
            insert certSpeciesToInsert;
        }
        
    }
}