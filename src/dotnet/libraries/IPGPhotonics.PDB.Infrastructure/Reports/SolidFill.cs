using System;
using System.Drawing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class SolidFill : FillBase
        {
        protected internal override String ClassName { get { return "SolidFill"; }}
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color Color { get; }

        public SolidFill(Color color)
            {
            Color = color;
            }

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
            }
        #endregion
        }
    }