using System;
using System.Collections.Generic;
using System.ComponentModel;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    public abstract class BandBase : BreakableComponent
        {
        [UsedImplicitly][Field] public Boolean FirstRowStartsNewPage { get; } = true;
        [UsedImplicitly][Field] public Boolean KeepChild { get; }
        [UsedImplicitly][Field] public Boolean PrintOnBottom { get; }
        [UsedImplicitly][Field] public Boolean StartNewPage { get; }
        [UsedImplicitly][Field][TypeConverter(typeof(SqlSingleCollectionConverter))] public IList<Single> Guides { get; }
        [UsedImplicitly][Field] public String OutlineExpression { get; }
        [UsedImplicitly][Field] public String AfterLayoutEvent { get; }
        [UsedImplicitly][Field] public String BeforeLayoutEvent { get; }
        }
    }
