namespace IPGPhotonics.PDB.Infrastructure
    {
    public enum StageType
        {
        AfterSave = 1,
        AfterMethod = 2,
        AfterSaveInState = 3,
        BeforeSave = 4,
        OnDocumentChanges = 5,
        BeforeOpen = 6,
        BeforeDelete = 7,
        InsteadMethod = 8,
        EntityRowTrigger = 9,
        AfterSaveTransactionComplete = 10
        }
    }