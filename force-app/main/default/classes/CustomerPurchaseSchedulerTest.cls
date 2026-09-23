@IsTest
private class CustomerPurchaseSchedulerTest {

    @IsTest
    static void testSchedulerExecutesBatch() {

        Account testAccount = new Account(
            Name = 'Fazenda Teste Scheduler'
        );
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Venda Teste Scheduler',
            AccountId = testAccount.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 60000
        );
        insert testOpportunity;

        // Estraga o valor de propósito
        testAccount.Purchases_Last_12_Months__c = 1;
        testAccount.Customer_Size__c = 'Grande';
        update testAccount;

        Test.startTest();

        CustomerPurchaseScheduler scheduler =
            new CustomerPurchaseScheduler();

        scheduler.execute(null);

        Test.stopTest();

        Account recalculatedAccount = [
            SELECT Purchases_Last_12_Months__c,
                   Customer_Size__c
            FROM Account
            WHERE Id = :testAccount.Id
        ];

        System.assertEquals(
            60000.00,
            recalculatedAccount.Purchases_Last_12_Months__c,
            'O Scheduler deveria disparar o Batch e recalcular o total.'
        );

        System.assertEquals(
            'Medio',
            recalculatedAccount.Customer_Size__c,
            'O Scheduler deveria levar o cliente de volta para Medio.'
        );
    }
}