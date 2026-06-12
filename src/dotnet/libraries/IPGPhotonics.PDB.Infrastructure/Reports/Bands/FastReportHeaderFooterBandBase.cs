using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class FastReportHeaderFooterBandBase : FastReportBandBase
        {
        [UsedImplicitly][Field(Order=1000601)] public Boolean KeepWithData { get; }
        [UsedImplicitly][Field(Order=1000602)] public Boolean RepeatOnEveryPage { get; }
        }
    }
