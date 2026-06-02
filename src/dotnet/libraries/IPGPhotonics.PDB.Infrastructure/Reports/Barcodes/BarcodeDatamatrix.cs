using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class BarcodeDatamatrix : Barcode2DBase
        {
        [UsedImplicitly][Field] public DatamatrixSymbolSize SymbolSize { get; }
        [UsedImplicitly][Field] public DatamatrixEncoding Encoding { get; }
        [UsedImplicitly][Field] public Int32 CodePage { get; } = 1252;
        [UsedImplicitly][Field] public Int32 PixelSize { get; } = 3;

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            if (visitor == null) { throw new ArgumentNullException(nameof(visitor)); }
            visitor.Visit(this);
            }
        #endregion
        }
    }