using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;

    [FastReportClass("Style")]
    internal sealed class Style : StyleBase
        {
        [UsedImplicitly][Field(Order=1000001)] public String Name { get; }
        }
    }