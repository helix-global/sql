using System;
using System.ComponentModel;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class Base : FastReportObject
        {
        [UsedImplicitly][Field(Order=1000110)] public virtual String Name { get; }
        [UsedImplicitly][Field(Order=1000120)][DefaultValue(0)] public Int32 ZOrder { get; }
        [UsedImplicitly][Field(Order=1000130)][DefaultValue(Restrictions.None)] public Restrictions Restrictions { get; }
        }
    }
