@IsTest
private class CustomerPurchaseBatchTest {

    @IsTest
    static void testBatchRecalculatesAccounts() {

        Account testAccount = new Account(
            Name = 'Fazenda Teste Batch'
        );
        insert testAccount;

        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'Venda Batch 1',
                AccountId = testAccount.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                Amount = 30000
            ),
            new Opportunity(
                Name = 'Venda Batch 2',
                AccountId = testAccount.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                Amount = 40000
            )
        };

        insert opportunities;

        // Estraga os valores de propósito
        testAccount.Purchases_Last_12_Months__c = 1;
        testAccount.Customer_Size__c = 'Grande';
        update testAccount;

        Test.startTest();

        Database.executeBatch(
            new CustomerPurchaseBatch(),
            200
        );

        Test.stopTest();

        Account recalculatedAccount = [
            SELECT Purchases_Last_12_Months__c,
                   Customer_Size__c
            FROM Account
            WHERE Id = :testAccount.Id
        ];

        System.assertEquals(
            70000.00,
            recalculatedAccount.Purchases_Last_12_Months__c,
            'O Batch deveria recalcular o total para 70 mil.'
        );

        System.assertEquals(
            'Medio',
            recalculatedAccount.Customer_Size__c,
            'O Batch deveria classificar o cliente como Medio.'
        );
    }
}