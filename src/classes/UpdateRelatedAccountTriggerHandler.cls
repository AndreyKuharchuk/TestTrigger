public class UpdateRelatedAccountTriggerHandler {
    private static Map<Id, List<Opportunity>> mapAcctIdOpportunityList = new Map<Id, List<Opportunity>>();
    private static Map<Id, List<Opportunity>> mapAcctIdDeleteOpportunityList = new Map<Id, List<Opportunity>>();
    private static Set<Id> acctIds = new Set<Id>();
    private static List<Account> accounts = new List<Account>();

    public static void handleInsert(List <Opportunity> newOpportunities) {
        for (Opportunity opp : newOpportunities)
            if (opp.AccountId != NULL && opp.StageName == 'Closed Won') {
                    addOpportunityToPlus(opp);
            }
    }

    public static void handleUpdate(List <Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunities) {
        for (Opportunity opp : newOpportunities) {
            if (opp.AccountId != NULL && oldOpportunities.get(opp.Id).AccountId == opp.AccountId) {
                if (oldOpportunities.get(opp.Id).StageName == 'Closed Won' && opp.StageName == 'Closed Won') {
                    if (oldOpportunities.get(opp.Id).Amount != opp.Amount) {
                        addOpportunityToPlus(opp);
                        addOpportunityToMinus(oldOpportunities.get(opp.Id));
                    }
                } else if (oldOpportunities.get(opp.Id).StageName == 'Closed Won' && opp.StageName != 'Closed Won') {
                    addOpportunityToMinus(oldOpportunities.get(opp.Id));
                }else if (oldOpportunities.get(opp.Id).StageName != 'Closed Won' && opp.StageName == 'Closed Won') {
                    addOpportunityToPlus(opp);
                }
            } else if (opp.AccountId != NULL && oldOpportunities.get(opp.Id).AccountId != opp.AccountId) {
                if (opp.StageName == 'Closed Won') {
                    addOpportunityToPlus(opp);

                } else if (oldOpportunities.get(opp.Id).StageName == 'Closed Won') {
                    addOpportunityToMinus(oldOpportunities.get(opp.Id));
                }
            }else if (opp.AccountId == NULL && oldOpportunities.get(opp.Id).AccountId != NULL) {
                addOpportunityToMinus(oldOpportunities.get(opp.Id));
            }
        }
    }

    public static void handleUnDelete(List <Opportunity> newOpportunities) {
        for (Opportunity opp : newOpportunities) {
            if (opp.AccountId != NULL && opp.StageName == 'Closed Won') {
                    addOpportunityToPlus(opp);
            }
        }
    }

    public static void handleDelete(List <Opportunity> deletedOpportunities) {
        for (Opportunity opp : deletedOpportunities) {
            if (opp.AccountId != NULL && opp.StageName == 'Closed Won') {
                    addOpportunityToMinus(opp);
            }
        }
    }

    public static void updateRelatedAccounts() {
        if (acctIds.size() > 0) {
            accounts = [SELECT Id, Royalty__c FROM Account WHERE Id IN :acctIds];

            for (Account account : accounts) {
                Decimal countRoyalty = 0;

                if (mapAcctIdOpportunityList.containsKey(account.Id)) {
                    for (Opportunity opportunity : mapAcctIdOpportunityList.get(account.Id)) {
                        if (opportunity.Amount != NULL) {
                            countRoyalty += opportunity.Amount;
                        }
                    }
                }

                if (mapAcctIdDeleteOpportunityList.containsKey(account.Id)) {
                    for (Opportunity opportunity : mapAcctIdDeleteOpportunityList.get(account.Id)) {
                        if (opportunity.Amount != NULL) {
                            countRoyalty -= opportunity.Amount;
                        }
                    }
                }

                account.Royalty__c = account.Royalty__c == null ? countRoyalty : (account.Royalty__c + countRoyalty);

                update accounts;
            }
        }
    }

    public static void addOpportunityToPlus(Opportunity opp){
        if (!mapAcctIdOpportunityList.containsKey(opp.AccountId)) {
            mapAcctIdOpportunityList.put(opp.AccountId, new List<Opportunity>());
        }
        mapAcctIdOpportunityList.get(opp.AccountId).add(opp);
        acctIds.add(opp.AccountId);
    }

    public static void addOpportunityToMinus(Opportunity opp){
        if (!mapAcctIdDeleteOpportunityList.containsKey(opp.AccountId)) {
            mapAcctIdDeleteOpportunityList.put(opp.AccountId, new List<Opportunity>());
        }
        mapAcctIdDeleteOpportunityList.get(opp.AccountId).add(opp);
        acctIds.add(opp.AccountId);
    }
}