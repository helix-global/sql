using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("GroupBoxControl")]
    internal sealed class FastReportGroupBoxControl : FastReportParentControl
        {
        [UsedImplicitly][Field(Order=1000408)][DefaultValue(false)] public override Boolean TabStop { get; }
        }
    }