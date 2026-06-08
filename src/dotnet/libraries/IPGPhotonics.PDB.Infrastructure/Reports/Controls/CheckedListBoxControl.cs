using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("CheckedListBoxControl")]
    internal sealed class CheckedListBoxControl : ListBoxBaseControl
        {
        [UsedImplicitly][Field(Order=1000701)] public Boolean CheckOnClick { get; }
        [UsedImplicitly][Field(Order=1000702)] public String ItemCheckEvent { get; }
        }
    }