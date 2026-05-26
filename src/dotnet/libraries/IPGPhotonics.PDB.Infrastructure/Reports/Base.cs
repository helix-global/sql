using System;
using System.Collections.Generic;
using System.ComponentModel;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    public abstract class Base : FastReportObject
        {
        [UsedImplicitly][Field] public String Name { get; }
        [UsedImplicitly][Field] public Int32 ZOrder { get; }
        [UsedImplicitly][Field] public Restrictions Restrictions { get; }
        }
    }
