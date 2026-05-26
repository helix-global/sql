using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
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
        [UsedImplicitly][Field("ChartData")][TypeConverter(typeof(SqlArrayConverter))] public Byte[] Chart { get; }
        }
    }
