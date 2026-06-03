using System;
using System.ComponentModel;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("DataBand")]
    internal sealed class DataBand : BandBase
        {
        [UsedImplicitly][Field(Order=1000615)] public Boolean CollectChildRows { get; }
        [UsedImplicitly][Field(Order=1000611)] public Boolean KeepDetail { get; }
        [UsedImplicitly][Field(Order=1000610)] public Boolean KeepTogether { get; }
        [UsedImplicitly][Field(Order=1000609)] public Boolean PrintIfDatasourceEmpty { get; }
        [UsedImplicitly][Field(Order=1000608)] public Boolean PrintIfDetailEmpty { get; }
        [UsedImplicitly][Field(Order=1000616)] public Boolean ResetPageNumber { get; }
        [UsedImplicitly][Field(Order=1000601)] public String DataSource { get; }
        [UsedImplicitly][Field(Order=1000606)] public String Filter { get; }
        [UsedImplicitly][Field(Order=1000612)] public String IdColumn { get; }
        [UsedImplicitly][Field(Order=1000613)] public String ParentIdColumn { get; }
        [UsedImplicitly][Field(Order=1000604)] public String Relation { get; }
        [UsedImplicitly][Field(Order=1000602)][DefaultValue(1)] public Int32 RowCount { get; } = 1;
        [UsedImplicitly][Field(Order=1000603)] public Int32 MaxRows { get; }
        [UsedImplicitly][Field(Order=1000614)][DefaultValue(37.8f)] public Single Indent { get; } = 37.8f;
        [UsedImplicitly][Field(Order=1000607)] public BandColumns Columns { get; } = new BandColumns();

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            if (visitor == null) { throw new ArgumentNullException(nameof(visitor)); }
            visitor.Visit(this);
            }
        #endregion
        }
    }
