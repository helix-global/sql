using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;
using System;
using System.Drawing;
using System.Drawing.Drawing2D;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class HatchFill : FillBase
        {
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color BackColor { get; } = Color.White;
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color ForeColor { get; } = Color.Black;
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<HatchStyle>))] public HatchStyle Style { get; } = HatchStyle.BackwardDiagonal;

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
            }
        #endregion
        }
    }