using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class DataSourceBase : Column
        {
        [UsedImplicitly][Field] public Boolean ForceLoadData { get; }
        }
    }