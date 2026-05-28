using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("PercentFormat")]
    internal sealed class PercentFormat : FormatBase
        {
        [UsedImplicitly][Field] public Boolean UseLocale { get; } = true;
        [UsedImplicitly][Field] public Int32 DecimalDigits { get; } = 2;
        [UsedImplicitly][Field] public String DecimalSeparator { get; }
        [UsedImplicitly][Field] public String GroupSeparator { get; }
        [UsedImplicitly][Field] public String PercentSymbol { get; }
        [UsedImplicitly][Field] public Int32 NegativePattern { get; }
        [UsedImplicitly][Field] public Int32 PositivePattern { get; }
        }
    }