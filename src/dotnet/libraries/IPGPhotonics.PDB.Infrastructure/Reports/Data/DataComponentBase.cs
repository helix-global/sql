using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class DataComponentBase : Base
        {
        [UsedImplicitly][Field(Order=1000220)][DefaultValue(true)] public virtual Boolean Enabled { get; } = true;
        [UsedImplicitly][Field(Order=1000210)] public String Alias { get; }
        [UsedImplicitly][Field(Order=1000230)] public String ReferenceName { get; }
        }
    }
