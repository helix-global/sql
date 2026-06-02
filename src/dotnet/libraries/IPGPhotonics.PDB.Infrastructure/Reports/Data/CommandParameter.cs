using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("CommandParameter")]
    internal sealed class CommandParameter : Base
        {
        [UsedImplicitly][Field(Order=1000210)] public Int32 DataType { get; }
        [UsedImplicitly][Field(Order=1000220)][DefaultValue(0)] public Int32 Size { get; }
        [UsedImplicitly][Field(Order=1000240)] public String DefaultValue { get; }
        [UsedImplicitly][Field(Order=1000230)] public String Expression { get; }

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            if (visitor == null) { throw new ArgumentNullException(nameof(visitor)); }
            visitor.Visit(this);
            }
        #endregion
        }
    }
