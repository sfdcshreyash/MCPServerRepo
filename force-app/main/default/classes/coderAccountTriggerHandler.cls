public with sharing class coderAccountTriggerHandler {

    public static void beforeInsert(List<Account> newList) {
        enforceUniqueAccountName(newList, null);
    }

    public static void beforeUpdate(List<Account> newList, Map<Id, Account> oldMap) {
        enforceUniqueAccountName(newList, oldMap);
    }

    private static void enforceUniqueAccountName(List<Account> newList, Map<Id, Account> oldMap) {
        if (newList == null || newList.isEmpty()) {
            return;
        }

        // Collect all non-null names from the trigger batch (case-insensitive, trimmed)
        Set<String> accountNameKeys = new Set<String>();
        for (Account acc : newList) {
            if (acc.Name != null) {
                accountNameKeys.add(acc.Name.trim().toLowerCase());
            }
        }

        if (accountNameKeys.isEmpty()) {
            return;
        }

        // Query existing accounts with the same names
        Map<String, List<Account>> existingByNameKey = new Map<String, List<Account>>();
        for (Account existing : [
            SELECT Id, Name
            FROM Account
            WHERE Name IN :accountNameKeys
        ]) {
            String key = existing.Name == null ? null : existing.Name.trim().toLowerCase();
            if (key == null) {
                continue;
            }
            if (!existingByNameKey.containsKey(key)) {
                existingByNameKey.put(key, new List<Account>());
            }
            existingByNameKey.get(key).add(existing);
        }

        // Group records in the current trigger batch by name key
        Map<String, List<Account>> batchByNameKey = new Map<String, List<Account>>();
        for (Account acc : newList) {
            if (acc.Name == null) {
                continue;
            }
            String key = acc.Name.trim().toLowerCase();
            if (!batchByNameKey.containsKey(key)) {
                batchByNameKey.put(key, new List<Account>());
            }
            batchByNameKey.get(key).add(acc);
        }

        // For each name, check duplicates in DB and inside the same batch
        for (String key : batchByNameKey.keySet()) {
            List<Account> batchAccounts = batchByNameKey.get(key);
            List<Account> existingAccounts = existingByNameKey.get(key);

            Boolean hasExistingOther = false;
            if (existingAccounts != null && !existingAccounts.isEmpty()) {
                for (Account existing : existingAccounts) {
                    Boolean sameRecord = false;
                    for (Account batchAcc : batchAccounts) {
                        if (batchAcc.Id != null && batchAcc.Id == existing.Id) {
                            sameRecord = true;
                            break;
                        }
                    }
                    if (!sameRecord) {
                        hasExistingOther = true;
                        break;
                    }
                }
            }

            Boolean hasBatchDuplicates = batchAccounts.size() > 1;

            if (hasExistingOther || hasBatchDuplicates) {
                for (Account acc : batchAccounts) {
                    acc.addError('Duplicate Account Name is not allowed. An Account with this Name already exists.');
                }
            }
        }
    }
}
