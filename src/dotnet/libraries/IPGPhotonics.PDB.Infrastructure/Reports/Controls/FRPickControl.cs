using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("FRPickControl")]
    internal class FRPickControl : BindableDialogControl
        {
        [UsedImplicitly][Field] public String ClassOIDLabel { get; }
        [UsedImplicitly][Field] public String Filter { get; }
        [UsedImplicitly][Field] public String IDField { get; }
        [UsedImplicitly][Field] public String InitQueryOIDLabel { get; }
        [UsedImplicitly][Field] public String NameField { get; }
        [UsedImplicitly][Field] public String Options { get; }
        [UsedImplicitly][Field] public String PickEvent { get; }
        [UsedImplicitly][Field] public String SelectedIdentifiersChangedEvent { get; }
        [UsedImplicitly][Field] public String ViewOIDLabel { get; }
        [UsedImplicitly][Field] public Boolean MultiSelect { get; }
        }
    }
