using System;
using System.Collections.Generic;
using System.ComponentModel;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class BreakableComponent : ReportComponentBase
        {
        [UsedImplicitly][Field] public Boolean CanBreak { get; }
        }
    }
