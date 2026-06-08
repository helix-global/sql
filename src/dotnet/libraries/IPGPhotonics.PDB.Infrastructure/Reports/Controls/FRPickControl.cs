using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("FRPickControl")]
    internal sealed class FRPickControl : BindableDialogControl
        {
        [UsedImplicitly][Field(Order=1000601)] public String ClassOIDLabel { get; }
        [UsedImplicitly][Field(Order=1000604)] public String Filter { get; }
        [UsedImplicitly][Field(Order=1000605)] public String IDField { get; }
        [UsedImplicitly][Field(Order=1000608)] public String InitQueryOIDLabel { get; }
        [UsedImplicitly][Field(Order=1000606)] public String NameField { get; }
        [UsedImplicitly][Field(Order=1000603)] public String Options { get; }
        [UsedImplicitly][Field(Order=1000609)] public String PickEvent { get; }
        [UsedImplicitly][Field(Order=1000610)] public String SelectedIdentifiersChangedEvent { get; }
        [UsedImplicitly][Field(Order=1000607)] public String ViewOIDLabel { get; }
        [UsedImplicitly][Field(Order=1000602,Converter=typeof(SqlBooleanConverter))] public Boolean MultiSelect { get; }
        }
    }
