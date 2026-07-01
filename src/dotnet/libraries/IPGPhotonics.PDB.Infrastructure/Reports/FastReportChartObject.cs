using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics.CodeAnalysis;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("MSChartObject")]
    internal sealed class FastReportChartObject : ReportComponentBase
        {
        [UsedImplicitly][Field(Order=1000403)] public Boolean AlignXValues { get; }
        [UsedImplicitly][Field(Order=1000405)] public String AutoSeriesColor { get; }
        [UsedImplicitly][Field(Order=1000404)] public String AutoSeriesColumn { get; }
        [UsedImplicitly][Field(Order=1000401)] public String DataSource { get; }
        [UsedImplicitly][Field(Order=1000402)] public String Filter { get; }
        [UsedImplicitly][Field(Order=1000406)][DefaultValue(SortOrder.None)] public SortOrder AutoSeriesSortOrder { get; } = SortOrder.None;
        [UsedImplicitly][Field("ChartData",Order=1000407,Converter=typeof(SqlBase64ArrayConverter))] public Byte[] Chart { get; }
        public IList<FastReportChartSeries> Series { get; } = new SqlObjectCollection<FastReportChartSeries>();
        public override IEnumerable<FastReportObject> Children { get {
            foreach (var o in Series) {
                yield return o;
                }
            }}

        #region M:UpdateReferences(IList<FastReportObject>)
        [SuppressMessage("ReSharper", "LocalVariableHidesMember")]
        protected override void UpdateReferences(IList<FastReportObject> source) {
            using (var Series = PrepareChanges(this.Series)) {
                foreach (var o in source) {
                    if (o is FastReportChartSeries MSChartSeries) {
                        Series.Add(MSChartSeries);
                        }
                    }
                }
            }
        #endregion
        #region M:Serialize(IFastReportSerializer,String,Object)
        public override void Serialize(IFastReportSerializer serializer,String prefix,Object other) {
            if (serializer == null) { throw new ArgumentNullException(nameof(serializer)); }
            serializer.Serialize(this,prefix,other);
            }
        #endregion
        }
    }
