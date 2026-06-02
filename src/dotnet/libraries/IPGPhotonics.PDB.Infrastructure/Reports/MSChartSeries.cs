using System;
using System.Windows.Media;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;

    [FastReportClass("MSChartSeries")]
    internal sealed class MSChartSeries : Base
        {
        [UsedImplicitly][Field] public Collect Collect { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color CollectedItemColor { get; }
        [UsedImplicitly][Field] public String CollectedItemText { get; }
        [UsedImplicitly][Field] public Single CollectValue { get; }
        [UsedImplicitly][Field] public Single GroupInterval { get; } = 1f;
        [UsedImplicitly][Field] public String Color { get; }
        [UsedImplicitly][Field] public String Filter { get; }
        [UsedImplicitly][Field] public String Label { get; }
        [UsedImplicitly][Field] public String PieExplodeValue { get; }
        [UsedImplicitly][Field] public String XValue { get; }
        [UsedImplicitly][Field] public String YValue1 { get; }
        [UsedImplicitly][Field] public String YValue2 { get; }
        [UsedImplicitly][Field] public String YValue3 { get; }
        [UsedImplicitly][Field] public String YValue4 { get; }
        [UsedImplicitly][Field] public GroupBy GroupBy { get; }
        [UsedImplicitly][Field] public TotalType GroupFunction { get; }
        [UsedImplicitly][Field] public PieExplode PieExplode { get; }
        [UsedImplicitly][Field] public SortBy SortBy { get; }
        [UsedImplicitly][Field] public ChartSortOrder SortOrder { get; }

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
            }
        #endregion
        }
    }
