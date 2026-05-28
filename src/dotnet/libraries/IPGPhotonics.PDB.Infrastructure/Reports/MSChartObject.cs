using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using static System.Resources.ResXFileRef;
    using FieldAttribute=SqlObjectFieldMappingAttribute;

    [FastReportClass("MSChartObject")]
    internal sealed class MSChartObject : ReportComponentBase
        {
        [UsedImplicitly][Field] public Boolean AlignXValues { get; }
        [UsedImplicitly][Field] public String AutoSeriesColor { get; }
        [UsedImplicitly][Field] public String AutoSeriesColumn { get; }
        [UsedImplicitly][Field] public String DataSource { get; }
        [UsedImplicitly][Field] public String Filter { get; }
        [UsedImplicitly][Field] public SortOrder AutoSeriesSortOrder { get; } = SortOrder.None;
        [UsedImplicitly][Field("ChartData",Converter=typeof(SqlArrayConverter))] public Byte[] Chart { get; }
        }
    }
