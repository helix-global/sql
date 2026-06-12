using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class DataComponentBase : FastReportBase
        {
        [UsedImplicitly][Field(Order=1000202)][DefaultValue(true)] public virtual Boolean Enabled { get; } = true;
        [UsedImplicitly][Field(Order=1000201)] public String Alias { get; }
        [UsedImplicitly][Field(Order=1000203)] public String ReferenceName { get; }
        }
    }
