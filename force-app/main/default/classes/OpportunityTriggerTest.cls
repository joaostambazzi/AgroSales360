@IsTest
private class OpportunityTriggerTest {

    @IsTest
    static void testAfterInsert() {

        Account testAccount = new Account(
            Name = 'Fazenda Teste Apex'
        );

        insert testAccount;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Venda Teste Apex',
            AccountId = testAccount.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 60000
        );

        insert testOpportunity;

        Account updatedAccount = [
            SELECT Purchases_Last_12_Months__c,
                   Customer_Size__c
            FROM Account
            WHERE Id = :testAccount.Id
        ];

        System.assertEquals(
            60000.00,
            updatedAccount.Purchases_Last_12_Months__c,
            'O total de compras deveria ser 60 mil.'
        );

        System.assertEquals(
            'Medio',
            updatedAccount.Customer_Size__c,
            'Um cliente com 60 mil em compras deveria ser Medio.'
        );
    }


    @IsTest
    static void testAfterUpdate() {

        Account testAccount = new Account(
            Name = 'Fazenda Teste Update'
        );
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Venda Teste Update',
            AccountId = testAccount.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 60000
        );
        insert testOpportunity;

        testOpportunity.Amount = 160000;
        update testOpportunity;

        Account updatedAccount = [
            SELECT Purchases_Last_12_Months__c,
                   Customer_Size__c
            FROM Account
            WHERE Id = :testAccount.Id
        ];

        System.assertEquals(
            160000.00,
            updatedAccount.Purchases_Last_12_Months__c,
            'O total deveria ser atualizado para 160 mil.'
        );

        System.assertEquals(
            'Grande',
            updatedAccount.Customer_Size__c,
            'Um cliente com 160 mil em compras deveria ser Grande.'
        );
    }


        @IsTest
    static void testAfterDelete() {

        Account testAccount = new Account(
            Name = 'Fazenda Teste Delete'
        );
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Venda Teste Delete',
            AccountId = testAccount.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 60000
        );
        insert testOpportunity;

        delete testOpportunity;

        Account updatedAccount = [
            SELECT Purchases_Last_12_Months__c,
                Customer_Size__c
            FROM Account
            WHERE Id = :testAccount.Id
        ];

        System.assertEquals(
            0.00,
            updatedAccount.Purchases_Last_12_Months__c,
            'O total deveria voltar para zero depois da exclusão.'
        );

        System.assertEquals(
            'Pequeno',
            updatedAccount.Customer_Size__c,
            'Um cliente sem compras deveria ser Pequeno.'
        );
    }


        @IsTest
    static void testAfterUndelete() {

        Account testAccount = new Account(
            Name = 'Fazenda Teste Undelete'
        );
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Venda Teste Undelete',
            AccountId = testAccount.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 60000
        );
        insert testOpportunity;

        delete testOpportunity;

        undelete testOpportunity;

        Account updatedAccount = [
            SELECT Purchases_Last_12_Months__c,
                Customer_Size__c
            FROM Account
            WHERE Id = :testAccount.Id
        ];

        System.assertEquals(
            60000.00,
            updatedAccount.Purchases_Last_12_Months__c,
            'O total deveria voltar para 60 mil após restaurar a Opportunity.'
        );

        System.assertEquals(
            'Medio',
            updatedAccount.Customer_Size__c,
            'O cliente deveria voltar para Medio após restaurar a Opportunity.'
        );
    }

        @IsTest
    static void testBulkInsert() {

        Account accountA = new Account(
            Name = 'Fazenda Bulk A'
        );

        Account accountB = new Account(
            Name = 'Fazenda Bulk B'
        );

        insert new List<Account>{ accountA, accountB };

        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'Venda A1',
                AccountId = accountA.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                Amount = 30000
            ),
            new Opportunity(
                Name = 'Venda A2',
                AccountId = accountA.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                Amount = 40000
            ),
            new Opportunity(
                Name = 'Venda B1',
                AccountId = accountB.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                Amount = 100000
            ),
            new Opportunity(
                Name = 'Venda B2',
                AccountId = accountB.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                Amount = 80000
            )
        };

        Test.startTest();

        insert opportunities;

        Test.stopTest();

        Set<Id> accountIds = new Set<Id>{
            accountA.Id,
            accountB.Id
        };

        Map<Id, Account> accountsById = new Map<Id, Account>([
            SELECT Purchases_Last_12_Months__c,
                Customer_Size__c
            FROM Account
            WHERE Id IN :accountIds
        ]);

        System.assertEquals(
            70000.00,
            accountsById.get(accountA.Id).Purchases_Last_12_Months__c,
            'A Fazenda A deveria ter 70 mil em compras.'
        );

        System.assertEquals(
            'Medio',
            accountsById.get(accountA.Id).Customer_Size__c,
            'A Fazenda A deveria ser Medio.'
        );

        System.assertEquals(
            180000.00,
            accountsById.get(accountB.Id).Purchases_Last_12_Months__c,
            'A Fazenda B deveria ter 180 mil em compras.'
        );

        System.assertEquals(
            'Grande',
            accountsById.get(accountB.Id).Customer_Size__c,
            'A Fazenda B deveria ser Grande.'
        );
    }


        @IsTest
    static void testAccountChange() {

        Account accountA = new Account(
            Name = 'Fazenda Origem'
        );

        Account accountB = new Account(
            Name = 'Fazenda Destino'
        );

        insert new List<Account>{ accountA, accountB };

        Opportunity testOpportunity = new Opportunity(
            Name = 'Venda Troca de Cliente',
            AccountId = accountA.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 60000
        );

        insert testOpportunity;

        // Move a Opportunity da Account A para a Account B
        testOpportunity.AccountId = accountB.Id;
        update testOpportunity;

        Set<Id> accountIds = new Set<Id>{
            accountA.Id,
            accountB.Id
        };

        Map<Id, Account> accountsById = new Map<Id, Account>([
            SELECT Purchases_Last_12_Months__c,
                Customer_Size__c
            FROM Account
            WHERE Id IN :accountIds
        ]);

        System.assertEquals(
            0.00,
            accountsById.get(accountA.Id).Purchases_Last_12_Months__c,
            'A Account antiga deveria ficar com zero em compras.'
        );

        System.assertEquals(
            'Pequeno',
            accountsById.get(accountA.Id).Customer_Size__c,
            'A Account antiga deveria ficar como Pequeno.'
        );

        System.assertEquals(
            60000.00,
            accountsById.get(accountB.Id).Purchases_Last_12_Months__c,
            'A nova Account deveria receber os 60 mil.'
        );

        System.assertEquals(
            'Medio',
            accountsById.get(accountB.Id).Customer_Size__c,
            'A nova Account deveria ser Medio.'
        );
    }


        @IsTest
    static void testLeavingClosedWon() {

        Account testAccount = new Account(
            Name = 'Fazenda Teste Stage'
        );
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Venda Teste Stage',
            AccountId = testAccount.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 60000
        );
        insert testOpportunity;

        // A venda deixa de ser considerada ganha
        testOpportunity.StageName = 'Prospecting';
        update testOpportunity;

        Account updatedAccount = [
            SELECT Purchases_Last_12_Months__c,
                Customer_Size__c
            FROM Account
            WHERE Id = :testAccount.Id
        ];

        System.assertEquals(
            0.00,
            updatedAccount.Purchases_Last_12_Months__c,
            'O total deveria voltar para zero ao sair de Closed Won.'
        );

        System.assertEquals(
            'Pequeno',
            updatedAccount.Customer_Size__c,
            'O cliente deveria voltar para Pequeno sem vendas Closed Won.'
        );
    }

        @IsTest
    static void testCloseDateOutsideLast12Months() {

        Account testAccount = new Account(
            Name = 'Fazenda Teste CloseDate'
        );
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Venda Teste CloseDate',
            AccountId = testAccount.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 60000
        );
        insert testOpportunity;

        // Move a venda para fora dos últimos 12 meses
        testOpportunity.CloseDate = Date.today().addMonths(-13);
        update testOpportunity;

        Account updatedAccount = [
            SELECT Purchases_Last_12_Months__c,
                Customer_Size__c
            FROM Account
            WHERE Id = :testAccount.Id
        ];

        System.assertEquals(
            0.00,
            updatedAccount.Purchases_Last_12_Months__c,
            'A venda fora dos últimos 12 meses não deveria entrar no total.'
        );

        System.assertEquals(
            'Pequeno',
            updatedAccount.Customer_Size__c,
            'Sem compras nos últimos 12 meses, o cliente deveria ser Pequeno.'
        );
    }

}