using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("DataBand")]
    public class DataBand : BandBase
        {
        [UsedImplicitly][Field] public Boolean CollectChildRows { get; }
        [UsedImplicitly][Field] public Boolean KeepDetail { get; }
        [UsedImplicitly][Field] public Boolean KeepTogether { get; }
        [UsedImplicitly][Field] public Boolean PrintIfDatasourceEmpty { get; }
        [UsedImplicitly][Field] public Boolean PrintIfDetailEmpty { get; }
        [UsedImplicitly][Field] public Boolean ResetPageNumber { get; }
        [UsedImplicitly][Field] public String DataSource { get; }
        [UsedImplicitly][Field] public String Filter { get; }
        [UsedImplicitly][Field] public String IdColumn { get; }
        [UsedImplicitly][Field] public String ParentIdColumn { get; }
        [UsedImplicitly][Field] public String Relation { get; }
        [UsedImplicitly][Field] public Int32 RowCount { get; } = 1;
        [UsedImplicitly][Field] public Int32 MaxRows { get; }
        [UsedImplicitly][Field] public Single Indent { get; } = 37.8f;
        [UsedImplicitly][Field] public BandColumns Columns { get; } = new BandColumns();
        }
    }
