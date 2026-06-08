using System;
using System.ComponentModel;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class BreakableComponent : ReportComponentBase
        {
        [UsedImplicitly][Field(Order=1000400)][DefaultValue(true)] public Boolean CanBreak { get; } = true;
        }
    }
