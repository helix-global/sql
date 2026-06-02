using System;
using System.Drawing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class GlassFill : FillBase
        {
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color StartColor { get; } = Color.White;
        [UsedImplicitly][Field] public Single Blend { get; } = 0.2f;
        [UsedImplicitly][Field] public Boolean Hatch { get; } = true;

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
            }
        #endregion
        }
    }