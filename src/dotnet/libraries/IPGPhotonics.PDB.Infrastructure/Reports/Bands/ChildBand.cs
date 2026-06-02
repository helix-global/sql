using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("ChildBand")]
    internal sealed class ChildBand : BandBase
        {
        [UsedImplicitly][Field] public Int32 CompleteToNRows { get; }
        [UsedImplicitly][Field] public Boolean FillUnusedSpace { get; }
        [UsedImplicitly][Field] public Boolean PrintIfDatabandEmpty { get; }

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            if (visitor == null) { throw new ArgumentNullException(nameof(visitor)); }
            visitor.Visit(this);
            }
        #endregion
        }
    }
