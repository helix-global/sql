using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("TableDataSource")]
    internal sealed class TableDataSource : DataSourceBase
        {
        [UsedImplicitly][Field] public String SelectCommand { get; }
        [UsedImplicitly][Field] public String TableName { get; }
        [UsedImplicitly][Field] public Boolean StoreData { get; }
        }
    }