using System;
using System.ComponentModel;
using System.Windows.Media;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("CheckBoxObject")]
    internal sealed class FastReportCheckBoxObject : ReportComponentBase
        {
        [UsedImplicitly][Field(Order=1000404,Converter=typeof(FastReportColorConverter))] public Color CheckColor { get; }
        [UsedImplicitly][Field(Order=1000401)][DefaultValue(true)] public Boolean Checked { get; } = true;
        [UsedImplicitly][Field(Order=1000408)] public Boolean HideIfUnchecked { get; }
        [UsedImplicitly][Field(Order=1000402)] public CheckedSymbol CheckedSymbol { get; }
        [UsedImplicitly][Field(Order=1000403)] public UncheckedSymbol UncheckedSymbol { get; }
        [UsedImplicitly][Field(Order=1000407,ConverterCulture="en-US")][DefaultValue(1f)] public Single CheckWidthRatio { get; } = 1f;
        [UsedImplicitly][Field(Order=1000405)] public String DataColumn { get; }
        [UsedImplicitly][Field(Order=1000406)] public String Expression { get; }
        }
    }
