using System;
using System.ComponentModel;
using System.Windows.Media;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;

    [FastReportClass("MSChartSeries")]
    internal sealed class MSChartSeries : Base
        {
        [UsedImplicitly][Field(Order=1000207)] public Collect Collect { get; }
        [UsedImplicitly][Field(Order=1000210,Converter=typeof(FastReportColorConverter))] public Color CollectedItemColor { get; }
        [UsedImplicitly][Field(Order=1000209)] public String CollectedItemText { get; }
        [UsedImplicitly][Field(Order=1000208,ConverterCulture="en-US")] public Single CollectValue { get; }
        [UsedImplicitly][Field(Order=1000205,ConverterCulture="en-US")][DefaultValue(1f)] public Single GroupInterval { get; } = 1f;
        [UsedImplicitly][Field(Order=1000218)] public String Color { get; }
        [UsedImplicitly][Field(Order=1000201)] public String Filter { get; }
        [UsedImplicitly][Field(Order=1000219)] public String Label { get; }
        [UsedImplicitly][Field(Order=1000212)] public String PieExplodeValue { get; }
        [UsedImplicitly][Field(Order=1000213)] public String XValue { get; }
        [UsedImplicitly][Field(Order=1000214)] public String YValue1 { get; }
        [UsedImplicitly][Field(Order=1000215)] public String YValue2 { get; }
        [UsedImplicitly][Field(Order=1000216)] public String YValue3 { get; }
        [UsedImplicitly][Field(Order=1000217)] public String YValue4 { get; }
        [UsedImplicitly][Field(Order=1000204)] public GroupBy GroupBy { get; }
        [UsedImplicitly][Field(Order=1000206)] public TotalType GroupFunction { get; }
        [UsedImplicitly][Field(Order=1000211)] public PieExplode PieExplode { get; }
        [UsedImplicitly][Field(Order=1000203)] public SortBy SortBy { get; }
        [UsedImplicitly][Field(Order=1000202)] public ChartSortOrder SortOrder { get; }
        }
    }
