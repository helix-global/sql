using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("ChildBand")]
    internal sealed class ChildBand : BandBase
        {
        [UsedImplicitly][Field(Order=1000602)] public Int32 CompleteToNRows { get; }
        [UsedImplicitly][Field(Order=1000601)] public Boolean FillUnusedSpace { get; }
        [UsedImplicitly][Field(Order=1000603)] public Boolean PrintIfDatabandEmpty { get; }
        }
    }
