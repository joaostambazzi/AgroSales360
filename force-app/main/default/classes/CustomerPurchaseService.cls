public class CustomerPurchaseService {

    public static void recalculate(Set<Id> accountIds) {

        if (accountIds == null || accountIds.isEmpty()) {
            return;
        }

        Map<Id, Decimal> totalsByAccount = new Map<Id, Decimal>();

        for (AggregateResult result : [
            SELECT AccountId accountId,
                   SUM(Final_Amount__c) totalPurchases
            FROM Opportunity
            WHERE AccountId IN :accountIds
              AND StageName = 'Closed Won'
              AND CloseDate >= :Date.today().addMonths(-12)
              AND CloseDate <= :Date.today()
            GROUP BY AccountId
        ]) {
            Id accountId = (Id) result.get('accountId');
            Decimal total = (Decimal) result.get('totalPurchases');

            totalsByAccount.put(accountId, total);
        }

        List<Account> accountsToUpdate = new List<Account>();

        for (Id accountId : accountIds) {

            Decimal totalPurchases = totalsByAccount.containsKey(accountId)
                ? totalsByAccount.get(accountId)
                : 0;

            String customerSize;

            if (totalPurchases <= 50000) {
                customerSize = 'Pequeno';
            } else if (totalPurchases <= 150000) {
                customerSize = 'Medio';
            } else {
                customerSize = 'Grande';
            }

            accountsToUpdate.add(new Account(
                Id = accountId,
                Purchases_Last_12_Months__c = totalPurchases,
                Customer_Size__c = customerSize
            ));
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}