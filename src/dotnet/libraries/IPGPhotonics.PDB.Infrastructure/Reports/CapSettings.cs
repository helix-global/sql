using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class CapSettings : FastReportObject
        {
        [UsedImplicitly][Field] public Single Height { get; } = 8f;
        [UsedImplicitly][Field] public Single Width { get; } = 8f;
        [UsedImplicitly][Field] public CapStyle Style { get; }

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
            }
        #endregion
        }
    }