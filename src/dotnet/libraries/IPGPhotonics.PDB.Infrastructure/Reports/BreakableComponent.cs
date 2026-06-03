using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class BreakableComponent : ReportComponentBase
        {
        [UsedImplicitly][Field(Order=1000400)] public Boolean CanBreak { get; }
        }
    }
