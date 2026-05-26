using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("CheckedListBoxControl")]
    internal sealed class CheckedListBoxControl : ListBoxBaseControl
        {
        [UsedImplicitly][Field] public Boolean CheckOnClick { get; }
        [UsedImplicitly][Field] public String ItemCheckEvent { get; }
        }
    }