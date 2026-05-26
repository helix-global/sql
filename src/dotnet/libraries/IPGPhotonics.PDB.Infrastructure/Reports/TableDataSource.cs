using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("TableDataSource")]
    public class TableDataSource : DataSourceBase
        {
        [UsedImplicitly][Field] public String SelectCommand { get; }
        }
    }