using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("DataBand")]
    public class DataBand : BandBase
        {
        [UsedImplicitly][Field] public String DataSource { get; }
        }
    }
