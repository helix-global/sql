using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class DataConnectionBase : DataComponentBase
        {
        [UsedImplicitly][Field] public Int32 CommandTimeout { get; } = 30;
        }
    }