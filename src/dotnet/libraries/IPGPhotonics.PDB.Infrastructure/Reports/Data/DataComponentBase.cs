using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class DataComponentBase : Base
        {
        [UsedImplicitly][Field] public Boolean Enabled { get; } = true;
        [UsedImplicitly][Field] public Boolean LoginPrompt { get; }
        [UsedImplicitly][Field] public Int32 CommandTimeout { get; }
        [UsedImplicitly][Field] public String Alias { get; }
        [UsedImplicitly][Field] public String ConnectionString { get; }
        [UsedImplicitly][Field] public String ConnectionStringExpression { get; }
        }
    }
