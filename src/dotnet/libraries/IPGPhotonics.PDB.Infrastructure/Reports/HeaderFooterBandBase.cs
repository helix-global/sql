using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    public abstract class HeaderFooterBandBase : BandBase
        {
        [UsedImplicitly][Field] public Boolean KeepWithData { get; }
        [UsedImplicitly][Field] public Boolean RepeatOnEveryPage { get; }
        }
    }
