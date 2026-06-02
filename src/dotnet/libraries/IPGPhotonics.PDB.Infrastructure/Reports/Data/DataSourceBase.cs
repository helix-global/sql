using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class DataSourceBase : Column
        {
        [UsedImplicitly][Field(Order=1000410)][DefaultValue(false)] public override Boolean Enabled { get; } = true;
        [UsedImplicitly][Field(Order=1000420)][DefaultValue(false)] public Boolean ForceLoadData { get; }
        }
    }