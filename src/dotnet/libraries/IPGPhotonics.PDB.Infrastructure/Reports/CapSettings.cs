using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;
using System;
using System.Xml;

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
        #region M:Serialize(XmlWriter,String)
        public override void Serialize(XmlWriter writer,String prefix) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            SerializeAttributes(writer,this,prefix);
            }
        #endregion
        }
    }